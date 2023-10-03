-- Define the bag and the location to place the object
local bagGUID = "a343d0"

function placeRandomObject()
    local bag = getObjectFromGUID(bagGUID)

    -- Check if the bag exists
    if bag ~= nil then
        local objectsInBag = bag.getObjects()
        
        -- Check if the bag contains any objects
        if #objectsInBag > 0 then
            -- Select a random object from the bag
            local randomIndex = math.random(1, #objectsInBag)
            local randomObject = objectsInBag[randomIndex]
            
            -- Remove the selected object from the bag
            bag.takeObject({
                index = randomIndex,
                position = {-44.87, 1.24, 9.39},
                rotation = {0, 0, 0}, -- You can change the rotation as needed
            })
            
            print("Placed random object on the board.")
        else
            print("The bag is empty.")
        end
    else
        print("Bag not found. Make sure you have provided the correct bag GUID.")
    end
end