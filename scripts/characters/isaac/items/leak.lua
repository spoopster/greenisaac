local mod = jezreelMod
local helper = include("scripts/func")

local leak = mod.ENUMS.VEGETABLES.LEAK
local spicyPepper = mod.ENUMS.VEGETABLES.MILDLY_SPICY_PEPPER
local pissColor = Color(1,1,1,1,0,0,0)
    pissColor:SetColorize(1,1,0.2,2)
local funcs = {}

---@param tear EntityTear
function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    if(player:HasCollectible(leak)) then
        tear.Color = pissColor
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

---@param entity Entity
---@param amount number
---@param source EntityRef
function funcs:entityTakeDMG(entity, amount, _, source, _)
    if(entity.HitPoints<=amount and entity:IsVulnerableEnemy()) then
        local leakNum = helper:allPlayersCollNum(leak)
        if(leakNum>0 and not (source.Type==1000 and source.Variant==EffectVariant.PLAYER_CREEP_LEMON_MISHAP)) then
            local pissChance = (2/3)^leakNum
            if(entity:GetDropRNG():RandomFloat()>pissChance) then
                local piss = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_LEMON_MISHAP, 0, entity.Position, Vector.Zero, source.Entity):ToEffect()
                piss:GetData().leekPiss = true
                piss.CollisionDamage = 2
                piss:Update()
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

---@param effect EntityEffect
function funcs:postEffectUpdate(effect)
    local sprite = effect:GetSprite()
    if(effect.Variant==32) then
        if(effect:GetData().leekPiss==true) then
            if((effect.FrameCount%8==0 and effect.FrameCount<=220)
            or (effect.FrameCount%12==0 and effect.FrameCount<=255)
            or (effect.FrameCount%16==0 and effect.FrameCount<=290)) then
                local rng = effect:GetDropRNG()
                local pos = Vector(rng:RandomFloat()*60-30, rng:RandomFloat()*30-15)
                if(effect.FrameCount>220) then
                    pos = pos*((290-effect.FrameCount)/70)
                end
                pos = effect.Position+pos
                local tear = Isaac.Spawn(2, 0, 0, pos, Vector(rng:RandomFloat()*10-5, rng:RandomFloat()*10-5), effect):ToTear()
                tear.Height = -5
                tear.FallingSpeed = -15
                tear.FallingAcceleration = 1.5
                tear.Scale = 1+rng:RandomFloat()*0.5-0.25
                tear.CollisionDamage = 1.5
                tear.Color = pissColor
                tear:GetData().pissTear = true

                if(helper:anyPlayerHas(spicyPepper) and rng:RandomInt(6)==0) then
                    mod:synergyFlame(tear, tear.Position, tear.Velocity, 0.66)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate)

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(leak)) then
        if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay/(1.1^(player:GetCollectibleNum(leak)))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.LEAK = funcs