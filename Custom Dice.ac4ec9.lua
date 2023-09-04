    function onLoad()
      sides = 8

      self.setRotationValues({
          {value = "Hit", rotation = {x = 33.74, y = 180.17, z = 0}},
          {value = "Hit", rotation = {x = 326.26, y = 5.66, z = 180}},
          {value = "Hit", rotation = {x = 33.74, y = 180.17, z = 180}},
          {value = "Attack Expertise", rotation = {x = 326.26, y = 5.66, z = 90}},
          {value = "Attack Expertise", rotation = {x = 33.74, y = 180.17, z = 90}},
          {value = "Critical", rotation = {x = 326.26, y = 0.17, z = 0}},
          {value = "Failure", rotation = {x = 33.74, y = 180.17, z = 270}},
          {value = "Failure", rotation = {x = 326.26, y = 0.17, z = 270}}
      })


    end

    --Allows for quick changing dice with added code to broadcast the change (This is to stop cheaters from changing dice without notice)
    function onNumberTyped(player_color, number)
        newResult = ""
        if number == 1 or number == 2 or number == 3 then
            newResult = "Hit"
        elseif number == 4 or number == 5 then
            newResult = "Attack Expertise"
        elseif number == 6 then
            newResult = "Critical"
        elseif number == 7 or number == 8 then
            newResult = "Failure"
        end
        
        if newResult != "" then
            broadcastToAll("R2D2: " .. Player[player_color].steam_name .. " manually changed a " .. self.getRotationValue() .. " to a " .. newResult, {0,0.9,1})

            Wait.time(
                function() 
                    local tray = getObjectFromGUID("752fc4")
                    tray.call('countDices')
                end,
                1
            )
        end
    end

    --Broadcasts a message when dice are picked up (This is to stop cheaters from changing dice without notice)
    function onPickUp(player_color)
        broadcastToAll("R2D2: " .. Player[player_color].steam_name .. " picked up a " .. self.getRotationValue() .. " die", {0,0.9,1})
    end

    --Broadcasts a message if a player chooses another state for the dice through a submenu (This is to stop cheaters from changing dice without notice)
    function onPlayerAction(player, action, targets)
        if action == 5 and targets[1] == self then
            oldResult = self.getRotationValue()
            Wait.frames(function() broadcastToAll("R2D2: " .. player.steam_name .. " flipped a " .. oldResult .. " making it a " .. self.getRotationValue(), {0,0.9,1}) end, 30)
        end
    end