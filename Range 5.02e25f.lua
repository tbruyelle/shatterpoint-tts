parentGUID = "1fbf69"
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

    