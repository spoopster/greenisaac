local mod = jezreelMod

local coffeeBarry = mod.ENUMS.VEGETABLES.COFFEEBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local speedChance = 0.15

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(coffeeBarry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed+0.2*(berryNum+giftNum/2)
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.2*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

---@param entity Entity
function funcs:entityTakeDMG(entity, amount)
    entity = entity:ToPlayer()
    local room = Game():GetRoom()

    local berryNum = entity:GetCollectibleNum(coffeeBarry)
    local giftNum = entity:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        local rng = entity:GetCollectibleRNG(coffeeBarry)
        if(rng:RandomFloat()>(1-speedChance)^(berryNum+giftNum)) then
            Game():GetRoom():SetBrokenWatchState(2) -- speed up room

            local pillCol = Game():GetItemPool():GetPill(Game():GetSeeds():GetNextSeed())
            local pill = Isaac.Spawn(5, PickupVariant.PICKUP_PILL, pillCol, entity.Position, Vector.FromAngle(rng:RandomFloat()*360)*4, entity):ToPickup()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

mod.ITEMS.COFFEEBERRY = funcs