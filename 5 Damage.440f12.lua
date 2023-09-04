function onLoad()
  self.createButton({
    click_function = 'clicked',
    function_owner = self,
    position       = {0.3,0,0.2},
    rotation       = {0,0,0},
    width          = 1400,
    height         = 1400,
    color          = {0,0,0,0},
    tooltip        = "5 Damage",
  })
end

function clicked()
  self.setState(2)
end