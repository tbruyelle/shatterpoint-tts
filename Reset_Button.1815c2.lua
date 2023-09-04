function onLoad(save_state)
    createButtons()
	struggleTracker = getObjectFromGUID("42c0e4")
    pointList = struggleTracker.getSnapPoints()
end

function createButtons()
    self.createButton({
        click_function = "resetStruggleTracker",
        function_owner = self,
        label = "Reset",
        position = {0, 0, 0},
        rotation = {0, 270, 0},
        width = 1000,
        height = 800,
        font_size = 300,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Resets the Struggle Tracker"
    })
end

function resetStruggleTracker()
	clearTokens()
	spawnTokens()
end

function spawnTokens()
	local start_positions = {1,16}
	for k,v in pairs(start_positions) do
        spawnMomentumToken(v)
    end
	spawnStruggleToken()
end

function clearTokens()
	local tagsToDestroy = {"tknMomentum", "tknStruggle"}
	existingTokens = {}
	for k,v in pairs(tagsToDestroy) do
		allTokens = getObjectsWithTag(v)
		for i = 1, 17 do -- cycle through snap points on both sides
			for j, object in ipairs(allTokens) do -- cycle through all struggle & momentum tokens
				if object.getPosition()[1] >= (struggleTracker.positionToWorld(pointList[i].position)[1] - 0.002) and object.getPosition()[1] <= (struggleTracker.positionToWorld(pointList[i].position)[1] + 0.002) and object.getPosition()[3] >= (struggleTracker.positionToWorld(pointList[i].position)[3] - 0.002) and object.getPosition()[3] <=  (struggleTracker.positionToWorld(pointList[i].position)[3] + 0.002) then
						existingTokens = object.getGUID()
						getObjectFromGUID(existingTokens).destruct()
				end
			end
		end
	end   
end

function spawnMomentumToken(moPos)
	spawnObjectData({
		data = {
			Name = "BlockSquare",
			Transform = {
				rotX = 0.0,
				rotY = 0.0,
				rotZ = 0.0,
				scaleX = 0.575,
				scaleY = 0.575,
				scaleZ = 0.575
			},
			Nickname = "Momentum Token",
			Description = "",
			GMNotes = "",
			AltLookAngle = {
				x = 0.0,
				y = 0.0,
				z = 0.0
			},
			ColorDiffuse = {
				r = 0.0,
				g = 0.0,
				b = 0.0
			},
			Tags = {
				"snapMomentum",
				"tknMomentum"
			},
		},
		position = struggleTracker.positionToWorld(pointList[moPos].position)
	})
end

function spawnStruggleToken()
	spawnObjectData({
		data = {
			Name = "BlockSquare",
			Transform = {
				rotX = 0.0,
				rotY = 0.0,
				rotZ = 0.0,
				scaleX = 0.575,
				scaleY = 0.575,
				scaleZ = 0.575
			},
			Nickname = "Struggle Token",
			Description = "",
			GMNotes = "",
			AltLookAngle = {
				x = 0.0,
				y = 0.0,
				z = 0.0
			},
			ColorDiffuse = {
				r = 0.705575049,
				g = 0.606007755,
				b = 0.606007755
			},
			Tags = {
				"snapStruggle",
				"tknStruggle"
			},
		},
		position = struggleTracker.positionToWorld(pointList[17].position)
	})
end