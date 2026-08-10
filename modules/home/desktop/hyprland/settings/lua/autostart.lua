local vars = require("vars")

-- Reference: <https://wiki.hypr.land/Configuring/Basics/Autostart/>

hl.on("hyprland.start", function()
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd(vars.editor)
  hl.exec_cmd(vars.terminal .. " --hold btop", { workspace = "special:system silent" })
  hl.exec_cmd(vars.terminal, { workspace = "name:primary silent" })
  hl.exec_cmd(vars.webBrowser, { workspace = "name:primary silent" })
  hl.exec_cmd(vars.ai, { workspace = "name:auxiliary silent" })
  hl.exec_cmd(vars.mediaPlayer, { workspace = "name:auxiliary silent" })
end)
