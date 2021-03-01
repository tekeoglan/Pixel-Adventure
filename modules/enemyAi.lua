local enemyAi = {points = {}, 
                 pos = vmath.vector3(), 
                 direction = vmath.vector3(),
                 moving = nil,
                 checkPoint = nil,
                 speed = nil,
                 destination = vmath.vector3(), 
                 animation = ""}

local function isPropExist(property)
    return pcall(function(property)
    go.get("#", property)
end,property)
end

local function getPoints()
    local counter = 1
    while true do
        local name = "point" .. counter
        if isPropExist(name) then
            enemyAi.points[counter] = go.get("#",name)
            counter = counter + 1
        else
            break
        end
    end
end

local function Animate()
   if enemyAi.direction ~= 0 then
        if enemyAi.direction.x < 0 then
            sprite.set_hflip("#sprite", false) 
        else
            sprite.set_hflip("#sprite", true)
        end
        return "chicken_run"
    else
        return "chicken_idle"
    end
end

local function playAnimation()
    if Animate() ~= enemyAi.animation then
        enemyAi.animation = Animate()
        local  id = hash(Animate())
        msg.post("#sprite", "play_animation", {id = id})
    end
end

local function pathFinding(dt)
    if not enemyAi.moving then
        return
    end

    enemyAi.pos = go.get_position()
    local position = enemyAi.destination - enemyAi.pos
    if vmath.length(position) > 1 then
        enemyAi.direction = vmath.normalize(position)
        local move =  enemyAi.pos + enemyAi.direction*enemyAi.speed*dt 
        go.set_position(move)
    else
        print("reached the checkpoint")
        enemyAi.direction = vmath.vector3(0,0,enemyAi.pos.z)
        if enemyAi.points[enemyAi.checkPoint + 1] ~= nil then
            print("incremented the checkpoint")
            enemyAi.checkPoint = enemyAi.checkPoint + 1
        else
            print("checkpoint not exist")
            enemyAi.checkPoint = enemyAi.checkPoint - 1
        end
        enemyAi.destination = enemyAi.points[enemyAi.checkPoint]
    end
end

function enemyAi.init()
    enemyAi.pos = go.get_position()
    enemyAi.speed = go.get("#", "speed")
    enemyAi.checkPoint = 1
    enemyAi.destination = go.get("#", "point1")
    enemyAi.moving = true
    enemyAi.animation = "chicken_idle"
    getPoints()
end

function enemyAi.update(dt)
    pathFinding(dt)
    playAnimation()
end

function enemyAi.onMessage(self,message_id,message,sender)
   if message_id == hash("trigger_response") then 
        if message.other_group == hash("player") then
            enemyAi.moving = false
            msg.post("#sprite", "play_animation", {id = hash("chicken_hit")})
        end
   end
   if message_id == hash("animation_done") then
        go.delete()
    end
end

return enemyAi