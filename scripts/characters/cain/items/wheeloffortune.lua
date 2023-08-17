local mod = jezreelMod

local h = include("scripts/func")

local wheelOfFortune = mod.ENUMS.ITEMS.WHEEL_OF_FORTUNE
local greenmobileVar = Isaac.GetEntityVariantByName("Greenmobile")

local CAR_SPEED = 20
local CAR_BATTERY_SPEED = 10
local CAR_DAMAGE = 40
local CAR_BATTERY_DAMAGE = 80

local genericActiveReturn = {
    Discharge=true,
    Remove=false,
    ShowAnim=true,
}

local DIRECTION_TO_ANIM = {
    [Direction.LEFT] = "Left",
    [Direction.RIGHT] = "Right",
    [Direction.UP] = "Up",
    [Direction.DOWN] = "Down",
}

local funcs = {}

local function angleToDir(angle)
    angle = angle%360

    if((angle>315) or (angle>=0 and angle<=45)) then return Direction.RIGHT
    elseif(angle>45 and angle<=135) then return Direction.DOWN
    elseif(angle>135 and angle<=225) then return Direction.LEFT end
    return Direction.UP
end

function funcs:useItem(item, rng, player, flags, slot, vData)
    if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then return genericActiveReturn end

    local tear = Isaac.Spawn(2,greenmobileVar,0,player.Position,Vector.Zero,player):ToTear()
    tear:GetData().carBatteryMobile = false
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then
        tear:SetSize(tear.Size, tear.SizeMulti*2, 12)
        tear:GetData().carBatteryMobile = true
    end

    return genericActiveReturn
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, wheelOfFortune)

---@param tear EntityTear
function funcs:postTearInit(tear)
    tear:GetSprite():Play("Right", true)
    tear.FallingAcceleration = -0.1
    tear.FallingSpeed = 0
    tear.Height = -5
    tear.SpriteOffset = Vector(0,5)
    tear.CollisionDamage = 0
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, funcs.postTearInit, greenmobileVar)

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    --if(tear.Variant~=greenmobileVar) then return end
    local player = tear.SpawnerEntity
    if(not player or (player and not player:ToPlayer())) then return end
    player = player:ToPlayer()

    local stick = player:GetShootingJoystick()
    local lerpF = 0.15
    if(stick:Length()==0) then lerpF=0.25 end
    local speed = (tear:GetData().carBatteryMobile and CAR_BATTERY_SPEED) or CAR_SPEED
    tear.Velocity = h:lerp(tear.Velocity, stick*speed, lerpF)


    local dir = DIRECTION_TO_ANIM[angleToDir(tear.Velocity:GetAngleDegrees())]
    tear:GetSprite():SetAnimation(dir, false)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate, greenmobileVar)

function funcs:postTearRemove(tear)
    tear=tear:ToTear()

    if(tear.Variant==greenmobileVar) then
        local spawner = tear.SpawnerEntity or Isaac.GetPlayer()
        Isaac.Explode(tear.Position,spawner,(tear:GetData().carBatteryMobile and CAR_BATTERY_DAMAGE) or CAR_DAMAGE)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postTearRemove, EntityType.ENTITY_TEAR)

mod.ITEMS.WHEELOFFORTUNE = funcs