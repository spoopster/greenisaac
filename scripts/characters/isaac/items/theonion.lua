local mod = jezreelMod

local onion = mod.ENUMS.VEGETABLES.THE_ONION

local funcs = {}

function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    if(player:HasCollectible(onion)) then
        local onionNum = player:GetCollectibleNum(onion)
        local rng = tear:GetDropRNG()
        if(rng:RandomFloat()<1-0.95^onionNum) then tear:AddTearFlags(TearFlags.TEAR_PIERCING) end
        if(rng:RandomFloat()<1-0.95^onionNum) then tear:AddTearFlags(TearFlags.TEAR_SPECTRAL) end
        if(rng:RandomFloat()<1-0.9^onionNum) then tear:AddTearFlags(TearFlags.TEAR_CONFUSION) end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

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