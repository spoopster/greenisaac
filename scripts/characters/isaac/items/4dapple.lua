local mod = jezreelMod
local SFX = SFXManager()

local fourDimApple =  mod.ENUMS.VEGETABLES.FOUR_DIMENSIONAL_APPLE
local appleVariant = Isaac.GetEntityVariantByName("The Apple")
local shootSfx = SoundEffect.SOUND_BEAST_GHOST_DASH

SFX:Preload(shootSfx)

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    local roomApples = {}
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, appleVariant)) do
        if(GetPtrHash(entity:ToFamiliar().Player)==GetPtrHash(player)) then
            roomApples[#roomApples+1]=entity
        end
    end
    data.playerApples = data.playerApples or 0
    if(data.playerApples~=#roomApples or (#roomApples>0 and roomApples[#roomApples]:GetData().rotationOffset~=190)) then
        for i, entity in ipairs(roomApples) do
            entity:GetData().rotationOffset = (i/(#roomApples))*190
        end
        data.playerApples = #roomApples
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param familiar EntityFamiliar
function funcs:familiarInit(familiar)
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()
    sprite:Play("Idle", true)
    familiar:AddToOrbit(42)
    data.rotationOffset = 0
    data.transmogrifyCooldown = 0
    familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    familiar.SpriteOffset = Vector(0,-16)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, appleVariant)

---@param familiar EntityFamiliar
function funcs:familiarUpdate(familiar)
    local data = familiar:GetData()
    local player = familiar.Player

    local orbitX = 0
    local orbitY = 0

    if(familiar.Hearts<=0) then
        local time = (Game():GetFrameCount()+data.rotationOffset)/30
        local f = 1/math.cos(time-(math.pi/2)*(math.floor((4*time+math.pi)/(2*math.pi))))
        orbitX = math.cos(time)*f
        orbitY = math.sin(time)*f

        local newPos = player.Position+player.Velocity+Vector(orbitX,orbitY)*60

        familiar.Velocity = newPos-familiar.Position
    else
        local time = familiar.Coins/30
        local f = 1/math.cos(time-(math.pi/2)*(math.floor((4*time+math.pi)/(2*math.pi))))
        orbitX = math.cos(time)*f
        orbitY = math.sin(time)*f

        local newPos = player.Position+player.Velocity+Vector(orbitX,orbitY)*60

        familiar.Position = newPos
    end

    if(data.transmogrifyCooldown>0)then
        data.transmogrifyCooldown = data.transmogrifyCooldown-1
    end

    local tears = Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.TEAR)
    if(#tears>=1 and data.transmogrifyCooldown==0) then
        for _, apple in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,appleVariant)) do
            if(GetPtrHash(familiar)~=GetPtrHash(apple) and GetPtrHash(familiar.Player)==GetPtrHash(apple:ToFamiliar().Player)) then
                local angle = (apple.Position-familiar.Player.Position):GetAngleDegrees()
                if(angle < 45 and angle >= -45) then
                    angle = 0
                elseif(angle < -45 and angle >= -135) then
                    angle = -90
                elseif(angle > 45 and angle <= 135) then
                    angle = 90
                else
                    angle = 180
                end
                for _, tear in ipairs(tears) do
                    if(tear.Velocity:Length()>=3 and apple:GetData().transmogrifyCooldown==0) then
                        tear = tear:ToTear()
                        if(tear and tear:GetData().appleTear~=true) then
                            local tear1 = Isaac.Spawn(tear.Type, tear.Variant, tear.SubType, apple.Position, tear.Velocity:Rotated(angle-tear.Velocity:GetAngleDegrees()), tear.SpawnerEntity):ToTear()
                            for key, val in pairs(tear:GetData()) do
                                tear1:GetData()[key] = val
                            end
                            local anim = tear1:GetSprite():GetAnimation()
                            tear1:GetSprite():Play(anim, true)
                            tear1:GetData().appleTear = true
                            tear1.FallingSpeed = tear.FallingSpeed
                            tear1.FallingAcceleration = tear.FallingAcceleration
                            tear1.Height = tear.Height
                            local col = tear.Color
                            tear1:GetData().baseColor = col
                            col:SetColorize(20,20,20,5)
                            tear1.Color = col
                            tear1.Scale = tear.Scale
                            tear1.TearFlags = tear.TearFlags
                            tear1.CollisionDamage = tear.CollisionDamage
                            SFX:Play(shootSfx, 0.5, 2, false, 1.5, 0)
                        end
                        apple:GetData().transmogrifyCooldown=15
                    end
                end
                data.transmogrifyCooldown=15
            end
        end
        for _, tear in ipairs(tears) do
            if(tear.Velocity:Length()>=3) then
                tear = tear:ToTear()
                if(tear and tear:GetData().appleTear~=true) then
                    tear:GetData().appleTear = true
                end
            end
        end
    end

    if(familiar.Hearts>0) then familiar.Hearts=familiar.Hearts-1 end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, appleVariant)

---@param player EntityPlayer
function funcs:peffectUpdate(player)
    player:GetData().playerApples = #(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,appleVariant))
    local appleNum = player:GetCollectibleNum(fourDimApple)+player:GetEffects():GetCollectibleEffectNum(fourDimApple)
    local appleMult = 4
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then appleMult=6 end

	player:CheckFamiliar(appleVariant,appleNum*appleMult,player:GetCollectibleRNG(fourDimApple),Isaac.GetItemConfig():GetCollectible(fourDimApple))
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, funcs.peffectUpdate)

function funcs:postTearUpdate(tear)
    local data = tear:GetData()
    if(data.appleTear) then
        if(data.baseColor) then
            local col = data.baseColor
            local tint = math.sin(tear.FrameCount/2)*0.5+1

            col:SetColorize(tint,tint,tint,0.8)
            tear.Color = col
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

function funcs:postNewRoom()
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, appleVariant)) do
        entity.Velocity = Vector.Zero
        entity:ToFamiliar().Hearts=1
        entity:ToFamiliar().Coins=(Game():GetFrameCount()+math.floor(entity:GetData().rotationOffset))
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ITEMS.FOURDIMENSIONALAPPLE = funcs