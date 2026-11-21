local vars = require("vars")

-- The system scratchpad spawns a terminal whenever it is created empty.
hl.on("workspace.created", function(ws)
  if ws.addressable_name == vars.systemWorkspace and ws.is_empty then
    hl.exec_cmd(vars.terminal, { workspace = vars.systemWorkspace })
  end
end)
