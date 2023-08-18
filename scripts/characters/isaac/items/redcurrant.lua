local mod = jezreelMod

local redcurrant = mod.ENUMS.VEGETABLES.REDCURRANT
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(redcurrant)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay*(0.8^(berryNum+giftNum/2))
        end
        if(flag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck+0.75*(berryNum+giftNum/2)
        end
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange*(0.75^(berryNum+giftNum/2))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.REDCURRANT = funcs