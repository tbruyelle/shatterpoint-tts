parentGUID = "ea6ef8"
pieceB = "312304"

    function onLoad(save_state)
        playMat = Global.getVar("playMat")              --load scripting zone in order to find characters on the table
        database = Global.getTable("characterDatabase") --load character database from Global so the tool knows that to c
        parent = getObjectFromGUID(parentGUID)          --makes sure the tool knows which tray it responds to. parent GUID if given on creation

        init = false        --boolean used to decipher first time setup2
        attached = false    --boolean for if the movement tool is in 2 pieces
        snapped = false     --boolean for if normal snap is active
        snappedTA = false   --boolean for if the toward and away snap is active
        moved = false       --boolean for if character has been moved yet
        placed = false      --boolean for if if place function is active
        towardAway = false  --boolean to determine if button should be on the tool
        toward = false       --boolean to determine which direction the tool should snap
        rogueTool = false   --boolean used to determine if tool is at great risk to knock around models
        base = 0            --initial character base size this will be changed once its needed
        direction = 0       --initial direction
        length = 0          --initialized length
        whoAmI()            --assigned length
        coneTA  = false
        iAmTrash = false    --keeps track of if the tool is auto cleanup


        createButtons() --creates all buttons needed

        --loads saved data from previous saves
        if save_state ~= "" then
            local loaded_data = JSON.decode(save_state)
            origin = loaded_data[1]
            savedRotA = loaded_data[2]
            savedRotB = loaded_data[3]
            if getObjectFromGUID(pieceB) == nil then
                attached = true
            else
                attached = false
                templateB = getObjectFromGUID(pieceB)
            end
        else
            --sets up cleanup phase
            origin = {}
            origin.pos = self.getPosition()
            origin.rot = self.getRotation()
            Wait.frames(function() initTemplateB() end, 5) --allows for loading to complete then attaches to its second part
        end

        updateButtons()
        updateSave()
    end

    --will update this information on save. This will allow for players to save halfway through a game and come back to finish.
    function updateSave()
        local data_to_save = {origin, savedRotA, savedRotB}
        saved_data = JSON.encode(data_to_save)
        self.script_state = saved_data
    end


    --finds template B for this part
    function initTemplateB()
        templateB = getObjectFromGUID(pieceB)
        templateB.setPosition(self.getPosition())
        templateB.setRotation(self.getRotation())

        savedRot = templateB.getRotation()
        Wait.frames(function() toggleAttach() end, 15)
    end

    --function creates all buttons upfront
    function createButtons()
        self.createButton({
            click_function = "toggleAttach",
            function_owner = self,
            label          = "Bend",
            position       = {0.5,0.17,0},
            rotation       = {0,-90,0},
            scale          = {1,1,1},
            width          = 275,
            height         = 100,
            font_size      = 75,
            color          = {0,0,0},
            font_color     = {1,1,1},
        })
        self.createButton({
            index          = 1,
            click_function = "snapButton",
            function_owner = self,
            label          = "Snap",
            position       = {(length)-0.75, 0.17, 0},
            rotation       = {0, -90, 0},
            width          = 275,
            height         = 100,
            font_size      = 75,
            color          = {0, 0, 0, 1},
            font_color     = {1, 1, 1},
            tooltip = "Snap to nearest character"
        })

        movePos = {x = -((length)-0.75), y = 0.17, z = 0}

        self.createButton({
            index          = 2,
            click_function = "placeObject",
            function_owner = self,
            label          = "Place",
            position       = movePos,
            rotation       = {0, -90, 0},
            width          = 275,
            height         = 100,
            font_size      = 75,
            color          = {0, 0, 0, 1},
            font_color     = {1, 1, 1},
            tooltip        = "Move Character Max Range"
        })
        self.createButton({
            index          = 3,
            click_function = "snapTAButton",
            function_owner = self,
            label          = "Toward/Away",
            position       = {0, 0.17, 1.5},
            rotation       = {0, -90, 0},
            width          = 500,
            height         = 100,
            font_size      = 75,
            color          = {0, 0, 0, 1},
            font_color     = {1, 1, 1},
            tooltip        = "Snap to character inside tool for measuring away or toward"
        })

        self.createButton({
            click_function = "setupThrow",
            function_owner = self,
            label          = "Throw\nPush",
            position       = {0.5,0.17,0},
            rotation       = {0,-90,0},
            scale          = {1,1,1},
            width          = 275,
            height         = 200,
            font_size      = 75,
            color          = {0,0,0},
            font_color     = {1,1,1},
        })

    end

    function updateButtons()
        --this function uses all the snapped, attached, snappedTA, and moved booleans to determine:
            --which buttons should be visible
            --which labels should be on those buttons

        if savedRotB != nil then

            local rotA = savedRotA.y
            local rotB = savedRotB.y

            if (rotA - rotB) > 180 then
                rotB = rotB + 360
            elseif (rotA - rotB) < -180 then
                rotA = rotA + 360
            end

            angle = rotA - rotB

            local a = (0.4)-self.getPosition().x
            local b = (0.4)-self.getPosition().z
            local rotY = math.rad(angle-180)
            local moveX = math.cos(rotY)*(0.4)
            local moveZ = math.sin(rotY)*(0.4)

            moveRot = (-angle+90) - 180
            movePos = {x = moveX, y = 0.17, z = -moveZ}
        else
            moveRot = -90
            movePos = {x = -((length)-0.4), y = 0.17, z = 0}
        end


        if attached == true and snappedTA == false then
            self.editButton({index=0, label="Bend", tooltip = "Allow Tool to Bend", width = 275, height = 100,  rotation = {0,moveRot,0}, position = movePos, color = {0, 0, 0, 1},})
        elseif snappedTA == true then
            self.editButton({index=0, label="Bend", tooltip = "", width = 0, height = 0, rotation = {0,moveRot,0}, position = movePos, color = {0, 0, 0, 0}})
        else
            self.editButton({index=0, label="Lock", tooltip = "Lock Tool Angle in Place", width = 275, height = 100, rotation = {0,-90,0}, position = {0,0.17,0}, color = {0, 0, 0, 1},})

        end

        if snapped == true and attached == true or snappedTA == true then
            self.editButton({index=1, label="Unsnap", tooltip = "Click to Unsnap", width = 275, height = 100, color = {0, 0, 0, 1},})
        elseif init == false or attached == false then
            self.editButton({index=1, label="Snap", tooltip = "", width = 0, height = 0, color = {0, 0, 0, 0},})
        elseif snapped == false and attached == true then
            self.editButton({index=1, label="Snap", tooltip = "Snap to nearest Base", width = 275, height = 100, color = {0, 0, 0, 1},})
        end

        if savedRotB != nil then

            local rotA = savedRotA.y
            local rotB = savedRotB.y

            if (rotA - rotB) > 180 then
                rotB = rotB + 360
            elseif (rotA - rotB) < -180 then
                rotA = rotA + 360
            end

            angle = rotA - rotB

            local a = ((length)-0.4)-self.getPosition().x
            local b = ((length)-0.4)-self.getPosition().z
            local rotY = math.rad(angle-180)
            local moveX = math.cos(rotY)*(length-0.4)
            local moveZ = math.sin(rotY)*(length-0.4)

            moveRot = (-angle+90) - 180
            movePos = {x = moveX, y = 0.17, z = -moveZ}
        else
            moveRot = -90
            movePos = {x = -((length)-0.4), y = 0.17, z = 0}
        end

        if attached == false then
            self.editButton({index=2, label="Place", tooltip = "", width = 0, height = 0, rotation = {0,moveRot,0} , position = movePos, color = {0, 0, 0, 0}})
        elseif placed == false and snapped == true and moved == false then
            self.editButton({index=2, label="Place", tooltip = "Activate Placement Function\nRight Click move model full distance", width = 275, height = 100, rotation = {0,moveRot,0}, position = movePos, color = {0, 0, 0, 1}})
        elseif placed == true and snapped == true then
            self.editButton({index=2, label="Done", tooltip = "Turn Off Placement Function", width = 275, height = 100, rotation = {0,moveRot,0}, position = movePos, color = {0, 0, 0, 1}})
        else
            if moved == false then
                self.editButton({index=2, label="Place", tooltip = "", width = 0, height = 0, rotation = {0,moveRot,0},  color = {0, 0, 0, 0}})
            else
                self.editButton({index=2, label="Undo", tooltip = "Undo full movement and bring character back to beginning.", width = 275, height = 100, rotation = {0,moveRot,0}, position = movePos, color = {0, 0, 0, 1}})
            end
        end

        if towardAway == true then
            if snappedTA == false then
                self.editButton({index=3, label="Toward/Away", tooltip = "Snap tool to measure toward and away", position = {0, 0.18, 1.5*direction}, width = 500, height = 100, color = {0, 0, 0, 1},})
            elseif toward == true then
                self.editButton({index=3, label="Toggle: Toward", tooltip = "Snap tool to measure toward and away", position = {0, 0.18, 1.5*direction}, width = 600, height = 100, color = {0, 0, 0, 1},})
                if direction == 1 then self.editButton({index=3, label="Toggle: Away",}) end
            elseif toward == false then
                self.editButton({index=3, label="Toggle: Away", tooltip = "Snap tool to measure toward and away", position = {0, 0.18, 1.5*direction}, width = 600, height = 100, color = {0, 0, 0, 1},})
                if direction == 1 then self.editButton({index=3, label="Toggle: Toward",}) end
            end
        else
            self.editButton({index=3, label="Toward/Away", tooltip = "", width = 0, height = 0, color = {0, 0, 0, 0},})
        end

        if savedRotB != nil then
            if savedRotB != savedRotA and attached == true and throwPlaced == false then
                self.editButton({index=4, label="\u{2191}", tooltip = "Straighten the move tool.", click_function = "straightenTool", width = 150, font_size = 150,})
            elseif attached == true and throwPlaced == false then
                self.editButton({index=4, label="Throw\nPush", tooltip = "Sets up a lock so models can only be placed on the center of the tool.", click_function = "setupThrow", width = 275, font_size = 75,})
            else
                self.editButton({index=4, label="", tooltip = "Sets up a lock so models can only be placed on the center of the tool.", click_function = "setupThrow", width = 0,})
            end
        end

    end


    --function checks to see if its in 1 or two pieces changes accordingly
    function toggleAttach(obj, color, alt_click)
        if placed == true then
            placeObject()
        end
        templateB = getObjectFromGUID(pieceB) --this needs to be set everytime. When an object is attached/detached the reference is broken
        if attached == false then
            templateB.setPosition(self.getPosition())
            savedRotB = templateB.getRotation()
            savedRotA = self.getRotation()
            self.addAttachment(templateB)
            attached = true
            checkAngle()
        else
            self.removeAttachments()
            attached = false
            towardAway = false
        end
        updateButtons()
        updateSave()
        throwPlaced = false
    end

    function unattach()
        if attached == true then
            toggleAttach()
        end
    end

    function checkAngle()
        if snapped == false then
            local rotA = savedRotA.y
            local rotB = savedRotB.y

            if (rotA - rotB) > 180 then
                rotB = rotB + 360
            elseif (rotA - rotB) < -180 then
                rotA = rotA + 360
            end

            --turns on toward/away button
            angle = rotA - rotB
            if angle > 89 or angle < -89 then
                if angle < 0 then
                    direction = -1
                else
                    direction = 1
                end
                towardAway = true
            end
        end
    end


    function onPickUp(player_color)
        iAmTrash = false
        rogueTool = false --tool will only be rogue from the time it moves on its own to when the player picks it up
        init = true
        clickPlayerColor = player_color
        self.use_gravity = true

        if closeObj != nil and attached == true then
            --makes sure object isnt nudged by
            holding = closeObj.getVar("holding")
            if holding != nil then
                local curPos = closeObj.getPosition()
                if holding == false then
                    if math.abs(curPos.x-objPos.x) > 0.75 or math.abs(curPos.y-objPos.y) > 0.75 or math.abs(curPos.z-objPos.z) > 0.75 then
                        pickedUp = false
                        if snapped == true then
                            snapBase()
                        elseif snappedOne == true then
                            snapOne()
                        end
                    end
                end
            end
        end

        if moved == true and snapped == true then
            snapped = false
            moved = false
        end
        if attached == false then
            local pos = self.getPosition()
            toggleAttach()
            self.drop()
            self.setPosition(pos)
        else
            startLuaCoroutine(self, "turnToCursor")
        end
        updateButtons()
    end

    function onDropped(player_color)
        self.editButton({index = 1, color = {0,0,0}})
        if towardAway == true then self.editButton({index = 3, color = {0,0,0}}) end
        if snapped == true or snappedTA == true then
            positionTemplate()

        elseif parent.getVar("cleanUp") == true then
            local checkBounds = self.getPosition()
            local x = checkBounds.x
            local z = checkBounds.z
            local cleanup = 36/2
            if x > cleanup or x < -cleanup or z > cleanup or z < -cleanup then
                toggleAttach()
                Wait.frames(function() cleanUp() end, 3)
            end
        end
        pickedUp = false
        self.use_gravity = true
        -- stop velocity
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
    end

    function turnToCursor()
        pickedUp = true
        -- math

        if snapped == true or snappedTA == true then
            while (pickedUp == true) do
                positionTemplate()
                coroutine.yield(0)
            end
        else
            if parent.getVar("highlight") == true then
                while (pickedUp == true) do
                    HighlightTarget()
                    coroutine.yield(0)
                end
            end
        end
        return 1
    end

    function highlightTarget()
        distance = length
        green = {0,1,0}
        findClosest(distance)
        if closeObj != nil then
            highlightSnap = closeObj
            if towardAway == true then
                local distance = 0
                local yellow = {1,1,0}
                local blue = {0,0,1}
                findClosest(distance)
                if closeObj != highlightSnap and closeObj != nil then
                    closeObj.highlightOn(yellow, 0.2)
                    self.editButton({index = 3, color = yellow})
                    highlightSnap.highlightOn(blue, 0.2)
                    self.editButton({index = 1, color = blue})
                else
                    highlightSnap.highlightOn(green, 0.2)
                    self.editButton({index = 1, color = green})
                    self.editButton({index = 3, color = {0,0,0}})
                end
            else
                highlightSnap.highlightOn(green, 0.2)
                self.editButton({index = 1, color = green})
                if towardAway == true then self.editButton({index = 3, color = {0,0,0}}) end
            end
        end
        return 1
    end


    --maintains the rulers snap to the selected base and allows for rotation
    function positionTemplate()

        --finds the mouse coordinates of the player who last picked up the range tool
        local mouseX = Player[clickPlayerColor].getPointerPosition().x
        local mouseZ = Player[clickPlayerColor].getPointerPosition().z

        -- finds the x/z difference between the mouse and the center of the base
        local a = objPos.x-mouseX
        local b = objPos.z-mouseZ

        --finds the angle of the line drawn from mouse to base center
        local q = math.deg(math.atan2(a, b))


        objTA = getObjectFromGUID(closeObj.getVar("towardAwayTool"))
        if objTA != nil then
            if string.find(objTA.getName(), "Movement") then
                --nothing to see here
            else
                objTA = nil
            end
        end

        if objTA != nil and objTA != self then
            objTAPos = objTA.getPosition()

            -- finds the x/z difference between the mouse and the center of the base
            local tempA = objPos.x-objTAPos.x
            local tempB = objPos.z-objTAPos.z

            --finds the angle of the line drawn from mouse to base center
            TAangle = math.deg(math.atan2(tempA, tempB))
            TAangle = TAangle + 180

            if TAangle > 90 then
                if q < 0 then
                    q = (180 + q) + 180
                end
            end
            if TAangle > 270 then
                if q < 90 then
                    q = q + 360
                end
            end

            if q > TAangle+45 then
                q = TAangle+45
            elseif q < TAangle-45 then
                q = TAangle-45
            end

            a = -math.cos(math.rad(q+90))
            b = math.sin(math.rad(q+90))
        end

        templatePos = self.getPosition()

        --applies the offset math to make sure ruler doesnt snap in center of base
        local a2 = offset*math.cos(math.atan2(b, a))
        local b2 = offset*math.sin(math.atan2(b, a))
        templatePos = {x = objPos.x-a2, y = templatePos.y , z = objPos.z-b2}

        -- set rotation with offset
        self.setRotation({x = 0, y = q+rotOff, z = 0})
        templateRot = self.getRotation()


        if snapped == true or snappedTA == true then
            self.setPosition(templatePos)
        else
            self.setPositionSmooth(templatePos) --adds a nice touch so you can watch the range ruler lock into place while it snaps
        end

        -- stop velocity
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
    end

    function snapButton(obj)
        snapBase(nil)
    end

    function snapBase(givenObj)
        throwPlaced = false
        --checks to see if the range is currently snapped so it can toggle the button
        if givenObj != nil then
            iAmTrash = false
            snapped = false
        end

        changed = false

        if snapped == true and attached == true then
            if placed == true then
                placeObject()
            end
            moved = false
            snapped = false
            snappedTA = false
            checkAngle()
            changed = true
        elseif attached == false then
            toggleAttach()

        elseif snappedTA == true then
            if closeObj != nil then
                closeObj.call("towardAway", nil)
                changed = true
            elseif givenObj != nil then
                givenObj.call("towardAway", nil)
            end
            snappedTA = false
            snapped = false

        end
        if init == true and snapped == false and changed == false then
            towardAway = false
            if givenObj == nil then
                findClosest(length)
            else
                findInfo(givenObj)
            end

            rotOff = 90
            offset = length+(base/2) --set offset so ruler snaps on edge of ruler to edge of base
            if objPos != nil then
                rogueTool = true
                self.setPosition({self.getPosition().x, objPos.y+0.5, self.getPosition().z})
                positionTemplate() --perform snap
                snapped = true
            else
                moved = false
                snapped = false
            end


        end
        updateButtons()
    end

    function snapTAButton()
        snapTA()
    end

    function snapTA(givenObj)
        throwPlaced = false
        if givenObj != nil then
            snappedTA = false
            snapped = false
            iAmTrash = false
        end

        if snappedTA == false then
            snappedTA = true
            if givenObj == nil then
                findClosest(0)
                closeObj.call("towardAway", self.getGUID())
            else
                findInfo(givenObj)
                givenObj.call("towardAway", self.getGUID())
                self.setPosition({self.getPosition().x, objPos.y+0.5, self.getPosition().z})
            end
            rogueTool = true
            towardAway = true
        end

        if snappedTA == true then
            if toward == true then
                offset = base*-direction --set offset so ruler snaps on edge of ruler to edge of base
                rotOff = 135*-direction
                positionTemplate() --perform snap
                toward = false
            elseif toward == false then
                offset = -base*-direction --set offset so ruler snaps on edge of ruler to edge of base
                rotOff = -45*-direction
                positionTemplate() --perform snap
                toward = true
            end
            rogueTool = true
        end

        updateButtons()
    end

    function findClosest(num)
        --finds all the objects within the playmat (scripting zone)
        local objects = playMat.getObjects()

        --prime the proximity float
        proximity = 1000

        closeObj = nil

        --iterate through each object in playMat (i)
        for i, unit in pairs(objects) do
            if unit.type != "Surface" then
                local obj = getObjectFromGUID(unit.guid)

                if obj != nil then
                    name = obj.getName()
                    --iterates through the global database to check character names with object namess
                    for k, v in pairs(database) do
                        if (name == v.cName) and v.cName != nil and v.cName != "Objective" then
                                local distance = findProximity(self, unit, v.cBase, num) --matches a character in database so checks proximity to ruler

                                --compares this object with the closest object so far and replaces the object for
                                --closest if it is closer than the previous one
                                if proximity > distance then
                                    proximity = distance
                                    indexNum = k
                                    closeObj = obj
                                    base = v.cBase
                                end
                        end
                    end
                end
            end
        end
        if closeObj != nil then
            objPos = closeObj.getPosition() --set object that will be selected to snap
            self.setPosition({self.getPosition().x, objPos.y+0.5, self.getPosition().z})
            --pickedUp = false
            self.setVelocity({0,0,0})
            self.setAngularVelocity({0,0,0})
        end
    end


    function findInfo(newObj)
        --iterates through the global database to check character names with object names
        for k, v in pairs(database) do
            name = newObj.getName()
            if name == v.cName then
                if v.objective == true and parent.getVar("snapObjective") == true or v.objective == nil then
                    indexNum = k
                    closeObj = newObj
                    objPos = closeObj.getPosition()
                    if v.objective == true then
                        base = closeObj.getVar("objectiveSize")
                    else
                        base = v.cBase
                    end
                end

            end
        end
    end


    function findProximity(self, object, base, num)
        local objectPos = object.getPosition()
        local selfPos = self.getPosition()
        local selfRot = self.getRotation()


        local rotY = math.rad(selfRot.y)
        local offsetX = math.cos(rotY)*((num+base)/2)
        local offsetZ = math.sin(rotY)*((num+base)/2)

        a = self.getPosition().x-offsetX
        b = self.getPosition().z+offsetZ


        local xDis = math.abs(objectPos.x - a)
        local zDis = math.abs(objectPos.z - b)
        local distance = xDis^2 + zDis^2
        return math.sqrt(distance)
    end

    function moveBase()
        throwPlaced = false

        if snapped == true then
            if moved == false then

                if attached == true then
                    rangeRot = (self.getRotation() - savedRotA) + savedRotB
                else
                    templateB = getObjectFromGUID(pieceB)
                    rangeRot = templateB.getRotation()
                end
                rangePos = self.getPosition()
                previousPos = objPos

                -- finds the x/z difference between the move tool and the object
                local a = objPos.x-rangePos.x
                local b = objPos.z-rangePos.z
                local rotY = math.rad(rangeRot.y-180)
                local moveX = math.cos(rotY)*(length+(base/2))
                local moveZ = math.sin(rotY)*(length+(base/2))
                a = self.getPosition().x-moveX
                b = self.getPosition().z+moveZ

                newPos = {x = a, y = rangePos.y-0.1 , z = b}
                closeObj.setPositionSmooth(newPos)
                moved = true
                closeObj.call("clearSecure")
            else

                closeObj.setPositionSmooth(previousPos)
                moved = false
            end
            closeObj.setRotation({0,closeObj.getRotation().y, 0})
        elseif attached == false then
            toggleAttach()
        end
        updateButtons()
    end

    function getBentRotation()
        return (self.getRotation().y - savedRotA.y) + savedRotB.y
    end

    function placeObject(obj, player, alt)

      if snapped == true then
            if moved == false then
                if placed == false then
                    if alt == true then
                        moveBase()
                    else
                        Global.call("updatePlace", self.getGUID())
                        placed = true
                        updateButtons()
                    end
                else
                    Global.call("updatePlace", nil)
                    placed = false
                    throwPlaced = false
                    updateButtons()
                end
            else
                moveBase()
            end
        end

    end

    function setupThrow()
        throwPlaced = true
        if placed == false then
            placeObject()
        else
            updateButtons()
        end
    end

    function straightenTool()
        self.removeAttachments()
        templateB = getObjectFromGUID(pieceB)
        templateB.setRotation(self.getRotation())
        attached = false
        toggleAttach()
    end


    --when the tool collides it will stop the object from moving
    function onCollisionEnter()
        if pickedUp == false and iAmTrash == false then
            smallCollision = true
            self.setPosition({self.getPosition().x, self.getPosition().y + 0.1,self.getPosition().z})
            stopObject()
            self.setRotation({x = 0,y = self.getRotation().y,z = 0})
        end
    end

    --usually called when the object is stuck inside the object. It will move it faster out of the object
    function onCollisionStay()
        if pickedUp == false and smallCollision == true and iAmTrash == false  then
            smallCollision = false
            self.setPosition({self.getPosition().x, self.getPosition().y + 1,self.getPosition().z})
            stopObject()
            self.setRotation({x = 0,y = self.getRotation().y,z = 0})
        end
    end

    --makes sure when the item leaves collision it doesnt float too high above the object
    function onCollisionExit(collision_info)
        if smallCollision == false and iAmTrash == false then
            self.setPosition({self.getPosition().x, self.getPosition().y + 0.5,self.getPosition().z})
            self.use_gravity = true
            self.setRotation({x = 0,y = self.getRotation().y,z = 0})
        end
    end

    --stops the object from moving and stops any rotation
    function stopObject()
        self.use_gravity = false
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
    end

    --Used to move tool back to tool tray in its spot
    function cleanUp()
        iAmTrash = true
        if savedRotB.y != savedRotA.y or attached == false then
            templateB = getObjectFromGUID(pieceB)
            templateB.setRotation(self.getRotation())
            toggleAttach()
        end
        self.setPositionSmooth(origin.pos)
        self.setRotationSmooth(origin.rot)
        self.use_gravity = true
        if snapped == true or snappedTA == true then
            snapBase()
        end
        if closeObj != nil then
            closeObj.call("towardAway", nil)
        elseif givenObj != nil then
            givenObj.call("towardAway", nil)
        end
        pickedUp = false
    end


    --checks to see if another tool of the same type is on the game board when this one enters
    function onObjectEnterScriptingZone(zone, obj)
        if obj == self and iAmTrash == false then
            if string.find(obj.getName(), "Movement B") then
                --nada
            else
                moveTools = zone.getObjects()
                Wait.frames(function() goHomeToolYoureDrunk(obj) end, 5)
            end
        end
    end

    -- removes other tools so only 1 of each type is present on the game board at a time
    function goHomeToolYoureDrunk(obj)
        if snappedTA == false then
            for i, obj in pairs(moveTools) do
                if obj.getDescription() == self.getDescription() and string.find(obj.getName(), "Movement") and obj != self and parent.getVar("cleanUp") == true and obj.getVar("snappedTA") == false then
                    obj.call("toggleAttach")
                    Wait.frames(function() obj.call("cleanUp") end, 3)
                end
            end
        end
    end

    --Assigns length based on which mesh is being used.
    function whoAmI()
        identity = self.getCustomObject().mesh
        if identity     == "http://cloud-3.steamusercontent.com/ugc/1773824946632947455/585B7DABC9BA1B52E72AA783C7BAA5AF11FE5832/" then length = 7.16535/2
        elseif identity == "http://cloud-3.steamusercontent.com/ugc/1773824946632961921/3BFA6A3BCCA5929B1AB8B9C482A3F985EC2641C1/" then length = 5.90551/2
        elseif identity == "http://cloud-3.steamusercontent.com/ugc/1773824946632972740/A60555FE748439623544F5292B70266D4851196D/" then length = 3.34646/2
        end
    end

    --Makes sure to release the lock on the toward and away
    --without this if the tool is destroyed then other tools wont be able to circle around the whole model
    function onDestroy()
        if closeObj != nil then
            closeObj.call("towardAway", nil)
        elseif givenObj != nil then
            givenObj.call("towardAway", nil)
        end
    end

    --Cleanup function that is callable from the parent tool tray
    function parentCleanUp()
        if savedRotB.y != savedRotA.y and attached == true then
            toggleAttach()
        end
        Wait.frames(function() cleanUp() end, 5)
    end

    function onObjectHover(player_color, hovered_object)
        if parent.getVar("withinRange") then
            if hovered_object != nil then
                if hovered_object.type != "Surface" then
                    if hovered_object.getVar("baseSize") != nil and closeObj != nil and pickedUp and snapped then
                        if hovered_object != closeObj and savedRotB == savedRotA then
                            inRange = hovered_object.getVar("baseSize")/2 + closeObj.getVar("baseSize")/2 + length*2
                            local hovObjPos = hovered_object.getPosition()
                            local snapObjPos = closeObj.getPosition()
                            local distance = math.sqrt((hovObjPos.x-snapObjPos.x)^2 + (hovObjPos.z-snapObjPos.z)^2)

                            if inRange > distance then
                                hovered_object.highlightOn({0,0.9,0}, 3)
                            else
                                hovered_object.highlightOn({0.9,0,0}, 3)
                            end
                        end
                    end
                end
            end
        end
    end
    