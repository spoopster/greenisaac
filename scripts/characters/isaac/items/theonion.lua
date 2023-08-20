local mod = jezreelMod

local onion = mod.ENUMS.VEGETABLES.THE_ONION

local PIERCE_CHANCE = 0.05
local SPECTRAL_CHANCE = 0.05
local CONFUSE_CHANCE = 0.1

local funcs = {}

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end
    if(tear.FrameCount~=1) then return end
    local player = tear.SpawnerEntity:ToPlayer()
    local onionNum = player:GetCollectibleNum(onion)
    if(onionNum<=0) then return end

    local data = tear:GetData()
    local rng = tear:GetDropRNG()

    if(rng:RandomFloat()<(1-PIERCE_CHANCE)^onionNum) then tear:AddTearFlags(TearFlags.TEAR_PIERCING) end
    if(rng:RandomFloat()<(1-SPECTRAL_CHANCE)^onionNum) then tear:AddTearFlags(TearFlags.TEAR_SPECTRAL) end
    if(rng:RandomFloat()<(1-CONFUSE_CHANCE)^onionNum) then tear:AddTearFlags(TearFlags.TEAR_CONFUSION) end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(onion)) then
        if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay*(0.95^(player:GetCollectibleNum(onion)))
        end
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange+0.5*40*player:GetCollectibleNum(onion)
        end
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed-0.1*player:GetCollectibleNum(onion)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.THEONION = funcs