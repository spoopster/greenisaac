local mod = jezreelMod

local grayBerry = mod.ENUMS.VEGETABLES.GRAYBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(grayBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.25*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.PEARRY = funcs