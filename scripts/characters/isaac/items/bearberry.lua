local mod = jezreelMod
local sfx = SFXManager()

local bearSFX = Isaac.GetSoundIdByName("BearzerkRoar")
sfx:Preload(bearSFX)

local bearBerry = mod.ENUMS.VEGETABLES.BEARBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT

local bearzerkChance = 1/6

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(bearBerry)
    local giftNum = player:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1.35^(berryNum+giftNum/2))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

---@param entity Entity
function funcs:entityTakeDMG(entity, amount)
    entity = entity:ToPlayer()

    local berryNum = entity:GetCollectibleNum(bearBerry)
    local giftNum = entity:GetCollectibleNum(naturalGift)
    if(berryNum>0) then
        if(entity:GetCollectibleRNG(bearBerry):RandomFloat()>(1-bearzerkChance)^(berryNum+giftNum)) then
            entity:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK, UseFlag.USE_NOANIM, -1)
            sfx:Play(bearSFX,2)
            sfx:Stop(SoundEffect.SOUND_BERSERK_START)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

function funcs:postRender()
	if sfx:IsPlaying(bearSFX) then
		sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.postRender)

mod.ITEMS.BEARBERRY = funcs