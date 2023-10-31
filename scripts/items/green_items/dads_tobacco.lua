local mod = jezreelMod
local h = include("scripts/func")
local sfx = SFXManager()

local dadsTobacco = mod.ENUMS.VEGETABLES.DADS_TOBACCO

local TOBACCO_CHARGE_DURATION = 2.5*60

local TOBACCO_CHEW_NUM = 1
local TOBACCO_CHEW_DAMAGE = 15
local TOBACCO_CHEW_SPEED = 12

local TOBACCO_SPIT_NUM = 8
local TOBACCO_SPIT_DAMAGE = 3.5
local TOBACCO_SPIT_ANGLE = 45
local TOBACCO_SPIT_SPEED = 15

local TOBACCO_HUNK_EXPL_NUM = 12

local TOBACCO_CHARGEBAR_SFX = Isaac.GetSoundIdByName("TobaccoSpit")
sfx:Preload(TOBACCO_CHARGEBAR_SFX)

local TOBACCO_CHARGEBAR_GFX = "gfx/entities/effects/tobacco/chargebar.anm2"

local TOBACCO_COLOR = Color(1,1,1)

TOBACCO_COLOR:SetColorize(0.5,0.35,0.1,1)

local funcs = {}

local function fireBasicTobaccoTear(player, vel)
    local tear = player:FireTear(player.Position, vel, true, true, false, player)

    tear.FallingSpeed = 0
    tear.FallingAcceleration = 0
    tear.TearFlags = TearFlags.TEAR_NORMAL
    tear.CollisionDamage = 3.5
    tear.Scale = 1

    tear.Color = TOBACCO_COLOR

    return tear
end

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local tobaccoNum = player:GetCollectibleNum(dadsTobacco)
    if(tobaccoNum<=0) then return end
    local data = player:GetData()
    local rng = player:GetCollectibleRNG(dadsTobacco)
    local joystick = player:GetShootingJoystick()

    if(data.tobbacoCharge==nil) then data.tobbacoCharge=0 end
    if(data.prevJoystick==nil) then data.prevJoystick=joystick end

    if(player:GetFireDirection()~=-1) then
        if(data.tobbacoCharge<=math.ceil(TOBACCO_CHARGE_DURATION*1.13)) then data.tobbacoCharge=data.tobbacoCharge+1 end
    else
        if(data.tobbacoCharge>=TOBACCO_CHARGE_DURATION) then
            sfx:Play(TOBACCO_CHARGEBAR_SFX)

            for i=1,TOBACCO_CHEW_NUM do
                local vel = Vector.FromAngle(data.prevJoystick:GetAngleDegrees())*TOBACCO_CHEW_SPEED
                local tear = fireBasicTobaccoTear(player, vel):ToTear()
                tear.FallingSpeed = -15
                tear.FallingAcceleration = 2
                tear.CollisionDamage = TOBACCO_CHEW_DAMAGE*1.5^(tobaccoNum-1)
                tear.Scale = 2

                tear:GetData().tobaccoHunkTear = true
            end

            local spitNum = TOBACCO_SPIT_NUM*tobaccoNum
            for i=1,spitNum do
                local vel = Vector.FromAngle(data.prevJoystick:GetAngleDegrees()+(rng:RandomFloat()-0.5)*TOBACCO_SPIT_ANGLE)*TOBACCO_SPIT_SPEED*(rng:RandomFloat()*2/3+1/3)
                local tear = fireBasicTobaccoTear(player, vel):ToTear()
                tear.FallingSpeed = -10
                tear.FallingAcceleration = 2
                tear.CollisionDamage = TOBACCO_SPIT_DAMAGE*1.5^(tobaccoNum-1)
                tear.Scale = rng:RandomFloat()*0.5+0.5
            end
        end

        data.tobbacoCharge=0
    end

    data.prevJoystick = joystick
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:postEntityRemove(entity)
    if(entity.Type~=2) then return end
    if(not (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer())) then return end
    if(entity:GetData().tobaccoHunkTear==nil) then return end

    entity = entity:ToTear()
    local player = entity.SpawnerEntity:ToPlayer()
    local tobaccoNum = player:GetCollectibleNum(dadsTobacco)
    local rng = player:GetCollectibleRNG(dadsTobacco)

    local tearsNum = TOBACCO_HUNK_EXPL_NUM*tobaccoNum
    for i=1,tearsNum do
        local vel = Vector.FromAngle(rng:RandomFloat()*360)*TOBACCO_SPIT_SPEED*(rng:RandomFloat()*2/3+1/3)
        local tear = fireBasicTobaccoTear(player, vel):ToTear()

        tear.FallingSpeed = -10
        tear.FallingAcceleration = 2
        tear.CollisionDamage = TOBACCO_SPIT_DAMAGE*1.5^(tobaccoNum-1)
        tear.Scale = rng:RandomFloat()*0.5+0.5
        tear.Position = entity.Position

        tear.Height = -5
    end

    local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, entity.Position, Vector.Zero, player):ToEffect()
    creep.Timeout = 6*30
    creep.Scale = 2

    creep.Color = Color(1,1,1,1,0.4,0.3,0.1)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

function funcs:postPlayerRender(player, offset)
    local tobaccoNum = player:GetCollectibleNum(dadsTobacco)
    if(tobaccoNum<=0) then return end

    local charge = player:GetData().tobbacoCharge or 0
    local barOffset = Vector(-15,0)+offset-Game():GetRoom():GetRenderScrollOffset()
    if(charge>0) then
        h:RenderChargebar(player, TOBACCO_CHARGEBAR_GFX, barOffset, charge/TOBACCO_CHARGE_DURATION, false)
    else
        h:RenderChargebar(player, TOBACCO_CHARGEBAR_GFX, barOffset, 0, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, funcs.postPlayerRender, 0)

mod.ITEMS.DADSTOBACCO = funcs