rangeTool = [[
    function onLoad(save_state)
        playMat = Global.getVar("playMat")              --load scripting zone in order to find characters on the table
        database = Global.getTable("characterDatabase") --load character database from Global so the tool knows that to c
        parent = getObjectFromGUID(parentGUID)          --makes sure the tool knows which tray it responds to. parent GUID if given on creation

        base = 0            --initial character base size this will be changed once its needed
        snapped = false     --initial snapped state (range ruler starts out not snapped to any character)
        snappedOne = false  --initial snapped state (range ruler starts out not snapped to any character)
        moved = false       --initial moved state used to determine what buttons do and their labels
        placed = false      --initial placed state used to determine what buttons do and their labels
        placedOne = false   --initial placed state used to determine what buttons do and their labels
        init = false        --boolean used to decipher first time setup
        rogueTool = false   --boolean used to determine if tool is at great risk to knock around models
        length = 0          --initial length
        mySize = 2          --the tool name 2-5
        whoAmI()            --assign actual length based on mesh
        iAmTrash = false    --keeps track of if cleanup is being used
        rotationOffset = 90

        --loads saved data from previous saves
        if save_state ~= "" then
            local loaded_data = JSON.decode(save_state)
            origin = loaded_data[1]
        else
            --sets up cleanup phase
            origin = {}
            origin.pos = self.getPosition()
            origin.rot = self.getRotation()
        end
        updateSave()
        createButtons()
    end

    --will update this information on save. This will allow for players to save halfway through a game and come back to finish.
    function updateSave()
        local data_to_save = {origin}
        saved_data = JSON.encode(data_to_save)
        self.script_state = saved_data
    end

    function createButtons()
        self.createButton({
            index = 0,
            click_function = "snapButton",
            function_owner = self,
            label = "Snap " .. tostring(mySize),
            position = {(length/2)-0.2, 0.22, 0},
            rotation = {0, 270, 0},
            width = 425,
            height = 125,
            font_size = 75,
            color = {0, 0, 0, 0},
            font_color = {1, 1, 1, 1},
            tooltip = "Snap " .. tostring(mySize) .. " to nearest character"
        })

        -- Create Snap button that will be pressed to snap range ruler to character
        self.createButton({
            index = 1,
            click_function = "snapOneButton",
            function_owner = self,
            label = "",
            position = {0, 0.22, 0.3},
            rotation = {0, 0, 0},
            width = 0,
            height = 125,
            font_size = 75,
            color = {0, 0, 0, 0},
            font_color = {1, 1, 1, 1},
            tooltip = ""
        })

        self.createButton({
            index = 2,
            click_function = "placeObject",
            function_owner = self,
            label = "",
            position = {-((length/2)-0.2), 0.22, 0},
            rotation = {0, 270, 0},
            width = 0,
            height = 125,
            font_size = 75,
            color = {0, 0, 0, 0},
            font_color = {1, 1, 1, 1},
            tooltip = ""
        })

    end

    function updateButtons()
        --this function uses all the snapped, attached, snappedTA, and moved booleans to determine:
        --which buttons should be visible
        --which labels should be on those buttons
        if init == true then

            if snapped == true then
                self.editButton({index=0, label="Unsnap", tooltip = "Click to Unsnap", width = 425, color = {0, 0, 0, 1},})
                if placed == false then
                    self.editButton({index=2, label="Place " .. tostring(mySize), tooltip = "Click to start Place " .. tostring(mySize) .. " function.", color = {0, 0, 0, 1}, width = 425, position = {-((length/2)-0.2), 0.22, 0}, rotation = {0, 270, 0},})
                else
                    self.editButton({index=2, label="Done", tooltip = "Click to stop placement function.", color = {0, 0, 0, 1}, width = 425, position = {-((length/2)-0.2), 0.22, 0}, rotation = {0, 270, 0}})
                end
            else
                self.editButton({index=0, label = "Snap " .. tostring(mySize), tooltip = "Snap " .. tostring(mySize) .. " to nearest Base", width = 425, color = {0, 0, 0, 1}})
            end

            if snappedOne == true then
                self.editButton({index=1, label="Unsnap", width = 425, tooltip = "Click to Unsnap", color = {0, 0, 0, 1},})
                if placedOne == false then
                    self.editButton({index=2, label="Place 1", width = 425, tooltip = "Click to start Place 1 function.", color = {0, 0, 0, 1}, position = {0, 0.22, -0.3}, rotation = {0, 0, 0}})
                else
                    self.editButton({index=2, label="Done", width = 425, tooltip = "Click to stop placement function.", color = {0, 0, 0, 1}, position = {0, 0.22, -0.3}, rotation = {0, 0, 0},})
                end
            else
                self.editButton({index=1, label = "Snap 1", tooltip = "Snap 1 to nearest Base", width = 425, color = {0, 0, 0, 1},})
            end

            if snappedOne == false and snapped == false then
                self.editButton({index=2, label = "", width = 0, color = {0, 0, 0, 0}})
            end
        end
    end

    --assigns the length of the range tools based on what mesh they are using.
    function whoAmI()
        identity = self.getCustomObject().mesh
        if identity     == "http://cloud-3.steamusercontent.com/ugc/1773824946630669692/ECAF9512CEA0A9D613C73FF133CEE025A41A006B/" then
            length = 10
            mySize = 5
        elseif identity == "http://cloud-3.steamusercontent.com/ugc/1773824946630669498/515412D7D115DC09D306CCB09142FBF05F9492D6/" then
            length = 8
            mySize = 4
        elseif identity == "http://cloud-3.steamusercontent.com/ugc/1773824946630669283/611614A95EFA88AC8AC5538C39679D81113AFD8C/" then
            length = 6
            mySize = 3
        elseif identity == "http://cloud-3.steamusercontent.com/ugc/1773824946630669095/86EF9991794417762BDA0D52A64949F74CB60E64/" then
            length = 3
            mySize = 2
        end
    end


    --This sets up the player who picks up the tool as the operating player for that tool
    function onPickUp(player_color)
        if init == false then init = true end
        rogueTool = false   --tool will only be rogue from the time it moves on its own to when the player picks it up
        iAmTrash = false
        if snapObj != nil then
            --makes sure object isnt nudged by
            holding = snapObj.getVar("holding")
            if holding != nil then
                local curPos = snapObj.getPosition()
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

        if moved == true then
            moved = false
            snapBase()
        else
            clickPlayerColor = player_color
            startLuaCoroutine(self, "turnToCursor")
        end
        updateButtons()
    end

    --function maintains positionTemplate function while the mouse button is held down
    function turnToCursor()
        pickedUp = true

        if snapped == true or snappedOne == true then
            while (pickedUp == true) do
                positionTemplate()
                coroutine.yield(0)
            end
        else
            if parent.getVar("highlight") == true then
                while (pickedUp == true) do
                    highlightTarget()
                    coroutine.yield(0)
                end
            end
        end
        return 1
    end

    function highlightTarget()
        findClosest()
        if closeObj != nil then
            closeObj.highlightOn({0,1,0}, 0.1)
            self.editButton({index = 0, color = {0,1,0}})
            self.editButton({index = 1, color = {0,1,0}})
        end
        checked = false
        return 1
    end

    function findClosest()
        --finds all the objects within the playmat (scripting zone)
        local objects = playMat.getObjects()

        --prime the proximity float
        proximity = 1000

        --iterate through each object in playMat (i)
        for i, unit in pairs(objects) do
            if unit.type != "Surface" then -- this makes sure not to include the table in the code below
                local obj = getObjectFromGUID(unit.guid) --This further makes sure the object is a valid object before moving foward
                if obj != nil then

                    --iterates through the global database to check character names with object names
                    for k, v in pairs(database) do
                        name = obj.getName()
                        custom = obj.getDescription()
                        if name == v.cName or custom == v.cName then
                            if v.objective == true and parent.getVar("snapObjective") == true or v.objective == nil then
                                local distance = findProximity(self, unit, v.cBase) --matches a character in database so checks proximity to ruler
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
        end
    end


    --Finds the snap edge of the tool and returns the distance from object, to snap edge
    function findProximity(tool, object, base)
        local objectPos = object.getPosition()
        local selfPos = self.getPosition()
        local selfRot = self.getRotation()
        local rotY = math.rad(selfRot.y)
        local offsetX = math.cos(rotY)*((length+base)/2)
        local offsetZ = math.sin(rotY)*((length+base)/2)

        a = selfPos.x-offsetX
        b = selfPos.z+offsetZ

        local xDis = math.abs(objectPos.x - a)
        local zDis = math.abs(objectPos.z - b)
        local distance = xDis^2 + zDis^2

        return math.sqrt(distance)
    end

    --Used for when an object to snap is provided by the parent. This will find the object and get the info needed
    function findInfo(newObj)
        characterInfo = newObj.getTable("characterInfo")
        if characterInfo == nil then
            --iterates through the global database to check character names with object names
            for k, v in pairs(database) do
                name = newObj.getName()
                if name == v.cName then
                    if v.objective == true and parent.getVar("snapObjective") == true or v.objective == nil then
                        indexNum = k
                        closeObj = newObj
                        snapObj = newObj
                        if v.objective == true then
                            base = snapObj.getVar("objectiveSize")
                        else
                            base =  v.cBase
                        end
                    end
                end
            end
        else
            closeObj = newObj
            snapObj = closeObj
            objPos = closeObj.getPosition()
            base = closeObj.getVar("baseSize")
        end
    end


    --This is the function called by pressing a button
    function snapButton(obj)
        snapBase(nil)
    end

    --Searches for closest character base and then calls for the template to be moved correctly
    --This is the function that can be called from elsewhere and provide the object needed to snap
    function snapBase(givenObj)
        --This allows swapping between each snap type
        if snappedOne == true then
            snapOne(nil)
        end

        --If an object was given from an outside call the code needs to assume a snap hasnt occured yet
        if givenObj != nil then
            snapped = false
            iAmTrash = false
        end

        if snapped == true then
            --Updates Buttons when tool is unsnapped
            snapped = false
            placed = false
            moved = false -- reset Moved bool
            snapObj = nil
            Global.call("updatePlace", nil)
        else
            rotationOffset = 90
            rogueTool = true --tool will now move on its own so it will be rogue until someone picks it up
            if givenObj == nil then
                findClosest()
                snapObj = closeObj
            else
                findInfo(givenObj) -- finds the info of the given object
            end

            --nil check to avoid errors
            if snapObj != nil then
                objPos = snapObj.getPosition() --set object that will be selected to snap
                objRot = snapObj.getRotation() --set object that will be selected to snap
                self.setPosition({self.getPosition().x, objPos.y+0.5, self.getPosition().z})
                offset = ((length+base)/2) --set offset so ruler snaps on edge of ruler to edge of base
                positionTemplate() --perform snap
                snapped = true --object is now snapped
            else
                --Updates Buttons when tool is unsnapped
                snapped = false

                moved = false -- reset Moved bool
            end
        end
        updateButtons()
    end

    --This is the function called by pressing a button
    function snapOneButton(obj)
        snapOne(nil)
    end

    --Searches for closest character base and then calls for the template to be moved correctly
    --This is the function that can be called from elsewhere and provide the object needed to snap
    function snapOne(givenObj)
        --This allows swapping between each snap type
        if snapped == true then
            snapBase(nil)
        end

        --If an object was given from an outside call the code needs to assume a snap hasnt occured yet
        if givenObj != nil then
            snappedOne = false
            iAmTrash = false
        end

        if snappedOne == true then
            rotationOffset = 90
            --Updates Buttons when tool is unsnapped
            snappedOne = false
            self.editButton({index=1, label="Snap 1", tooltip = "Snap 1 to nearest Base"})
            placedOne = false
            moved = false -- reset Moved bool
            snapObj = nil
            Global.call("updatePlace", nil)
        else
            rotationOffset = 0
            rogueTool = true --tool will now move on its own so it will be rogue until someone picks it up


            if givenObj == nil then
                findClosest()
                snapObj = closeObj
            else
                findInfo(givenObj)
            end

            --nil check to avoid errors
            if snapObj != nil then
                objPos = snapObj.getPosition() --set object that will be selected to snap
                objRot = snapObj.getRotation() --set object that will be selected to snap
                self.setPosition({self.getPosition().x, objPos.y+0.5, self.getPosition().z})
                offset = ((1+base)/2) --set offset so ruler snaps on edge of ruler to edge of base
                positionTemplate() --perform snap
                snappedOne = true --object is now snapped
            else
                --Updates Buttons when tool is unsnapped
                snappedOne = false
            end
        end
        updateButtons()
    end


    --maintains the rulers snap to the selected base and allows for rotation
    function positionTemplate()
            if snapObj != nil then
                --makes sure object isnt nudged by
                holding = snapObj.getVar("holding")
                if holding != nil then
                    local curPos = closeObj.getPosition()
                    if holding == false then
                        if math.abs(curPos.x-objPos.x) > 0.75 or math.abs(curPos.y-objPos.y) > 0.75 or math.abs(curPos.z-objPos.z) > 0.75 then
                            pickedUp = false
                            snapBase()
                        else
                            snapObj.setPosition(objPos)
                            snapObj.setRotation(objRot)
                        end
                    end
                end
            end

            --finds the mouse coordinates of the player who last picked up the range tool
            local mouseX = Player[clickPlayerColor].getPointerPosition().x
            local mouseZ = Player[clickPlayerColor].getPointerPosition().z

            -- finds the x/z difference between the mouse and the center of the base
            local a = objPos.x-mouseX
            local b = objPos.z-mouseZ

            --finds the angle of the line drawn from mouse to base center
            local q = math.deg(math.atan2(a, b))
            -- set rotation with a 90 degree offset
            self.setRotation({x = 0, y = q+rotationOffset, z = 0})
            templatePos = self.getPosition()

            --applies the offset math to make sure ruler doesnt snap in center of base
            local a2 = offset*math.cos(math.atan2(b, a))
            local b2 = offset*math.sin(math.atan2(b, a))
            templatePos = {x = objPos.x-a2, y = templatePos.y , z = objPos.z-b2}

            if rotationOffset == 0 then
                local offset = length/2
                local a2 = offset*math.sin(math.rad(q+90))
                local b2 = offset*math.cos(math.rad(q+90))
                templatePos = {x = templatePos.x-a2, y = templatePos.y , z = templatePos.z-b2}
            end


            if snapped == true or snappedOne == true then
                self.setPosition(templatePos)
            else
                self.setPositionSmooth(templatePos) --adds a nice touch so you can watch the range ruler lock into place while it snaps
            end


            -- stop velocity
            self.setVelocity({0,0,0})
            self.setAngularVelocity({0,0,0})

    end

    function placeObject()
      if snapped == true then
            if placed == false then
                Global.call("updatePlace", self.getGUID())
                placed = true
            else
                Global.call("updatePlace", nil)
                placed = false
            end
        elseif snappedOne == true then
            if placedOne == false then
                Global.call("updatePlace", self.getGUID())
                placedOne = true
            else
                Global.call("updatePlace", nil)
                placedOne = false
            end
        end
        updateButtons()
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

    function onCollisionStay(info)
        if pickedUp == false and smallCollision == true and iAmTrash == false then
            local offset = 1
            smallCollision = false
            self.setPosition({self.getPosition().x, self.getPosition().y + offset ,self.getPosition().z})
            stopObject()
            self.setRotation({x = 0,y = self.getRotation().y,z = 0})
        end
    end

    function onCollisionExit()
        if smallCollision == false and iAmTrash == false then
            self.setPosition({self.getPosition().x, self.getPosition().y + 0.5, self.getPosition().z})
            self.use_gravity = true
            self.setRotation({x = 0,y = self.getRotation().y,z = 0})
        end
    end

    function stopObject()
        self.use_gravity = false
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
    end

    --once the tool is dropped it sets its position again so it doesn2t land on top
    function onDropped(player_color)
        self.editButton({index = 0, color = {0,0,0}})
        self.editButton({index = 1, color = {0,0,0}})
        pickedUp = false
        if snapped == true then
            positionTemplate()


        --checks for position of tool and automatically cleans it up
        elseif parent.getVar("cleanUp") == true then
            local checkBounds = self.getPosition()
            local x = checkBounds.x
            local z = checkBounds.z
            local cleanup = 36/2
            if x > cleanup or x < -cleanup or z > cleanup or z < -cleanup then
                cleanUp()
            end
        end

        self.use_gravity = true

        -- stop velocity
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
        updateButtons()
    end

    --automatically returns tool to its position on the tray
    function cleanUp()
        iAmTrash = true
        if snapped == true then
            snapBase()
        elseif snappedOne == true then
            snapOne()
        end
        self.setPositionSmooth(origin.pos)
        self.setRotationSmooth(origin.rot)
        self.use_gravity = true
    end

    function onObjectEnterScriptingZone(zone, obj)
        if obj == self and iAmTrash == false then
            rangeTools = zone.getObjects()
            Wait.frames(function() goHomeToolYoureDrunk(obj) end, 5)
        end
    end

    function goHomeToolYoureDrunk(obj)
        for i, obj in pairs(rangeTools) do
            if obj.getDescription() == self.getDescription() and string.find(obj.getName(), "Range") and obj != self and parent.getVar("cleanUp") == true then
                obj.call("cleanUp")
            end
        end
    end

    function onObjectHover(player_color, hovered_object)
        if parent.getVar("withinRange") then
            if hovered_object != nil then
                if hovered_object.type != "Surface" then
                    if hovered_object.getVar("baseSize") != nil and snapObj != nil and pickedUp then
                        if snapped or snappedOne then
                            if hovered_object != snapObj then
                                inRange = hovered_object.getVar("baseSize")/2 + snapObj.getVar("baseSize")/2 + length
                                if snappedOne then inRange = hovered_object.getVar("baseSize")/2 + snapObj.getVar("baseSize")/2 + 1 end
                                local hovObjPos = hovered_object.getPosition()
                                local snapObjPos = snapObj.getPosition()
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
    end

    ]]
--Code for Part A of the movement tools
moveTemplateA = [[

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
    ]]
--This string contains the code for Part B of the movement tools
moveTemplateB = [[

    function onLoad()
        parent = getObjectFromGUID(pieceA)
        centerPos = parent.getPosition()
        originalRot = parent.getRotation().y
        self.use_gravity = false
    end

    --This sets up the player who picks up the tool as the operating player for that tool
    function onPickUp(player_color)
        snapped = true
        clickPlayerColor = player_color
        startLuaCoroutine(self, "turnToCursor")
    end

    --function maintains positionTemplate function while the mouse button is held down
    function turnToCursor()
        templateRot = self.getRotation()
        pickedUp = true

        while (pickedUp == true) do
            positionTemplate()
            coroutine.yield(0)
        end
        return 1
    end


    --maintains the rulers snap to the selected base and allows for rotation
    function positionTemplate()
        parent.setPosition(centerPos)
        parent.setRotation({0,originalRot,0})
        if clickPlayerColor != nil then
            --finds the mouse coordinates of the player who last picked up the range tool
            mouseX = Player[clickPlayerColor].getPointerPosition().x
            mouseZ = Player[clickPlayerColor].getPointerPosition().z

        else
            mouseX = centerPos.x
            mouseZ = centerPos.z
        end

        -- finds the x/z difference between the mouse and the center of the base
        local a = centerPos.x-mouseX
        local b = centerPos.z-mouseZ

        --finds the angle of the line drawn from mouse to base center
        local moveB = math.deg(math.atan2(a, b))+90


        if moveB > 180 then
            moveB = moveB - 360
        end

        moveA = originalRot
        lastY = templateRot.y

        if moveA > 180 then
            moveA = moveA - 360
        end


        --Finds the bounds for the 90 degree rotation
        if moveA > -90 and moveA < 90 then
            if moveB < moveA +90 and moveB > moveA -90 then
                templateRot.y = moveB
                self.setRotation({x = 0, y = templateRot.y, z = 0})
            elseif moveB > moveA + 90 then
                self.setRotation({0,moveA + 90,0})
            elseif moveB < moveA -90 then
                self.setRotation({0,moveA - 90,0})
            end
        elseif moveA > 90  or moveA == 90 then
            if moveB > moveA - 90 or moveB < moveA - 270 then
                templateRot.y = moveB
                self.setRotation({x = 0, y = templateRot.y, z = 0})
            elseif moveB > moveA -180 then
                self.setRotation({0,moveA - 90,0})
            elseif moveB < moveA -180 then
                self.setRotation({0,moveA + 90,0})
            end
        elseif moveA < -90 or moveA == -90 then
            if moveB < moveA + 90 or moveB > moveA + 270 then
                templateRot.y = moveB
                self.setRotation({x = 0, y = templateRot.y, z = 0})
            elseif moveB < moveA +180 then
                self.setRotation({0,moveA + 90,0})
            elseif moveB > moveA +180 then
                self.setRotation({0,moveA - 90,0})
            end
        end

        if self.getPosition().y < centerPos.y then
            self.setPosition(centerPos)
        else
            self.setPosition({centerPos.x, self.getPosition().y, centerPos.z})
            parent.setPosition(self.getPosition())
        end



        -- stop velocity
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
    end

    --once the tool is dropped it sets its position again so it doesn't land on top
    function onDropped(player_color)
        pickedUp = false
        positionTemplate()

    end

    function onCollisionStay(collision_info)
        self.setRotation({x = 0,y = self.getRotation().y,z = 0})
        stopObject()
    end

    function stopObject()
        self.use_gravity = false
        self.setVelocity({0,0,0})
        self.setAngularVelocity({0,0,0})
    end
    ]]

--allows for mirror image of tool tray
assetbundle180 = "http://cloud-3.steamusercontent.com/ugc/1034085686588454156/B6380F85797062271F9860AE17643051D743F9D0/"
assetbundle0 = "http://cloud-3.steamusercontent.com/ugc/1034085686588318236/B70BB9BDDBC5C3F9B1694B40D45BA39EBAFECE39/"

toolsImage = {"http://cloud-3.steamusercontent.com/ugc/2021597657827463993/8E486DEB796D4A8531F3844477352231CD0660CE/"}


range5Mesh        = "http://cloud-3.steamusercontent.com/ugc/1773824946630669692/ECAF9512CEA0A9D613C73FF133CEE025A41A006B/"
range4Mesh        = "http://cloud-3.steamusercontent.com/ugc/1773824946630669498/515412D7D115DC09D306CCB09142FBF05F9492D6/"
range3Mesh        = "http://cloud-3.steamusercontent.com/ugc/1773824946630669283/611614A95EFA88AC8AC5538C39679D81113AFD8C/"
range2Mesh        = "http://cloud-3.steamusercontent.com/ugc/1773824946630669095/86EF9991794417762BDA0D52A64949F74CB60E64/"
range1Mesh        = "http://cloud-3.steamusercontent.com/ugc/1773824946630668896/8EBB9A4F569DE4C13FF0D6C0C05E97C827D53AB5/"


mediumMeshA       = "http://cloud-3.steamusercontent.com/ugc/1773824946632961921/3BFA6A3BCCA5929B1AB8B9C482A3F985EC2641C1/"
mediumColliderA   = "http://cloud-3.steamusercontent.com/ugc/1057730731008470906/3E81158F574FFF24746E3D56CCA501F182BEB1A6/"
mediumMeshB       = "http://cloud-3.steamusercontent.com/ugc/2021597657822238445/313A48C5650F630630B4EEF98BFA234B552E0EA2/"
mediumColliderB   = "http://cloud-3.steamusercontent.com/ugc/1057730731008491795/E1AE20C893877B2F8967A65AB65FA004E4449A91/"

shortMeshA        = "http://cloud-3.steamusercontent.com/ugc/1773824946632972740/A60555FE748439623544F5292B70266D4851196D/"
shortColliderA    = "http://cloud-3.steamusercontent.com/ugc/1057730731008468229/D89A153ADD49B83907FC88CBA003D728BF687827/"
shortMeshB        = "http://cloud-3.steamusercontent.com/ugc/2021596932956748965/752029EB356D7123B1FA518F5EFB4C3526C3D3CF/"
shortColliderB    = "http://cloud-3.steamusercontent.com/ugc/1057730731008467517/910AD7AC0EA7B6AE0132DFB9AF791AB32B772945/"


function onLoad(save_state)
    scripts = getObjectFromGUID(Global.getVar("scriptsGUID"))
    database = getObjectFromGUID(Global.getVar("databaseGUID"))

    characterDatabase = database.getTable("characterDatabase")

    setinteractable = true
    self.interactable = setinteractable
    self.drag_selectable = setinteractable

    --Rotates the tool tray and assigns it the proper assetbundle
    selfRot = self.getRotation()
    checkY = selfRot.y


    if checkY > 90 and checkY < 270 then
        myplayer = "Red"
        myColor = Color.Red

        self.setRotation({0, 180, 0})
        angleOffset = 1     --normal (no offset needed)
        if self.getCustomObject().assetbundle == assetbundle0 then
            self.setCustomObject({assetbundle = assetbundle180})
            --self.reload()
        end
    else
        myplayer = "Blue"
        myColor = Color.Blue
        self.setRotation({0, 0, 0})
        angleOffset = -1    --inverse (negative offset needed)
        if self.getCustomObject().assetbundle == assetbundle180 then
            self.setCustomObject({assetbundle = assetbundle0})
            --self.reload()
        end
    end


    refreshing = false


    buttonX = -1.05*angleOffset --applies offset to button placement

    --declares default settings
    openSettings = false
    highlight = false
    snapObjective = true
    cleanUp = true
    changing = false
    withinRange = true

    if save_state ~= "" then
        local loaded_data = JSON.decode(save_state)
        highlight = loaded_data[1]
        snapObjective = loaded_data[2]
        cleanUp = loaded_data[3]
        tools = loaded_data[4]
        imageNum = loaded_data[5]
        withinRange = loaded_data[6]
        if tools != nil then
            assignTools()
        end
    end

    if imageNum == nil then
        imageNum = 1
    end

    createButtons()

    --Wait.frames(function() spawnRangeTools() end, 11) --gives the game a few frames to load in old tools before deleting/spawning new ones

    parentGUID =  'parentGUID = "' .. self.getGUID() .. '"\n' --this script it placed on every tool's heading

    Wait.frames(function() findTools() end, 60)
    Wait.frames(function() refresh() end, 90)
end

--save data is kept to give the player more control during game when rewinding time
function updateSave()
    local data_to_save = {rangeMove, snapObjective, cleanUp, tools, imageNum, withinRange}
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

function findTools()
    tools = {}
    --if range1 != nil then tools.range1 = range1.getGUID() end
    if range2 != nil then tools.range2 = range2.getGUID() end
    if range3 != nil then tools.range3 = range3.getGUID() end
    if range4 != nil then tools.range4 = range4.getGUID() end
    if range5 != nil then tools.range5 = range5.getGUID() end
    if short != nil then tools.short = short.getGUID() end
    if medium != nil then tools.medium = medium.getGUID() end
    myTools = {range1, range2, range3, range4, range5, short, medium}
    updateSave()
end

function assignTools()
    --range1 = getObjectFromGUID(tools.range1)
    range2 = getObjectFromGUID(tools.range2)
    range3 = getObjectFromGUID(tools.range3)
    range4 = getObjectFromGUID(tools.range4)
    range5 = getObjectFromGUID(tools.range5)
    short  = getObjectFromGUID(tools.short)
    medium = getObjectFromGUID(tools.medium)
end

function createButtons()
    self.createButton({
        click_function = "refresh",
        function_owner = self,
        label = "Refresh",
        position = {buttonX, 0.38, -5.4},
        rotation = {0, 0, 0},
        width = 600,
        height = 200,
        font_size = 150,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Replaces all Range and Movement Tools"
    })

    self.createButton({
        click_function = "settings",
        function_owner = self,
        label = "Settings",
        position = {buttonX, 0.38, -5},
        rotation = {0, 0, 0},
        width = 600,
        height = 200,
        font_size = 150,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Change how the tools operate"
    })

    self.createButton({
        click_function = "nextSet",
        function_owner = self,
        label = "\u{2192}",
        position = {-buttonX*3.2*angleOffset, 0.38, 5.4},
        rotation = {0, 0, 0},
        width = 400,
        height = 200,
        font_size = 300,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Change to next photo"
    })
    self.createButton({
        click_function = "prevSet",
        function_owner = self,
        label = "\u{2190}",
        position = {buttonX*3.2*angleOffset, 0.38, 5.4},
        rotation = {0, 0, 0},
        width = 400,
        height = 200,
        font_size = 300,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Change to previous photo"
    })

    self.createInput({
        input_function = "imageInput",
        function_owner = self,
        label          = "Paste Tool URL here",
        position       = {0, 0.38, 5.4},
        rotation       = {0,0,0},
        scale          = {1,1,1},
        width          = 2200,
        height         = 150,
        font_size      = 100,
        validation     = 1,
        tab            = 1,
        alignment      = 3,
        })

    self.createButton({
        click_function = "importPhoto",
        function_owner = self,
        label = "Import",
        position = {-buttonX*2.9, 0.38, 4.445},
        rotation = {0, 0, 0},
        width = 725,
        height = 725,
        font_size = 150,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Import photo url"
    })
end

--Settings up settings buttons
function settings()
    updateLabels()
    if openSettings == false then
        self.createButton({
            click_function = "toggleCleanUp",
            function_owner = self,
            label = labelCU,
            position = {buttonX, 0.4, -4.5},
            rotation = {0, 0, 0},
            width = 1400,
            height = 200,
            font_size = 100,
            color = {0, 0, 0, 1},
            font_color = {1, 1, 1, 1},
            tooltip = "When tools are dropped outside of the play area they return to their spot in this tray."
        })
        self.createButton({
            click_function = "toggleHighlight",
            function_owner = self,
            label = labelHigh,
            position = {buttonX, 0.4, -4},
            rotation = {0, 0, 0},
            width = 1400,
            height = 200,
            font_size = 100,
            color = {0, 0, 0, 1},
            font_color = {1, 1, 1, 1},
            tooltip = "When tools are picked up they will highlight their snap target. (Uses a lot of resources)."
        })
        self.createButton({
            click_function = "toggleWithinRange",
            function_owner = self,
            label = labelRange,
            position = {buttonX, 0.4, -3.5},
            rotation = {0, 0, 0},
            width = 1400,
            height = 200,
            font_size = 100,
            color = {0, 0, 0, 1},
            font_color = {1, 1, 1, 1},
            tooltip = "When tools are snapped and picked up. Characters within range will highlight when you hover over them."
        })
        openSettings = true
    else
        self.removeButton(5)
        self.removeButton(6)
        self.removeButton(7)
        openSettings = false
    end
end


--toggles auto clean up of tools dropped off the game mat
function toggleCleanUp()
    if cleanUp == true then
        cleanUp = false
    else
        cleanUp = true
    end
    updateLabels()
    updateButtons()
end


--toggles highlighting of objects when tools are picked up
function toggleHighlight()
    if highlight == true then
        highlight = false
    else
        highlight = true
    end
    updateLabels()
    updateButtons()
end

--toggles highlighting of objects when tools are picked up
function toggleWithinRange()
    if withinRange == true then
        withinRange = false
    else
        withinRange = true
    end
    updateLabels()
    updateButtons()
end

function updateLabels()
    if cleanUp == true then
        labelCU = "Automatic Tool Clean Up (ON)"
    else
        labelCU = "Automatic Tool Clean Up (OFF)"
    end
    if highlight == true then
        labelHigh = "Highlight Snap Target (ON)"
    else
        labelHigh = "Highlight Snap Target (OFF)"
    end
    if withinRange == true then
        labelRange = "Within Range Indicator (ON)"
    else
        labelRange = "Within Range Indicator (OFF)"
    end
end

function updateButtons()
    self.editButton({index = 5, label = labelCU})
    self.editButton({index = 6, label = labelHigh})
    self.editButton({index = 7, label = labelRange})
    updateSave()
end

function imageInput(obj, color, input, stillEditing)
    if not stillEditing then
        inputUrl = input
    end
end

function importPhoto()
    if changing == false then
        if inputUrl != "" then
            updateAllTools(inputUrl)
            self.editInput({label = "Paste Tool URL here"})
        end
    end
end

function nextSet()
    if changing == false then
        if imageNum < #toolsImage then
            imageNum = imageNum + 1
        else
            imageNum = 1
        end
        updateAllTools(toolsImage[imageNum])
    end
end

function prevSet()
    if changing == false then
        if imageNum == 1 then
            imageNum = #toolsImage
        else
            imageNum = imageNum - 1
        end
        updateAllTools(toolsImage[imageNum])
    end
end

function updateAllTools(url)
    changing = true
    updateToolImage(url)
    Wait.frames(function() assignTools() end, 1)
    Wait.frames(function() refreshMove() end, 2)
    Wait.frames(function() changing = false end, 5)

    updateSave()
end

function updateToolImage(url)
    if short != nil then changeMove(short, url) end
    if medium != nil then changeMove(medium, url) end
    --if range1 != nil then changeRange(range1, url) end
    if range2 != nil then changeRange(range2, url) end
    if range3 != nil then changeRange(range3, url) end
    if range4 != nil then changeRange(range4, url) end
    if range5 != nil then changeRange(range5, url) end
end





function refreshMove()
    short.call("toggleAttach")
    medium.call("toggleAttach")
end

function refresh()
    origin = self.getPosition()
    rotationY = self.getRotation().y -90


    --if range1 != nil then
        --range1.call("cleanUp")
    --else
        --range1 = createRange({origin.x+3, origin.y+1, origin.z-4.5*angleOffset}, "Range 1", range1Mesh)
    --end
    if range2 != nil then
        range2.call("cleanUp")
    else
        range2 = createRange({origin.x+1.5, origin.y+1, origin.z-3.5*angleOffset}, "Range 2", range2Mesh)
    end
    if range3 != nil then
        range3.call("cleanUp")
    else
        range3 = createRange({origin.x-0.05, origin.y+1, origin.z-2*angleOffset}, "Range 3", range3Mesh)
    end
    if range4 != nil then
        range4.call("cleanUp")
    else
    range4 = createRange({origin.x-1.55, origin.y+1, origin.z-1*angleOffset}, "Range 4", range4Mesh)
    end
    if range5 != nil then
        range5.call("cleanUp")
    else
        range5 = createRange({origin.x-3.1, origin.y+1, origin.z}, "Range 5", range5Mesh)
    end

    if medium != nil then
        medium.call("parentCleanUp")
    else
        Wait.frames(function() medium = createMove({origin.x+3.3, origin.y+1, origin.z+1*angleOffset}, "Medium Movement", {1.18, 1,1}, {61/255,215/255,21/255}, mediumMeshA, mediumColliderA, mediumMeshB, mediumColliderB) end, 10)
    end
    if short != nil then
        short.call("parentCleanUp")
    else
        Wait.frames(function() short = createMove({origin.x+2, origin.y+1, origin.z+2.5*angleOffset}, "Short Movement", {1.09,1,1}, {236/255,21/255,21/255}, shortMeshA, shortColliderA, shortMeshB, shortColliderB) end, 20)
    end

    Wait.frames(function() findTools() end, 60)
end

function createRange(pos, name, rMesh)
    range = spawnObject({
        type              = "Custom_Model",
        position          = pos,
        rotation          = {0,rotationY-180,0},
        scale             = {1,1,1},
        sound             = false,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj, name) end,
    })

    range.setCustomObject({
        mesh        = rMesh,
        diffuse     = toolsImage[imageNum],
        type        = 0,
        material    = 3,
    })

    range.setColorTint(myColor)
    range.setLuaScript(parentGUID .. rangeTool)
    return range
end

function createMove(pos, name, scale, color, mMesh, mCollider, mMeshB, mColliderB)
    move = spawnObject({
        type              = "Custom_Model",
        position          = pos,
        rotation          = {0,rotationY-180,0},
        scale             = scale,
        sound             = false,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj, name) end,
    })


    move.setCustomObject({
        mesh        = mMesh,
        diffuse     = toolsImage[imageNum],
        collider    = mCollider,
        type        = 0,
        material    = 3,
    })

    --move.setColorTint(color)
    move.setColorTint(myColor)

    if name == "Medium Movement" then scale = {1 ,1,1} end

    moveB = spawnObject({
        type              = "Custom_Model",
        position          = {pos[1], pos[2]+1, pos[3]},
        rotation          = {0,rotationY-180,0},
        scale             = scale,
        sound             = false,
        snap_to_grid      = false,
        callback_function = function(obj) spawn_callback(obj, name .. " B") end,
    })

    moveB.setCustomObject({
        mesh        = mMeshB,
        diffuse     = toolsImage[imageNum],
        collider    = mColliderB,
        type        = 0,
        material    = 3,
    })
    moveB.setColorTint(myColor)
    --moveB.setColorTint(color)

    Wait.frames(function() setAllScripts(move.getGUID(), moveB.getGUID()) end, 5)
    return move
end

function spawn_callback(obj, name)
    obj.setName(name)
    obj.sticky = false
    obj.use_grid = false
    obj.setDescription(self.getName())
end

--called on a wait to supply plenty of frames for both objects to be created it then grabs info from each and places it on the other
function setAllScripts(guid1, guid2)
    local piece1 = getObjectFromGUID(guid1)
    local piece2 = getObjectFromGUID(guid2)

    local script1 = 'pieceB = "' .. guid2 .. '"\n' .. moveTemplateA
    local script2 = 'pieceA = "' .. guid1 .. '"\n' .. moveTemplateB

    piece1.setLuaScript(parentGUID .. script1)
    piece2.setLuaScript(parentGUID .. script2)
end


function onDropped()
    self.reload()
end

function onObjectHover(player_color, hovered_object)
    found = false
    if myplayer == player_color  and hovered_object != nil then
        name = hovered_object.getName()
        descr = hovered_object.getDescription()
        for i, char in pairs(characterDatabase) do
            if char.cName == name or char.cName == descr then
                hoverobj = hovered_object
                found = true
            end
        end
        if found == false then
            hoverobj = nil
        end
    end

end

function onScriptingButtonDown(index, color)
    if myplayer == color then
        if hoverobj != nil then
            if index == 1 then
                Wait.frames(function() snapOne(range2, color) end, 1)
            elseif index == 2 then
                Wait.frames(function() snapTool(range2, color) end, 1)
            elseif index == 3 then
                Wait.frames(function() snapTool(range3, color) end, 1)
            elseif index == 4 then
                Wait.frames(function() snapTool(range4, color) end, 1)
            elseif index == 5 then
                Wait.frames(function() snapTool(range5, color) end, 1)
            elseif index == 6 then
                if medium.getVar("snapped") == true then
                    medium.call("snapBase")
                end
                Wait.frames(function() snapTATool(medium, color) end, 1)
            elseif index == 7 then
                Wait.frames(function() snapTool(short, color) end, 1)
            elseif index == 8 then
                Wait.frames(function() snapTool(medium, color) end, 1)
            end
        else
            if index == 1 then
                Wait.frames(function() range2.call("cleanUp") end, 1)
            elseif index == 2 then
                Wait.frames(function() range2.call("cleanUp") end, 1)
            elseif index == 3 then
                Wait.frames(function() range3.call("cleanUp") end, 1)
            elseif index == 4 then
                Wait.frames(function() range4.call("cleanUp") end, 1)
            elseif index == 5 then
                Wait.frames(function() range5.call("cleanUp") end, 1)
            elseif index == 7 then
                Wait.frames(function() short.call("unattach") end, 1)
                Wait.frames(function() short.call("cleanUp") end, 4)
            elseif index == 8 then
                Wait.frames(function() medium.call("unattach") end, 1)
                Wait.frames(function() medium.call("cleanUp") end, 4)
            end
        end
        if index == 10 then
            refresh()
        end
    end
end



function snapTool(tool, color)
    tool.call("onPickUp", color)
    tool.call("snapBase", hoverobj)
    tool.call("onDropped", color)
end

function snapOne(tool, color)
    tool.call("onPickUp", color)
    tool.call("snapBase", hoverobj)
    tool.call("onDropped", color)
    Wait.frames(function() tool.call("snapOne", hoverobj) end, 5)
end



function snapTATool(tool, color)
    local rotation = tool.getRotation()
    toolGUID = tool.getGUID()
    toolBGUID = tool.getVar("pieceB")
    tool.call("toggleAttach", color)

    Wait.frames(function() rotateAway(toolGUID, toolBGUID, color, rotation) end, 15)
    Wait.frames(function() finallySnap(toolGUID, color) end, 30)
end

function rotateAway(toolGUID, toolBGUID, color, rot)
    tool = getObjectFromGUID(toolGUID)
    rotate = -90
    toward = tool.getVar("toward")
    if (toward) then
        rotate = 90
    end
    toolB = getObjectFromGUID(toolBGUID)
    toolB.setRotation({rot.x , rot.y+rotate, rot.z})
    tool.call("toggleAttach", color)
end

function finallySnap(toolGUID, color)
    tool.call("onPickUp", color)
    tool.call("snapTA", hoverobj)
    tool.call("onDropped", color)
end