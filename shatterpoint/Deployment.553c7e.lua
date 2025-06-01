function onLoad(save_state)
  self.createButton({
    click_function = "toggleDeploy",
    function_owner = self,
    label          = "Deploy:\n" ..  tostring(Global.getVar("deploying")),
    position       = {0,0.05,0},
    rotation       = {0,0,0},
    scale          = {1,1,1},
    width          = 1800,
    height         = 1800,
    font_size      = 500,
    color          = {0,0,0, 1},
    font_color     = {1,1,1},
    tooltip        = "Toggle Deploy",
  })
end

function toggleDeploy()
  Global.setVar("deploying", not Global.getVar("deploying"))
  self.editButton({index = 0, label = "Deploy:\n" ..  tostring(Global.getVar("deploying"))})
end