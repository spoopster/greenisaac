local mod = jezreelMod
local sfx = SFXManager()
local helper = include("scripts/func")

local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local blockbumSubType = 3

local damageCooldown = 30
local slamCooldown = 240
local maxHP = 8
local maxRooms = 5
local gibsAmount = 5
local collDamage = 1.5

local deathSFX1 = 79
local deathSFX2 = 77
local tpSFX1 = 215
local tpSFX2 = 214
sfx:Preload(deathSFX1)
sfx:Preload(deathSFX2)
sfx:Preload(tpSFX1)
sfx:Preload(tpSFX2)


local funcs = {}

function funcs:familiarInit(familiar)
    if(familiar.SubType==blockbumSubType) then
        local sprite = familiar:GetSprite()
        local data = familiar:GetData()
        sprite:Load("gfx/entities/familiars/blockbum/key.anm2", true)
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

        familiar.Velocity = familiar.Velocity*0.6

        if(sprite:IsFinished("Appear")) then sprite:Play("Idle", true) end
        if(sprite:IsFinished("Jump")) then
            sprite:Play("Slam", true)
            familiar.Position = data.currentTarget.Position
        end
        if(sprite:IsFinished("Slam")) then sprite:Play("Idle", true) end
        if(sprite:IsFinished("Shoot")) then sprite:Play("Idle", true) end

        if(sprite:IsEventTriggered("Jump")) then
            data.isInvincible = true
            data.isTouchable = false
            familiar.Visible = true

            sfx:Play(tpSFX1, 0.66, 0, false, 1.2)
        end
        if(sprite:IsEventTriggered("Slam")) then
            sfx:Play(tpSFX2, 0.66, 0, false, 1.2)

            familiar.Coins = 0
            familiar.Velocity = Vector.Zero
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
            familiar.Coins = familiar.Coins+1

            if(familiar.Coins%10==0 and (not helper:isRoomClear())) then
                local closestEnt = helper:closestEnemy(familiar.Position)
                if(closestEnt==nil) then closestEnt = familiar.Player end
                if((closestEnt.Position-familiar.Position):Length()<=320) then
                    local tear = Isaac.Spawn(2,0,0,familiar.Position,Vector(8,0):Rotated((closestEnt.Position-familiar.Position):GetAngleDegrees()), familiar):ToTear()
                    tear.Scale = 0.8
                    tear.FallingAcceleration = -0.1
                    tear.FallingSpeed = 2
                    local dmgMulti = 1
                    if(familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then dmgMulti = 2 end
                    tear.CollisionDamage = collDamage*dmgMulti

                    sprite:Play("Shoot", true)
                end
            end

            if(familiar.Coins>=slamCooldown) then
                familiar.Coins = 0

                data.currentTarget = familiar.Player
                sprite:Play("Jump", true)
            end
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