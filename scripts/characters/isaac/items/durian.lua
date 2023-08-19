local mod = jezreelMod
local h = include("scripts/func")

local greenD6 = mod.ENUMS.ITEMS.G6
local durian = mod.ENUMS.VEGETABLES.SPIKY_DURIAN
local durianVariant = Isaac.GetEntityVariantByName("Durian Aura")

local funcs = {}

local durianColor = Color(0.88,0.74,0.15,1,0,0,0)

local function calculateFearAura(player)
    local magnitude = player:GetData().durianFear

    return 1.2^(magnitude-1)
end
local function spawnFearAura(player)
    local size = player:GetData().fearAura

    local aura = Isaac.Spawn(1000, durianVariant, 0, player.Position-Vector(0,1), Vector.Zero, player):ToEffect()
    aura:GetSprite():Play("Spawn", true)
    aura.Color = Color(1,1,1,0.3,0,0,0)
    aura.SpriteScale = Vector(1,1)*size*0.8
    aura.Parent = player
    aura:FollowParent(player)

    return aura
end

function funcs:useItem(_, rng, player, _, _, _)
    local data = player:GetData()

    for i=1, player:GetCollectibleNum(durian)*10 do
        local angle = i*(36/player:GetCollectibleNum(durian))+rng:RandomFloat()*20-10
        local spike = Isaac.Spawn(2, TearVariant.ICE, 1290, player.Position, Vector(24,0):Rotated(angle), player):ToTear()
    end
    data.durianFear = player:GetCollectibleNum(durian)
    if(data.durianFear>0 and data.fearAura==nil) then
        data.fearAura = calculateFearAura(player)
        local aura = spawnFearAura(player)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenD6)

function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    if(data.durianFear and data.durianFear>0) then
        for _, entity in ipairs(Isaac.FindInRadius(player.Position, data.fearAura*36, EntityPartition.ENEMY)) do
            if(entity:IsVulnerableEnemy() and (not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) and (not entity:HasEntityFlags(EntityFlag.FLAG_FEAR))) then
                entity:AddFear(EntityRef(player), 45)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:postTearInit(tear)
    local data = tear:GetData()
    if(tear.SubType==1290) then
        tear.SpriteScale = Vector(1, 0.6)
        tear.Color = durianColor
        tear.CollisionDamage = 2.5
        tear.TearFlags = TearFlags.TEAR_PIERCING
        data.poppedTear = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, funcs.postTearInit, TearVariant.ICE)

function funcs:postEffectUpdate(effect)
    local sprite = effect:GetSprite()

    if(sprite:IsFinished("AuraAppear")) then sprite:Play("Idle", true) end
    if(sprite:GetAnimation()=="Idle") then
        local cos = math.cos(effect.FrameCount/12)
        effect.SpriteScale = Vector(1,1)*effect.SpawnerEntity:GetData().fearAura*(0.8+cos*0.05)
        effect.Color = Color(1,1,1,(0.3+cos*0.1))
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, durianVariant)

function funcs:postNewRoom()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player:GetData().durianFear = 0
        player:GetData().fearAura = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

-- CURSED GRAPES SYNERGY --
local GRAPE_DURIAN_CHANCE = 2/3
local GRAPE_AURA_SIZE = 2/3

local cursedGrapes = mod.ENUMS.VEGETABLES.CURSED_GRAPES
function funcs:postNewRoomGrapes()
    if(h:isRoomClear()) then return end
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local data = player:GetData()
        local rng = player:GetCollectibleRNG(cursedGrapes)

        local chance = (1-GRAPE_DURIAN_CHANCE)^(player:GetCollectibleNum(cursedGrapes))

        if(rng:RandomFloat()>chance and player:HasCollectible(cursedGrapes) and player:HasCollectible(durian)) then
            data.durianFear = player:GetCollectibleNum(durian)
            if(data.durianFear>0) then
                data.fearAura = calculateFearAura(player)*GRAPE_AURA_SIZE
                local aura = spawnFearAura(player)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoomGrapes)

mod.ITEMS.SPIKYDURIAN = funcs