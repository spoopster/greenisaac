local mod = jezreelMod
local h = include("scripts/func")

local bloodyOrange = mod.ENUMS.VEGETABLES.BLOODY_ORANGE

local BLOOD_CREEP_COOL = 2 --frames
local ORANGE_CREEP_COOL = 300 --frames
local ORANGE_TEAR_NUM = 5
local ORANGE_EXTRATEARS_NUM = 2

local ORANGE_TEAR_SPEED = 6
local ORANGE_TEAR_ANGLE = 15

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    if(not player:HasCollectible(bloodyOrange)) then return end

    local data = player:GetData()
    local orangeNum = player:GetCollectibleNum(bloodyOrange)

    if(data.spawnedOrangeCreep==nil) then
        if(player.FrameCount%ORANGE_CREEP_COOL==0 and not h:isRoomClear()) then
            local blood = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_LEMON_MISHAP, 0, player.Position, Vector.Zero, player):ToEffect()
            blood.CollisionDamage = 2
            blood.Color = Color(0.65,0,0,1,0,0,0)
            for i=1,6 do
                blood:Update()
            end

            local tearNum = ORANGE_TEAR_NUM+ORANGE_EXTRATEARS_NUM*(orangeNum-1)

            for i=1,tearNum do
                local tear = player:FireTear(player.Position, Vector.FromAngle(i*360/tearNum)*ORANGE_TEAR_SPEED,true,true,false,player,1)
                tear.CollisionDamage = player.Damage*0.5
                tear:ClearTearFlags(tear.TearFlags)

                tear.Color = Color(1,0,0,1)
                tear:GetData().isBloodyOrangeTear = true

                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
                tear.KnockbackMultiplier = 0

                tear.Height = -6
                tear.FallingAcceleration = -0.0895
                tear.FallingSpeed = 0
            end
        elseif(player.FrameCount%BLOOD_CREEP_COOL==0 and player.Velocity:Length()>2) then
            local blood = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector.Zero, player):ToEffect()
            blood.CollisionDamage = 1
            blood.Scale = 0.5
            blood.Timeout = 10
            blood:Update()
        end


        data.spawnedOrangeCreep=true
    else
        data.spawnedOrangeCreep=nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    if(tear:GetData().isBloodyOrangeTear) then
        if(tear.FrameCount>=5 and tear.FrameCount<20) then
            tear.FallingSpeed = -3.75*((tear.FrameCount-5)/15)
        elseif(tear.FrameCount==20) then
            tear.FallingSpeed = 0
        end
        tear.Velocity = tear.Velocity:Rotated(ORANGE_TEAR_ANGLE)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

mod.ITEMS.BLOODYORANGE = funcs