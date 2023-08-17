local mod = jezreelMod
local h = include("scripts/func")

local babyCarrot = mod.ENUMS.VEGETABLES.BABY_CARROT

local POINT_CHANCE = 0.33

local funcs = {}

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end
    if(tear.FrameCount>0) then return end
    local player = tear.SpawnerEntity:ToPlayer()
    local carrotNum = player:GetCollectibleNum(babyCarrot)
    if(carrotNum<=0) then return end

    local data = tear:GetData()
    local rng = tear:GetDropRNG()

    if(rng:RandomFloat()>(1-POINT_CHANCE)^carrotNum) then
        tear:AddTearFlags(TearFlags.TEAR_PIERCING)

        local closest = h:closestEnemy(player.Position)
        if(not closest) then return end
        local angle = (closest.Position-tear.Position):GetAngleDegrees()
        tear.Velocity = tear.Velocity:Rotated(angle-tear.Velocity:GetAngleDegrees())
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(babyCarrot)) then
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed+0.1*player:GetCollectibleNum(babyCarrot)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.BABYCARROT = funcs