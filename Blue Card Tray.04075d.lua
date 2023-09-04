function onLoad()
	createButtons()
	self.interactable = false

	-- Set Variables
	databaseGUID = "b657bc"
	database = getObjectFromGUID(databaseGUID)
    characterDatabase = database.getTable("characterDatabase")
	
    squad1ZoneGUID = "c649c3"
	squad1Zone = getObjectFromGUID(squad1ZoneGUID)
	squad2ZoneGUID = "e464fa"
	squad2Zone = getObjectFromGUID(squad2ZoneGUID)
	trayZoneGUID = "0dce2c"
	trayZone = getObjectFromGUID(trayZoneGUID)
	
	strike_team = {}
	local squad1 = {
		primary = nil,
		secondary = nil,
		support = nil
	}

	local squad2 = {
		primary = nil,
		secondary = nil,
		support = nil
	}

	strike_team[1] = squad1
	strike_team[2] = squad2
	
    owner = "blue"
	--blue = { r = 0.090196, g = 0.101961, b = 0.862745 }
	--red = { r = 0.862745, g = 0.101961, b = 0.090196}
    ownerTint = { r = 0.090196, g = 0.101961, b = 0.862745 }
	
	traySnapPoints = self.getSnapPoints()
end

function createButtons() 
    self.createInput({
        input_function = "listInput",
        function_owner = self,
        label          = "Paste pointbreak/tabletopAdmiral export here",
        position       = {0, 0.15, 1.07},
        rotation       = {0,0,0},
        --scale          = {0.75,1,1},
        width          = 500,
        height         = 50,
        font_size      = 20,
        validation     = 1,
        tab            = 1,
        alignment      = 3,
    })

    self.createButton({
        click_function = "importStrikeTeam",
        function_owner = self,
        label = "Import",
        position = {0, 0.15, 1.2},
        rotation = {0, 0, 0},
        width = 75,
        height = 75,
        font_size = 20,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Import list build code"
    })
	
end

--[[function printStrikeTeam()
    for i, squad in ipairs(strike_team) do
        print("Squad " .. i .. ":")
        if squad.primary then
            print("Primary: " .. squad.primary.cName)
        else
            print("Primary: nil")
        end
        if squad.secondary then
            print("Secondary: " .. squad.secondary.cName)
        else
            print("Secondary: nil")
        end
        if squad.support then
            print("Support: " .. squad.support.cName)
        else
            print("Support: nil")
        end
        print("----------------------")
    end
end

function spawnScriptingZoneOnSelf(obj)
    local bounds = obj.getBounds()
    local center = bounds.center
    local size = bounds.size

    -- Spawn a scripting zone for squad 1 character cards
    local squad1ZoneParams = {
        type = 'ScriptingTrigger',
        position = Vector(center.x + size.x/4, center.y, center.z),
        scale = Vector(size.x/2, size.y, size.z),
        snap_to_grid = false,
    }

    squad1Zone = spawnObject(squad1ZoneParams)
    squad1ZoneGUID = squad1Zone.getGUID()
    squad1Zone.setTags({'Squad1', 'Character Card'})
	
	-- Spawn a scripting zone for squad 2 character cards
    local squad2ZoneParams = {
        type = 'ScriptingTrigger',
        position = Vector(center.x - size.x/4, center.y, center.z),
        scale = Vector(size.x/2, size.y, size.z),
        snap_to_grid = false,
    }

    squad2Zone = spawnObject(squad2ZoneParams)
    squad2ZoneGUID = squad2Zone.getGUID()
    squad2Zone.setTags({'Squad2', 'Character Card'})
	
	--Spawn a scripting zone for the entire card tray
	local trayZoneParams = {
        type = 'ScriptingTrigger',
        position = center,
        scale = Vector(size.x, size.y, size.z),
        snap_to_grid = false,
    }

    trayZone = spawnObject(trayZoneParams)
    trayZoneGUID = trayZone.getGUID()
end

function destroyScriptingZoneOnSelf(obj)
    local selfGUID = self.getGUID() -- Assuming this function is called within the object's script
    local allObjects = getAllObjects()

    for _, object in ipairs(allObjects) do
        if object.type == "Scripting" and object.getGUID() ~= "3b5d33" then
            object.destroy()
        end
    end
end

function getSourceDeck(object)
	local allObjs = getAllObjects()
	for _, obj in ipairs (allObjs) do
		objPos = obj.getPosition()
		if objPos.x == object.pick_up_position.x and objPos.z == object.pick_up_position.z then
			local sourceDeckGUID = obj.getGUID()
			local sourceDeck = getObjectFromGUID(sourceDeckGUID)
			
			return sourceDeck
		end
	end
end--]]

function getAllNames(object)
    local cardName = object.getName()
    local unitName = string.gsub(cardName, " Card$", "")
    local orderName = unitName .. " Order"
    local stanceName = unitName .. " Stance"

    return {
        cardName = cardName, 
        unitName = unitName, 
        orderName = orderName, 
        stanceName = stanceName
    }
end

function onObjectEnterScriptingZone(zone, object)
    if (zone == squad1Zone or zone == squad2Zone) and (object.tag == 'Card') then
        local deckGUID = "b272d8"
		local deck = getObjectFromGUID(deckGUID)
        local name = getAllNames(object)
        local unit = findUnit(characterDatabase, "cName", name.unitName)
		
		-- Find the existing card object within the scripting zone
		local existingCard = nil
		local zoneObjects = zone.getObjects()
		for _, obj in ipairs(zoneObjects) do
			if obj.tag == 'Card' then
				local existingCardName = obj.getName()
				local existingUnitName = string.gsub(existingCardName, " Card$", "")
				local existingUnit = findUnit(characterDatabase, "cName", existingUnitName)
				if existingUnit and existingUnitName ~= unit.cName and existingUnit.cType == unit.cType then
					existingCard = obj
					break
				end
			end
		end
		
		if existingCard then
			cleanUpUnit(zone, existingCard)
		
			-- Move the existing card higher along the z-axis
			local existingPosition = existingCard.getPosition()
			existingCard.setPosition({existingPosition.x, existingPosition.y, existingPosition.z - 7})
		end
		
		-- Add Tags to Card
        object.addTag(owner)
		if zone == squad1Zone then
			object.addTag('Squad1')
		elseif zone == squad2Zone then
			object.addTag('Squad2')
		else
			print("Object didn't enter squad1Zone or squad2Zone")
		end

		snapToSlot(zone, object)
		object.locked = true
		
		-- Clone the deck & populate all of the cards and models
		local clonedDeck = deck.clone({0, 0, 0})
        
		addUnitIntoStrikeTeam(unit, zone)
        getStanceCard(object, name.stanceName, deck, clonedDeck)
		getOrderCards(object, name.orderName, deck, clonedDeck)
		getUnitDurabilityTokens(unit, zone, object)
		getUnitModels(unit, object, deck, clonedDeck)
		
		clonedDeck.destruct()
    end
end

function onObjectLeaveScriptingZone(zone, object)
    if (zone == squad1Zone or zone == squad2Zone) and (object.tag == 'Card') then
		cleanUpUnit(zone, object)
    end
end

function cleanUpUnit(zone, card)
    card.removeTag('Squad1')
    card.removeTag('Squad2')

    local name = getAllNames(card)
    local unit = findUnit(characterDatabase, "cName", name.unitName)
    local ownerObjects = getObjectsWithTag(owner)

    clearUnitDurability(unit, name.unitName, zone)
    clearUnitFromTray(name.stanceName, ownerObjects)
    removeUnitFromStrikeTeam(unit, name.unitName)
    removeUnitModelsFromTable(name.unitName, ownerObjects)
    removeUnitOrderFromTable(name.orderName, ownerObjects)
end

function snapToSlot(zone, object)
    local snapPoints = self.getSnapPoints()
    for _, snap in ipairs(snapPoints) do
        local snapTags = snap.tags
        if object.hasTag(snapTags[1]) and object.hasTag(snapTags[2]) then
            local snapWorldPos = self.positionToWorld(snap.position)
            object.setPosition(snapWorldPos)
            object.setRotation(snap.rotation + Vector(0, 0, 0))
            break
        end
    end
end

function rotateAndRepositionObject(object, position, rotation, xOffset, yOffset, zOffset)
    local rotationY = math.rad(rotation.y) -- Convert rotation to radians

    -- Calculate the new offsets based on rotation
    local newXOffset = xOffset * math.cos(rotationY) + zOffset * math.sin(rotationY)
    local newZOffset = -xOffset * math.sin(rotationY) + zOffset * math.cos(rotationY)

    -- Update the position with new offsets
    local newPosition = {
        position[1] + newXOffset,
        position[2] + yOffset,
        position[3] + newZOffset
    }

    -- Move and rotate the object if it has a setPosition method
    if object.setPosition then
        object.setPosition(newPosition)
        object.setRotation({0, rotation.y, 0})
    else
        print("Cannot reposition object: setPosition method not found.")
    end
end

function getUnitCard(unit, unitSquad)
    local deckGUID = "b272d8"
    local deck = getObjectFromGUID(deckGUID)
    local clonedCard = nil
    local cardPositions = {
        { squadIndex = 1, cardType = "primary", position = { -16.5, 0.2, 3 } }, -- Position for strike_team[1] primary
        { squadIndex = 1, cardType = "secondary", position = { -10, 0.2, 3 } }, -- Position for strike_team[1] secondary
        { squadIndex = 1, cardType = "support", position = { -5, 0.2, 3 } }, -- Position for strike_team[1] support
        { squadIndex = 2, cardType = "primary", position = { 5, 0.2, 3 } }, -- Position for strike_team[2] primary
        { squadIndex = 2, cardType = "secondary", position = { 10, 0.2, 3 } }, -- Position for strike_team[2] secondary
        { squadIndex = 2, cardType = "support", position = { 15, 0.2, 3 } } -- Position for strike_team[2] support
    }

    -- Find the card position based on squadIndex and cardType
    local position = nil

    for _, cardPos in ipairs(cardPositions) do
        if cardPos.squadIndex == unitSquad and cardPos.cardType == unit.cType then
            position = cardPos.position
            break
        end
    end

    if position then
        local cardName = unit.cName .. " Character Card"
        local foundCard = nil

        -- Iterate through each card in the deck
        for _, deckCard in ipairs(deck.getObjects()) do
            if deckCard.name == cardName then
                foundCard = deckCard
                break
            end
        end

        if not foundCard then
            cardName = unit.cName .. " Card"
            for _, deckCard in ipairs(deck.getObjects()) do
                if deckCard.name == cardName then
                    foundCard = deckCard
                    break
                end
            end
        end

        if foundCard then
            local cardGUID = foundCard.guid

            -- Clone the deck
            local clonedDeck = deck.clone({ position = position, rotation = { 0, 180, 0 } })

            local scriptPosition = self.getPosition()

            -- Take the card from the cloned deck
            local cloneParams = {
                position = {
                    x = scriptPosition[1] + position[1],
                    y = scriptPosition[2] + position[2],
                    z = scriptPosition[3] + position[3]
                },
                rotation = { 0, 180, 0 },
                guid = cardGUID,
                smooth = false
            }
            local clonedCard = clonedDeck.takeObject(cloneParams)

            clonedDeck.destruct()
        else
            print("Card not found: " .. cardName)
        end
    else
        print("Card position not found for squadIndex " .. unitSquad .. " and cardType " .. unit.cType)
    end

    return clonedCards
end

function getUnitModels(unit, object, deck, clonedDeck)
	local size = object.getBounds().size
    local unitModels = {}
    for _, deckObject in ipairs(deck.getObjects()) do
        if deckObject.name == unit.cName then
            table.insert(unitModels, deckObject)
        end
    end

    for index, model in ipairs(unitModels) do
        local modelOffset = (index - 1) * 2
        local clonedModel = clonedDeck.takeObject({
            position = {0, 0, 0},
            rotation = {0, 0, 0},
            guid = model.guid,
            smooth = false
        })
		
        local xOffset = size.x/2 - 1 - modelOffset
        local yOffset = 0
        local zOffset = -5.5
        rotateAndRepositionObject(clonedModel, object.getPosition(), object.getRotation(), xOffset, yOffset, zOffset)

        clonedModel.addTag(owner)
		clonedModel.setColorTint(ownerTint)	
    end
end

function getStanceCard(object, stanceName, deck, clonedDeck)
	local foundCard = nil
	for _, deckCard in ipairs(deck.getObjects()) do
		if deckCard.name == stanceName then
			foundCard = deckCard
			break
		end
	end

    if foundCard then
        local cardGUID = foundCard.guid

        -- Take the card from the cloned deck
        local stanceCard = clonedDeck.takeObject({
            position = {0, 0, 0},
            rotation = {0, 0, 0},
            guid = cardGUID,
            smooth = false
        })

        -- Calculate the new position and rotation based on object's properties
        local xOffset = 0
        local yOffset = 0
        local zOffset = 4.5
        rotateAndRepositionObject(stanceCard, object.getPosition(), object.getRotation(), xOffset, yOffset, zOffset)
        stanceCard.addTag(owner)
    else
        print("Card not found: " .. stanceName)
    end
end

function getOrderCards(object, orderName, deck, clonedDeck)
	local foundCard = nil
	for _, deckCard in ipairs(deck.getObjects()) do
		if deckCard.name == orderName then
			foundCard = deckCard
			break
		end
	end

	if foundCard then
		local cardGUID = foundCard.guid

		-- Take the card from the cloned deck
		local orderCard = clonedDeck.takeObject({
			position = {0, 0, 0},
			rotation = {0, 0, 0},
			guid = cardGUID,
			smooth = false
		})	
		
		-- Calculate the new position and rotation based on object's properties
		local xOffset = 0
        local yOffset = 0.2
        local zOffset = 6
		
		rotateAndRepositionObject(orderCard, object.getPosition(), object.getRotation(), xOffset, yOffset, zOffset)
        orderCard.addTag(owner)
	else
		print("Card not found: " .. orderName)
	end
end

function getUnitDurabilityTokens(unit, zone, object)
	local unitDurability = unit.cDurability
	local durabilityBagGUID = "b8f377"
	local durabilityBag = getObjectFromGUID(durabilityBagGUID)

	-- Calculate the offset for each durability token
	local tokenOffset = 1 -- Adjust this value to set the spacing between tokens
	local objectPosition = object.getPosition()
	local objectSize = object.getBounds().size
	local unitType = unit.cType
	
	-- Iterate through the number of unitDurability
	for i = 1, unitDurability do
		local durabilityToken = durabilityBag.takeObject({
			position = {0, 0, 0},
			rotation = {0, 0, 0},
			smooth = false,
		})
		
		if zone == squad1Zone then
			durabilityToken.setTags({unitType, 'Squad1'})
		elseif zone == squad2Zone then
			durabilityToken.setTags({unitType, 'Squad2'})
		else
			print("fail")
		end
	
		-- Calculate the new position and rotation based on object's properties
		local xOffset = - (objectSize.x/2) - 0.5
        local yOffset = 0
        local zOffset = (objectSize.z/2 + 0.5) - (i * tokenOffset)
		
		rotateAndRepositionObject(durabilityToken, object.getPosition(), object.getRotation(), xOffset, yOffset, zOffset)
        durabilityToken.locked = true
	end
end

function removeUnitOrderFromTable(orderName, ownerObjects)
	for _, obj in ipairs(ownerObjects) do
		if obj.getName() == orderName then
			obj.destruct()
		end
	end
end

function removeUnitModelsFromTable(unitName, ownerObjects)
    for _, obj in ipairs(ownerObjects) do
		if obj.getName() == unitName and hasPlayMatZone(obj) ==  false then
			obj.destruct()
		end
    end
end

function clearUnitDurability(unit, unitName, zone)
	local zoneObjects = zone.getObjects()
	for _, obj in ipairs(zoneObjects) do
		if obj.getName() == 'Wound/Injured' and obj.hasTag(unit.cType) then
			obj.destruct()
		end
	end
end

function clearUnitFromTray(stanceName, ownerObjects)
    local updatedUnitStance = stanceName:gsub("-", "%%-")
    for _, obj in ipairs(ownerObjects) do
        local cardName = obj.getName()
        if string.match(cardName, updatedUnitStance) then
            obj.destruct()
        end
    end
end

function hasPlayMatZone(object)
	local modelZones = object.getZones()
	for _, modelZone in ipairs(modelZones) do
		if modelZone.getGUID() == "3b5d33" then
			return true
		end
	end
	return false
end

function listInput(obj, color, input, stillEditing)
    if not stillEditing then
        inputUrl = input
    end
end

function importStrikeTeam()
    if inputUrl ~= "" then
		strike_team = {}

		if string.find(inputUrl, "spt%[") == 1 then
			print("Url is from pointbreak")
			-- Parse pointbreak format
			local pb_ids = inputUrl:match("spt%[(.-)%]")
			if pb_ids then
				local pb_id_list = {}
				local hierarchyOrder = {} -- Store the hierarchy order for each unit type
				hierarchyOrder["primary"] = 2
				hierarchyOrder["secondary"] = 1
				hierarchyOrder["support"] = 0

				for pb_id in pb_ids:gmatch("(%d+)") do
					table.insert(pb_id_list, pb_id)
				end

				-- Assign units to squads
				local squad1 = {}
				local squad2 = {}
				local unitSquad = 1
				local previousOrder = 3 -- Default previous order to a lower value

				for _, pb_id in ipairs(pb_id_list) do
					local unit = findUnit(characterDatabase, "cPbid", pb_id)
					if unit then
						local unitOrder = hierarchyOrder[unit.cType]
						if previousOrder <= unitOrder then
							-- Start of Squad 2
							unitSquad = 2
						end
						getUnitCard(unit, unitSquad)
						previousOrder = unitOrder
					else
						print("Unit not found for pbreak_id: " .. pb_id)
					end
				end
			end
		elseif string.find(inputUrl, "https://tabletopadmiral.com/shatterpoint/listbuilder/") == 1 then
			-- Parse tabletopAdmiral format
			local index = 1  -- Counter to keep track of the IDs
			for id in inputUrl:gmatch("%d+") do
				local unit = findUnit(characterDatabase, "cTtaid", id)
				if unit then
					if index <= 3 then
						local unitSquad = 1
						getUnitCard(unit, unitSquad)
					elseif index <= 6 then
						local unitSquad = 2
						getUnitCard(unit, unitSquad)
					else
						print("Invalid number of units specified.")
						break
					end
					index = index + 1
				else
					print("Unit not found for tta_id: " .. id)
				end
			end
		end	
		self.editInput({label = "Paste pointbreak/tabletopAdmiral export here"})
    end
end

function addUnitIntoStrikeTeam(unit, zone)
    if unit then
        local squad = nil
        local squadNumber = nil

        if zone == squad1Zone then
            squadNumber = 1
            squad = strike_team[1]
        elseif zone == squad2Zone then
            squadNumber = 2
            squad = strike_team[2]
        else
            print("Invalid zone specified.")
            return
        end

        if not squad then
            squad = {
                primary = nil,
                secondary = nil,
                support = nil
            }
            strike_team[squadNumber] = squad
        end

        if unit.cType == "primary" then
            squad.primary = unit
			updateForceTokens()
        elseif unit.cType == "secondary" then
            squad.secondary = unit
        elseif unit.cType == "support" then
            squad.support = unit
        else
            print("Invalid unit type specified.")
        end
    end
end

function removeUnitFromStrikeTeam(unit, unitName)
    for i, squad in ipairs(strike_team) do
        if squad.primary == unit then
			squad.primary = nil
			updateForceTokens()
            return
        elseif squad.secondary == unit then
			squad.secondary = nil
            return
        elseif squad.support == unit then
            squad.support = nil
            return
        end
    end
end

function findUnit(characterDatabase, searchCriterion, value)
    for _, unit in ipairs(characterDatabase) do
        if unit[searchCriterion] == value then
            return unit
        end
    end
    return nil
end

function updateForceTokens()
    local forcePool = 0
    local forceBagGUID = "44a83a"
	local bounds = self.getBounds()
    local center = bounds.center
    local size = bounds.size
    local zOffset = 1.1
    local objectsInZone = trayZone.getObjects()
    
    for _, obj in ipairs(objectsInZone) do
        if obj.getName() == "Force" then
            obj.destruct()
        end
    end
    
    -- Calculate the force pool based on the strike_team
    for _, squad in ipairs(strike_team) do
        if squad.primary and squad.primary.cForce then
            forcePool = forcePool + squad.primary.cForce
        end
    end
    
    local forceBag = getObjectFromGUID(forceBagGUID)
    local numTokens = forcePool
    
    -- Place the new force tokens
    for i = 1, numTokens do
        local tokenPosition = { center.x, center.y + size.y/2, (center.z - size.z/2) + (i) * zOffset }
        local token = forceBag.takeObject({ position = tokenPosition, rotation = {0, 0, 0}, smooth = false })
        token.locked = true
    end
end

--[[function checkSquadsValid(strike_team)
    local uniqueNames = {}

    for squadIndex, squad in ipairs(strike_team) do
        local primary = squad.primary
        local secondary = squad.secondary
        local support = squad.support

        -- Check era consistency within the squad
        local primaryEras = type(primary.cEra) == "table" and primary.cEra or { primary.cEra }
        if secondary then
            local secondaryEras = type(secondary.cEra) == "table" and secondary.cEra or { secondary.cEra }
            local sharedEra = false
            for _, primaryEra in ipairs(primaryEras) do
                for _, secondaryEra in ipairs(secondaryEras) do
                    if primaryEra == secondaryEra then
                        sharedEra = true
                        break
                    end
                end
                if sharedEra then
                    break
                end
            end
            if not sharedEra then
                print("Secondary unit in squad " .. squadIndex .. " has a different era")
                return false
            end
        end

        if support then
            local supportEras = type(support.cEra) == "table" and support.cEra or { support.cEra }
            local sharedEra = false
            for _, primaryEra in ipairs(primaryEras) do
                for _, supportEra in ipairs(supportEras) do
                    if primaryEra == supportEra then
                        sharedEra = true
                        break
                    end
                end
                if sharedEra then
                    break
                end
            end
            if not sharedEra then
                print("Support unit in squad " .. squadIndex .. " has a different era")
                return false
            end
        end

        -- Check points validity within the squad
        local squadPoints = primary.cSquadPoints
        local combinedPoints = (secondary and secondary.cPointCost or 0) + (support and support.cPointCost or 0)
        if combinedPoints > squadPoints then
            print("Combined point cost of secondary and support units exceeds squad points in squad " .. squadIndex)
            return false
        end

        -- Check for duplicate unique units within the strike_team
        local uniqueUnitName = primary.cUnique
        if uniqueNames[uniqueUnitName] then
            print("Duplicate unique unit \"" .. uniqueUnitName .. "\" found in squad " .. squadIndex)
            return false
        else
            uniqueNames[uniqueUnitName] = true
        end

        if secondary then
            uniqueUnitName = secondary.cUnique
            if uniqueNames[uniqueUnitName] then
                print("Duplicate unique unit \"" .. uniqueUnitName .. "\" found in squad " .. squadIndex)
                return false
            else
                uniqueNames[uniqueUnitName] = true
            end
        end

        if support then
            uniqueUnitName = support.cUnique
            if uniqueNames[uniqueUnitName] then
                print("Duplicate unique unit \"" .. uniqueUnitName .. "\" found in squad " .. squadIndex)
                return false
            else
                uniqueNames[uniqueUnitName] = true
            end
        end
    end

    return true
end--]]