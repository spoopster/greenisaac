local mod = jezreelMod
local sfx = SFXManager()

local blockbumVar = Isaac.GetEntityVariantByName("Green Abel")

local slamCooldown = 60
local collDamage = 20
local smokeColor = Color(0.4,0.8,0.75,0.8,0,0,0)

local damageSFX = 213
local landSFX = 77
sfx:Preload(damageSFX)
sfx:Preload(landSFX)


local funcs = {}

local function getVulnerableEntities(familiar)
    local entities = Isaac.FindInRadius(familiar.Position, 600, EntityPartition.ENEMY)
    if(#entities==0) then return familiar.Player end
    local vulnerableEntities = {}
    for i, entity in ipairs(entities) do
        if(entity:IsVulnerableEnemy()) then vulnerableEntities[#vulnerableEntities+1] = entity end
    end
    if(#vulnerableEntities==0) then return familiar.Player end
    return vulnerableEntities[familiar:GetDropRNG():RandomInt(#vulnerableEntities)+1]
end

function funcs:familiarInit(familiar)
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()
    sprite:Play("Appear", true)
    data.currentTarget = nil
    data.isTouchable = true
    familiar.Coins = 0

    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, blockbumVar)

function funcs:familiarUpdate(familiar)
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()

    if(sprite:IsFinished("Appear")) then sprite:Play("Idle", true) end
    if(sprite:IsFinished("Jump")) then sprite:Play("JumpIdle", true) end
    if(sprite:IsFinished("Slam")) then sprite:Play("Idle", true) end

    if(sprite:IsEventTriggered("Jump")) then
        data.isTouchable = false
    end
    if(sprite:IsEventTriggered("Slam")) then
        local poof = Isaac.Spawn(1000,16,1,familiar.Position,Vector.Zero,familiar):ToEffect()
        local poofSprite = poof:GetSprite()
        poofSprite:ReplaceSpritesheet(0, "gfx/entities/familiars/blockbum/blockbumPoof.png")
        poofSprite:LoadGraphics()
        poof.SpriteScale = Vector(0.5,0.5)
        poof.Color = smokeColor

        sfx:Play(landSFX, 0.2)

        local entities = Isaac.FindInRadius(familiar.Position, 30, EntityPartition.ENEMY)
        local dmgMulti = 1
        if(familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then dmgMulti = 2 end
        for i, entity in ipairs(entities) do
            entity:TakeDamage(collDamage*dmgMulti, 0, EntityRef(familiar), 0)
        end
        if(#entities>0) then
            sfx:Play(damageSF, 0.8)
        end

        familiar.Coins = 0
        familiar.Velocity = Vector.Zero
        data.isTouchable = true
    end

    local anim = sprite:GetAnimation()

    if(anim=="Idle") then
        familiar.Velocity = familiar.Velocity*0.6
        familiar.Coins = familiar.Coins+1

        if(familiar.Coins>=slamCooldown) then
            familiar.Coins = 0

            data.currentTarget = getVulnerableEntities(familiar)
            sprite:Play("Jump", true)
        end
    end
    if((anim=="Jump" and data.isTouchable==false) or anim=="JumpIdle" or (anim=="Slam" and data.isTouchable==false)) then
        local speedMult=0.3*(familiar.Coins/20)+0.01*(1-familiar.Coins/20)
        familiar.Coins = familiar.Coins+1
        familiar.Velocity = (data.currentTarget.Position-familiar.Position)*speedMult*(1+(familiar.Coins*10)/100)

        if((anim=="JumpIdle" and (data.currentTarget.Position-familiar.Position):Length()<=120) or familiar.Coins>120) then
            sprite:Play("Slam", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, blockbumVar)

function funcs:preFamiliarCollision(familiar, collider, low)
    local data = familiar:GetData()
    if(data.isTouchable==false) then return true end

    if(collider.Type==9) then collider:Die()
    else return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.preFamiliarCollision, blockbumVar)

mod.ENTITIES.BLOCKBUMS.ABEL = {}