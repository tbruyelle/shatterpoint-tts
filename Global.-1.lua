function onLoad(save_data)
    deploying = false


    playMat = getObjectFromGUID("3b5d33")
    playMat.setPosition({0,20,0})
    playMat.setRotation({0,0,0})
    playMat.setScale({36,50,36})

    nonStreamers = {"White | Brown | Red | Orange | Green | Teal | Blue | Purple | Pink | Grey | Black"}

    placeObjGUID = nil


    settingsOn = false
    allPlayers = {"White", "Brown", "Red", "Orange", "Yellow", "Green", "Teal", "Blue", "Purple", "Pink", "Grey"}


    findMyFriends()
--    checkMyFriends()


    if Player.White.seated and Player.Red.seated and (Player.Blue.seated == false) then
        Player.White.changeColor("Blue")
    elseif Player.White.seated and (Player.Red.seated == false) then
        Player.White.changeColor("Red")
    end



    whitelist = {
        "76561197970279274", --LTJkrazyglue04
        "76561198064333783", --Carefree Llama
        "76561198040691179", --Verscen
        "76561198018103385", --Gronco
        "76561198000047130", --Zetan
        "76561197992750593", --Dyzard
        "76561198029100473"  --Harleyz
    }
    deleteHiddenZones()

    streamerLock = false
end

function deleteHiddenZones()
    objects = getAllObjects()
    for i, obj in pairs(objects) do
        if obj.tag == "Fog" then
            obj.destruct()
        end
    end
end

function openSettings(player)
    UIController.call("showSettings", player.color)
end
function hideSettings(player)
    UIController.call("hideSettings", player.color)
end
function onStreamer(player)
    UIController.call("showStreamer", player.color)
end
function offStreamer(player)
    UIController.call("hideStreamer", player.color)
end

function offCharacters(player)
    params = {color = player.color, list = "Characters"}
    UIController.call("hideComponents", params)
end
function onCharacters(player)
    params = {color = player.color, list = "Characters"}
    UIController.call("showComponents", params)
end
function offDice(player)
    params = {color = player.color, list = "Dice"}
    UIController.call("hideComponents", params)
end
function onDice(player)
    params = {color = player.color, list = "Dice"}
    UIController.call("showComponents", params)
end
function offHeader(player)
    params = {color = player.color, list = "Header"}
    UIController.call("hideComponents", params)
end
function onHeader(player)
    params = {color = player.color, list = "Header"}
    UIController.call("showComponents", params)
end

function offTimers(player)
    params = {color = player.color, list = "Timers"}
    UIController.call("hideComponents", params)
end
function onTimers(player)
    params = {color = player.color, list = "Timers"}
    UIController.call("showComponents", params)
end

function tacticClick(a, b, c)
    if self.UI.getAttribute(c, "color") == "rgba(1,1,1,1)" then
        self.UI.setAttribute(c, "color", "rgba(0.7,0,0,1)")
    else
        self.UI.setAttribute(c, "color", "rgba(1,1,1,1)")
    end
end

function prioritySwitch(a, b, c)
    if self.UI.getAttribute(c, "image") == "PriorityFaded" then
        if c == "BluePriority" then
            Global.UI.setAttribute("BluePriority", "image", "Priority")
            Global.UI.setAttribute("RedPriority", "image", "PriorityFaded")
            if priorityToken != nil then
                priorityToken.call("moveBlue")
            end
        else
            Global.UI.setAttribute("RedPriority", "image", "Priority")
            Global.UI.setAttribute("BluePriority", "image", "PriorityFaded")
            if priorityToken != nil then
                priorityToken.call("moveRed")
            end
        end
    end
end

function diceColor(a, b, c)
    if self.UI.getAttribute(c, "color") == "rgba(0,0,0,1)" then
        if c == "RedDice" then
            self.UI.setAttribute(c, "color", "#ff5f5f")
        elseif c == "BlueDice" then
            self.UI.setAttribute(c, "color", "#609dff")
        end
    else
        self.UI.setAttribute(c, "color", "rgba(0,0,0,1)")
    end
end

function findMyFriends()
    scoreBoard = getObjectFromGUID("f1c596")

    strangers = getAllObjects()

    for i, obj in pairs(strangers) do
        oName = obj.getName()
        if oName == "Scripts" then
            scripts = obj
            scriptsGUID = obj.getGUID()
            obj.setPosition({50, 1, -32})
            obj.setInvisibleTo(allPlayers)
            obj.setLock(true)
        end
        if oName == "Database" then
            database = obj
            databaseGUID = obj.getGUID()
            characterDatabase = database.getTable("characterDatabase")
            tokenDatabase = database.getTable("tokenDatabase")
            obj.setPosition({-50, 1, -32})
            obj.setInvisibleTo(allPlayers)
            obj.setLock(true)
        end
        if oName == "UI Controller" then
            UIController = obj
            UIControllerGUID = obj.getGUID()
            obj.setPosition({50, 1, 32})
            obj.setInvisibleTo(allPlayers)
            obj.setLock(true)
        end
        if oName == "Placeholder" then
            obj.setPosition({-50, 1, 32})
            obj.setInvisibleTo(allPlayers)
            obj.setLock(true)
        end
        if oName == "Red Dice Tray" then
            diceAvengers = obj
            diceAvengersGUID = obj.getGUID()
        end
        if oName == "Blue Dice Tray" then
            diceHydra = obj
            diceHydraGUID = obj.getGUID()
        end
        if oName == "Red Tool Tray" then
            toolsAvengers = obj
            toolsAvengersGUID = obj.getGUID()
        end
        if oName == "Blue Tool Tray" then
            toolsHydra = obj
            toolsHydraGUID = obj.getGUID()
        end
        if oName == "Automatic Crisis Deployment" then
            spawnerCrisis = obj
            spawnerCrisisGUID = obj.getGUID()
        end
        if oName == "Red Tray Spawner" then
            spawnerTraysAvengers = obj
            spawnerTraysAvengersGUID = obj.getGUID()
        end
        if oName == "Blue Tray Spawner" then
            spawnerTraysHydra = obj
            spawnerTraysHydraGUID = obj.getGUID()
        end
        if oName == "Red Roster Tray" then
            rosterLeft = obj
            rosterLeftGUID = obj.getGUID()
        end
        if oName == "Blue Roster Tray" then
            rosterRight = obj
            rosterRightGUID = obj.getGUID()
        end
        if oName == "Red Tactic Tray" then
            tacticAvengers = obj
            tacticAvengersGUID = obj.getGUID()
        end
        if oName == "Blue Tactic Tray" then
            tacticHydra = obj
            tacticHydraGUID = obj.getGUID()
        end
        if oName == "Tracker" then
            scoreBoard = obj
            scoreBoardGUID = obj.getGUID()
        end
        if oName == "Red Roster Maker" then
            rosterMakerLeft = obj
            rosterMakerLeftGUID = obj.getGUID()
        end
        if oName == "Blue Roster Maker" then
            rosterMakerRight = obj
            rosterMakerRightGUID = obj.getGUID()
        end
        if oName == "Priority Token" then
            priorityToken = obj
            priorityTokenGUID = obj.getGUID()
        end
        if oName == "MCP Chess Clock" then
            chessClock = obj
            chessClockGUID = obj.getGUID()
        end
        if oName == "Cerebro Platform" then
            obj.interactable = false
        end
        if oName == "Placeholder" then
            Placeholder = obj
            PlaceholderGUID = obj.getGUID()
        end
    end
end

-- function checkMyFriends()
    -- if diceAvengers.getLuaScript() != diceHydra.getLuaScript() then
        -- broadcastToAll("Updated Dice Roller Code")
        -- diceHydra.setLuaScript(diceAvengers.getLuaScript())
        -- Wait.frames(function() diceHydra.reload() end, 5)
        -- Wait.frames(function() diceHydra = getObjectFromGUID(diceHydraGUID) end, 10)
    -- end

    -- if toolsAvengers.getLuaScript() !=  toolsHydra.getLuaScript() then
        -- broadcastToAll("Updated Movement Tools Code")
        -- toolsHydra.setLuaScript(toolsAvengers.getLuaScript())
        -- Wait.frames(function() toolsHydra.reload() end, 5)
        -- Wait.frames(function() toolsHydra = getObjectFromGUID(toolsHydraGUID) end, 10)
    -- end

   -- if spawnerTraysAvengers.getLuaScript() != spawnerTraysHydra.getLuaScript() then
        -- broadcastToAll("Updated Character Tray Spawner Code")
        -- spawnerTraysHydra.setLuaScript(spawnerTraysAvengers.getLuaScript())
        -- Wait.frames(function() spawnerTraysHydra.reload() end, 5)
        -- Wait.frames(function() spawnerTraysHydra = getObjectFromGUID(spawnerTraysHydraGUID) end, 10)
    -- end

    -- if rosterLeft.getLuaScript() != rosterRight.getLuaScript()  then
        -- broadcastToAll("Updated Roster Tray Code")
        -- rosterRight.setLuaScript(rosterLeft.getLuaScript())
        -- Wait.frames(function() rosterRight.reload() end, 5)
        -- Wait.frames(function() rosterRight = getObjectFromGUID(rosterRightGUID) end, 10)
    -- end

    -- if rosterMakerLeft.getLuaScript() != rosterMakerRight.getLuaScript() then
        -- broadcastToAll("Updated Roster Maker Code")
        -- rosterMakerRight.setLuaScript(rosterMakerLeft.getLuaScript())
        -- Wait.frames(function() rosterMakerRight.reload() end, 5)
        -- Wait.frames(function() rosterMakerRight = getObjectFromGUID(rosterMakerRightGUID) end, 10)
    -- end
-- end

function tokenUI()
    UIController.call("toggleToken")
    local tokenUI = UIController.getVar("tokenUI")
    if tokenUI == false then
        UIstring = "Toggle Token UI: Off"
    else
        UIstring = "Toggle Token UI: On"
    end
    self.UI.setAttribute("token", "text", UIstring)
end
function hideUI(player)
    UIController.call("hideUI", player.color)
    broadcastToColor("Character UI Turned Off", player.color)
end
function showUI(player)
    UIController.call("showUI", player.color)
    broadcastToColor("Character UI Turned On", player.color)
end
function default(player)
    UIController.call("default")
    broadcastToAll(player.color .. " Reset All Settings to Default", "Red")
    Placeholder.call("clearSave")
end

function autoCleanup(player)
    toolsHydra.call("refresh")
    toolsAvengers.call("refresh")
--    getObjectFromGUID(scoreBoardGUID).call("advanceRoundToken")
    local color = ""
    UIController.call("priority")
    if player == nil then
        color = "Red"
    else
        color = player.color
    end
    UIController.call("autoCleanup", color)
end

function autoPower(player)
    if UIController.getVar("powerReady") == true then
        UIController.call("autoPower", player.color)
    end
end

function tipClick()
    UIController.call("tipClick")
end

function toggleJarvis()
    UIController.call("toggleJarvis")
    checkJarvis()
end

function updatePlace(sGUID)
    placeObjectGUID = sGUID
end

function backDown()
    objects = getAllObjects()
    for i, obj in pairs(objects) do
        obj.translate({0, -0.03, 0})
    end
end

function onPlayerConnect(player_id)
    whitelist = {}
    whitelist = {
        "76561197970279274", --LTJkrazyglue04
        "76561198064333783", --Carefree Llama
        "76561198040691179", --Verscen
        "76561198018103385", --Gronco
        "76561198000047130", --Zetan
        "76561197992750593", --Dyzard
    }
    for i, ids in pairs(whitelist) do
        if player_id.steam_id == ids and player_id.promoted == false then
            player_id.promote()
        end
    end

    players = getSeatedPlayers()
    local redPlayer = false
    local bluePlayer = false

    for i, p in pairs(players) do
        if p == "Red" then
            redPlayer = true
        elseif p == "Blue" then
            bluePlayer = true
        end
    end

    if redPlayer == false then
        color = "Red"
    else
        color = "Blue"
    end

    if redPlayer == true and bluePlayer == true then
        player_id.changeColor(color)
    end

end

function onPlayerChangeColor(player_color)
    local red = false
    local blue = false
    local greenNormal = {position = {-70, 0.55, 10}, rotation = {0, 180, 0}, scale = {1,1,1}}
    local greenUE = {position = {-20, 0, -50}, rotation = {0, 0, 0}, scale = {1,1,1}}
    local redNormal = {position = {0, 0, -50}, rotation = {0, 0, 0}, scale = {1,1,1}}
    local redUE = {position = {20, 0, -50}, rotation = {0, 0, 0}, scale = {1,1,1}}

    for i, p in pairs(getSeatedPlayers()) do
        if p == "Red" then
            red = true
        elseif p == "Blue" then
            blue = true
        end
    end

    setupUE = false
    if setupUE == true then
        if red == true and blue == true then
            Player["Red"].setHandTransform(redUE, 1)
            Player["Green"].setHandTransform(greenUE, 1)
        else
            Player["Red"].setHandTransform(redNormal, 1)
            Player["Green"].setHandTransform(greenNormal, 1)
        end
    end

    if player_color == "Red" or player_color == "Blue" and Player[player_color].promoted == false then
        Player[player_color].promote()
    end
end

function customizeUI(player)
    Global.UI.setAttribute("customUISettings"  .. player.color, "active", "true")
    hideSettings(player)
end

function hideCustomUI(player)
    Global.UI.setAttribute("customUISettings"  .. player.color, "active", "false")
    openSettings(player)
end


function toggleTelecasting(player)
    if telecastor == nil then

        telecastor = spawnObject({
            type              = "Custom_Model",
            position          = {0,45,0},
            rotation          = {0,0,0},
            scale             = {0.5,1,0.5},
            sound             = false,
        })

        telecastor.setCustomObject({
            mesh = "http://cloud-3.steamusercontent.com/ugc/1698381221492518267/0BEE49487FCAE9BC3D9FD5F006706B983FAAA54D/",
            material = 3
        })

        telecastor.setLock(true)
        telecastor.setColorTint({0,0,0,0.1})
        telecastor.setInvisibleTo({"Red", "Blue"})

        telecastorScript = [[
            function onLoad(saved_data)
                init = false

                if saved_data ~= "" then
                    local loaded_data = JSON.decode(saved_data)
                    init = loaded_data[1]
                end

                if init == true then
                    self.destruct()
                end
                init = true
                updateSave()
            end
            function updateSave()
                local data_to_save = {init}
                saved_data = JSON.encode(data_to_save)
                self.script_state = saved_data
            end

            function onCollisionEnter(a)
                local pos = a.collision_object.getPosition()
                a.collision_object.setPosition({pos.x, pos.y-1, pos.z})
                a.collision_object.use_gravity = true
                Wait.frames(function() a.use_gravity = true end, 30)
            end
            ]]

        telecastor.setLuaScript(telecastorScript)
        telecastor.highlightOn(player.color)
        player.lookAt({
            position = {x=0,y=0,z=0},
            distance = 46
        })
        player.setCameraMode("TopDown")
        UIController.call("topDownOn", player.color)
    else
        telecastor.destruct()
        player.setCameraMode("ThirdPerson")
        UIController.call("topDownOff", player.color)
    end
end

function topDownOn(player)
    UIController.call("topDownOn", player.color)
end
function topDownOff(player)
    UIController.call("topDownOff", player.color)
end

function extractObjective(player)
    if Global.UI.getAttribute("extractObjectiveImg" .. player.color, "color") == "rgba(1,1,1,1)" then
        Global.UI.setAttribute("extractObjectiveImg" .. player.color, "color", "rgba(1,1,1,0.2)")
        UIController.call("extractOff", player.color)
    else
        Global.UI.setAttribute("extractObjectiveImg" .. player.color, "color", "rgba(1,1,1,1)")
        UIController.call("extractOn", player.color)
    end
end

function secureObjective(player)
    if Global.UI.getAttribute("secureObjectiveImg" .. player.color, "color") == "rgba(1,1,1,1)" then
        Global.UI.setAttribute("secureObjectiveImg" .. player.color, "color", "rgba(1,1,1,0.2)")
        UIController.call("secureOff", player.color)
    else
        Global.UI.setAttribute("secureObjectiveImg" .. player.color, "color", "rgba(1,1,1,1)")
        UIController.call("secureOn", player.color)
    end
end

function characterBars(player)
    if Global.UI.getAttribute("characterBarsImg" .. player.color, "color") == "rgba(1,1,1,1)" then
        Global.UI.setAttribute("characterBarsImg" .. player.color, "color", "rgba(1,1,1,0.2)")
        UIController.call("hideUI", player.color)
    else
        Global.UI.setAttribute("characterBarsImg" .. player.color, "color", "rgba(1,1,1,1)")
        UIController.call("showUI", player.color)
    end
end

function statusTokens(player)
    if Global.UI.getAttribute("statusTokens1" .. player.color, "color") == "rgba(1,1,1,1)" then
        Global.UI.setAttribute("statusTokens1" .. player.color, "color", "rgba(1,1,1,0.2)")
        Global.UI.setAttribute("statusTokens2" .. player.color, "color", "rgba(1,1,1,0.2)")
        Global.UI.setAttribute("statusTokens3" .. player.color, "color", "rgba(1,1,1,0.2)")
        UIController.call("statusOff", player.color)
    else
        Global.UI.setAttribute("statusTokens1" .. player.color, "color", "rgba(1,1,1,1)")
        Global.UI.setAttribute("statusTokens2" .. player.color, "color", "rgba(1,1,1,1)")
        Global.UI.setAttribute("statusTokens3" .. player.color, "color", "rgba(1,1,1,1)")
        UIController.call("statusOn", player.color)
    end
end

function HighlightButton(player, b, c)
    Global.UI.setAttribute(b, "color", player.color)
end
function ClearButtonHighlight(player, b, c)
    Global.UI.setAttribute(b, "color", "rgba(0.99,0.99,0.99,1)")
end

function toggleLock()
    if streamerLock == false then
        assetDrag(streamerLock)
        streamerLock = true
        Global.UI.setAttribute("lockIMG", "image", "Lock")
    else
        assetDrag(streamerLock)
        streamerLock = false
        Global.UI.setAttribute("lockIMG", "image", "Unlock")
    end
end

function assetDrag(bool)
    Global.UI.setAttribute("BlueDice", "allowDragging", bool)
    Global.UI.setAttribute("RedDice", "allowDragging", bool)
    Global.UI.setAttribute("Header", "allowDragging", bool)
    Global.UI.setAttribute("Timers", "allowDragging", bool)
    Global.UI.setAttribute("BlueCharacters", "allowDragging", bool)
    Global.UI.setAttribute("RedCharacters", "allowDragging", bool)
end

function clickBlueTimer()
    chessClock.call("Click_1")
end

function clickRedTimer()
    chessClock.call("Click_2")
end

function clickWhiteTimer()
    chessClock.call("Click_White")
end


function refreshTrays()
    characterBoxRed = getObjectFromGUID("1aed9b")
    modelBoxRed = getObjectFromGUID("70b737")
    infinityBoxRed = getObjectFromGUID("7f2962")
    tacticBoxRed = getObjectFromGUID("1ff905")
    extractBoxRed = getObjectFromGUID("7e1bed")
    secureBoxRed = getObjectFromGUID("3d92b9")

    characterBoxBlue = getObjectFromGUID("1468c0")
    modelBoxBlue = getObjectFromGUID("9502dd")
    infinityBoxBlue = getObjectFromGUID("28b7d1")
    tacticBoxBlue = getObjectFromGUID("da8584")
    extractBoxBlue = getObjectFromGUID("8cecc1")
    secureBoxBlue = getObjectFromGUID("9700ff")

    --grabs all the tables/variables needed from scripts/database
    database = getObjectFromGUID(Global.getVar("databaseGUID"))
    scripts = getObjectFromGUID(Global.getVar("scriptsGUID"))
    cardDatabase = database.getTable("cardDatabase")
    characterDatabase = database.getTable("characterDatabase")

    spawnCharactersCard()
    spawnOtherCards()
end

function spawnCharactersCard()
    characterBoxRed.reset()
    characterBoxBlue.reset()
    local pos = characterBoxRed.getPosition()
    local rot = characterBoxRed.getRotation()
    local pos2 = characterBoxBlue.getPosition()
    local rot2 = characterBoxBlue.getRotation()
    pos.y = pos.y + 1
    pos2.y = pos2.y + 1
    recSpawnCharacterCard(#characterDatabase, pos, rot, pos2, rot2)
end

function recSpawnCharacterCard(num, pos, rot, pos2, rot2)
    charCardNum = num
    if charCardNum > 5 then
        if characterDatabase[charCardNum].threat != nil and characterDatabase[charCardNum].released == true then
            if characterDatabase[charCardNum].threat < 10 then
                local healthy = ""
                local injured = ""

                if #characterDatabase[charCardNum].cCard.face < 50 then
                    healthy = characterDatabase[charCardNum].cCard.face[1]
                    injured = characterDatabase[charCardNum].cCard.back[1]
                else
                    healthy = characterDatabase[charCardNum].cCard.face
                    injured = characterDatabase[charCardNum].cCard.back
                end

                if characterDatabase[charCardNum].newCard then
                    setSize = 1.33
                elseif characterDatabase[charCardNum].daddy != nil then
                    setSize = 1.53
                else
                    setSize = 2
                end

                local card = spawnObject({
                    type              = "CardCustom",
                    position          = pos,
                    rotation          = rot,
                    scale             = {setSize,1,setSize},
                    --callback_function = callbackFunction(),
                    sound             = false,
                    snap_to_grid      = false,
                })

                card.setCustomObject({
                    face = healthy,
                    back = injured,
                    type = 1,
                })

                card.setName(characterDatabase[charCardNum].cName .. " Character Card")
                affil_string = "Affiliation:\n"
                for i, aff in pairs(characterDatabase[charCardNum].affiliation) do
                    affil_string = affil_string .. aff .. "\n"
                end
                card.setDescription(characterDatabase[charCardNum].ID .. "\n" .. findCP(characterDatabase[charCardNum].ID) .. findErrata(characterDatabase[charCardNum].errata) .. affil_string)
                card.sticky = false
                card.use_grid = false
                card.use_hands = false
                card.use_snap_points = true
                card.hide_when_face_down = false
                if characterDatabase[charCardNum].twoCards != nil then
                    newCard = card.clone({position = pos, sound = false})
                    newCard.setCustomObject({
                        face = characterDatabase[charCardNum].cTCard.face,
                        back = characterDatabase[charCardNum].cTCard.back,
                    })
                    newCardBlue = newCard.clone({position = pos2, rotation = rot2, sound = false})
                    characterBoxRed.putObject(newCard)
                    characterBoxBlue.putObject(newCardBlue)
                end
                cardBlue = card.clone({position = pos2, rotation = rot2, sound = false})
                characterBoxRed.putObject(card)
                characterBoxBlue.putObject(cardBlue)

            end
        end
    end
    if charCardNum > 5 then
        recSpawnCharacterCard(charCardNum - 1, pos, rot, pos2, rot2)
    end
end


function spawnOtherCards()
    infinityBoxRed.reset()
    tacticBoxRed.reset()
    extractBoxRed.reset()
    secureBoxRed.reset()

    infinityBoxBlue.reset()
    tacticBoxBlue.reset()
    extractBoxBlue.reset()
    secureBoxBlue.reset()

    recSpawnCard(#cardDatabase)
end

function recSpawnCard(num)
    cardNum = num
    if cardDatabase[cardNum].released == true then
        if #cardDatabase[cardNum].face < 50 then
            cFront = cardDatabase[cardNum].face[1]
            cBack = cardDatabase[cardNum].back[1]
        else
            cFront = cardDatabase[cardNum].face
            cBack = cardDatabase[cardNum].back
        end

        local pos = nil
        local rot = nil
        local pos2 = nil
        local rot2 = nil
        local luaScript = nil

        if cardDatabase[cardNum].type == "Tactic Card" then
            box = tacticBoxRed
            box2 = tacticBoxBlue
            cName = cardDatabase[cardNum].name .. " (" .. cardDatabase[cardNum].tags .. ")"
            cDescr = cardDatabase[cardNum].ID .. "\n" .. findCP(cardDatabase[cardNum].ID) .. findErrata(cardDatabase[cardNum].errata) .. cardDatabase[cardNum].description
            cHide = false
            cSnap = true
            luaScript = rosterLeft.getVar("tacticCard")
        elseif cardDatabase[cardNum].type == "Infinity Gem" then
            box = infinityBoxRed
            box2 = infinityBoxBlue
            cName = cardDatabase[cardNum].name
            cDescr = cardDatabase[cardNum].ID .. "\n" .. findCP(cardDatabase[cardNum].ID) .. findErrata(cardDatabase[cardNum].errata) .. cardDatabase[cardNum].description
            cHide = false
            cSnap = true
        elseif cardDatabase[cardNum].type == "Crisis Card" then
            if cardDatabase[cardNum].tags == "Extract" then
                box = extractBoxRed
                box2 = extractBoxBlue
                cName = cardDatabase[cardNum].tags .. " - " .. cardDatabase[cardNum].name
                cDescr = cardDatabase[cardNum].ID .. "\n" .. findCP(cardDatabase[cardNum].ID) .. findErrata(cardDatabase[cardNum].errata) .. cardDatabase[cardNum].description
            elseif cardDatabase[cardNum].tags == "Secure" then
                box = secureBoxRed
                box2 = secureBoxBlue
                cName = cardDatabase[cardNum].tags .. " - " .. cardDatabase[cardNum].name
                cDescr = cardDatabase[cardNum].ID .. "\n" .. findCP(cardDatabase[cardNum].ID) .. findErrata(cardDatabase[cardNum].errata) .. cardDatabase[cardNum].description
            end
            cHide = true
            cSnap = true
        end

        pos = box.getPosition()
        rot = box.getRotation()
        pos2 = box2.getPosition()
        rot2 = box2.getRotation()
        pos.y = pos.y + 1
        pos2.y = pos2.y + 1

        local card = spawnObject({
            type              = "CardCustom",
            position          = pos,
            rotation          = rot,
            scale             = {1.18,1,1.18},
            --callback_function = callbackFunction(),
            sound             = false,
            snap_to_grid      = false,
        })

        card.setCustomObject({
            face = cFront,
            back = cBack,
            type = 0,
        })

        if cardDatabase[cardNum].list != nil then
            if cardDatabase[cardNum].list == "Restricted" then
                card.setDecals({
                    {
                        name     = "Restricted",
                        url      = "http://cloud-3.steamusercontent.com/ugc/1669109279196445319/4A4DB3AEA2E1C83144BDBECDE14A44CD91BF04D2/",
                        position = {-0.5, 1, -0.6},
                        rotation = {90, 180, 0},
                        scale    = {1,1,1},
                    },
                })
            elseif cardDatabase[cardNum].list == "Banned" then
                card.setDecals({
                    {
                        name     = "Banned",
                        url      = "http://cloud-3.steamusercontent.com/ugc/1669109279196448111/6EDBF65E0CBEF097B70ACC0B31E5324D3F8CE056/",
                        position = {-0.5, 1, -0.6},
                        rotation = {90, 180, 0},
                        scale    = {1,1,1},
                    },
                })
            elseif cardDatabase[cardNum].list == "Rotated" then
                card.setDecals({
                    {
                        name     = "Rotated",
                        url      = "http://cloud-3.steamusercontent.com/ugc/1809908637915664319/E9C174363F10D55D7BBBF52D08F3F2EE059D4545/",
                        position = {-0.5, 1, -0.6},
                        rotation = {90, 180, 0},
                        scale    = {1,1,1},
                    },
                })
            end
        end

        if luaScript != nil then card.setLuaScript("myName = [[" .. cardDatabase[cardNum].name  .. "]]\n" .. luaScript) end

        card.setName(cName)
        card.setDescription(cDescr)
        card.sticky = false
        card.use_grid = false
        card.use_hands = false
        card.use_snap_points = cSnap
        card.hide_when_face_down = cHide

        local cardBlue = card.clone({position = pos2, rotation = rot2, sound = false})

        box.putObject(card)
        box2.putObject(cardBlue)
    end
    if cardNum > 1 then
        recSpawnCard(cardNum - 1)
    end

end

function findCP(ID)
    local idString = tostring(ID)
    if string.sub(idString, 1, 1) == "1" then
      return "Included in CPE " .. string.sub(idString, 3, 4) .. "\n"
    else
      return "Included in CP " .. string.sub(idString, 3, 4) .. "\n"
    end
end

function findErrata(var)
    if var then
        return "Updated with Errata\n"
    else
        return ""
    end
end

function spawnCharacters()
    modelBox.reset()
    local pos = modelBox.getPosition()
    local rot = modelBox.getRotation()
    pos.y = pos.y + 1
    recSpawnCharacter(#characterDatabase, pos, rot)
end

function recSpawnCharacter(num, pos, rot)
    charNum = num
    if characterDatabase[charNum].released == true then

        if pos.z < 0 then
            fColor = {220/255, 26/255, 23/255}
        else
            fColor = {31/255, 136/255, 255/255}
        end
        if charNum > 10 then
            if characterDatabase[charNum].threat != nil then
                if characterDatabase[charNum].cTFigA != nil then
                    if characterDatabase[charNum].cTModel != "" then

                        local model3D = spawnObject({
                            type              = "Custom_Assetbundle",
                            position          = pos,
                            rotation          = rot,
                            scale             = {1,1,1},
                            --callback_function = callbackFunction(),
                            sound             = false,
                            snap_to_grid      = false,
                        })

                        model3D.setCustomObject({
                            assetbundle = characterDatabase[charNum].cTModel,
                            type = 0,
                            material = 3,
                        })

                        model3D.setName(characterDatabase[charNum].cName)
                        model3D.sticky = false
                        model3D.use_grid = false
                        model3D.use_hands = false
                        model3D.use_snap_points = false
                        model3D.hide_when_face_down = false
                        model3D.setColorTint(fColor)
                        modelBox.putObject(model3D)
                    end
                    if characterDatabase[charNum].cTFigA != "" then
                        if characterDatabase[charNum].cBase == small then
                            mScale = {0.75, 0.75, 0.75}
                        elseif characterDatabase[charNum].cBase == medium then
                            mScale = {1.1, 1.1, 1.1}
                        elseif characterDatabase[charNum].cBase == large then
                            mScale = {1.4, 1.4, 1.4}
                        end
                        if characterDatabase[charNum].cTFigB != "" then
                            secondPic = characterDatabase[charNum].cTFigB
                        else
                            secondPic = characterDatabase[charNum].cTFigA
                        end
                        local model2D = spawnObject({
                            type              = "Figurine_Custom",
                            position          = pos,
                            rotation          = rot,
                            scale             = mScale,
                            sound             = false,
                            snap_to_grid      = false,
                        })

                        model2D.setCustomObject({
                            image = characterDatabase[charNum].cTFigA,
                            image_secondary = secondPic,
                        })



                        model2D.setName(characterDatabase[charNum].cName)
                        model2D.sticky = false
                        model2D.use_grid = false
                        model2D.use_hands = false
                        model2D.use_snap_points = false
                        model2D.hide_when_face_down = false
                        model2D.setColorTint(fColor)
                        modelBox.putObject(model2D)
                    end
                end
                if characterDatabase[charNum].cModel != "" then

                    local model3D = spawnObject({
                        type              = "Custom_Assetbundle",
                        position          = pos,
                        rotation          = rot,
                        scale             = {1,1,1},
                        --callback_function = callbackFunction(),
                        sound             = false,
                        snap_to_grid      = false,
                    })

                    model3D.setCustomObject({
                        assetbundle = characterDatabase[charNum].cModel,
                        type = 0,
                        material = 3,
                    })

                    model3D.setName(characterDatabase[charNum].cName)
                    model3D.sticky = false
                    model3D.use_grid = false
                    model3D.use_hands = false
                    model3D.use_snap_points = false
                    model3D.hide_when_face_down = false
                    model3D.setColorTint(fColor)
                    modelBox.putObject(model3D)
                end
                if characterDatabase[charNum].cFigA != "" then
                    if characterDatabase[charNum].cBase == small then
                        mScale = {0.75, 0.75, 0.75}
                    elseif characterDatabase[charNum].cBase == medium then
                        mScale = {1.1, 1.1, 1.1}
                    elseif characterDatabase[charNum].cBase == large then
                        mScale = {1.4, 1.4, 1.4}
                    end
                    if characterDatabase[charNum].cFigB != "" then
                        secondPic = characterDatabase[charNum].cFigB
                    else
                        secondPic = characterDatabase[charNum].cFigA
                    end
                    local model2D = spawnObject({
                        type              = "Figurine_Custom",
                        position          = pos,
                        rotation          = rot,
                        scale             = mScale,
                        sound             = false,
                        snap_to_grid      = false,
                    })

                    model2D.setCustomObject({
                        image = characterDatabase[charNum].cFigA,
                        image_secondary = secondPic,
                    })



                    model2D.setName(characterDatabase[charNum].cName)
                    model2D.sticky = false
                    model2D.use_grid = false
                    model2D.use_hands = false
                    model2D.use_snap_points = false
                    model2D.hide_when_face_down = false
                    model2D.setColorTint(fColor)
                    modelBox.putObject(model2D)
                end
            end

        end
    end
    if charNum > 5 then
        Wait.frames(function() recSpawnCharacter(charNum - 1, pos, rot) end, 5)
    end

end

function onChat(message)
    if message == "SpawnCharacters" then
        log("Loading Characters...")
        refreshTrays()
    end
end