local mod = jezreelMod

local kramBerry = mod.ENUMS.VEGETABLES.KRAM_BERRY

local KRAM_LASER_NUM = 4
local KRAM_COAL_CHANCE = 1/3

local funcs = {}

---@param entity Entity
function funcs:entityTakeDMG(entity, amount)
    local player = entity:ToPlayer()
    if(player.Variant~=0) then return nil end

    local berryNum = player:GetCollectibleNum(kramBerry)
    if(berryNum<=0) then return nil end

    local laserNum = math.min(KRAM_LASER_NUM*berryNum,10)

    for i=1, laserNum do
        local angle = i*360/laserNum
        local laser = EntityLaser.ShootAngle(1, player.Position, angle, 21, Vector.Zero, player)
        laser.CollisionDamage = 6.66
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()

    if(tear.FrameCount~=1) then return end

    local rng = player:GetCollectibleRNG(kramBerry)
    local berryNum = player:GetCollectibleNum(kramBerry)

    if(berryNum<=0) then return end

    if(rng:RandomFloat()>(1-KRAM_COAL_CHANCE)^berryNum) then
        if(tear:HasTearFlags(TearFlags.TEAR_GROW)) then
            tear.CollisionDamage = tear.CollisionDamage*1.5
        else
            tear:AddTearFlags(TearFlags.TEAR_GROW)
        end
        local col = tear.Color
        col:SetColorize(0.5,0.6,0.5,1)
        tear.Color = col
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

mod.ITEMS.KRAMBERRY = funcs