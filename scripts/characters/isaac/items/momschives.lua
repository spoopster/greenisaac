local mod = jezreelMod
local h = include("scripts/func")

local momsChives = mod.ENUMS.VEGETABLES.MOMS_CHIVES
local chive = Isaac.GetEntityVariantByName("Mom's Chive")

local CHIVE_ANGLECHANGE = 1.5
local SIN_SPEED_MOD = 3.1
local CHIVE_MAXDIST = 120
local CHIVE_MINDIST = 40

local CHIVE_DAMAGE_FAR = 3
local CHIVE_DAMAGE_CLOSE = 8

local funcs = {}

local function getPlayerChives(player)
    local chives = {}

    for i, ent in ipairs(Isaac.FindByType(3,chive)) do
        if(GetPtrHash(ent:ToFamiliar().Player)==GetPtrHash(player)) then
            chives[#chives+1] = ent
        end
    end

    return chives
end

function funcs:postUpdate()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local chives = getPlayerChives(player)
        local isOffsetChanged = false
        for i, ent in ipairs(chives) do
            local oldOffset = ent:GetData().chiveAngleOffset
            ent:GetData().chiveAngleOffset = i*360/(#chives)
            if(oldOffset~=ent:GetData().chiveAngleOffset) then
                isOffsetChanged=true
            end
        end
        if(isOffsetChanged) then
            for j, ent in ipairs(chives) do
                ent:GetData().chiveCurrAngle=0
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, funcs.postUpdate)

---@param familiar EntityFamiliar
function funcs:postFamiliarInit(familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle", true)
    sprite.Offset = Vector(0, -16)

    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    familiar.Target = nil
    familiar:GetData().chiveCurrAngle = 0
    familiar:GetData().chiveAngleOffset = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.postFamiliarInit, chive)

---@param familiar EntityFamiliar
function funcs:postFamiliarUpdate(familiar)
    local data = familiar:GetData()
    local player = familiar.Player:ToPlayer()

    local hasBffsMod = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local hasSpinToWinEffect = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIN_TO_WIN)>0

    local damageMod = ((hasSpinToWinEffect and 1.5*((hasBffsMod and 0.5) or 1)) or 1)*((h:hasGreenIsaacBirthright(player) and 1.5) or 1)

    if(hasSpinToWinEffect) then
        local shouldTint = (math.sin(math.rad(familiar.FrameCount*20))+1)/2
        local tint = 0.1+0.2*shouldTint
        familiar.Color = Color(1,1,1,1,tint,tint,tint)
    else
        familiar.Color = Color(1,1,1,1,0,0,0)
    end

    local angle = 0
    local sin = 0

    if(familiar.Hearts<=0) then
        data.chiveCurrAngle = data.chiveCurrAngle+(CHIVE_ANGLECHANGE)*((hasSpinToWinEffect and 3) or 1)

        angle = data.chiveCurrAngle+data.chiveAngleOffset
        sin = (math.sin(math.rad(angle*SIN_SPEED_MOD))/2+1/2)

        local pos = Vector.FromAngle(angle):Resized(CHIVE_MINDIST+sin*(CHIVE_MAXDIST-CHIVE_MINDIST))+player.Position+player.Velocity

        familiar.Velocity = pos-familiar.Position
    else
        angle = familiar.Coins/100+data.chiveAngleOffset
        sin = (math.sin(math.rad(angle*SIN_SPEED_MOD))/2+1/2)

        local pos = Vector.FromAngle(angle):Resized(CHIVE_MINDIST+sin*(CHIVE_MAXDIST-CHIVE_MINDIST))+player.Position+player.Velocity

        familiar.Position = pos
    end

    familiar.SpriteRotation = angle
    familiar.CollisionDamage = (CHIVE_DAMAGE_CLOSE+sin*(CHIVE_DAMAGE_FAR-CHIVE_DAMAGE_CLOSE))*damageMod+((hasSpinToWinEffect and 6) or 0)

    if(familiar.Hearts>0) then familiar.Hearts=familiar.Hearts-1 end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.postFamiliarUpdate, chive)

function funcs:peffectUpdate(player)
	local chiveNum = player:GetCollectibleNum(momsChives)+player:GetEffects():GetCollectibleEffectNum(momsChives)

    local chiveMult = 3
    if(h:hasGreenIsaacBirthright(player)) then chiveMult = 5 end

	player:CheckFamiliar(chive,chiveNum*chiveMult,player:GetCollectibleRNG(momsChives),Isaac.GetItemConfig():GetCollectible(momsChives))
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, funcs.peffectUpdate)

function funcs:postNewRoom()
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, chive)) do
        entity.Velocity = Vector.Zero
        entity:ToFamiliar().Hearts=1
        entity:ToFamiliar().Coins=(math.floor((entity:GetData().chiveCurrAngle)*100))
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ITEMS.MOMSCHIVES = funcs