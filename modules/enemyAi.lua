local enemyAi = {}

local function isPropExist(property)
    return pcall(function(property)
    go.get("#", property)
end,property)
end

local function getPoints(self)
    local counter = 1
    while true do
        local name = "point" .. counter
        if isPropExist(name) then
            self.points[counter] = go.get(self.url,name)
            counter = counter + 1
        else
            break
        end
    end
end

local function Animate(self)
   if self.direction ~= 0 then
        if self.direction.x < 0 then
            sprite.set_hflip("#sprite", false) 
        else
            sprite.set_hflip("#sprite", true)
        end
        return self.name .. "_run"
    else
        return self.name .. "_idle"
    end
end

local function playAnimation(self)
    if Animate(self) ~= self.animation then
        self.animation = Animate(self)
        local  id = hash(Animate(self))
        msg.post("#sprite", "play_animation", {id = id})
    end
end

local function pathFinding(self,dt)
    if not self.moving then
        return
    end

    self.pos = go.get_position()
    local position = self.destination - self.pos
    if vmath.length(position) > 1 then
        self.direction = vmath.normalize(position)
        local move =  self.pos + self.direction*self.speed*dt 
        go.set_position(move)
    else
        self.direction = vmath.vector3(0,0,self.pos.z)
        if self.points[self.checkPoint + 1] ~= nil and self.movingForward then
            self.checkPoint = self.checkPoint + 1
        else
            self.movingForward = false
            if self.points[self.checkPoint - 1] ~= nil then
                self.checkPoint = self.checkPoint - 1
            else
                self.movingForward = true
            end
        end
        self.destination = self.points[self.checkPoint]
    end
end

function enemyAi:init()
    self.points = {} 
    self.direction = vmath.vector3()
    self.pos = go.get_position()
    self.speed = go.get("#", "speed")
    self.checkPoint = 1
    self.destination = go.get("#", "point1")
    self.moving = true
    self.animation = self.name .. "_idle"
    self.url = msg.url("#")
    self.movingForward = true
    getPoints(self)
end

function enemyAi:update(dt)
    pathFinding(self, dt)
    playAnimation(self)
end

function enemyAi.onMessage(self,message_id,message,sender)
   if message_id == hash("trigger_response") then 
        if message.other_group == hash("player") then
            self.moving = false
            msg.post("#body", "disable")
            msg.post("#sprite", "play_animation", {id = hash(self.name .. "_hit")})
        end
   end
   if message_id == hash("animation_done") then
        go.delete()
    end
end

return enemyAi