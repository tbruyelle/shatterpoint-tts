function onScriptingButtonDown(index, color)
    if index == 1 then        
        Player["White"].lookAt({
            position = {x=-32,y=0,z=-32},
            pitch    = 25,
            yaw      = 0,
            distance = 1,
        })
        Player["White"].setCameraMode("TopDown")
    elseif index==2 then
        Player["White"].setCameraMode("ThirdPerson")
        Player["White"].lookAt({
            position = {x=0,y=15,z=-35},
            pitch    = 45,
            yaw      = 0,
            distance = 0,
        })
        --local paraphs = getObjectFromGUID("f94a98")
        --paraphs.Book.setPage(1, false)
    end
end
