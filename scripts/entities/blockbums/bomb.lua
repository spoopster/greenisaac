local mod = jezreelMod
local sfx = SFXManager()
local h = include("scripts/func")

local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local blockbumSubType = 4

local damageCooldown = 30
local slamCooldown = 150
local maxHP = 12
local maxRooms = 6
local gibsAmount = 5
local collDamage = 10
local smokeColor = Color(0.6,0.8,0.5,0.8,0,0,0)

local deathSFX1 = 79
local deathSFX2 = 77
local damageSFX = 213
local landSFX = 77
sfx:Preload(deathSFX1)
sfx:Preload(deathSFX2)
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
    if(familiar.SubType==blockbumSubType) then
        local sprite = familiar:GetSprite()
        local data = familiar:GetData()
        sprite:Load("gfx/entities/familiars/blockbum/bomb.anm2", true)
        sprite:Play("Appear", true)
        data.currentTarget = nil
        data.isInvincible = true
        data.isTouchable = true
        data.dmgCooldown = 30
        data.slamInvincibility = false
        familiar.Keys = maxRooms
        familiar.Coins = 0
        familiar.HitPoints = maxHP

        familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, blockbumVar)

function funcs:familiarUpdate(familiar)
    if(familiar.SubType==blockbumSubType) then
        local sprite = familiar:GetSprite()
        local data = familiar:GetData()

        if(sprite:IsFinished("Appear")) then sprite:Play("Idle", true) end
        if(sprite:IsFinished("Jump")) then sprite:Play("JumpIdle", true) end
        if(sprite:IsFinished("Slam")) then sprite:Play("Idle", true) end

        if(sprite:IsEventTriggered("Jump")) then
            data.isInvincible = true
            data.isTouchable = false
            familiar.Visible = true
        end
        if(sprite:IsEventTriggered("Slam")) then
            local poof = Isaac.Spawn(1000,16,1,familiar.Position,Vector.Zero,familiar):ToEffect()
            local poofSprite = poof:GetSprite()
            poofSprite:ReplaceSpritesheet(0, "gfx/entities/familiars/blockbum/blockbumPoof.png")
            poofSprite:LoadGraphics()
            poof.SpriteScale = Vector(0.5,0.5)
            poof.Color = smokeColor

            sfx:Play(landSFX)

            if(not h:isRoomClear()) then
                local dmgMulti = 1
                if(familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then dmgMulti = 2 end
                Isaac.Explode(familiar.Position, familiar.Player, collDamage*dmgMulti)
            end

            familiar.Coins = 0
            data.dmgCooldown = damageCooldown
            data.isInvincible = false
            data.isTouchable = true
            data.slamInvincibility = true
            familiar.Visible = true
        end

        if(data.dmgCooldown>0) then
            if(data.isInvincible==false) then data.isInvincible=true end
            if(data.dmgCooldown==damageCooldown-3) then
                familiar.Color = Color(1,1,1,1,0,0,0)
            end

            if(data.slamInvincibility==false) then familiar.Visible = (data.dmgCooldown%6>2) end

            data.dmgCooldown=data.dmgCooldown-1
            if(data.dmgCooldown==0) then
                data.isInvincible = false
                data.slamInvincibility = false
                familiar.Visible = true
            end
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
        if((anim=="Jump" and data.isTouchable==false) or anim=="JumpIdle") then
            local speedMult=0.1*(familiar.Coins/20)+0.001*(1-familiar.Coins/20)
            familiar.Coins = familiar.Coins+1
            familiar.Velocity = (data.currentTarget.Position-familiar.Position)*speedMult*(1+(familiar.Coins*10)/100)

            if((anim=="JumpIdle" and (data.currentTarget.Position-familiar.Position):Length()<=20) or familiar.Coins>120) then
                sprite:Play("Slam", true)
            end
        end
        if(anim=="Slam") then
            familiar.Velocity = Vector.Zero
        end
        if(familiar.HitPoints==0 or familiar.Keys==0) then
            for _=1, gibsAmount do
                local particle = Isaac.Spawn(1000,5,0,familiar.Position,Vector(2,0):Rotated(familiar:GetDropRNG():RandomFloat()*360), familiar):ToEffect()
            end
            local explosion = Isaac.Spawn(1000,2,0,familiar.Position,Vector.Zero,familiar):ToEffect()
            sfx:Play(deathSFX1)
            sfx:Play(deathSFX2)
            familiar:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, blockbumVar)

function funcs:preFamiliarCollision(familiar, collider, low)
    if(familiar.SubType==blockbumSubType) then
        local data = familiar:GetData()
        if(data.isTouchable==false) then return true end

        if(collider:IsVulnerableEnemy() or collider.Type==9) then
            if(collider.Type==9) then collider:Die() end

            if(data.isInvincible==false) then
                familiar.HitPoints = familiar.HitPoints-1
                data.oldColor = familiar.Color
                local color = familiar.Color
                color.RO = 1
                familiar.Color = color
                data.dmgCooldown = damageCooldown
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.preFamiliarCollision, blockbumVar)

function funcs:postNewRoom()
    local room = Game():GetRoom()
    if(room:IsFirstVisit() and not room:IsClear()) then
        for i, entity in ipairs(Isaac.FindByType(3, blockbumVar, blockbumSubType)) do
            entity = entity:ToFamiliar()
            entity.Keys = entity.Keys-1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ENTITIES.BLOCKBUMS.BASIC = {}