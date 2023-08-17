local mod = jezreelMod

local funcs = {}

local rockTypeTable = {
    [2]=true,
    [4]=true,
    [5]=true,
    [6]=true,
    [12]=true,
    [14]=true,
    [25]=true,
    [26]=true,
    [27]=true,
}
local badRockTypes = {
    [3]=true,
    [11]=true,
    [7]=true,
    [21]=true,
    [24]=true,
}



--[[

This function spawns a single shockwave at the given position

position    =   Position to spawn the shockwave                     [TYPE: VECTOR]  - Default: Game():GetRoom():GetCenterPos()
parent      =   Shockwave's parent and spawner entity               [TYPE: ENTITY]  - Default: Isaac.GetPlayer(0)
scale       =   SpriteScale of the shockwave                        [TYPE: FLOAT]   - Default: 1
destroyGrid =   Should the shockwave destroy grid objects?          [TYPE: BOOLEAN] - Default: true
                (that a normal bomb can break)
collDamage  =   Shockwave's collision damage                        [TYPE: FLOAT]   - Default: 3.5
dmgCool     =   Cooldown for hurting entities (in frames)           [TYPE: INTEGER] - Default: 3
hurtParent  =   Should the shockwave hurt its parent?               [TYPE: BOOLEAN] - Default: true
isHelper    =   Is the shockwave a helper entity?                   [TYPE: BOOLEAN] - Default: false
                (should always be false when used, used specifically for the ellipse function)
]]
function funcs:spawnShockwaveSingle(position, parent, scale, destroyGrid, collDamage, dmgCool, hurtParent, isHelper)
    local room = Game():GetRoom()
    local pos = position or room:GetCenterPos()
    local collWithBadGrid = false
    local gridEnt = room:GetGridEntityFromPos(pos)
    if gridEnt then
        local gType = gridEnt:GetType()
        if badRockTypes[gType] == true then
            collWithBadGrid = true
        end
    end
    if(collWithBadGrid==false and room:IsPositionInRoom(pos, 0)) then
        local par = parent or Isaac.GetPlayer(0)
        local scl = scale or 1
        local sType = 0
        if(isHelper) then sType = 5817 end
        local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, sType, pos, Vector(0,0), par)
        shockwave.Parent = par
        local data = shockwave:GetData()
        data.SHSpawnedByLib = true
        data.SHScl = scl
        data.SHDestroyGrid = destroyGrid
        if(destroyGrid==nil) then data.SHDestroyGrid = true end
        data.SHMaxDamageCooldown = dmgCool or 3
        data.SHCurDMGCooldown = 0
        data.SHHurtParent = hurtParent
        if(hurtParent==nil) then data.SHHurtParent = true end
        data.SHParentInitSeed = par.InitSeed
        shockwave.CollisionDamage = collDamage or 3.5
        shockwave.SpriteScale = Vector(scl,scl)
        return shockwave
    else
        return nil
    end
end



--[[

This function spawns a line of shockwaves that begins at the given position

startPos    =   Position to spawn the start of the line             [TYPE: VECTOR]  - Default: Game():GetRoom():GetCenterPos()
parent      =   Shockwave's parent and spawner entity               [TYPE: ENTITY]  - Default: Isaac.GetPlayer(0)
scale       =   SpriteScale of the shockwave                        [TYPE: FLOAT]   - Default: 1
destroyGrid =   Should the shockwave destroy grid objects?          [TYPE: BOOLEAN] - Default: true
                (that a normal bomb can break)
collDamage  =   Shockwave's collision damage                        [TYPE: FLOAT]   - Default: 3.5
dmgCool     =   Cooldown for hurting entities (in frames)           [TYPE: INTEGER] - Default: 3
hurtParent  =   Should the shockwave hurt its parent?               [TYPE: BOOLEAN] - Default: true
direction   =   The direction in which the line should move         [TYPE: FLOAT]   - Default: 0
length      =   Amount of shockwaves to spawn before stopping       [TYPE: INTEGER] - Default: 10
distance    =   The distance between each shockwave                 [TYPE: FLOAT]   - Default: 40
delay       =   The delay (in frames) between spawning shockwaves   [TYPE: INTEGER] - Default: 3
angleVar    =   Should the line have angle variance?                [TYPE: BOOLEAN] - Default: false
randAngle   =   Should the angle variance be random?                [TYPE: BOOLEAN] - Default: false
angle       =   The size of the arc used for random angle variance  [TYPE: FLOAT]   - Default: 0
                Formula: newAngle = direction+(random int 0 to angle)-(angle/2)
scaleVar    =   The amount to increase the SpriteScale by for       [TYPE: FLOAT]   - Default: 0
                every new shockwave in the line
]]
function funcs:spawnShockwaveLine(startPos, parent, scale, destroyGrid, collDamage, dmgCool, hurtParent, direction, length, distance, delay, angleVar, randAngle, angle, scaleVar)
    local len = length or 10
    local pos = startPos or Game():GetRoom():GetCenterPos()
    if(len>0 and Game():GetRoom():IsPositionInRoom(pos, 0)) then
        local shockwave = funcs:spawnShockwaveSingle(pos, parent, scale, destroyGrid, collDamage, dmgCool, hurtParent)
        if shockwave then
            local data = shockwave:GetData()
            data.SHVar = 1
            data.SHDir = direction or 0
            data.SHLen = length or 10
            data.SHDist = distance or 40
            data.SHDel = delay or 3
            data.SHAngVar = angleVar or false
            data.SHRandAngVar = randAngle or false
            data.SHAng = angle or 0
            data.SHSclVar = scaleVar or 0
        end
        return shockwave
    else
        return nil
    end
end

--[[

This function spawns an ellipse of shockwaves centered at the given position

The ellipse is created based on steps, going from initStep to maxStep
The step determines the radius of the ellipse using the following formulas:
    radiusX = currentStep*distance.X
    radiusY = currentStep*distance.Y
The initStep being larger means the ellipse starts at a wider radius, 
and the maxStep being larger means the ellipse can be larger

position    =   Position of the ellipse's center                    [TYPE: VECTOR]  - Default: Game():GetRoom():GetCenterPos()
parent      =   Shockwave's parent and spawner entity               [TYPE: ENTITY]  - Default: Isaac.GetPlayer(0)
scale       =   SpriteScale of the shockwave                        [TYPE: FLOAT]   - Default: 1
destroyGrid =   Should the shockwave destroy grid objects?          [TYPE: BOOLEAN] - Default: true
                (that a normal bomb can break)
initStep    =   The step at which the ellipse should begin          [TYPE: INTEGER] - Default: 1
maxStep     =   The step at which the ellipse should end            [TYPE: INTEGER] - Default: 5
distance    =   The X and Y distances between                       [TYPE: VECTOR]  - Default: Vector(30,30)
                each ring of shockwaves (see above)  
delay       =   The delay (in frames) between spawning rings        [TYPE: INTEGER] - Default: 3
scaleVar    =   The amount to increase the SpriteScale by for       [TYPE: FLOAT]   - Default: 0
                every new ring
]]
function funcs:spawnShockwaveEllipse(position, parent, scale, destroyGrid, collDamage, dmgCool, hurtParent, initStep, maxStep, distance, delay, scaleVar)
    local shockwave = funcs:spawnShockwaveSingle(position, parent, scale, destroyGrid, collDamage, dmgCool, hurtParent, true)
    if(shockwave) then
        local data = shockwave:GetData()
        data.SHVar = 2
        data.SHInitStep = initStep or 1
        data.SHCurStep = data.SHInitStep
        data.SHMaxStep = maxStep or 5
        data.SHDist = distance or Vector(30,30)
        data.SHDel = delay or 3
        data.SHSclVar = scaleVar or 0
        return shockwave
    else
        return nil
    end
end

function mod:shockwaveUpdateLIB(effect)
    local data = effect:GetData()
    if data.SHSpawnedByLib then
        if data.SHDestroyGrid then
            local room = Game():GetRoom()
            local gridEnt = room:GetGridEntityFromPos(effect.Position)
            if gridEnt then
                local gType = gridEnt:GetType()
                if rockTypeTable[gType] == true then
                    room:DestroyGrid(room:GetGridIndex(effect.Position), false)
                end
            end
        end
        if data.SHVar == 1 then
            local del = data.SHDel or 3
            if effect.FrameCount == del then
                local dir = data.SHDir or 0
                local len = data.SHLen or 10
                local dist = data.SHDist or 40
                local angVar = data.SHAngVar or false
                local randAngVar = data.SHRandAngVar or false
                local ang = data.SHAng or 0
                local sclVar = data.SHSclVar or 0
                local scl = data.SHScl or 1

                local angle = dir
                if(angVar) then
                    if (randAngVar==false) then
                        angle = angle+ang
                        dir = dir+ang
                    else
                        angle = angle+effect:GetDropRNG():RandomInt(ang+1)-(ang/2)
                    end
                end

                local strPos = effect.Position+Vector.FromAngle(angle)*Vector(dist,dist)

                local shockwave = funcs:spawnShockwaveLine(strPos, effect.Parent, scl+sclVar, data.SHDestroyGrid, effect.CollisionDamage, data.SHMaxDamageCooldown, data.SHHurtParent, dir, len-1, dist, del, data.SHAngVar, data.SHRandAngVar, ang, sclVar)
            end
        end
        if effect.SubType == 5817 then
            local del = data.SHDel or 3
            if effect.FrameCount % del == 0 then
                local initStep = data.SHInitStep or 1
                local curStep = data.SHCurStep or initStep
                local maxStep = data.SHMaxStep or 5
                local dist = data.SHDist or Vector(30,30)
                local sclVar = data.SHSclVar or 0
                local scl = data.SHScl or 1
                local pi = math.pi
                local nrWaves = math.max(math.floor(pi*2*curStep),1)
                local room = Game():GetRoom()

                for i=1, nrWaves do
                    local degree = (360/nrWaves)*i
                    local strX = math.cos(degree*2*(math.pi)/360)*dist.X*curStep
                    local strY = math.sin(degree*2*(math.pi)/360)*dist.Y*curStep
                    local strPos = effect.Position+Vector(strX,strY)

                    if(room:IsPositionInRoom(strPos, 0)) then
                        funcs:spawnShockwaveSingle(strPos, effect.Parent, scl+sclVar, data.SHDestroyGrid, effect.CollisionDamage, data.SHMaxDamageCooldown, data.SHHurtParent, false)
                    end
                end

                if(curStep==maxStep) then effect:Remove() end
                data.SHCurStep = curStep+1
            end
        else
            if data.SHCurDMGCooldown == 0 then
                local scl = data.SHScl or 1
                local enemies = Isaac.FindInRadius(effect.Position, effect.Size*scl, EntityPartition.ENEMY | EntityPartition.PLAYER)
                if(enemies[1])then
                    for i, enemy in ipairs(enemies) do
                        if(enemy.InitSeed == data.SHParentInitSeed and data.SHHurtParent==true) then
                            enemy:TakeDamage(1, 0, EntityRef(effect), data.SHMaxDamageCooldown)
                        end
                        if(enemy.InitSeed ~= data.SHParentInitSeed) then
                            enemy:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), data.SHMaxDamageCooldown)
                        end
                    end
                    data.SHCurDMGCooldown = data.SHMaxDamageCooldown or 3
                end
            else
                data.SHCurDMGCooldown = data.SHCurDMGCooldown-1
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.shockwaveUpdateLIB, EffectVariant.ROCK_EXPLOSION)

return funcs