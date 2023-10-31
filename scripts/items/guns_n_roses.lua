local mod = jezreelMod

local gunsnroses1 = mod.ENUMS.ITEMS.GUNS_N_ROSES_REVOLVER
local gunsnroses2 = mod.ENUMS.ITEMS.GUNS_N_ROSES_SHOTGUN
local gunsnroses3 = mod.ENUMS.ITEMS.GUNS_N_ROSES_NAILGUN
local gunsnroses4 = mod.ENUMS.ITEMS.GUNS_N_ROSES_RAILGUN

local MAX_REVOLVER_CHARGES = Isaac.GetItemConfig():GetCollectible(gunsnroses1).MaxCharges
local MAX_SHOTGUN_CHARGES = Isaac.GetItemConfig():GetCollectible(gunsnroses2).MaxCharges
local MAX_NAILGUN_CHARGES = Isaac.GetItemConfig():GetCollectible(gunsnroses3).MaxCharges

local VALID_GUN_ITEMS = {[gunsnroses1]=0,[gunsnroses2]=1,[gunsnroses3]=2,[gunsnroses4]=3,}
local VALID_CHARGE_ITEMS = {[gunsnroses1]=MAX_REVOLVER_CHARGES,[gunsnroses2]=MAX_SHOTGUN_CHARGES,}
local GUN_ITEM_QUEUE = {[0]=gunsnroses1,[1]=gunsnroses2,[2]=gunsnroses3,[3]=gunsnroses4,}

local REVOLVER_TEARSPEED = 3
local REVOLVER_BEAMDAMAGE = 48
local REVOLVER_BEAMTICKS = 5
local REVOLVER_BEAMCOOLDOWN = 1.5
local REVOLVER_DEATHTIME = 15

local SHOTGUN_TEARS = 9
local SHOTGUN_TEARSPEED = 3
local SHOTGUN_GRENADESPEED = 1.5
local SHOTGUN_DEATHTIME = 4
local SHOTGUN_GRENADEDAMAGE = 60
local SHOTGUN_GRENADECOOLDOWN = 1.5

local NAILGUN_TEARSPEED = 1.5
local NAILGUN_DEATHTIME = 35

local RAILGUN_BEAMDAMAGE = 100
local RAILGUN_TICKS = 10

local funcs = {}

local function fireDelayToTps(fireDelay)
    return 30/(fireDelay + 1)
end
local function tpsToFireDelay(tps)
    return math.max((30/tps)-1, -0.99)
end

local function spawnTearTrail(tear)
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, tear.Position+tear.PositionOffset, Vector.Zero, tear):ToEffect()
    trail:FollowParent(tear)
    trail.ParentOffset = tear.PositionOffset
    trail.Color = tear.Color
    trail.MinRadius = 0.15
    trail.SpriteScale = Vector(1,1)*(tear.Scale+tear.SpriteScale.Y)
    trail:GetData().bulletTrail = tear
    trail:Update()

    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
end
local function updateCanShoot(player, canShoot)
    local oldChallenge = Game().Challenge
    Game().Challenge = canShoot and 0 or 6
    player:UpdateCanShoot()
    Game().Challenge = oldChallenge
end
local function holdingCanShoot(player)
    local isHoldingDownActive = ((VALID_CHARGE_ITEMS[player:GetActiveItem(0)]~=nil and player:GetActiveCharge(0)~=VALID_CHARGE_ITEMS[player:GetActiveItem(0)]) and
                                 Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex)==true)
    local isHoldingDownPocket = ((VALID_CHARGE_ITEMS[player:GetActiveItem(2)]~=nil and player:GetActiveCharge(2)~=VALID_CHARGE_ITEMS[player:GetActiveItem(2)]) and
                                 Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)==true)
    local isCooldownNotReady = (player:GetData().chargeCooldown>0)
    if(((isHoldingDownActive or isHoldingDownPocket) and not isCooldownNotReady) or isCooldownNotReady) then
        if(player:CanShoot()==true) then updateCanShoot(player, false) end
    else
        if(player:CanShoot()==false) then updateCanShoot(player, true) end
    end
end

local function postFireTearREVOLVER(tear, player)
    local data = tear:GetData()
    player.Velocity = player.Velocity-tear.Velocity/20
    if((player:GetActiveItem(2)==gunsnroses1 and player:GetActiveCharge(2)==MAX_REVOLVER_CHARGES)
    or (player:GetActiveItem(0)==gunsnroses1 and player:GetActiveCharge(0)==MAX_REVOLVER_CHARGES)) then

        local function turnToBeam(oldTear)
            local oldDamage = player.Damage
            player.Damage = 100
            local laser = player:FireTechLaser(oldTear.Position, 0, oldTear.Velocity, true, false, player, (REVOLVER_BEAMDAMAGE/REVOLVER_BEAMTICKS)/(oldDamage))
            laser:SetTimeout(REVOLVER_BEAMTICKS*2)
            laser.CollisionDamage = REVOLVER_BEAMDAMAGE/REVOLVER_BEAMTICKS
            laser.DisableFollowParent = false
            laser.Color = Color(0,1,1,1,0,1,0.33)
            oldTear:Die()
            player.Damage = oldDamage
        end

        if(player:GetActiveCharge(2)==MAX_REVOLVER_CHARGES) then
            turnToBeam(tear)
            player:SetActiveCharge(-30,2)
            player:GetData().chargeCooldown=REVOLVER_BEAMCOOLDOWN*60
        elseif(player:GetActiveCharge(0)==MAX_REVOLVER_CHARGES) then
            turnToBeam(tear)
            player:SetActiveCharge(-30,0)
            player:GetData().chargeCooldown=REVOLVER_BEAMCOOLDOWN*60
        end
    else
        data.isBullet="revolver"
        local rng = player:GetCollectibleRNG(gunsnroses1)
        tear.Velocity = tear.Velocity*REVOLVER_TEARSPEED
    end
    spawnTearTrail(tear)
end
local function postFireTearSHOTGUN(tear, player)
    local data = tear:GetData()
    spawnTearTrail(tear)
    player.Velocity = player.Velocity-tear.Velocity/5
    if((player:GetActiveItem(2)==gunsnroses2 and player:GetActiveCharge(2)==MAX_SHOTGUN_CHARGES)
    or (player:GetActiveItem(0)==gunsnroses2 and player:GetActiveCharge(0)==MAX_SHOTGUN_CHARGES)) then

        local function turnToGrenade(oldTear)
            oldTear.TearFlags = oldTear.TearFlags | TearFlags.TEAR_EXPLOSIVE
            oldTear.FallingSpeed = -30
            oldTear.FallingAcceleration = 4
            oldTear.Velocity = oldTear.Velocity*SHOTGUN_GRENADESPEED
            oldTear.CollisionDamage = SHOTGUN_GRENADEDAMAGE
        end

        if(player:GetActiveCharge(2)==MAX_SHOTGUN_CHARGES) then
            turnToGrenade(tear)
            player:SetActiveCharge(-30,2)
            player:GetData().chargeCooldown=SHOTGUN_GRENADECOOLDOWN*60
        elseif(player:GetActiveCharge(0)==MAX_SHOTGUN_CHARGES) then
            turnToGrenade(tear)
            player:SetActiveCharge(-30,0)
            player:GetData().chargeCooldown=SHOTGUN_GRENADECOOLDOWN*60
        end
    else
        data.isBullet="shotgun"
        local rng = player:GetCollectibleRNG(gunsnroses2)
        for i=1,SHOTGUN_TEARS-1 do
            local shotgunTear = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, tear.SubType, tear.Position, tear.Velocity:Rotated(rng:RandomFloat()*20-10)*(0.8+0.4*rng:RandomFloat())*SHOTGUN_TEARSPEED, player):ToTear()
            shotgunTear.TearFlags = tear.TearFlags
            shotgunTear.FallingSpeed = tear.FallingSpeed
            shotgunTear.FallingAcceleration = tear.FallingAcceleration
            shotgunTear.Height = tear.Height
            shotgunTear.CollisionDamage = tear.CollisionDamage
            shotgunTear.Scale = tear.Scale
            shotgunTear.Color = tear.Color
            shotgunTear.GridCollisionClass = tear.GridCollisionClass
            shotgunTear:SetKnockbackMultiplier(0.5)
            shotgunTear:GetData().isBullet = "shotgun"
            spawnTearTrail(shotgunTear)
        end
        tear.Velocity = tear.Velocity:Rotated(rng:RandomFloat()*20-10)*(0.8+0.4*rng:RandomFloat())*SHOTGUN_TEARSPEED
        tear:SetKnockbackMultiplier(0.5)
    end
end
local function postFireTearNAILGUN(tear, player)
    local data = tear:GetData()

    local function fireNailgun(nailTear, nailPlayer)
        nailPlayer.Velocity = nailPlayer.Velocity-nailTear.Velocity/40
        data.isBullet="nailgun"
        local rng = nailPlayer:GetCollectibleRNG(gunsnroses3)
        nailTear.Velocity = nailTear.Velocity*NAILGUN_TEARSPEED
        nailTear:AddTearFlags(TearFlags.TEAR_HOMING)
        nailTear.CollisionDamage = player.Damage/9
        nailTear.Scale = nailTear.Scale/3
        nailTear:SetKnockbackMultiplier(0.33)
        spawnTearTrail(nailTear)
    end
    if(player:GetActiveItem(0)==gunsnroses3 and player:GetActiveCharge(0)>0) then
        fireNailgun(tear, player)
        player:SetActiveCharge(math.max(0, player:GetActiveCharge(0)-1), 0)
    elseif(player:GetActiveItem(2)==gunsnroses3 and player:GetActiveCharge(2)>0) then
        fireNailgun(tear, player)
        player:SetActiveCharge(math.max(0, player:GetActiveCharge(2)-1), 2)
    else
        tear:Remove()
    end
end
local function postFireTearRAILGUN(tear, player)
    local data = tear:GetData()
    player.Velocity = player.Velocity-tear.Velocity/2
    data.isBullet="railgun"

    local oldDamage = player.Damage
    player.Damage = 200
    local laser = player:FireTechLaser(tear.Position, 0, tear.Velocity, true, false, player, (RAILGUN_BEAMDAMAGE/RAILGUN_TICKS)/3.5)
    laser:SetTimeout(RAILGUN_TICKS*2)
    laser.CollisionDamage = RAILGUN_BEAMDAMAGE/RAILGUN_TICKS
    laser.DisableFollowParent = false
    laser.Color = Color(0,1,1,1,0,1,0.33)
    tear:Die()
    player.Damage = oldDamage
end

---@param tear EntityTear
function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    if(player:HasCollectible(gunsnroses1)) then
        postFireTearREVOLVER(tear, player)
    elseif(player:HasCollectible(gunsnroses2)) then
        postFireTearSHOTGUN(tear, player)
    elseif(player:HasCollectible(gunsnroses3)) then
        postFireTearNAILGUN(tear, player)
    elseif(player:HasCollectible(gunsnroses4)) then
        postFireTearRAILGUN(tear, player)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local data = player:GetData()

    local shouldContinue = false
    for id, _ in pairs(VALID_GUN_ITEMS) do
        if(player:HasCollectible(id)) then shouldContinue=true end
    end
    if(not shouldContinue) then return end

    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
        for i=0,2,2 do
            local item = player:GetActiveItem(i)
            if(VALID_GUN_ITEMS[item]) then
                player:RemoveCollectible(item,true,i,true)
                local newItem = GUN_ITEM_QUEUE[(VALID_GUN_ITEMS[item]+1)%4]
                player:AddCollectible(newItem,Isaac.GetItemConfig():GetCollectible(newItem).InitCharge,false,i,0)
                if(newItem~=gunsnroses4) then player.FireDelay = player.MaxFireDelay/3
                else player.FireDelay = player.MaxFireDelay/6 end
            end
        end
    end

    if(data.chargeCooldown==nil) then data.chargeCooldown=0 end
    if(data.chargeCooldown>0) then data.chargeCooldown=data.chargeCooldown-1 end

    holdingCanShoot(player)

    if(data.chargeCooldown>0) then return end

    local shouldContinueCharge = false
    for id, _ in pairs(VALID_CHARGE_ITEMS) do
        if(player:HasCollectible(id)) then shouldContinueCharge=true end
    end
    if(shouldContinueCharge) then
        if(VALID_CHARGE_ITEMS[player:GetActiveItem(2)]) then
            local maxCharges = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(2)).MaxCharges
            if(Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)) then
                player:SetActiveCharge(math.min(player:GetActiveCharge(2)+1, maxCharges),2)
            else
                player:SetActiveCharge(math.max(0,player:GetActiveCharge(2)-6),2)
            end
        end
        if(VALID_CHARGE_ITEMS[player:GetActiveItem(0)]) then
            local maxCharges = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(0)).MaxCharges
            if(Input.IsActionPressed(ButtonAction.ACTION_ITEM, player.ControllerIndex)) then
                player:SetActiveCharge(math.min(player:GetActiveCharge(0)+1, maxCharges),0)
            else
                player:SetActiveCharge(math.max(0,player:GetActiveCharge(0)-6),0)
            end
        end
    end
    if(player:HasCollectible(gunsnroses3)) then
        if(player:GetShootingJoystick():Length()==0) then
            if(player:GetActiveItem(0)==gunsnroses3 and player:GetActiveCharge(0)<MAX_NAILGUN_CHARGES) then
                player:SetActiveCharge(math.min(MAX_NAILGUN_CHARGES, player:GetActiveCharge(0)+3), 0)
            elseif(player:GetActiveItem(2)==gunsnroses3 and player:GetActiveCharge(2)<MAX_NAILGUN_CHARGES) then
                player:SetActiveCharge(math.min(MAX_NAILGUN_CHARGES, player:GetActiveCharge(2)+1), 2)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param player EntityPlayer
---@param flag CacheFlag
function funcs:evaluateCache(player, flag)
    if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        if(player:HasCollectible(gunsnroses2)) then
            player.MaxFireDelay = tpsToFireDelay(fireDelayToTps(player.MaxFireDelay)/3)
        end
        if(player:HasCollectible(gunsnroses3)) then
            player.MaxFireDelay = tpsToFireDelay(fireDelayToTps(player.MaxFireDelay)*10)
        end
        if(player:HasCollectible(gunsnroses4)) then
            player.MaxFireDelay = tpsToFireDelay(fireDelayToTps(player.MaxFireDelay)/25)
        end
    end
    if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        if(player:HasCollectible(gunsnroses2)) then
            player.TearRange = player.TearRange
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

function funcs:postEffectRender(effect, offset)
    if(effect:GetData().bulletTrail) then
        if(effect:GetData().bulletTrail:Exists()) then
            effect.ParentOffset = effect:GetData().bulletTrail.PositionOffset
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, funcs.postEffectRender, EffectVariant.SPRITE_TRAIL)

function funcs:postTearUpdate(tear)
    local bulletType = tear:GetData().isBullet
    if(bulletType) then
        if(bulletType=="revolver") then
            if(tear.FrameCount==REVOLVER_DEATHTIME) then tear:Die() end
        elseif(bulletType=="shotgun") then
            if(tear.FrameCount==SHOTGUN_DEATHTIME) then tear:Die() end
        elseif(bulletType=="nailgun") then
            if(tear.FrameCount==NAILGUN_DEATHTIME) then tear:Die() end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

function funcs:useItem(item)
    if(VALID_GUN_ITEMS[item]) then
        return {
            Discharge=false,
            ShowAnim=false,
            Remove=false,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem)