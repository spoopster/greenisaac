local mod = jezreelMod

local yellowBerry = mod.ENUMS.VEGETABLES.YELLOWBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT
local melonVariant = Isaac.GetEntityVariantByName("Bowling Melon")

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

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end
    if(tear.Variant==Isaac.GetEntityVariantByName("Bananarang")) then return end
    if(tear.FrameCount~=1) then return end
    local player = tear.SpawnerEntity:ToPlayer()
    local berryNum = player:GetCollectibleNum(yellowBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum<=0) then return end

    local data = tear:GetData()
    local rng = tear:GetDropRNG()

    if(rng:RandomFloat()>(1-bananaChance)^(berryNum+giftNum)) then
        local banana = Isaac.Spawn(2, Isaac.GetEntityVariantByName("Bananarang"), 4, player.Position, tear.Velocity, tear):ToTear()
        tear:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

mod.ITEMS.YELLOWBERRY = funcs