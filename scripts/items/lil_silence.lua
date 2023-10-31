local mod = jezreelMod

local lilSilence = mod.ENUMS.ITEMS.LIL_SILENCE
local silenceVar = Isaac.GetEntityVariantByName("Lil Silence")

local LS_PROJSPEED = 2
local LS_PROJNUM = 4
local LS_ANGLECHANGE = 30
local LS_BURSTPROJNUM = 8

local LS_FIRECOOLDOWN = 15
local LS_BURSTCOOLDOWN = 6
local LS_DAMAGE = 3

local funcs = {}

---@param familiar EntityFamiliar
function funcs:familiarInit(familiar)
    familiar:AddToFollowers()
    familiar.SpriteOffset = Vector(0,-16)

    familiar.Coins = 0
    familiar.Hearts = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, silenceVar)

---@param familiar EntityFamiliar
function funcs:familiarUpdate(familiar)
    local data = familiar:GetData()
    local player = familiar.Player
    local sprite = familiar:GetSprite()

    if(sprite:IsFinished("Shoot")) then sprite:Play("Idle", true) end

    if(player:GetFireDirection()~=Direction.NO_DIRECTION) then
        if(familiar.FireCooldown<=0) then
            sprite:Play("Shoot", true)

            familiar.FireCooldown = LS_FIRECOOLDOWN
        end
    end

    if(sprite:IsEventTriggered("Shoot")) then
        for i=1, LS_PROJNUM do
            local tear = familiar:FireProjectile(Vector.FromAngle(i*360/LS_PROJNUM+familiar.Coins)*LS_PROJSPEED)
            tear.CollisionDamage = LS_DAMAGE*((player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2) or 1)
            tear.Color = Color(0.3,0.6,0.2,1,0,0,0)
        end

        if(familiar.Hearts==0) then
            for i=1, LS_BURSTPROJNUM do
                local tear = familiar:FireProjectile(Vector.FromAngle((i+0.5)*360/LS_BURSTPROJNUM)*LS_PROJSPEED/2)
                tear.CollisionDamage = LS_DAMAGE*1.25*((player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2) or 1)
                tear.Color = Color(0.3,0.6,0.2,1,0,0,0)
            end
        end

        familiar.Coins = familiar.Coins+LS_ANGLECHANGE
        familiar.Hearts = (familiar.Hearts+1)%LS_BURSTCOOLDOWN
    end

	if(familiar.FireCooldown>0) then
		familiar.FireCooldown = familiar.FireCooldown-1
	end

    familiar:FollowParent()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, silenceVar)

function funcs:peffectUpdate(player)
	local itemNum = player:GetCollectibleNum(lilSilence)+player:GetEffects():GetCollectibleEffectNum(lilSilence)
	player:CheckFamiliar(silenceVar,itemNum,player:GetCollectibleRNG(lilSilence),Isaac.GetItemConfig():GetCollectible(lilSilence))
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, funcs.peffectUpdate)
