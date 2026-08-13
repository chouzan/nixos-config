# Screenshot and screen recording for Hyprland.
#
# Needs these programs on PATH: grim, hyprctl, notify-send, satty, slurp,
# systemctl, systemd-run, wl-screenrec, and xdg-open.
#
# Reads these variables from the environment:
#
#   HYPR_CAPTURE_SCREENSHOT_DIR  Optional. Directory for a screenshot.
#   HYPR_CAPTURE_RECORDING_DIR   Optional. Directory for a recording.
#   WAYLAND_DISPLAY              Required to record.
#   XDG_RUNTIME_DIR              Required to record. Holds the state file.
#
# The script runs from a key binding, so it has no terminal. Every failure has
# to reach a desktop notification, which is why the helpers capture the output
# of a command rather than letting it stream.

const recording_unit = "hypr-capture-recording.service"

def screenshot-dir []: nothing -> string {
  $env.HYPR_CAPTURE_SCREENSHOT_DIR? | default ($nu.home-dir | path join "Pictures" "Screenshot")
}

def recording-dir []: nothing -> string {
  $env.HYPR_CAPTURE_RECORDING_DIR? | default ($nu.home-dir | path join "Videos" "Recording")
}

def required-env [name: string]: nothing -> string {
  let value = $env | get --optional $name | default ""

  if ($value | is-empty) {
    error make $"($name) is not set"
  }

  $value
}

def run-command [command: string, ...arguments: string]: nothing -> string {
  let result = run-external $command ...$arguments | complete

  if $result.exit_code != 0 {
    let message = $result.stderr | str trim

    error make (if ($message | is-empty) {
      $"Command failed with exit code ($result.exit_code): ($command)"
    } else {
      $message
    })
  }

  $result.stdout
}

def notify [summary: string, body?: string, --critical]: nothing -> nothing {
  let arguments = [--app-name "Screen capture"]
  | append (if $critical { ["--urgency=critical"] } else { [] })
  | append $summary
  | append (if $body == null { [] } else { [$body] })

  ^notify-send ...$arguments | complete | ignore
}

# notify-send prints the chosen action on standard output, and --action implies
# --wait, so the call blocks until the notification closes. The explicit expiry
# bounds that wait: the notification server honours a timeout from the sender,
# but gives a critical notification no expiry at all, which is why only a
# success is reported this way.
def notify-file [summary: string, file: path]: nothing -> nothing {
  let arguments = [
    --app-name
    "Screen capture"
    --expire-time
    "8000"
    --action
    "open=Open"
    --action
    "folder=Show folder"
    $summary
    $file
  ]

  let result = ^notify-send ...$arguments | complete

  # Anything other than an action name means the notification closed on its own.
  match ($result.stdout | str trim) {
    "open" => {
      ^xdg-open $file | complete | ignore
    }
    "folder" => {
      ^xdg-open ($file | path dirname) | complete | ignore
    }
    _ => { }
  }
}

# slurp reports a cancelled selection and a genuine failure with the same exit
# status, so the message on standard error is the only way to tell them apart.
# A cancelled selection returns null; anything else is an error worth reporting.
def select-region []: nothing -> oneof<string, nothing> {
  let result = ^slurp -d -c "#fb4934ff" | complete

  if $result.exit_code == 0 {
    return ($result.stdout | str trim)
  }

  let message = $result.stderr | str trim

  if ($message | str contains "selection cancelled") {
    null
  } else {
    error make (if ($message | is-empty) { "slurp failed" } else { $message })
  }
}

def focused-output []: nothing -> string {
  let outputs = run-command hyprctl monitors "-j" | from json --strict
  let focused = $outputs | where {|output| $output.focused }

  if ($focused | length) != 1 {
    error make "Expected exactly one focused output"
  }

  $focused.0.name
}

def active-window-geometry []: nothing -> string {
  let window = run-command hyprctl activewindow "-j" | from json --strict

  if ($window.address? | default "" | is-empty) {
    error make "No active window"
  }

  $"($window.at.0),($window.at.1) ($window.size.0)x($window.size.1)"
}

def capture-source [target: string]: nothing -> oneof<record, nothing> {
  match $target {
    "region" => {
      let geometry = select-region

      if $geometry == null {
        null
      } else {
        {
          screenshot: ["-g" $geometry]
          recording: ["--geometry" $geometry]
        }
      }
    }
    "output" => {
      let output = focused-output

      {
        screenshot: ["-o" $output]
        recording: ["--output" $output]
      }
    }
    "window" => {
      let geometry = active-window-geometry

      {
        screenshot: ["-g" $geometry]
        recording: ["--geometry" $geometry]
      }
    }
    _ => { error make $"Unknown capture target: ($target)" }
  }
}

def timestamp []: nothing -> string {
  date now | format date "%Y%m%d_%H%M%S"
}

def screenshot [target: string]: nothing -> nothing {
  let source = capture-source $target

  if $source == null {
    return
  }

  let directory = screenshot-dir
  mkdir $directory

  let destination = $directory | path join $"(timestamp)_screenshot.png"
  let temporary = mktemp --suffix .png

  try {
    run-command grim ...$source.screenshot $temporary | ignore
    # satty notifies on save under its own name and with its own wording. This
    # script reports the whole workflow, so it silences the satty notification
    # and reports the save itself.
    (run-command
      satty
      "--disable-notifications"
      "--filename"
      $temporary
      "--output-filename"
      $destination
    ) | ignore
  } catch {|error|
    rm --force $temporary
    error make $error
  }

  rm --force $temporary

  # satty writes the file only when the user saves, so the file itself is the
  # only evidence that the screenshot was kept.
  if ($destination | path exists) {
    notify-file "Screenshot saved" $destination
  }
}

def recording-state []: nothing -> string {
  required-env "XDG_RUNTIME_DIR" | path join "hypr-capture-recording"
}

def recording-active []: nothing -> bool {
  let result = ^systemctl --user is-active --quiet $recording_unit
  | complete

  $result.exit_code == 0
}

def stop-recording []: nothing -> nothing {
  let state = recording-state

  let destination = if ($state | path exists) {
    open --raw $state | str trim
  } else {
    ""
  }

  if not (recording-active) {
    rm --force $state

    # systemd-run runs the recorder with --collect, which reaps the unit as soon
    # as the recorder exits. A destination that was recorded but never written
    # therefore means the recorder failed, not that nothing was running.
    if ($destination | is-not-empty) and not ($destination | path exists) {
      notify "Recording failed" $"Nothing was written to ($destination)" --critical
    } else {
      notify "No recording is active"
    }

    return
  }

  run-command systemctl "--user" stop $recording_unit | ignore

  rm --force $state

  # systemctl stop sends SIGTERM, which wl-screenrec treats as a clean stop and
  # uses to finalise the container. The file is still the only evidence that it
  # wrote anything.
  if ($destination | is-empty) {
    notify "Recording stopped"
  } else if ($destination | path exists) {
    notify-file "Recording saved" $destination
  } else {
    notify "Recording produced no file" $destination --critical
  }
}

def start-recording [target: string]: nothing -> nothing {
  if (recording-active) {
    notify "A recording is already active"
    return
  }

  let wayland_display = required-env "WAYLAND_DISPLAY"
  let runtime_dir = required-env "XDG_RUNTIME_DIR"

  let source = capture-source $target

  if $source == null {
    return
  }

  let directory = recording-dir
  mkdir $directory

  let destination = $directory | path join $"(timestamp)_recording.mp4"
  let state = recording-state
  $destination | save --force $state

  let arguments = [
    "--user"
    "--quiet"
    "--collect" $"--unit=($recording_unit)"
    "--service-type=exec"
    "--property=TimeoutStopSec=10s"
    $"--setenv=WAYLAND_DISPLAY=($wayland_display)"
    $"--setenv=XDG_RUNTIME_DIR=($runtime_dir)"
    "--" "wl-screenrec"
    "--codec" "avc"
    "--max-fps" "60"
    "--filename" $destination
  ] | append $source.recording

  let result = ^systemd-run ...$arguments | complete

  if $result.exit_code != 0 {
    rm --force $state
    error make ($result.stderr | str trim)
  }

  notify "Recording started" $destination
}

def main [] {
  print --stderr "Use the screenshot or record subcommand."
  exit 2
}

def report-if-error [summary: string, action: closure]: nothing -> nothing {
  try {
    do $action
  } catch {|error|
    notify $summary $error.msg --critical
    error make $error
  }
}

# Capture a screenshot of a region, the focused output, or the active window.
def "main screenshot" [
  target: string # One of region, output, or window.
] {
  report-if-error "Screenshot failed" { screenshot $target }
}

# Start recording a region, the focused output, or the active window.
def "main record" [
  target: string # One of region, output, or window.
] {
  report-if-error "Recording failed" { start-recording $target }
}

# Stop the recording that is running.
def "main record stop" [] {
  report-if-error "Stopping the recording failed" { stop-recording }
}
