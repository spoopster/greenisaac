local mod = jezreelMod
local h = include("scripts/func")

local oliveOil = mod.ENUMS.VEGETABLES.OLIVE_OIL

-- [[
local OIL_SUBTYPE = 924
local OIL_FLAGS = CacheFlag.CACHE_DAMAGE
local OIL_DAMAGE_BONUS = 2

local OIL_TIMEOUT = 10*30
local OIL_DEATH_LENGTH = 10
local OIL_COLOR = Color(0,0,0,0.51,222/255,221/255,55/255)
--]]

local funcs = {}

-- Blud thought he was onto something until he realized this is literally just one of T.BB's poops
---@param player EntityPlayer
function funcs:useItem(_, rng, player, _, _, _)
    local oil = Isaac.Spawn(1000, EffectVariant.CREEP_SLIPPERY_BROWN, OIL_SUBTYPE, Game():GetRoom():GetCenterPos(), Vector.Zero, player):ToEffect()
    oil.Timeout = OIL_TIMEOUT+30+300
    oil.Scale = 100

    oil:Update()

    if(Game():GetRoom():HasWater()) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BIBLE, UseFlag.USE_NOANIM, -1)
    end

    return {
        Discharge=true,
        Remove=false,
        ShowAnim=true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, oliveOil)

function funcs:postEffectUpdate(effect)
    if(effect.SubType~=OIL_SUBTYPE) then return end
    if(h:isRoomClear() and effect.Scale==100) then effect.Scale = 100+effect.FrameCount end

    local a = OIL_COLOR.A
    if(effect.FrameCount>OIL_TIMEOUT or effect.Scale~=100) then
        if(effect.Scale==100) then
            a = a*(1-(effect.FrameCount-OIL_TIMEOUT)/OIL_DEATH_LENGTH)
        else
            a = a*(1-(effect.FrameCount-(effect.Scale-100))/OIL_DEATH_LENGTH)
        end
    end

    local col = Color(OIL_COLOR.R,OIL_COLOR.G,OIL_COLOR.B,a,OIL_COLOR.RO,OIL_COLOR.GO,OIL_COLOR.BO)

    effect.Color = col

    for _, player in ipairs(Isaac.FindInRadius(effect.Position, 25*effect.Scale,EntityPartition.PLAYER)) do
        player = player:ToPlayer()

        player:GetData().oilCreepBonus = true
        player:AddCacheFlags(OIL_FLAGS)
        player:EvaluateItems()
    end

    if(effect.FrameCount>=OIL_TIMEOUT+OIL_DEATH_LENGTH or (effect.Scale~=100 and effect.FrameCount>=effect.Scale+OIL_DEATH_LENGTH-100)) then effect:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, EffectVariant.CREEP_SLIPPERY_BROWN)

function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    if(data.oilCreepBonus==nil) then return end
    if(data.oilCreepBonus==false) then
        data.oilCreepBonus=nil
        player:AddCacheFlags(OIL_FLAGS)
        player:EvaluateItems()
    end

    data.oilCreepBonus=false
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:evaluateCache(player, flag)
    local stats = player:GetData().oilCreepBonus
    if(stats==nil) then return end
    if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*OIL_DAMAGE_BONUS
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)
--]]

mod.ITEMS.OLIVEOIL = funcs