local mod = jezreelMod
local h = include("scripts/func")

local barBerry = mod.ENUMS.VEGETABLES.BARBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT
local poisonChance = 1/20

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(barBerry)
    local giftNum = h:allPlayersCollNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange+2*(berryNum+giftNum/2)*40
        end
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed+0.15*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

---@param entity Entity
function funcs:entityTakeDMG(entity, amount)
    if(not (entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then return nil end
    if(entity:HasEntityFlags(EntityFlag.FLAG_POISON)) then return nil end

    local berryNum = h:allPlayersCollNum(barBerry)
    local giftNum = h:allPlayersCollNum(naturalGift)
    if(berryNum>0) then
        if(Isaac.GetPlayer():GetCollectibleRNG(barBerry):RandomFloat()>(1-poisonChance)^(berryNum+giftNum)) then
            entity:AddPoison(EntityRef(nil), 60, amount*2/3)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

mod.ITEMS.BARBERRY = funcs