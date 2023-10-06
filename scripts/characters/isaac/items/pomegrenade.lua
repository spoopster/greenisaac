local mod = jezreelMod

local pomegrenade = mod.ENUMS.VEGETABLES.POMEGRENADE

local grenadeCol = Color(1,1,1)
grenadeCol:SetColorize(1,0,0.3,1)

local GRENADE_NUM = 2
local GRENADE_ANGLE = 40
local GRENADE_SPEED = 20
local GRENADE_BOMB_DAMAGE = 40

local SEED_NUM = 10
local SEED_DAMAGE = 3
local SEED_SPEED = 10

local JUICE_DAMAGE = 3

local funcs = {}

---@param player EntityPlayer
local function firePomegrenadeTear(player, pos, vel)
    local tear = player:FireTear(pos, vel, false, true, false, player)

    local rng = player:GetCollectibleRNG(pomegrenade)

    tear.FallingSpeed = -20
    tear.FallingAcceleration = 2+rng:RandomFloat()-0.5
    tear.TearFlags = TearFlags.TEAR_NORMAL
    tear.CollisionDamage = 0

    tear.Color = grenadeCol

    return tear
end

---@param player EntityPlayer
local function usePomegrenade(player)
    local joystick = player:GetShootingJoystick()
    local rng = player:GetCollectibleRNG(pomegrenade)

    local carBatteryMod = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CAR_BATTERY)+1

    for i=1, GRENADE_NUM*carBatteryMod do
        local tearVel = Vector.FromAngle(joystick:GetAngleDegrees()+(rng:RandomFloat()-0.5)*GRENADE_ANGLE)*GRENADE_SPEED*(rng:RandomFloat()*1/2+1/2)
        local tear = firePomegrenadeTear(player, player.Position, tearVel)

        tear:GetData().pomegrenadeTear = true
        tear.CollisionDamage = 0

        tear.Scale = 1.5

        tear.Color = grenadeCol
    end
end

function funcs:useItem(_, _, player, flags, slot, _)
    if(flags & UseFlag.USE_CARBATTERY == 0) then
        local data = player:GetData()
        if(data.usingPomegrenade) then
            player:AnimateCollectible(pomegrenade, "HideItem", "PlayerPickup")
            data.usingPomegrenade = nil
        else
            player:AnimateCollectible(pomegrenade, "LiftItem", "PlayerPickup")
            data.usingPomegrenade = slot
        end
    end

    return{
        Discharge = false,
        Remove = false,
        ShowAnim = false,
    }
end

mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.LATE, funcs.useItem, pomegrenade)

function funcs:postPlayerRender(player, _)
    local data = player:GetData()
    if(data.usingPomegrenade) then
        local joystick = player:GetShootingJoystick()

        if(joystick:Length()>0.05) then
            player:DischargeActiveItem(data.usingPomegrenade)

            data.usingPomegrenade = nil

            usePomegrenade(player)

            player:AnimateCollectible(pomegrenade, "HideItem", "PlayerPickup")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, funcs.postPlayerRender)

function funcs:inputAction(entity, hook, action)
    if(hook==InputHook.IS_ACTION_TRIGGERED and action==ButtonAction.ACTION_DROP) then
        if(entity and entity:ToPlayer()) then
            if(entity:GetData().usingPomegrenade) then
                return false
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, funcs.inputAction, InputHook.IS_ACTION_TRIGGERED)

function funcs:postNewRoom()
    for i=0,Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(i)
        if(player:GetData().usingPomegrenade) then
            player:GetData().usingPomegrenade=nil
            player:AnimateCollectible(pomegrenade, "HideItem", "PlayerPickup")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:entityTakeDMG(entity)
    entity=entity:ToPlayer()
    if(entity and entity:GetData().usingPomegrenade) then
        entity:GetData().usingPomegrenade=nil
        entity:AnimateCollectible(pomegrenade, "HideItem", "PlayerPickup")
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, 1)

function funcs:postEntityRemove(entity)
    if(entity.Type~=2) then return end
    if(not (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer())) then return end
    if(entity:GetData().pomegrenadeTear==nil) then return end

    entity = entity:ToTear()
    local player = entity.SpawnerEntity:ToPlayer()

    Isaac.Explode(entity.Position, player, GRENADE_BOMB_DAMAGE)

    local rng = player:GetCollectibleRNG(pomegrenade)

    for i=1, SEED_NUM do
        local tearVel = Vector.FromAngle(rng:RandomFloat()*360)*SEED_SPEED*(rng:RandomFloat()*3/4+1/4)
        local tear = firePomegrenadeTear(player, entity.Position, tearVel)

        tear.CollisionDamage = SEED_DAMAGE
    end

    local juice = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_LEMON_MISHAP, 0, entity.Position, Vector.Zero, player):ToEffect()
    juice.Color = Color(0,0,0,1,0.8,0.1,0.2)
    juice.CollisionDamage = JUICE_DAMAGE
    juice:Update()
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

mod.ITEMS.POMEGRENADE = funcs