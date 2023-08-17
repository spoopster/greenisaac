local mod = jezreelMod
local fj = include("scripts/firejet")

local reallySpicyPepper = mod.ENUMS.VEGETABLES.REALLY_SPICY_PEPPER

local PEPPER_CHANCE = 1/100
local TEAR_SPEED = 18
local TEAR_ANGLE_RAND = 45

local JET_DAMAGE_MOD = 3/5
local JET_LENGTH = 3
local JET_DIST = 45
local JET_DELAY = 3

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local pepperNum = player:GetCollectibleNum(reallySpicyPepper)
    if(pepperNum<=0) then return end

    local joyStick = player:GetShootingJoystick()
    if(joyStick:Length()>0.05) then
        local rng = player:GetCollectibleRNG(reallySpicyPepper)
        local pepperChance = (1-PEPPER_CHANCE)^pepperNum

        if(rng:RandomFloat()>pepperChance) then
            local tearVel = Vector.FromAngle(joyStick:GetAngleDegrees()+(rng:RandomFloat()-0.5)*TEAR_ANGLE_RAND)*TEAR_SPEED*(rng:RandomFloat()*2/3+1/3)
            local tear = player:FireTear(player.Position, tearVel, false, true, false, player, 2)

            tear.FallingSpeed = -15
            tear.FallingAcceleration = 2
            tear.TearFlags = TearFlags.TEAR_NORMAL

            tear:GetData().reallySpicyTear = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:postEntityRemove(entity)
    if(entity.Type~=2) then return end
    if(not (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer())) then return end
    if(entity:GetData().reallySpicyTear==nil) then return end

    entity = entity:ToTear()
    local player = entity.SpawnerEntity:ToPlayer()

    for i=0,3 do
        local jet = fj:spawnFireJet(player, player.Damage*JET_DAMAGE_MOD, entity.Position, JET_LENGTH, JET_DIST, JET_DELAY, i*90, nil, nil)
        jet:GetData().fjIsPlayerFriendly = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

mod.ITEMS.REALLYSPICYPEPPER = funcs