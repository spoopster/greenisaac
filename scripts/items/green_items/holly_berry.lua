local mod = jezreelMod

local hollyBerry = mod.ENUMS.VEGETABLES.HOLLY_BERRY

local HOLLY_LASER_NUM = 4
local HOLLY_GOD_CHANCE = 1/6

local funcs = {}

---@param entity Entity
function funcs:entityTakeDMG(entity, amount)
    local player = entity:ToPlayer()
    if(player.Variant~=0) then return nil end

    local berryNum = player:GetCollectibleNum(hollyBerry)
    if(berryNum<=0) then return nil end

    local laserNum = math.min(HOLLY_LASER_NUM*berryNum,10)

    for i=1, laserNum do
        local angle = i*360/laserNum+45
        local laser = EntityLaser.ShootAngle(LaserVariant.LIGHT_BEAM, player.Position, angle, 25, Vector.Zero, player)
        laser.CollisionDamage = 7.77
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()

    if(tear.FrameCount~=1) then return end

    local rng = player:GetCollectibleRNG(hollyBerry)
    local berryNum = player:GetCollectibleNum(hollyBerry)

    if(berryNum<=0) then return end

    if(rng:RandomFloat()>(1-HOLLY_GOD_CHANCE)^berryNum) then
        if(tear:HasTearFlags(TearFlags.TEAR_GLOW)) then
            tear.CollisionDamage = tear.CollisionDamage*1.33
        else
            tear:AddTearFlags(TearFlags.TEAR_HOMING)
            tear:AddTearFlags(TearFlags.TEAR_GLOW)
            tear.Velocity = tear.Velocity*0.9
            tear:Update()
        end
        local col = tear.Color
        col:SetColorize(1.1,1.2,1,1)
        tear.Color = col
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

mod.ITEMS.KRAMBERRY = funcs

mod.ITEMS.HOLLYBERRY = funcs