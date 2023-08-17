local mod = jezreelMod
local fj = include("scripts/firejet")
local h = include("scripts/func")

local dragonfruitBombs = mod.ENUMS.VEGETABLES.DRAGONFRUIT_BOMBS
local auraVar = Isaac.GetEntityVariantByName("Dragon Aura")

local DRAGONFIRE_DAMAGE = 7

local DRAGONFIRE_AMOUNT = 4
local DRAGONFIRE_MEGA_AMOUNT = 5
local DRAGONFIRE_BOMBER_AMOUNT = 20

local DRAGONFIRE_DELAY = 3
local DRAGONFIRE_MEGA_DELAY = 2
local DRAGONFIRE_BOMBER_DELAY = 0

local DRAGONFIRE_DIST = 50
local DRAGONFIRE_MEGA_DIST = 40
local DRAGONFIRE_BOMBER_DIST = 55

local funcs = {}

---@param bomb EntityBomb
function funcs:postBombUpdate(bomb)
    if(bomb.SpawnerType~=EntityType.ENTITY_PLAYER) then return end
    local player = bomb.SpawnerEntity:ToPlayer()
    local dragonNum = player:GetCollectibleNum(dragonfruitBombs)
    if(dragonNum<1) then return end

    local sprite = bomb:GetSprite()
    if sprite:IsPlaying("Explode") then
        local hasMega = player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA)
        local hasBomber = player:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)

        local fireAngle = 45*((hasBomber and 1) or 0)

        if(hasBomber) then
            for i=0,3 do
                local jet = fj:spawnFireJet(player, 5, bomb.Position, DRAGONFIRE_BOMBER_AMOUNT, DRAGONFIRE_BOMBER_DIST, DRAGONFIRE_BOMBER_DELAY, i*90, nil, nil)
                jet:GetData().fjIsPlayerFriendly = true
            end
        end

        if(hasMega) then
            for i=0,3 do
                local jet = fj:spawnFireJet(player, DRAGONFIRE_DAMAGE*2, bomb.Position, DRAGONFIRE_MEGA_AMOUNT, DRAGONFIRE_MEGA_DIST, DRAGONFIRE_MEGA_DELAY, i*90+fireAngle, nil, nil)
                jet:GetData().fjIsPlayerFriendly = true
            end
        else
            for i=0,3 do
                local jet = fj:spawnFireJet(player, DRAGONFIRE_DAMAGE, bomb.Position, DRAGONFIRE_AMOUNT, DRAGONFIRE_DIST, DRAGONFIRE_DELAY, i*90+fireAngle, nil, nil)
                jet:GetData().fjIsPlayerFriendly = true
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, funcs.postBombUpdate)


local function getFireAuraSize(player)
    return 1.5^(player:GetCollectibleNum(dragonfruitBombs)-1)
end

function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    local dragonNum = player:GetCollectibleNum(dragonfruitBombs)
    if(dragonNum<1) then return end
    local rng = player:GetCollectibleRNG(dragonfruitBombs)

    local auraSizeMod = getFireAuraSize(player)*((Game():GetRoom():IsClear() and 0.85) or 1)
    local fireAuraSize = auraSizeMod*64

    for _, entity in ipairs(Isaac.FindInRadius(player.Position, fireAuraSize, EntityPartition.ENEMY)) do
        if(entity:IsVulnerableEnemy() and (not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and (not entity:HasEntityFlags(EntityFlag.FLAG_BURN))) then
            entity:AddBurn(EntityRef(player), 43, player.Damage/2)
        end
    end

    if((not data.fireAura) or (data.fireAura and not data.fireAura:Exists())) then
        data.fireAura = Isaac.Spawn(1000, auraVar, 0, player.Position,Vector.Zero,player):ToEffect()
        data.fireAura.RenderZOffset = -9999
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

local function getAuraSpriteScale(effect)
    return Vector(1,1)*(0.65+effect.Color.A/2)*getFireAuraSize(effect.SpawnerEntity:ToPlayer())
end

---@param effect EntityEffect
function funcs:postEffectInit(effect)
    effect:GetSprite():Play("Idle", true)
    effect:FollowParent(effect.SpawnerEntity)

    local col = effect.Color
    if(Game():GetRoom():IsClear()) then
        col.A = col.A*0.05
    else
        col.A = col.A*0.3
    end
    effect.Color = col
    effect.SpriteScale = getAuraSpriteScale(effect)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, funcs.postEffectInit, auraVar)

function funcs:postEffectUpdate(effect)
    local isClear = Game():GetRoom():IsClear()
    effect.SpriteRotation = effect.SpriteRotation+((isClear and 4) or 7)

    if(isClear) then
        local col = effect.Color
        col.A = h:lerp(col.A,0.05,0.05)

        effect.Color = col
    end
    effect.SpriteScale = getAuraSpriteScale(effect)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, auraVar)

mod.ITEMS.DRAGONFRUITBOMBS = funcs