local mod = jezreelMod

local sadCucumber = mod.ENUMS.VEGETABLES.SAD_CUCUMBER
local funcs = {}

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()

    if(tear.FrameCount~=1) then return end

    if(tear:GetData().cucumberTear) then return end
    local cucumberNum = player:GetCollectibleNum(sadCucumber)
    if(cucumberNum<=0) then return end

    for i=0,cucumberNum*2 do
        if(i~=cucumberNum) then
            local mult = tear.Size*1.25
            if(math.abs(i-cucumberNum)==1) then mult = tear.Size*(12.5/8) end
            local cucumberTear = player:FireTear(tear.Position+(tear.Velocity:Normalized()*mult*(i-cucumberNum)):Rotated(90)-tear.Velocity, tear.Velocity)

            cucumberTear.TearFlags = tear.TearFlags
            cucumberTear.FallingSpeed = tear.FallingSpeed
            cucumberTear.FallingAcceleration = tear.FallingAcceleration
            cucumberTear.Height = tear.Height
            cucumberTear.CollisionDamage = tear.CollisionDamage*0.25
            cucumberTear.Scale = tear.Scale/2
            cucumberTear.Color = tear.Color
            cucumberTear.GridCollisionClass = tear.GridCollisionClass

            cucumberTear:GetData().cucumberTear = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

--[[ EAT my fucking ass nicalis
function funcs:postLaserUpdate(laser)
    if(laser.FrameCount~=1) then return end
    if(laser:GetData().cucumberTear) then return end

    if(not (laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer())) then return end

    local player = laser.SpawnerEntity:ToPlayer()

    local numCucumber = player:GetCollectibleNum(sadCucumber)

    for i=0,numCucumber*2 do
        if(i~=numCucumber) then
            local mult = laser.Radius*0.15

            local angleDif = (i-numCucumber)

            local spawnPos = laser.Position+(Vector.FromAngle(laser.Angle)*mult*angleDif):Rotated(90)
            local cucumberTear = EntityLaser.ShootAngle(laser.Variant, spawnPos, laser.Angle+angleDif*mult*0.25, laser.Timeout, laser.PositionOffset, laser.SpawnerEntity)
            cucumberTear.SubType = laser.SubType
            cucumberTear.Velocity = laser.Velocity
            cucumberTear.TearFlags = laser.TearFlags
            cucumberTear.LaserLength = laser.LaserLength
            cucumberTear.MaxDistance = laser.MaxDistance
            cucumberTear.OneHit = laser.OneHit
            cucumberTear.ParentOffset = laser.ParentOffset
            cucumberTear.Shrink = laser.Shrink
            cucumberTear.Radius = laser.Radius
        end
    end


end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, funcs.postLaserUpdate)
]]

---@param player EntityPlayer
---@param flag CacheFlag
function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(sadCucumber)) then
        if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay*(0.9^player:GetCollectibleNum(sadCucumber))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.SADCUCUMBER = funcs