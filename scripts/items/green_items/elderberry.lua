local mod = jezreelMod
local h = include("scripts/func")

local elderBerry = mod.ENUMS.VEGETABLES.ELDERBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(elderBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange+(1*(berryNum+giftNum/2))*40
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed-0.1*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    if(pickup.InitSeed%10==0 and h:anyPlayerHas(elderBerry)) then
        pickup:Morph(pickup.Type,PickupVariant.PICKUP_OLDCHEST, 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, PickupVariant.PICKUP_LOCKEDCHEST)

mod.ITEMS.ELDERBERRY = funcs