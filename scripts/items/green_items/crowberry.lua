local mod = jezreelMod
local h = include("scripts/func")
local sfx = SFXManager()

local crowSFX = Isaac.GetSoundIdByName("CrowHit")
sfx:Preload(crowSFX)

local crowBerry = mod.ENUMS.VEGETABLES.CROWBERRY
local naturalGift = mod.ENUMS.VEGETABLES.NATURAL_GIFT
local spawnPickupChance = 1/3

local funcs = {}

function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(crowBerry)
    local giftNum = h:allPlayersCollNum(naturalGift)
    if(berryNum>0) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1.2^(berryNum+giftNum/2))
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.15*(berryNum+giftNum/2)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

function funcs:preSpawnCleanAward(rng, spawnPos)
    local roomType = Game():GetLevel():GetCurrentRoomDesc().Data.Type
    if(roomType==1) then
        local berryNum = h:allPlayersCollNum(crowBerry)
        local giftNum = h:allPlayersCollNum(naturalGift)
        if(berryNum>0) then
            if(rng:RandomFloat()>(1-spawnPickupChance)^(berryNum+giftNum)) then
                local pickup = Isaac.Spawn(5, (rng:RandomInt(4)+1)*10, 0, Game():GetRoom():FindFreePickupSpawnPosition(spawnPos,0),Vector.Zero,nil)
                sfx:Play(crowSFX)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, funcs.preSpawnCleanAward)

---@param entity Entity
function funcs:entityTakeDMG(entity)
    entity = entity:ToPlayer()

    local berryNum = entity:GetCollectibleNum(crowBerry)
    if(berryNum>0) then
        sfx:Play(crowSFX)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

function funcs:postRender()
	if sfx:IsPlaying(crowSFX) then
		sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.postRender)

mod.ITEMS.CROWBERRY = funcs