local mod = jezreelMod

local yellowBerry = mod.ENUMS.VEGETABLES.YELLOWBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local bananaChance = 1/15

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(yellowBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange+(1.5*(berryNum+giftNum/2))*40
        end
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed+0.1*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    local berryNum = player:GetCollectibleNum(yellowBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0 and player:GetCollectibleRNG(yellowBerry):RandomFloat()>(1-bananaChance)^(berryNum+giftNum)) then
        local banana = Isaac.Spawn(2, Isaac.GetEntityVariantByName("Bananarang"), 4, player.Position, tear.Velocity, tear):ToTear()
        tear:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

mod.ITEMS.YELLOWBERRY = funcs