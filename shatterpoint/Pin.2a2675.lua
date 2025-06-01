function onLoad()
  self.createButton({
    click_function = 'clicked',
    function_owner = self,
    position       = {0,-0.1,0},
    rotation       = {180,45,0},
    width          = 1200,
    height         = 1200,
    color          = {0,0,0,0},
    tooltip        = "Pin",
  })
end

function clicked()
  self.setState(2)
end