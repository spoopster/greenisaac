local mod = jezreelMod
local h = include("scripts/func")

local clumpOfHay = mod.ENUMS.VEGETABLES.CLUMP_OF_HAY
local haythingL1 = Isaac.GetEntityVariantByName("Haything L1")
local haythingL2 = Isaac.GetEntityVariantByName("Haything L2")
local haythingL3 = Isaac.GetEntityVariantByName("Haything L3")

local HAYTHING1_ORBITSPEED = 2
local HAYTHING2_ORBITSPEED = 2.5

local HAYTHING_ORBDIST = Vector(35,25)
local HAYTHINGORB_DAMAGE = 5

local HAYTHING2_PROJCOOLDOWN = 30

local HAYTHING3_DAMAGE = 2.5
local HAYTHING3_MAXDIST = 4*40
local HAYTHING3_MAXSPEED = 100

local funcs = {}

-- DO NOT ASK WHY I ONLY USE THIS IN THIS SPECIFIC FAMILIAR I LITERALLY JUST FORGOT IT EXISED UNTIL NOW LOL
function funcs:evaluateCache(player, cacheFlag)
	local clumpsNum = player:GetCollectibleNum(clumpOfHay)+player:GetEffects():GetCollectibleEffectNum(clumpOfHay)

	if(clumpsNum==1) then
        player:CheckFamiliar(haythingL1,1,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
        player:CheckFamiliar(haythingL2,0,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
        player:CheckFamiliar(haythingL3,0,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
    elseif(clumpsNum==2) then
        player:CheckFamiliar(haythingL1,0,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
        player:CheckFamiliar(haythingL2,1,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
        player:CheckFamiliar(haythingL3,0,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
    else
        player:CheckFamiliar(haythingL1,0,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
        player:CheckFamiliar(haythingL2,0,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
        player:CheckFamiliar(haythingL3,clumpsNum-2,player:GetCollectibleRNG(clumpOfHay),Isaac.GetItemConfig():GetCollectible(clumpOfHay))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache, CacheFlag.CACHE_FAMILIARS)

local function getNewOrbitPos(familiar, dist, speed, hasSpinToWin)
    local data = familiar:GetData()

    data.haythingAngle = (data.haythingAngle or 0) + speed*((hasSpinToWin and 3) or 1)

    local pos = Vector.FromAngle(data.haythingAngle):Normalized()*dist
    local finalPos = familiar.Player.Position+familiar.Player.Velocity+pos

    return finalPos
end
local function updateHaythingOrbitColor(familiar, hasSpinToWin)
    if(hasSpinToWin) then
        local shouldTint = (math.sin(math.rad(familiar.FrameCount*20))+1)/2
        local tint = 0.1+0.2*shouldTint
        familiar.Color = Color(1,1,1,1,tint,tint,tint)
    else
        familiar.Color = Color(1,1,1,1,0,0,0)
    end
end

--#region L1

---@param familiar EntityFamiliar
function funcs:postFamiliarInitL1(familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle", true)
    sprite.Offset = Vector(0, -16)

    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    familiar.Target = nil
    familiar:GetData().haythingAngle = 0

    familiar:AddToOrbit(2)
    familiar:RemoveFromFollowers()
    familiar.Position = familiar.Player.Position
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.postFamiliarInitL1, haythingL1)

---@param familiar EntityFamiliar
function funcs:postFamiliarUpdateL1(familiar)
    local player = familiar.Player:ToPlayer()

    local hasBffsMod = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local hasSpinToWinEffect = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIN_TO_WIN)>0

    local damageMod = ((hasSpinToWinEffect and 1.5*((hasBffsMod and 0.5) or 1)) or 1)*((player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 2) or 1)

    familiar.CollisionDamage = HAYTHINGORB_DAMAGE*damageMod+((hasSpinToWinEffect and 6) or 0)

    updateHaythingOrbitColor(familiar, hasSpinToWinEffect)

    familiar.OrbitDistance = HAYTHING_ORBDIST
	familiar.DepthOffset = -1
    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity)-familiar.Position
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.postFamiliarUpdateL1, haythingL1)

--#endregion

--#region L2

---@param familiar EntityFamiliar
function funcs:postFamiliarInitL2(familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle", true)
    sprite.Offset = Vector(0, -16)

    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    familiar.Target = nil
    familiar:GetData().haythingAngle = 0

    familiar:AddToOrbit(2)
    familiar:RemoveFromFollowers()
    familiar.Position = familiar.Player.Position
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.postFamiliarInitL2, haythingL2)

---@param familiar EntityFamiliar
function funcs:postFamiliarUpdateL2(familiar)
    local player = familiar.Player:ToPlayer()
    local sprite = familiar:GetSprite()

    local hasBffsMod = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local hasSpinToWinEffect = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIN_TO_WIN)>0

    local damageMod = ((hasSpinToWinEffect and 1.5*((hasBffsMod and 0.5) or 1)) or 1)

    familiar.CollisionDamage = (HAYTHINGORB_DAMAGE*damageMod+((hasSpinToWinEffect and 6) or 0))*((player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 2) or 1)

    updateHaythingOrbitColor(familiar, hasSpinToWinEffect)

    if(familiar.Hearts<=0 and player:GetFireDirection()~=-1) then
        local tear = familiar:FireProjectile(player:GetShootingJoystick())
        local col = Color(1,1,1)
        col:SetColorize(1,0.8,0.3,1)
        tear.Color = col

        familiar.Hearts = HAYTHING2_PROJCOOLDOWN
    end

    local anim = "Idle"
    if(familiar.Hearts>math.max(HAYTHING2_PROJCOOLDOWN-5, 0)) then anim="Shoot" end

    if(sprite:GetAnimation()~=anim) then
        sprite:SetAnimation(anim,false)
    end

    if(familiar.Hearts>0) then familiar.Hearts=familiar.Hearts-1 end

    familiar.OrbitDistance = HAYTHING_ORBDIST
	familiar.DepthOffset = -1
    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity)-familiar.Position
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.postFamiliarUpdateL2, haythingL2)

--#endregion

--#region L3

local function getCloserEnemy(enemy1, enemy2, pos)
    local dist1 = 2^32
    local dist2 = 2^32
    if(enemy1) then dist1 = enemy1.Position:Distance(pos) end
    if(enemy2) then dist2 = enemy2.Position:Distance(pos) end

    if(dist1<=dist2) then return enemy1
    else return enemy2 end
end

---@param familiar EntityFamiliar
function funcs:postFamiliarInitL3(familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle", true)

    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    familiar.Target = nil
    familiar:GetData().isHopping = false
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.postFamiliarInitL3, haythingL3)

---@param familiar EntityFamiliar
function funcs:postFamiliarUpdateL3(familiar)
    local player = familiar.Player:ToPlayer()
    local sprite = familiar:GetSprite()

    familiar.Velocity = familiar.Velocity*0.5
    familiar.CollisionDamage = HAYTHING3_DAMAGE*((player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 2) or 1)

    if(familiar.Target) then
        if(not (sprite:IsPlaying("Hop"))) then sprite:Play("Hop", true) end

        if(sprite:IsEventTriggered("StartHop")) then familiar:GetData().isHopping=true end
        if(sprite:IsEventTriggered("StopHop")) then
            familiar:GetData().isHopping=false

            local poof = Isaac.Spawn(1000,16,1,familiar.Position,Vector.Zero,familiar):ToEffect()
            local poofSprite = poof:GetSprite()
            poofSprite:ReplaceSpritesheet(0, "gfx/entities/familiars/blockbum/blockbumPoof.png")
            poofSprite:LoadGraphics()
            poof.SpriteScale = Vector(0.5,0.5)
            poof.Color = Color(1,0.8,0.4,0.75)
        end

        local dist = (familiar.Target.Position-familiar.Position)/4

        if(familiar:GetData().isHopping==true) then
            familiar.Velocity = ((dist:Length()<=HAYTHING3_MAXSPEED and dist) or dist:Resized(HAYTHING3_MAXSPEED))
            familiar.CollisionDamage = 0
        end
    else
        if(sprite:GetAnimation()=="Idle") then
            local c1=h:closestEnemy(familiar.Player.Position)
            if(c1) then c1=(c1.Position:Distance(familiar.Player.Position)<=HAYTHING3_MAXDIST and c1) or nil end
            local c2=h:closestEnemy(familiar.Position)
            if(c2) then c2=(c2.Position:Distance(familiar.Position)<=HAYTHING3_MAXDIST and c2) or nil end
            local closest = getCloserEnemy(c1, c2, familiar.Position)
            if(closest) then
                familiar.Target = closest
            end
        end
    end

    if(sprite:IsFinished("Hop")) then sprite:Play("Idle") end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.postFamiliarUpdateL3, haythingL3)

--#endregion

mod.ITEMS.CLUMPOFHAY = funcs