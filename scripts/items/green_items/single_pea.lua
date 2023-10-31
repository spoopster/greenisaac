local mod = jezreelMod
local h = include("scripts/func")

local singlePea = mod.ENUMS.VEGETABLES.SINGLE_PEA
local peaVariant = Isaac.GetEntityVariantByName("Juan the Pea")

local funcs = {}

---@param familiar EntityFamiliar
local function firePeaTears(familiar, speed, amount)
    local iMax = amount
    if(iMax==nil) then iMax=1 end
    local angleOffset = familiar:GetDropRNG():RandomFloat()*360
    for i=0, iMax-1 do
        local peaTear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, familiar.Position, Vector(speed,0):Rotated(360*i/iMax+angleOffset), familiar):ToTear()
        peaTear.FallingSpeed = -1
        peaTear.FallingAcceleration = -0.08
        peaTear:GetData().peaTear = true
        peaTear:AddTearFlags(TearFlags.TEAR_DECELERATE | TearFlags.TEAR_PIERCING)
        peaTear.Color = Color(0.5,1,0.2,1,0,0,0)

        peaTear.CollisionDamage = ((h:hasGreenIsaacBirthright(familiar.Player) and 6) or 3.5)
    end
end

---@param familiar EntityFamiliar
function funcs:familiarInit(familiar)
    local data = familiar:GetData()
    familiar.Velocity = Vector(5,5)
    data.peaCooldown = 0
    data.peaCollisionCooldown = 0
    familiar.SpriteOffset = Vector(0,-16)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, peaVariant)

function funcs:familiarUpdate(familiar)
    local data = familiar:GetData()
    local player = familiar.Player
    local room = Game():GetRoom()
    local walls = {
        [1]=room:GetTopLeftPos().Y+14,
        [2]=room:GetBottomRightPos().Y-14,
        [3]=room:GetTopLeftPos().X+14,
        [4]=room:GetBottomRightPos().X-14,
    }
    if((familiar.Position.Y<=walls[1] and familiar.Velocity.Y<0) or (familiar.Position.Y>=walls[2] and familiar.Velocity.Y>0)) then
        familiar.Velocity = Vector(familiar.Velocity.X, familiar.Velocity.Y*-1)
    end
    if((familiar.Position.X<=walls[3] and familiar.Velocity.X<0) or (familiar.Position.X>=walls[4] and familiar.Velocity.X>0)) then
        familiar.Velocity = Vector(familiar.Velocity.X*-1, familiar.Velocity.Y)
    end

    if(data.peaCooldown>0) then
        data.peaCooldown=data.peaCooldown-1
    end
    if(data.peaCollisionCooldown>0) then
        data.peaCollisionCooldown=data.peaCollisionCooldown-1
    end
    if(data.peaShootCooldown~=nil and data.peaShootCooldown>0) then
        data.peaShootCooldown=data.peaShootCooldown-1
    end

    if(data.isBFFs~=player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
        data.isBFFs=player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
        local sprite = familiar:GetSprite()
        if(data.isBFFs==true) then
            sprite:Play("IdleBFFs", true)
            data.peaShootCooldown = 0
            familiar.Size = 20
        else
            sprite:Play("Idle", true)
            data.peaShootCooldown = nil
            familiar.Size = 13
        end
        familiar.SpriteScale = Vector(1,1)
    end
    if(data.peaShootCooldown==0 and not h:isRoomClear()) then
        local peaTear = firePeaTears(familiar, 0, 1)
        data.peaShootCooldown=30
    end

    for i, tear in ipairs(Isaac.FindInRadius(familiar.Position, 13, EntityPartition.TEAR)) do
        if(data.peaCooldown~=0) then break end
        if(tear:GetData().peaTear~=true) then
            firePeaTears(familiar, 6, ((h:hasGreenIsaacBirthright(player) and 7) or 5))
            data.peaCooldown=30
        end
    end
    familiar.SpriteRotation = familiar.FrameCount*2
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, peaVariant)

function funcs:peffectUpdate(player)
	local juanNum = player:GetCollectibleNum(singlePea)+player:GetEffects():GetCollectibleEffectNum(singlePea)
	player:CheckFamiliar(peaVariant,juanNum,player:GetCollectibleRNG(singlePea),Isaac.GetItemConfig():GetCollectible(singlePea))
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, funcs.peffectUpdate)

function funcs:familiarCollision(familiar, collider, low)
    local data = familiar:GetData()
    if(h:isValidEnemy(collider) and data.peaCollisionCooldown==0) then
        firePeaTears(familiar, 6, ((h:hasGreenIsaacBirthright(familiar.Player) and 6) or 4))
        data.peaCollisionCooldown = 30
        data.peaCooldown = 30
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.familiarCollision, peaVariant)

function funcs:postNewRoom()
    for _, entity in ipairs(Isaac.FindByType(3, peaVariant)) do
        entity.Velocity = Vector(5,5):Rotated(entity:GetDropRNG():RandomFloat()*100-50)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ITEMS.SINGLEPEA = funcs
