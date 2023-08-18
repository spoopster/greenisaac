local mod = jezreelMod

local radish = mod.ENUMS.VEGETABLES.RADISH

local funcs = {}

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(radish)) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1.3^(player:GetCollectibleNum(radish)))
        end
        if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay*(1.2^(player:GetCollectibleNum(radish)))
        end
        if(flag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck+3*player:GetCollectibleNum(radish)
        end
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange+2*40*player:GetCollectibleNum(radish)
        end
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed+0.2*player:GetCollectibleNum(radish)
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.1*player:GetCollectibleNum(radish)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.RADISH = funcs