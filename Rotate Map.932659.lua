function rotatemap()
    -- Define the angle by which you want to rotate the playzone
    local rotationAngle = 180

    -- Find the playzone object in your game
    local playzone = getObjectFromGUID("3b5d33")

    -- Check if the playzone object exists
    if playzone then
        -- Store the positions and rotations of all objects in the playzone
        local objectData = {}
        local objectsInPlayzone = playzone.getObjects()

        for _, object in pairs(objectsInPlayzone) do
            local data = {
                object = object,
                position = object.getPosition(),
                rotation = object.getRotation()
            }
            table.insert(objectData, data)
        end

        -- Rotate the playzone by the specified angle
        playzone.setRotationSmooth({0, rotationAngle, 0}, false, true)

        -- Calculate the inverse rotation for objects to move them with the playzone
        local inverseRotation = {0, -rotationAngle, 0}

        -- Apply the inverse rotation to all objects and calculate new positions
        for _, data in pairs(objectData) do
            local object = data.object
            local position = data.position
            local rotation = data.rotation

            -- Calculate the new position based on the inverse rotation
            local newPosition = {
                position[1] * math.cos(math.rad(rotationAngle)) - position[3] * math.sin(math.rad(rotationAngle)),
                position[2],
                position[1] * math.sin(math.rad(rotationAngle)) + position[3] * math.cos(math.rad(rotationAngle))
            }

            -- Apply the inverse rotation to the object's rotation
            local newRotation = {
                rotation[1] + inverseRotation[1],
                rotation[2] + inverseRotation[2],
                rotation[3] + inverseRotation[3]
            }

            -- Set the new position and rotation for the object
            object.setRotationSmooth(newRotation, false, true)
            object.setPosition(newPosition)
        end

        print("Playzone and all objects in it moved and rotated by 180 degrees to create a mirrored image.")
    else
        print("Playzone object not found. Make sure to replace 'YourPlayzoneGUIDHere' with the actual GUID of your playzone.")
    end
end