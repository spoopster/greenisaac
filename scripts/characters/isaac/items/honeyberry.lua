local mod = jezreelMod

local honeyBerry = mod.ENUMS.VEGETABLES.HONEYBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(honeyBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck+1*(berryNum+giftNum/2)
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.15*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

function funcs:entityTakeDMG(entity, amount)
    entity = entity:ToPlayer()

    local berryNum = entity:GetCollectibleNum(honeyBerry)
    local giftNum = entity:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        for _=1, math.min((berryNum+giftNum)*2, 7)*(math.max(1, amount)) do
            local locust = Isaac.Spawn(3, 43, 3, entity.Position, Vector.Zero, entity):ToFamiliar()
            locust.Player = entity
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

mod.ITEMS.HONEYBERRY = funcs