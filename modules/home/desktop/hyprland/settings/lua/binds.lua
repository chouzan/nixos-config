local vars = require("vars")

-- Reference: <https://wiki.hypr.land/Configuring/Basics/Binds/>

-- Focus, navigate, launch
local mainMod = "SUPER"

-- Swap/move window
local shiftMod = mainMod .. " + SHIFT"

-- Resize window
local ctrlMod = mainMod .. " + CTRL"

-- Alter window/layout
local altMod = mainMod .. " + ALT"

-- Special mod
local hyperMod = mainMod .. " + SHIFT + CTRL + ALT"

-- Session ---------------------------------------------------------------------

hl.bind(hyperMod .. " + Q", hl.dsp.exit())
hl.bind(mainMod .. " + L",  hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + W",  hl.dsp.window.close())
hl.bind(mainMod .. " + Q",  hl.dsp.window.kill())

-- Launchers -------------------------------------------------------------------

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(vars.menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(vars.editor))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(vars.ai))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(vars.webBrowser))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(vars.mediaPlayer))

-- Screen capture --------------------------------------------------------------

hl.bind("Print",        hl.dsp.exec_cmd("hypr-capture screenshot region"))
hl.bind("ALT + Print",  hl.dsp.exec_cmd("hypr-capture screenshot output"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hypr-capture screenshot window"))

hl.bind("SHIFT + Print",              hl.dsp.exec_cmd("hypr-capture record region"))
hl.bind("SHIFT + ALT + Print",        hl.dsp.exec_cmd("hypr-capture record output"))
hl.bind("SHIFT + CTRL + Print",       hl.dsp.exec_cmd("hypr-capture record window"))
hl.bind("SHIFT + CTRL + ALT + Print", hl.dsp.exec_cmd("hypr-capture record stop"))

-- Window state ----------------------------------------------------------------

hl.bind(ctrlMod .. " + RETURN", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(altMod .. " + RETURN",  hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

-- Focus -----------------------------------------------------------------------

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

-- Toggle focus between tiled/floating
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(vars.toggleFocus))

-- Move window -----------------------------------------------------------------

hl.bind(shiftMod .. " + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(shiftMod .. " + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(shiftMod .. " + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(shiftMod .. " + right", hl.dsp.window.move({ direction = "right" }))

-- Move window to workspace ----------------------------------------------------

hl.bind(shiftMod .. " + 1", hl.dsp.window.move({ workspace = "name:primary" }))
hl.bind(shiftMod .. " + 2", hl.dsp.window.move({ workspace = "name:auxiliary" }))
hl.bind(shiftMod .. " + 3", hl.dsp.window.move({ workspace = "name:other" }))

-- Switch workspace ------------------------------------------------------------

hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = "name:primary" }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = "name:auxiliary" }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = "name:other" }))

-- Special workspace -----------------------------------------------------------

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("system"))

hl.bind(shiftMod .. " + S", hl.dsp.window.move({ workspace = "special:system" }))

-- Master layout ---------------------------------------------------------------

hl.bind(mainMod .. " + RETURN", hl.dsp.layout("focusmaster master"))

hl.bind(shiftMod .. " + RETURN", hl.dsp.layout("swapwithmaster master"))

hl.bind(altMod .. " + H",   hl.dsp.layout("orientationleft"))
hl.bind(altMod .. " + J",   hl.dsp.layout("orientationcenter"))
hl.bind(altMod .. " + Tab", hl.dsp.layout("orientationcycle left center"))

hl.bind(altMod .. " + 1", hl.dsp.layout("mfact exact 0.382")) -- Inverse golden ratio
hl.bind(altMod .. " + 2", hl.dsp.layout("mfact exact 0.414")) -- Silver ratio
hl.bind(altMod .. " + 3", hl.dsp.layout("mfact exact 0.45"))  -- More usable sides
hl.bind(altMod .. " + 4", hl.dsp.layout("mfact exact 0.55"))  -- Simple 55/45
hl.bind(altMod .. " + 5", hl.dsp.layout("mfact exact 0.618")) -- Golden ratio

-- Move/resize window (floating) ------------------------------------------------------
-- Repeating: repeat when held.

hl.bind(altMod .. " + left",  hl.dsp.window.move({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(altMod .. " + right", hl.dsp.window.move({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(altMod .. " + up",    hl.dsp.window.move({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(altMod .. " + down",  hl.dsp.window.move({ x = 0, y = 50, relative = true }), { repeating = true })

hl.bind(ctrlMod .. " + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(ctrlMod .. " + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(ctrlMod .. " + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(ctrlMod .. " + down",  hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

-- Media keys ------------------------------------------------------------------
-- Locked: active while the screen is locked.

hl.bind("XF86AudioPlay",    hl.dsp.exec_cmd("playerctl --player=" .. vars.mediaPlayer .. ",%any play-pause"), { locked = true })
hl.bind("XF86AudioPause",   hl.dsp.exec_cmd("playerctl --player=" .. vars.mediaPlayer .. ",%any play-pause"), { locked = true })
hl.bind("XF86AudioStop",    hl.dsp.exec_cmd("playerctl --all-players stop"), { locked = true })
hl.bind("XF86AudioNext",    hl.dsp.exec_cmd("playerctl --player=" .. vars.mediaPlayer .. ",%any next"), { locked = true })
hl.bind("XF86AudioPrev",    hl.dsp.exec_cmd("playerctl --player=" .. vars.mediaPlayer .. ",%any previous"), { locked = true })
hl.bind("XF86AudioForward", hl.dsp.exec_cmd("playerctl --player=" .. vars.mediaPlayer .. ",%any position 5+"), { locked = true })
hl.bind("XF86AudioRewind",  hl.dsp.exec_cmd("playerctl --player=" .. vars.mediaPlayer .. ",%any position 5-"), { locked = true })
hl.bind("XF86AudioMute",    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

-- Volume / brightness ---------------------------------------------------------
-- Locked + repeating.

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume --limit=1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --min-value=3 set 5%-"), { locked = true, repeating = true })

-- Mouse move/resize -----------------------------------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Clipboard manager -----------------------------------------------------------

if vars.clipManEnabled then
  hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(
    vars.terminal .. " --class " .. vars.clipMan .. " --execute " .. vars.clipMan))
end
