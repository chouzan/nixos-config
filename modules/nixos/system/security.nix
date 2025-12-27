{ pkgs, machine, ... }:

let
  inherit (machine) user;
in
{
  environment.systemPackages = with pkgs; [
    age
    sops
  ];

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = true;

      extraConfig = ''
        Defaults passwd_tries=3
        Defaults passwd_timeout=1
        Defaults timestamp_timeout=0
        Defaults insults

        Defaults use_pty

        Defaults logfile=/var/log/sudo.log
        Defaults log_input, log_output
        Defaults syslog=authpriv

        Defaults !visiblepw
        Defaults !pwfeedback

        # User

        Defaults:${user.username} timestamp_timeout=15

        # GUI support
        Defaults:${user.username} !requiretty
        Defaults:${user.username} env_keep += "DISPLAY XAUTHORITY WAYLAND_DISPLAY XDG_RUNTIME_DIR"

        Defaults:${user.username} env_keep += "PATH"
      '';
    };
  };
}
