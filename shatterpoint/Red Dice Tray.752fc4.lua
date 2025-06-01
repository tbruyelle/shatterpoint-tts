--used to be used more than once but still good for clarity
cGreen = {0, 0.8, 0}
cYellow = {0.8, 0.8, 0}
cRed = {0.8, 0, 0}
cGrey = {0.8 , 0.8, 0.8}

diceCode8 = [[
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
    end]]

diceCode6 = [[
    function onLoad()
      sides = 6
        self.setRotationValues({
            {value = "Defense Expertise", rotation = {x = 0, y = 0, z = -90}},
            {value = "Defense Expertise", rotation = {x = 0, y = 0, z = 90}},
            {value = "Block", rotation = {x = 0, y = 0, z = 0}},
            {value = "Block", rotation = {x = 0, y = 0, z = -180}},
            {value = "Failure", rotation = {x = -90, y = 0, z = 0}},
            {value = "Failure", rotation = {x = 90, y = 0, z = 0}}
          })

    end
    --Allows for quick changing dice with added code to broadcast the change (This is to stop cheaters from changing dice without notice)
    function onNumberTyped(player_color, number)
        newResult = ""
        if number == 1 or number == 2 then
            newResult = "Defense Expertise"
        elseif number == 3 or number == 4 then
            newResult = "Block"
        elseif number == 5 or number == 6 then
            newResult = "Failure"
        end

        if newResult != "" then
            broadcastToAll("R2D2: " .. Player[player_color].steam_name .. " manually changed a " .. self.getRotationValue() .. " to a " .. newResult, {0,0.9,1})
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
    end]]

function onLoad()
    setinteractable = true
    self.interactable = setinteractable    --Setting this to false ruins the ability to fast load using num shortcuts
    self.drag_selectable = false

    --declare Variables
    spawnedDice = {}            --Will hold all the dice objects
    numofDice = 0               --currently there are zero dice
    maxDice = 42                --total dice that can be rolled
    rolling = false             --boolean to keep track of if dice are rolling
    angleOffset = 0             --Used in determining positions of dice in both rotation states
    buttonMoving = false        --Keeps track of physical buttons movement
    resultsZ = 5.2              --Z location needed for the buttons to match the dice symbol perfectly
    diceStatus = "Initial Roll Results\n"   --String for header of dice printing results
    checkingDice = false

    --Determines which side of the table the tray is on
    checkY = self.getRotation().y
    if checkY > 90 and checkY < 270 then
        self.setRotation({0, 180, 0})
        angleOffset = 1
        myplayer = "Red" --used for Streamer UI and numpad scripting

        --deletes all dice on table
        local objects = getAllObjects()
        for i, o in pairs(objects) do
            if o.getDescription() == "diceComp" then
                o.destruct()
            elseif self.getName() == o.getName() and o != self then
                o.destruct()
            end
        end
    else
        self.setRotation({0, 0, 0})
        angleOffset = -1
        myplayer = "Blue" --used for Streamer UI and numpad scripting
    end

    center = self.getPosition()     --used in determining locations for physical buttons and dice rolls
    selfRot = self.getRotation()

    rollDelay = 1.5 --how often checks on the dice moving are made.

    self.setLock(true)

    resetCounters()     --onload this initializes counter, but is used later to reset to 0
    counterButtons()    --creates all buttons for the counters on the top of the tray and the hint on top
    reloadButton()
    Wait.time(function() init() end, 0.5)
end

--removes all buttons so moving on the table is easier
function onPickUp(player_color)
    removeObject(clearButton)
    removeObject(minusButton)
    removeObject(addButton)
    removeObject(totalButton)
    removeObject(rollButton)
end

function removeObject(obj)
    if obj != nil then
        obj.destruct()
    end
end

--onload this initializes counter, but is used later to reset to 0
function resetCounters()
    numBlock = 0
    numCrit = 0
    numAex = 0
    numDex = 0
    numHit = 0
    numFailure = 0
end

--creates all buttons for the counters on the top of the tray and the hint on top
function counterButtons()
    newButton("Hit", numHit, -5.61)
    newButton("Crit", numCrit, -3.16)
    newButton("AttackExpertise", numAex, -0.725)
    newButton("Failure", numFailure, 1.725)
    newButton("Block", numBlock, 4.175)
    newButton("DefenseExpertise", numDex, 6.61)
end

function reloadButton()
    self.createButton({
        click_function = "reloadMe",
        function_owner = self,
        label          = "Refresh",
        position       = {8.5*angleOffset, 0.5, -9},
        rotation       = {0,180+(90*angleOffset),90*angleOffset},
        scale          = {1,1,1},
        width          = 600,
        height         = 300,
        font_size      = 150,
        color          = {0.05, 0.05, 0.05},
        font_color     = {1, 1, 1},
    })
end

function reloadMe()
    self.reload()
end

--creates a button with defaults params and (string for function, number of specific dice for label, and x position for correct position)
function newButton(string, num, x)
    self.createButton({
        click_function = "reroll" .. string,
        function_owner = self,
        label          = num,
        position       = {x, 2.085, -11.1},
        rotation       = {0,0,0},
        scale          = {1,1,1},
        width          = 500,
        height         = 600,
        font_size      = 500,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Click to reroll a " .. string
    })
end

function init()
    resetComponents()
    Wait.frames(function() findComponents() end, 1)
    Wait.frames(function() spawnButtons() end, 3)       --do not change this order
end

function resetComponents()
    if angleOffset > 0 then
        obj = getObjectFromGUID("8b87fb")
        obj.reload()
        obj = getObjectFromGUID("7297c0")
        obj.reload()
        obj = getObjectFromGUID("a2ad93")
        obj.reload()
        obj = getObjectFromGUID("1fde62")
        obj.reload()
        obj = getObjectFromGUID("86e460")
        obj.reload()
        obj = getObjectFromGUID("c2fe0a")
        obj.reload()
    else
        obj = getObjectFromGUID("7c2665")
        obj.reload()
        obj = getObjectFromGUID("7db04e")
        obj.reload()
        obj = getObjectFromGUID("c170f0")
        obj.reload()
        obj = getObjectFromGUID("e8d782")
        obj.reload()
        obj = getObjectFromGUID("a50548")
        obj.reload()
        obj = getObjectFromGUID("93d3fe")
        obj.reload()
    end

end

function findComponents()
    if angleOffset > 0 then
        clearButton = addSingleComponent("8b87fb")
        addAttackButton = addSingleComponent("7297c0")
        minusButton = addSingleComponent("a2ad93")
        addDefenseButton = addSingleComponent("1fde62")
        totalButton = addSingleComponent("86e460")
        rollButton = addSingleComponent("c2fe0a")
    else
        clearButton = addSingleComponent("7c2665")
        addAttackButton = addSingleComponent("7db04e")
        minusButton = addSingleComponent("c170f0")
        addDefenseButton = addSingleComponent("e8d782")
        totalButton = addSingleComponent("a50548")
        rollButton = addSingleComponent("93d3fe")
    end

end


function addSingleComponent(guid)
    obj = getObjectFromGUID(guid)
    obj.interactable = setinteractable
    obj.drag_selectable = setinteractable
    return obj
end

--INIT function 1 destroys all left over components
function destroyAll(zone)
    local objects = zone.getObjects()
    for i, obj in pairs(objects) do
        if obj.getDescription() == "diceComp" then
            obj.destruct()
        end
    end
    zone.destruct()
end

--INIT function 2 creates all physical buttons on the dice tray
function spawnComponents()
    posX = center.x
    posY = center.y
    posZ = center.z


    compZ = posZ - (6.66*self.getScale().z)*angleOffset
    compY = (posY + (1.44*self.getScale().y)) - 1
    compXO = (5.55*self.getScale().x)*angleOffset
    compXI = (2.77*self.getScale().x)*angleOffset

    local bMesh = "http://cloud-3.steamusercontent.com/ugc/1057729584627386301/178C9ABD3881E3900669236FB28AE9290E672A7F/"

    --**************************************************************************************************************************************
        params = {
            type              = "Custom_Model",
            position          = {posX-compXO, compY, compZ},
            rotation          = {x=15*angleOffset, y=180, z=0},
            scale             = self.getScale(),
            sound             = false,
            snap_to_grid      = false,
            callback_function = function(obj) componentCallback(obj, false, cYellow, "clear") end

        }
        clearButton = spawnObject(params)

        params = {
            type = 0,
            mesh = bMesh,
            material = 1,
        }
        clearButton.setCustomObject(params)

        --**************************************************************************************************************************************

        params = {
            type              = "Custom_Model",
            position          = {posX-compXI, compY, compZ},
            rotation          = {x=15*angleOffset, y=180, z=0},
            scale             = {self.getScale().x*0.5, self.getScale().y, self.getScale().z},
            sound             = false,
            snap_to_grid      = false,
            callback_function = function(obj) componentCallback(obj, false, cRed, "minus") end

        }
        minusButton = spawnObject(params)

        params = {
            type = 0,
            mesh = bMesh,
            material = 1,
        }
        minusButton.setCustomObject(params)

        --**************************************************************************************************************************************

        params = {
            type              = "Custom_Model",
            position          = {posX+compXI, compY, compZ},
            rotation          = {x=15*angleOffset, y=180, z=0},
            scale             = {self.getScale().x*0.5, self.getScale().y, self.getScale().z},
            sound             = false,
            snap_to_grid      = false,
            callback_function = function(obj) componentCallback(obj, false, cRed, "add") end

        }
        addButton = spawnObject(params)

        params = {
            type = 0,
            mesh = bMesh,
            material = 1,
        }
        addButton.setCustomObject(params)

    --**************************************************************************************************************************************

        params = {
            type              = "Custom_Model",
            position          = {posX, compY, compZ},
            rotation          = {x=15*angleOffset, y=180, z=0},
            scale             = self.getScale(),
            sound             = false,
            snap_to_grid      = false,
            callback_function = function(obj) componentCallback(obj, false, cGrey,"total") end

        }
        totalButton = spawnObject(params)

        params = {
            type = 0,
            mesh = bMesh,
            material = 1,
        }
        totalButton.setCustomObject(params)

        --**************************************************************************************************************************************

        params = {
            type              = "Custom_Model",
            position          = {posX+compXO, compY, compZ},
            rotation          = {x=15*angleOffset, y=180, z=0},
            scale             = self.getScale(),
            sound             = false,
            snap_to_grid      = false,
            callback_function = function(obj) componentCallback(obj, false, cGreen, "roll") end

        }
        rollButton = spawnObject(params)

        params = {
            type = 0,
            mesh = bMesh,
            material = 1,
        }
        rollButton.setCustomObject(params)

        clearButton.setPositionSmooth({clearButton.getPosition().x, (posY + (1.44*self.getScale().y)), clearButton.getPosition().z})
        minusButton.setPositionSmooth({minusButton.getPosition().x, (posY + (1.44*self.getScale().y)), minusButton.getPosition().z})
        addButton.setPositionSmooth({addButton.getPosition().x, (posY + (1.44*self.getScale().y)), addButton.getPosition().z})
        totalButton.setPositionSmooth({totalButton.getPosition().x, (posY + (1.44*self.getScale().y)), totalButton.getPosition().z})
        rollButton.setPositionSmooth({rollButton.getPosition().x, (posY + (1.44*self.getScale().y)), rollButton.getPosition().z})
end

--function callback for objects created above
function componentCallback(obj, snap, color, name)
    obj.use_gravity = false
    obj.setLock(true)
    obj.setColorTint(color)
    obj.setDescription("diceComp") --flags it for deletion later
    obj.tooltip = false
    obj.setName(name)
    obj.interactable = setinteractable
    obj.drag_selectable = setinteractable
end

--INIT function 3 spawns the UI buttons on top of the physical buttons created above
function spawnButtons()

    if angleOffset == 1 then
        newY = 0
    else
        newY = 0
    end

    totalButton.createButton({
        index          = 0,
        function_owner = self,
        click_function = "rollSame",
        label          = numofDice,
        position       = {0, 0.5, 0.1},
        rotation       = {0,newY,0},
        scale          = {1,1,1},
        width          = 1000,
        height         = 1000,
        font_size      = 600,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Total Dice on Tray\nClick this button to 'Clear' and setup a new dice roll of this same value"
    })

    addAttackButton.createButton({
        index          = 1,
        click_function = "addAttackDice",
        function_owner = self,
        label          = "",
        position       = {0, 0.5, 0},
        rotation       = {0,newY,0},
        scale          = {1,1,1},
        width          = 1000,
        height         = 1000,
        font_size      = 3000,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Add Attack Dice"
    })

    addDefenseButton.createButton({
        index          = 2,
        click_function = "addDefenseDice",
        function_owner = self,
        label          = "",
        position       = {0, 0.5, 0},
        rotation       = {0,newY,0},
        scale          = {1,1,1},
        width          = 1000,
        height         = 1000,
        font_size      = 3000,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Add Defense Dice"
    })

    minusButton.createButton({
        index          = 3,
        click_function = "removeDice",
        function_owner = self,
        label          = "",
        position       = {0, 0.5, 0},
        rotation       = {0,newY,0},
        scale          = {1,1,1},
        width          = 1000,
        height         = 1000,
        font_size      = 500,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Remove Dice"
    })


    rollButton.createButton({
        index          = 5,
        click_function = "rollDice",
        function_owner = self,
        label          = "",
        position       = {0, 0.5, 0},
        rotation       = {0,newY,0},
        scale          = {1,1,1},
        width          = 1000,
        height         = 1000,
        font_size      = 300,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Roll Dice in Tray"
    })

    clearButton.createButton({
        index          = 6,
        click_function = "clearDice",
        function_owner = self,
        label          = "",
        position       = {0, 0.5, 0},
        rotation       = {0,newY,0},
        scale          = {1,1,1},
        width          = 1000,
        height         = 1000,
        font_size      = 300,
        color          = {0, 0, 0, 0.01},
        font_color     = {0, 0, 0, 100},
        tooltip        = "Remove all Dice"
    })
end

--called every time a physical bottom is pressed to simulate the button press
function clickButton(obj)
  if obj != nil then
    if buttonMoving == false then
        buttonMoving = true
        local objPos = obj.getPosition()

        local unpressed = center.y+(1.44*self.getScale().y)
        local pressed = unpressed - 0.1

        obj.setPositionSmooth({objPos.x,unpressed - 0.1 ,objPos.z})
        Wait.time(function() obj.setPositionSmooth({objPos.x,unpressed,objPos.z}) end, 0.5)
        Wait.time(function() buttonMoving = false end, 0.5)
    end
  end
end

--Button #1 will roll same amount of dice as is total in the tray right now
function rollSame(obj, player_color)
    setupRoll(numofDice, obj, player_color)
end

--works with rollSame button and can be called to from other objects
function setupRoll(num, obj, player_color)
    local newType = 1
    if spawnedDice[0].diceObj.getVar("sides") == 8 then
      newType = 2
    end
    clearDice(obj, player_color)
    rolling = false
    for i = 0, num-1, 1 do
        addDice(newType)
    end
end

function addAttackDice()
    addDice(2)
end

function addDefenseDice()
    addDice(1)
end

--Button #2 will add dice to the center of the dice tray
function addDice(givenType)
        rolling = false
        rollButton.editButton({index = 0, label = ""})

        clickButton(addButton) --simulate button clicked
        if numofDice < maxDice then
            rollCenter = center

            spawnedDice[numofDice] = {}
            spawnedDice[numofDice].diceObj  =   spawnObject({
                type              = "Custom_Dice",
                position          = {rollCenter.x+math.random(-3,3), 6, rollCenter.z+math.random(-3,3)+(1*angleOffset)},
                rotation          = {math.random(0,360),math.random(0,360),math.random(0,360)},
                scale             = self.getScale(),
                sound             = false,
            })

            if givenType == 1 then
                givenImage = "http://cloud-3.steamusercontent.com/ugc/2064379389794936900/3D3280A0C1F472058D9D5A3DF21BE10E29B6C963/"
            else
                givenImage = "http://cloud-3.steamusercontent.com/ugc/2064379389794968830/358C36D2973634923A7A38D3280743E638131BBB/"
            end

            spawnedDice[numofDice].diceObj.setCustomObject({
                image = givenImage,
                type = givenType
            })



            spawnedDice[numofDice].diceObj.sticky = false
            spawnedDice[numofDice].diceObj.use_grid = false
            spawnedDice[numofDice].diceObj.use_snap_points = false
            spawnedDice[numofDice].diceObj.bounciness = 0.8
            spawnedDice[numofDice].diceObj.setDescription("diceComp") --flags it for deletion later
            spawnedDice[numofDice].diceIndex = numofDice
            if givenType == 2 then
              spawnedDice[numofDice].diceObj.setLuaScript(diceCode8)
            else
              spawnedDice[numofDice].diceObj.setLuaScript(diceCode6)
            end
            spawnedDice[numofDice].diceObj.interactable = false
            diceStatus = "Rolling Crits:\n"
            numofDice = numofDice + 1
            updateButtons() -- needs to calculate new total of dice
        end
end

function removeAttackDice(obj, player_color)
  removeDice(obj, player_color)
end

function removeDefenseDice(obj, player_color)
  removeDice(obj, player_color)
end


--Button #3 will remove dice from the dice tray
function removeDice(obj, player_color)
    rolling = false
    rollButton.editButton({index = 0, label = ""})
    if numofDice > 1 then
        if spawnedDice[numofDice-1].diceObj != nil then
            spawnedDice[numofDice-1].diceObj.destruct()
        end
        numofDice = numofDice - 1
        clickButton(minusButton) --simulates button press
        updateButtons()
        if numofDice == 0 then
        end
    else
        clearDice(obj, player_color)
    end

end

--Button #4 will roll all dice in the large part of the dice tray
function rollDice(obj, player_color)
    clickPlayerColor = player_color
    dicePos = 0
    dicetoRoll = 0
        for roll = 0, numofDice-1 do
            dicePos = spawnedDice[roll].diceObj.getPosition().z - rollCenter.z
            if angleOffset > 0 then
                if dicePos < resultsZ then
                    spawnedDice[roll].diceObj.roll()
                    spawnedDice[roll].diceObj.interactable = false
                    dicetoRoll = dicetoRoll + 1
                    rolling = true
                end
            else
                if dicePos > -resultsZ then
                    spawnedDice[roll].diceObj.roll()
                    dicetoRoll = dicetoRoll + 1
                    rolling = true
                end
            end
        end
        if dicetoRoll > 0 then
            clickButton(rollButton)
            if checkingDice == false then
                checkDice(rollDelay)
            end

            if numBlock + numFailure + numCrit + numHit + numAex + numDex == 0 then
                diceStatus = "Initial Results:\n"
            elseif numBlock + numFailure + numCrit + numHit + numAex + numDex  == numofDice then
                diceStatus = "Reroll Results:\n"
            end
        end
end

--recurssive function that will continue to check to make sure dice are finished rolling
function checkDice(num)
    checkingDice = true
    if rolling == true and numofDice > 0 then
        finished = true
        for roll = 0, numofDice-1 do
            if spawnedDice[roll].diceObj.resting == false then
                finished = false
            end
        end
        if finished == true then
            checkingDice = false
            placeDice()
        else
            Wait.time(function() checkDice(num) end, num)
        end
    else
        checkingDice = false
    end
end

--Called after checkDice() sees the dice are done moving
--It will place each die in the correct position to display on the smaller tray
function placeDice()
    local first = rollCenter
    local xStart = first.x -((7.5*self.getScale().x)*angleOffset)
    local zStart = first.z +((9.55*self.getScale().z)*angleOffset)
    local yStart = first.y+(1.61*self.getScale().y)
    local xOff = (1.11*self.getScale().x)*angleOffset
    local zOff = (-1.22*self.getScale().z)*angleOffset
    local new = {xStart, yStart, zStart}
    local newX = xStart
    local newZ = zStart
    --z+10.5 is first row
    --z+9 is second row
    --z+7.5 is third row

    resetCounters()

    for place = 0, numofDice-1 do
            --determines new x, y, and z position
            if place < maxDice/3 then
                newX = xStart + (place*xOff)
            elseif place < (maxDice/3)*2  then
                newX = xStart + ((place - (maxDice/3) )*xOff)
                newZ = zStart + (zOff)
            else
                newX = xStart + ((place-((maxDice/3)*2 ))*xOff)
                newZ = zStart + (zOff*2)
            end

            --determines the new Rotational value of the dice
            rotVal = spawnedDice[place].diceObj.getRotationValue()
            if rotVal == "Failure" then
                numFailure = numFailure + 1

                if spawnedDice[place].diceObj.getVar("sides") == 8 then
                  spawnedDice[place].diceObj.setRotation({x = 33.74, y = 180.17, z = 270})
                elseif spawnedDice[place].diceObj.getVar("sides") == 6 then
                  spawnedDice[place].diceObj.setRotation({x = 270, y = 180, z = 0})
                end
                spawnedDice[place].result = rotVal
            elseif rotVal == "Block" then
                numBlock = numBlock + 1
                spawnedDice[place].diceObj.setRotation({x = 0, y = 0, z = 0})
                spawnedDice[place].result = rotVal
            elseif rotVal == "Hit" then
                numHit = numHit + 1
                spawnedDice[place].diceObj.setRotation({x = 33.74, y = 180.17, z = 180})
                spawnedDice[place].result = rotVal
            elseif rotVal == "Attack Expertise" then
                numAex = numAex + 1
                spawnedDice[place].diceObj.setRotation({x = 326.26, y = 5.66, z = 90})
                spawnedDice[place].result = rotVal
            elseif rotVal == "Critical" then
                numCrit = numCrit + 1
                spawnedDice[place].diceObj.setRotation({x = 326.26, y = 5.66, z = 0})
                spawnedDice[place].result = rotVal
            elseif rotVal == "Defense Expertise" then
                numDex = numDex + 1
                spawnedDice[place].diceObj.setRotation({x = 0, y = 0, z = 270})
                spawnedDice[place].result = rotVal

            end
            spawnedDice[place].diceObj.setPositionSmooth({newX, yStart, newZ})
            spawnedDice[place].diceObj.interactable = true
    end
    if needResults == true then
        params = {numHit, numCrit, numAex, numFailure, numBlock, numDex}
        sendResultsTo.call("printMessage", params)
        needResults = nil
        sendResultsTo = nil
    end
    --printResults()
    rollButton.editButton({index = 0, label = ""})
    rolling = false
    updateButtons()
end



--prints the results after the above function counts each dice rolled
function printResults()
    local results = ""
    results = results .. diceStatus
    results = results .. "Hits - " .. numHit .. "  "
    results = results .. "Crits - " .. numCrit .. "  "
    results = results .. "Wilds - " .. numWild .. "  "
    results = results .. "Blocks - " .. numBlock .. "  "
    results = results .. "Blanks - " .. numBlank .. "  "
    results = results .. "Fails - " .. numFailure
    printToAll(results, clickPlayerColor)
end

--Button #5 will clear all dice from the tray and reset variables
function clearDice(obj, player_color)
    rolling = false
    if player_color != nil then
        clickPlayerColor = player_color
        printToAll("\nDice Roller Cleared", clickPlayerColor)
    end
    clickButton(clearButton)
    for clear = 0, numofDice-1 do
        if spawnedDice[clear].diceObj != nil then
            spawnedDice[clear].diceObj.destruct()
        end
    end
    numofDice = 0
    resetCounters()
    updateButtons()
end

--blank function to avoid errors
function noFunc()

end

--updates total button and all counters on top
function updateButtons()
    totalButton.editButton({index = 0, label = numofDice})
    self.editButton({index = 0, label = numHit})
    self.editButton({index = 1, label = numCrit})
    self.editButton({index = 2, label = numAex})
    self.editButton({index = 3, label = numFailure})
    self.editButton({index = 4, label = numBlock})
    self.editButton({index = 5, label  = numDex})

    Global.UI.setAttribute(myplayer.."Hit", "text", numHit)
    Global.UI.setAttribute(myplayer.."Crit", "text", numCrit)
    Global.UI.setAttribute(myplayer.."Wild", "text", numWild)
    Global.UI.setAttribute(myplayer.."Block", "text", numBlock)
    Global.UI.setAttribute(myplayer.."Blank", "text", numBlank)
    Global.UI.setAttribute(myplayer.."Fail", "text", numFailure)
end


--***************************************************************************************************
--the next 6 functions are identical for each type of dice result/button
function rerollHit()
    numHit = numHit + rerollOne(numHit, "Hit")
    updateButtons()
end
function rerollCrit()
    numCrit = numCrit + rerollOne(numCrit, "Critical")
    updateButtons()
end
function rerollAttackExpertise()
    numAex = numAex + rerollOne(numAex, "Attack Expertise")
    updateButtons()
end
function rerollBlock()
    numBlock = numBlock + rerollOne(numBlock, "Block")
    updateButtons()
end
function rerollDefenseExpertise()
    numDex = numDex + rerollOne(numDex, "Defense Expertise")
    updateButtons()
end
function rerollFailure()
    numFailure = numFailure + rerollOne(numFailure, "Failure")
    updateButtons()
end

function rerollOne(number, string)
    diceStatus = "Reroll Results:\n"
    local trayZ = self.getPosition().z
    findReroll = false
    for reroll = 0, numofDice-1 do
        local pos = spawnedDice[reroll].diceObj.getPosition()
        if angleOffset > 0 and pos.z - trayZ > resultsZ or angleOffset < 0 and pos.z - trayZ < -resultsZ then
            if spawnedDice[reroll].result == string and findReroll == false and number > 0 then
                spawnedDice[reroll].diceObj.setPosition({pos.x, pos.y-0.5, pos.z-4*angleOffset})
                findReroll = true
                return(-1)
            end
        end
    end
    return(0)
end

--Used when a different object needs to roll dice and get the results
function askforResults(params)
    needResults = true
    sendResultsTo = params.obj
    setupRoll(params.num)
end


--the next two functions work in tandem. One checks for the hovered object by the mouse and the other uses that info to load the dice tray.
function onObjectHover(player_color, hovered_object)
    found = false
    if myplayer == player_color  and hovered_object != nil then
        if hovered_object == self or hovered_object == totalButton then
            hoverobj = self
            found = true
        end
        if found == false then
            hoverobj = nil
        end
    end
end

function onScriptingButtonDown(index, color)
    if myplayer == color then
        if hoverobj != nil then
            if hoverobj == self and index < 10 then
                setupRoll(index, self, color)
            end
        end
    end
end

function checkResults()
    local numTotal = numHit + numCrit + numWild + numBlock + numBlank + numFailure
    return {hit = numHit, crit = numCrit, wild = numWild, block = numBlock, blank = numBlank, failure = numFailure, total = numTotal}
end

function onObjectLeaveScriptingZone(zone, leave_object)
    if zone.getGUID() == "d9ebbf" and myplayer == "Red" and leave_object.getDescription() == "diceComp" then

        direction = leave_object.getVelocity()
        leave_object.setVelocity({-direction.x*1.1,-2, -direction.z*1.1})

        if math.abs(direction.x) + math.abs(direction.z) > 12 and rolling == true then
            local pos = self.getPosition()
            leave_object.setPosition({pos.x, pos.y + 3, pos.z})
            leave_object.roll()
        end
    end
end