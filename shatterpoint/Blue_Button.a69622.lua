function onLoad(save_state)
    createButtons()
    initStruggleTracker()
end

function initStruggleTracker()
    struggleTracker = getObjectFromGUID("42c0e4")
    pointList = struggleTracker.getSnapPoints() -- get the snap points
end

function createButtons()
    self.createButton({
        click_function = "spawnBlueMomentum",
        function_owner = self,
        label = "Add Momentum",
        position = {0, 0, 0},
        rotation = {0, 270, 0},
        width = 2400,
        height = 800,
        font_size = 300,
        color = {0, 0, 0, 1},
        font_color = {1, 1, 1, 1},
        tooltip = "Adds a Momentum"
    })
end

function spawnBlueMomentum()
	checkBlueSnapPoints() -- check for tokens
	if spawnPosition != nil then
		spawnMomentumToken(spawnPosition)
	end
end

function checkBlueSnapPoints()
	spawnPosition = nil
	size = 16
    allMomTokens = getObjectsWithTag("tknMomentum")
    existingTokens = {0, 0, 0, 0, 0, 0, 0, 0}
    for i = size, 9, -1 do -- cycle through snap points on blue side
        for j, object in ipairs(allMomTokens) do -- cycle through all momentum tokens
            if object.getPosition()[1] >= (struggleTracker.positionToWorld(pointList[i].position)[1] - 0.002) and object.getPosition()[1] <= (struggleTracker.positionToWorld(pointList[i].position)[1] + 0.002) and object.getPosition()[3] >= (struggleTracker.positionToWorld(pointList[i].position)[3] - 0.002) and object.getPosition()[3] <=  (struggleTracker.positionToWorld(pointList[i].position)[3] + 0.002) then
                    existingTokens[size - i + 1] = object.getGUID()
            end
        end
    end
    for k,v in pairs(existingTokens) do
        if v == 0 then
			spawnPosition = size - k + 1
            break
        end
    end
end

function spawnMomentumToken(spawnPosition)
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
		position = struggleTracker.positionToWorld(pointList[spawnPosition].position)
	})
end