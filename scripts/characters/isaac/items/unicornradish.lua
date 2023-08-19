local mod = jezreelMod
local h = include("scripts/func")

local unicornradish = mod.ENUMS.VEGETABLES.UNICORNRADISH
local unicorn = CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN

local RADISH_DURATION = 6*60
local RADISH_COOLDOWN = 5*60
local RADISH_SPEEDINCREMENT = 0.005
local RADISH_SPEEDDECREMENT = 0.05
local RADISH_THRESHOLD = 1

local RADISH_BEAM_COOL = 20
local RADISH_BEAM_DMG = 0.5
local RADISH_TEAR_NUM = 8
local RADISH_TEAR_DMG = 2

local UNICORN_NUM = 99

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    if(player:IsDead()) then return end
    local data = player:GetData()
    local radishNum = player:GetCollectibleNum(unicornradish)

    if(data.unicornRadishDuration and radishNum<=0) then
        data.unicornRadishDuration=nil

        player:GetEffects():RemoveCollectibleEffect(unicorn, UNICORN_NUM)
    end

    if(radishNum<=0) then return end
    if(data.unicornRadishCooldown==nil) then data.unicornRadishCooldown=0 end
    if(data.unicornSpeedBonus==nil) then data.unicornSpeedBonus=0 end
    if(data.unicornRadishDuration==nil) then data.unicornRadishDuration=-1 end

    if(data.unicornRadishDuration>0) then
        data.unicornRadishDuration=data.unicornRadishDuration-1

        if(data.unicornRadishDuration%RADISH_BEAM_COOL==0) then
            local lightBeam = Isaac.Spawn(1000, EffectVariant.CRACK_THE_SKY, 0, player.Position+Vector(0,1), Vector.Zero, player)
            lightBeam.CollisionDamage = RADISH_BEAM_DMG

            for i = 1, RADISH_TEAR_NUM do
                local vel = Vector.FromAngle(i*360/RADISH_TEAR_NUM)*12*player.ShotSpeed
                local tear = player:FireTear(player.Position, vel, true, true, false, player)

                tear.FallingSpeed = 0
                tear.FallingAcceleration = 0
                tear.TearFlags = TearFlags.TEAR_NORMAL
                tear.CollisionDamage = RADISH_TEAR_DMG

                local col = Color(1,1,1)

                col:SetColorize(1,1,0.6,1)

                tear.Color = col
            end
        end
    elseif(data.unicornRadishDuration==0) then
        data.unicornRadishDuration=-1
        data.unicornRadishCooldown=RADISH_COOLDOWN

        player:GetEffects():RemoveCollectibleEffect(unicorn, UNICORN_NUM)
    end

    if(data.unicornRadishDuration>=0) then return end

    if(data.unicornRadishCooldown>0 or h:isRoomClear()) then
        if(data.unicornRadishCooldown>0) then
            data.unicornRadishCooldown=data.unicornRadishCooldown-1
        end

        if(data.unicornSpeedBonus>0) then
            data.unicornSpeedBonus=data.unicornSpeedBonus-RADISH_SPEEDDECREMENT
            if(data.unicornSpeedBonus<=0) then data.unicornSpeedBonus=0 end
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    end
    if(data.unicornRadishCooldown>0 or h:isRoomClear()) then return end

    if(data.unicornSpeedBonus<RADISH_THRESHOLD) then
        if(player:GetShootingJoystick():Length()<=0.05) then
            data.unicornSpeedBonus=data.unicornSpeedBonus+RADISH_SPEEDINCREMENT*1.5^(radishNum-1)
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    else
        data.unicornRadishDuration=RADISH_DURATION
        player:GetEffects():AddCollectibleEffect(unicorn, true, UNICORN_NUM)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(unicornradish)) then
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed + (player:GetData().unicornSpeedBonus or 0)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

function funcs:postNewRoom()
    for i=0, Game():GetNumPlayers()-1 do
        local data = Isaac.GetPlayer(i):GetData()
        if(data.unicornRadishDuration and data.unicornRadishDuration>0) then data.unicornRadishDuration=-1 end
        if(data.unicornRadishCooldown and data.unicornRadishCooldown>0) then data.unicornRadishCooldown=0 end
        if(data.unicornSpeedBonus and data.unicornSpeedBonus>0) then data.unicornSpeedBonus=0 end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ITEMS.UNICORNRADISH = funcs