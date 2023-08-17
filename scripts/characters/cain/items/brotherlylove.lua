local mod = jezreelMod

local brotherlyLove = mod.ENUMS.ITEMS.BROTHERLY_LOVE
local abelVar = Isaac.GetEntityVariantByName("Green Abel")
local sethVar = Isaac.GetEntityVariantByName("Green Seth")

local funcs = {}

function funcs:peffectUpdate(player)
    local brotherlyLoveNum = player:GetCollectibleNum(brotherlyLove)+player:GetEffects():GetCollectibleEffectNum(brotherlyLove)
	player:CheckFamiliar(abelVar,math.ceil(brotherlyLoveNum/2),player:GetCollectibleRNG(brotherlyLove),Isaac.GetItemConfig():GetCollectible(brotherlyLove))
    player:CheckFamiliar(sethVar,math.floor(brotherlyLoveNum/2),player:GetCollectibleRNG(brotherlyLove),Isaac.GetItemConfig():GetCollectible(brotherlyLove))
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, funcs.peffectUpdate)

mod.ITEMS.BROTHERLYLOVE = funcs