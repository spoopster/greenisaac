local mod = jezreelMod
local sfx = SFXManager()
local music = MusicManager()

local h = include("scripts/func")
local fj = include("scripts/firejet")

local reapPrimeType = Isaac.GetEntityTypeByName("Reap Prime")

local REAP_ISDEAD = false
local FADEOUT_FRAME = 0

local MAX_HP = 1800
local SILENCE_DESPERATION_HP = 1400
local REAP2_START_HP = 900
local REAP3_START_HP = 500

local REAPPRIME_GRIDCOLLPOINTS = 24

local REAPPRIME_SIZE = 20
local REAPPRIME_SIZEMULT = Vector(1,1)

local REAPPRIME_TEARCOL = Color(0.3,0.6,0.2,1,0,0,0)

local SFX_REAP_AGH = Isaac.GetSoundIdByName("ReapAgh")
local SFX_REAP_ARGH = Isaac.GetSoundIdByName("ReapArgh")
local SFX_REAP_EUGH = Isaac.GetSoundIdByName("ReapEugh")
local SFX_REAP_GRR = Isaac.GetSoundIdByName("ReapGrr")
local SFX_REAP_WAH = Isaac.GetSoundIdByName("ReapWah")
local SFX_REAP_WAHAH = Isaac.GetSoundIdByName("ReapWahah")
local SFX_REAP_WUH = Isaac.GetSoundIdByName("ReapWuh")
local SFX_REAP_PAIN = Isaac.GetSoundIdByName("ReapPained")
local SFX_REAP_DEATH = Isaac.GetSoundIdByName("ReapDeath")
sfx:Preload(SFX_REAP_AGH)
sfx:Preload(SFX_REAP_ARGH)
sfx:Preload(SFX_REAP_EUGH)
sfx:Preload(SFX_REAP_GRR)
sfx:Preload(SFX_REAP_WAH)
sfx:Preload(SFX_REAP_WAHAH)
sfx:Preload(SFX_REAP_WUH)
sfx:Preload(SFX_REAP_PAIN)
sfx:Preload(SFX_REAP_DEATH)

--#region SILENCE_ENUMS
local SILENCE_SIZE = 25
local SILENCE_SIZEMULT = Vector(1.5, 0.75)
local SILENCE_ATTACKCHANCE = 1/3
local SILENCE_LONGATTACKANIM = "SilenceAttackLongIntro"
local SILENCE_ATTACKS = {
    [1]={Length=80, Anim=SILENCE_LONGATTACKANIM, ChangeState=true,},
    [2]={Length=60, Anim=SILENCE_LONGATTACKANIM, ChangeState=true,},
    [3]={Length=80, Anim=SILENCE_LONGATTACKANIM, ChangeState=true,},
    [4]={Length=300, Anim=SILENCE_LONGATTACKANIM, ChangeState=true,},
}
local SILENCE_IDLEATTACK = {
    PROJ_NUM = 12,
    PROJ_SPEED = 8,
    ARC_RADIUS = 120,
    ARC_SIZE = 60,

    SECONDARY_PROJ_NUM = 6,
    SECONDARY_PROJ_SPEED = 10,
    SECONDARY_ARC_RADIUS = 80,
    SECONDARY_ARC_SIZE = 60,
}
local SILENCE_ATTACK1 = { -- CONTINUUM ATTACK
    PROJ_NUM = 6,
    PROJ_SPEED = 9.5,
    PROJ_COOLDOWN = 6,
    PROJ_FLAGS = ProjectileFlags.CONTINUUM | ProjectileFlags.WIGGLE,
    TRAILLENGTH = 1,

    SFX = SoundEffect.SOUND_BOSS_LITE_ROAR,
}
local SILENCE_ATTACK2 = { -- RANDOM BULLSHIT GO ATTACK
    PROJ_AMOUNT = 1,
    PROJ_NUM = 12,
    PROJ_SPEED = 15,
    PROJ_FLAGS = ProjectileFlags.MEGA_WIGGLE,
    TRAILLENGTH = 2,

    SECONDARY_PROJ_NUM = 6,
    SECONDARY_PROJ_SPEED = 10,
    SECONDARY_PROJ_COOLDOWN = 6,
    SECONDARY_PROJ_FLAGS = ProjectileFlags.DECELERATE | ProjectileFlags.MEGA_WIGGLE,
    SECONDARY_TRAILLENGTH = 0.8,

    SFX = SoundEffect.SOUND_BOSS_LITE_ROAR,
}
local SILENCE_ATTACK3 = { -- FLESH PRISON ATTACK
    BLACKHOLE_NUM = 1,
    BLACKHOLE_SPEED = 8,
    BLACKHOLE_TRAILLENGTH = 3,
    BLACKHOLE_SCALEMOD = 4,

    PROJ_NUM = 64,
    PROJ_AMOUNT = 3,
    PROJ_SPEED = 24,
    TRAILLENGTH = 0.8,

    SFX = SoundEffect.SOUND_BOSS_LITE_ROAR,
}
local SILENCE_ATTACK4 = { -- DESPERATION "PHASE"
    PROJ_NUM = 5,
    PROJ_FREQUENCY = 2,
    PROJ_SPEED = 30,
    PROJ_ROTSPEED = 0.75,
    TRAILLENGTH = 0.4,

    SECONDARY_NUM = 16,
    SECONDARY_FREQUENCY = 12,
    SECONDARY_SPEED = 12,
    SECONDARY_TRAILLENGTH = 0.7,

    THIRD_NUM = 2,
    THIRD_FREQ = 4,
    THIRD_SPEED = 10,
    THIRD_TRAILLENGTH = 0.8,

    SFX = SoundEffect.SOUND_BOSS_LITE_ROAR,
}
--#endregion

--#region REAP1_ENUMS
local REAP1_BASESTAMINA = 10

local REAP1_ATTACKS = {
    [11]={Length=75, ChangeState=true, StaminaCost=2},
    [12]={Length=75, ChangeState=true, StaminaCost=1.5},
    [21]={Length=400, ChangeState=true, StaminaCost=2},
    [22]={Length=390, ChangeState=true, StaminaCost=1.5},
    [3]={Length=80, ChangeState=true, StaminaCost=2},
}
local REAP1_ATTACK11 = {
    PROJ_NUM = 12,
    PROJ_RADIUS = 75,
    PROJ_DELAY = 0,
    PROJ_SPEED = 30,

    SFX1 = 25,
    SFX2 = 38,
}
local REAP1_ATTACK12 = {
    PROJ_NUM = 12,
    PROJ_RADIUS = 60,
    PROJ_DELAY = 0,
    PROJ_SPEED = 25,

    PROJ2_AMOUNT = 2,
    PROJ2_NUM = 6,
    PROJ2_SPEED = 12,
    PROJ2_DELAY = 2,
    SFX1 = 112,
    SFX2 = 38,
}
local REAP1_ATTACK21 = {
    PROJ_NUM = 10,
    PROJ_SPEED = 8,
    SFX1 = 119,
    SFX2 = 38,

    SFX3 = 139,
}
local REAP1_ATTACK22 = {
    BRIM_DURATION = 40,

    PROJ_NUM = 6,
    PROJ_SPEED = 10,
    SFX1 = 167,
    SFX2 = 38,
    SFX3 = 159,
}
local REAP1_ATTACK3 = {
    PROJ_NUM = 5,
    PROJ_SPEED = 8,

    PROJ2_NUM = 10,
    PROJ2_SPEED = 16,
    PROJ2_ANGLE = 25,
    PROJ2_ROCKCHANCE = 0.1,

    PROJ3_AMOUNT = 1,
    PROJ3_NUM = 3,
    PROJ3_SPEED = 12,
    PROJ3_DELAY = 2,

    SFX1 = 146,
    SFX2 = 137,
    SFX3 = 38,
    SFX4 = 25,
}
--#endregion

--#region REAP2_ENUMS
local REAP2_BASESTAMINA = 15

local REAP2_ATTACKS = {
    [1]={Length=100, ChangeState=true, StaminaCost=0},
    [2]={Length=45, ChangeState=true, StaminaCost=1.5},
    [3]={Length=500, ChangeState=true, StaminaCost=2},
    [4]={Length=105, ChangeState=true, StaminaCost=2},
    [5]={Length=70, ChangeState=true, StaminaCost=1.5},
}

REAP2_ATTACK1 = {
    MELON_BOUNCES = 5,
    MELON_SPEED = 6,
    MELON_FSPEED = -20,
    MELON_FACCEL = 1.5,
    MINIBURST_PROJ = 10,
    MINIBURST_SPEED = 5,
    BURST_PROJ = 30,
    BURST_SPEED = 15,

    SFX2 = 28,
    SFX1 = 38,
    MELON_SFX1 = 77,
    MELON_SFX2 = 52,
}

REAP2_ATTACK2 = {
    PROJ_NUM = 6,
    PROJ_ANGLE = 90,
    PROJ_SPEED = 20,
    BURST_TIMER = 15,
    BURST_NUM = 6,
    BURST_SPEED = 8,
    TATER_NUM = 2,
    TATER_SPEED = 15,

    SFX1 = 38,
    BURST_SFX = 237,

    SFX2 = SFX_REAP_WAH,
}
REAP2_ATTACK3 = {
    REAP_SPEED = 17,5,
    FIRE_CHANCE = 0.15,
    FLAME_NUM = 12,
    FLAME_SPEED = 10,
    REAP_RUN_DURATION = 105,

    DUST_VARIANT = EffectVariant.DUST_CLOUD,
    FLAME_VARIANT = Isaac.GetEntityVariantByName("Spicy Fire"),

    SFX1 = SFX_REAP_WAHAH,
    SFX2 = SFX_REAP_GRR,
}
REAP2_ATTACK4 = {
    TANGERINE_NUM = 15,
    TANGERINE_COOLDOWN = 5,
    TANGERINE_DURATION = 30,
    TANGERINE_MESSAGE = "HA HA HA HA HA HA HA HA HA HA HA HA HA HA HA    ",
    TANG_VARIANT = Isaac.GetEntityVariantByName("Tangerine Dialogue"),

    SECONDARY_NUM = 4,
    SECONDARY_SPEED = 12,

    PROJ_NUM = 12,
    PROJ_SPEED = 15,

    SFX1 = SFX_REAP_WUH,
}
REAP2_ATTACK5 = {
    PEAR_NUM = 13,
    PEAR_SPEED = 6,
    PEAR_VARIANT = mod.PICKUPS.PEAR,

    PROJ_SPEED = 20,

    BURST_COOLDOWN = 30,
    BURST_NUM = 7,
    BURST_SPEED = 10,

    SFX1 = SFX_REAP_ARGH,
    SFX2 = 72,
}
--#endregion

--#region REAP3_ENUMS
local REAP3_SIZE = 25
local REAP3_SIZEMULT = Vector(1.5, 0.75)

local REAP3_SPEED = 1.5
local REAP3_SPEED2 = 3

local REAP3_ATTACKS = {
    [1]={Length=20, ChangeState=true},
    [2]={Length=40, ChangeState=true},
    [3]={Length=20, ChangeState=true},
}

REAP3_ATTACK1 = {
    PROJ_NUM = 12,
    PROJ_SPEED = 10,

    RANDOM_NUM = 18,
    RANDOM_SPEED = 8,

    SFX1 = SFX_REAP_PAIN,
}

REAP3_ATTACK2 = {
    PROJ_NUM = 6,
    PROJ_SPEED = 8,

    PROJ2_NUM = 4,
    PROJ2_SPEED = 8,

    PROJ_SPREAD = 60,

    PROJ_FLAGS = ProjectileFlags.WIGGLE,

    SFX1 = SFX_REAP_PAIN,
}
REAP3_ATTACK3 = {
    PROJ_NUM = 6,
    PROJ_SPREAD = 90,
    PROJ_SPEED = 8,

    SFX1 = SFX_REAP_PAIN,
}
--#endregion

local funcs = {}

--#region PROJECTILE_TRAILS --[[ PROJECTILE TRAILS ]]--
local function spawnTrail(projectile, length, offset, color)
    offset = offset or Vector.Zero
    color = color or projectile.Color
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, projectile.Position+projectile.PositionOffset+offset, Vector.Zero, projectile):ToEffect()
    trail:FollowParent(projectile)
    trail.ParentOffset = projectile.PositionOffset+offset
    trail.MinRadius = 0.15/length
    trail.SpriteScale = Vector(1,1)*(projectile.Scale+projectile.SpriteScale.Y)
    trail:GetData().isProjTrail = projectile
    trail:GetData().trailOffset = offset
    trail:GetData().trailColor = color
    trail:Update()

    return trail
end
function funcs:postEffectRender(effect, offset)
    local data = effect:GetData()
    if(data.isProjTrail) then
        if(data.isProjTrail:Exists()) then
            local proj = data.isProjTrail
            local offset2 = data.trailOffset or Vector.Zero
            effect.ParentOffset = proj.PositionOffset+offset2
            local color = data.trailColor or proj.Color
            if(proj:ToProjectile() and proj:ToProjectile():HasProjectileFlags(ProjectileFlags.CONTINUUM)) then
                color = proj.Color
            end
            if(Game():GetRoom():IsPositionInRoom(effect.Position, -40)) then
                color.A = 1
            else
                color.A = 0
            end
            effect.Color = color
        else
            local color = effect.Color
            color.A = 0
            effect.Color = color
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, funcs.postEffectRender, EffectVariant.SPRITE_TRAIL)
--#endregion

--#region HELPER_FUNCS --[[ HELPER FUNCTIONS ]]--

---@param npc EntityNPC
---@param state string
local function changeState(npc, state)
    local data = npc:GetData()
    data.state = state
    data.stateFrame = 0
    npc.I1=0
    npc.I2=0
    npc.State=4
end

---@param npc EntityNPC
---@param phase string
local function changePhase(npc, phase)
    npc:GetData().phase = phase
    npc:GetData().lastAttack = 0
    changeState(npc, "idle")

    npc.I2 = -999
end

---@param npc EntityNPC
local function chooseAttack(npc)
    local phase = npc:GetData().phase
    local rng = npc:GetDropRNG()
    local attack = 1
    if(phase=="silence") then
        if(npc.HitPoints<=SILENCE_DESPERATION_HP) then
            attack=4
        else
            attack = rng:RandomInt(3)+1
            while(attack==npc:GetData().lastAttack) do
                attack = rng:RandomInt(3)+1
            end
        end
        npc:GetData().lastAttack = attack
    elseif(phase=="reap1") then
        attack = rng:RandomInt(3)+1
        while(attack==npc:GetData().lastAttack) do
            attack = rng:RandomInt(3)+1
        end
        npc:GetData().lastAttack = attack
        if(attack==1 or attack==2) then
            attack = attack*10+rng:RandomInt(2)+1
        end
    elseif(phase=="reap2") then
        attack = rng:RandomInt(4)+2
        while(attack==npc:GetData().lastAttack) do
            attack = rng:RandomInt(4)+2
        end
        npc:GetData().lastAttack = attack
    elseif(phase=="reap3") then
        attack = rng:RandomInt(3)+1
        while(attack==npc:GetData().lastAttack) do
            attack = rng:RandomInt(3)+1
        end
        npc:GetData().lastAttack = attack
    end
    return attack
end

---@param color Color
local function cloneColor(color)
    return Color(color.R,color.G,color.B,color.A,color.RO,color.GO,color.BO)
end

---@param npc EntityNPC
local function initReapPrime(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    sprite:Play("SilenceIdle", true)
    data.phase = "silence"
    data.state = "idle"
    data.stateFrame = 0
    data.lastAttack = 0
    data.stamina = 0
    data.reapTrail = nil
    npc.State = 4
    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    npc.Target = h:closestPlayer(npc.Position)

    npc.MaxHitPoints = MAX_HP
    npc.HitPoints = npc.MaxHitPoints
    npc.Position = Game():GetRoom():GetCenterPos()
    npc:SetSize(SILENCE_SIZE, SILENCE_SIZEMULT, REAPPRIME_GRIDCOLLPOINTS)
end

local function fireProjectile(npc, velocity)
    local proj = Isaac.Spawn(9,4,0,npc.Position,velocity,npc):ToProjectile()
    proj.FallingAccel = -0.1
    proj.FallingSpeed = 0
    proj.Color = cloneColor(REAPPRIME_TEARCOL)
    return proj
end
--#endregion

--#region REAP_PRIME_AI --[[ REAP PRIME AI ]]

---@param npc EntityNPC
function funcs:postNpcInit(npc)
    initReapPrime(npc)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, funcs.postNpcInit, reapPrimeType)

---@param npc EntityNPC
function funcs:preNpcUpdate(npc)

    if(npc.FrameCount==0) then return true end

    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local rng = npc:GetDropRNG()
    local phase = data.phase
    local state = data.state
    local stateFrame = data.stateFrame
    local room = Game():GetRoom()

    local targetPos = npc.Target.Position
    local targetVector = Vector(1,0):Rotated((targetPos-npc.Position):GetAngleDegrees())

    if(npc.FrameCount%30==0) then
        npc.Target = h:closestPlayer(npc.Position)
    end

    --[[ SILENCE PHASE ]]
    if(phase=="silence") then
        npc.Position = room:GetCenterPos()
        npc.Velocity = npc.Velocity*0.5

        local postInit = (npc.FrameCount>0)

        if(npc.FrameCount==1) then
            music:Crossfade(Isaac.GetMusicIdByName("There Was Silence"), 2)
        end

        if(npc.HitPoints<SILENCE_DESPERATION_HP) then
            npc.HitPoints = SILENCE_DESPERATION_HP
            changeState(npc, "attack4")
            npc.I1 = SILENCE_ATTACKS[4].Length
            sprite:Play(SILENCE_ATTACKS[4].Anim, true)
            if(SILENCE_ATTACKS[4].ChangeState) then npc.State=5 end

            local npcHash = GetPtrHash(npc)
            for i, proj in ipairs(Isaac.FindByType(9)) do
                if(GetPtrHash(proj.SpawnerEntity)==npcHash) then proj:Die() end
            end
        end

        if(npc.State==4 and npc.FrameCount>10) then
            if(stateFrame%60==50 and postInit) then
                for i=1,SILENCE_IDLEATTACK.PROJ_NUM do
                    local proj = fireProjectile(npc, targetVector*SILENCE_IDLEATTACK.PROJ_SPEED)

                    local currentAngleOnArc = ((i-1)/(SILENCE_IDLEATTACK.PROJ_NUM-1)-1/2)*SILENCE_IDLEATTACK.ARC_SIZE
                    proj.Position = npc.Position+(targetVector:Rotated(currentAngleOnArc)-targetVector)*SILENCE_IDLEATTACK.ARC_RADIUS
                end
            elseif(stateFrame%60==0 and postInit) then
                for i=1,SILENCE_IDLEATTACK.SECONDARY_PROJ_NUM do
                    local proj = fireProjectile(npc, targetVector*SILENCE_IDLEATTACK.SECONDARY_PROJ_SPEED)

                    local currentAngleOnArc = ((i-1)/(SILENCE_IDLEATTACK.SECONDARY_PROJ_NUM-1)-1/2)*SILENCE_IDLEATTACK.SECONDARY_ARC_SIZE
                    proj.Position = npc.Position+(targetVector:Rotated(currentAngleOnArc)-targetVector)*SILENCE_IDLEATTACK.SECONDARY_ARC_RADIUS
                end
            end
        end
        if(state=="idle") then
            if(stateFrame>0 and (stateFrame>=180 or (stateFrame%60==0 and rng:RandomFloat()<SILENCE_ATTACKCHANCE))) then
                local attack = chooseAttack(npc)
                changeState(npc, "attack"..attack)
                npc.I1 = SILENCE_ATTACKS[attack].Length
                sprite:Play(SILENCE_ATTACKS[attack].Anim, true)
                if(SILENCE_ATTACKS[attack].ChangeState) then npc.State=5 end
            end
        elseif(string.sub(state, 1, 6)=="attack") then
            if(state=="attack1") then
                if(stateFrame==1) then
                    npc.I2 = rng:RandomInt(360)
                    sfx:Play(SILENCE_ATTACK1.SFX)
                end
                if(stateFrame%(SILENCE_ATTACK1.PROJ_COOLDOWN)==0) then
                    for i=1, SILENCE_ATTACK1.PROJ_NUM do
                        local projDirection = Vector(1,0):Rotated(360*(i/SILENCE_ATTACK1.PROJ_NUM)+stateFrame*2+npc.I2)
                        local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK1.PROJ_SPEED)
                        proj.Parent = npc
                        proj.FallingAccel = -0.075
                        proj.Scale = 1.5
                        proj:AddProjectileFlags(SILENCE_ATTACK1.PROJ_FLAGS)
                        spawnTrail(proj, SILENCE_ATTACK1.TRAILLENGTH)
                    end
                end
            elseif(state=="attack2") then
                if(stateFrame==1) then
                    npc.I2 = rng:RandomInt(360)
                    sfx:Play(SILENCE_ATTACK2.SFX)
                end
                local introAttackFrames = (SILENCE_ATTACK2.PROJ_AMOUNT-1)*2+1
                if(stateFrame<=introAttackFrames and stateFrame%2==1) then
                    for i=1, SILENCE_ATTACK2.PROJ_NUM do
                        local angleOffset = ((stateFrame-1)/(introAttackFrames))*(360/SILENCE_ATTACK2.PROJ_NUM)
                        local projDirection = Vector(1,0):Rotated(360*(i/SILENCE_ATTACK2.PROJ_NUM)+npc.I2+angleOffset)
                        local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK2.PROJ_SPEED)
                        proj.Parent = npc
                        proj.Scale = 1.5
                        proj:AddProjectileFlags(SILENCE_ATTACK2.PROJ_FLAGS)
                        spawnTrail(proj, SILENCE_ATTACK2.TRAILLENGTH)
                    end
                end
                if(stateFrame>introAttackFrames and stateFrame%(SILENCE_ATTACK2.SECONDARY_PROJ_COOLDOWN)==0) then
                    for i=1, SILENCE_ATTACK2.SECONDARY_PROJ_NUM do
                        local projDirection = Vector(1,0):Rotated(360*(i/SILENCE_ATTACK2.SECONDARY_PROJ_NUM)+stateFrame*2+npc.I2)
                        local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK2.SECONDARY_PROJ_SPEED)
                        proj.Parent = npc
                        proj.FallingAccel = -0.075
                        proj:AddProjectileFlags(SILENCE_ATTACK2.SECONDARY_PROJ_FLAGS)
                        spawnTrail(proj, SILENCE_ATTACK2.SECONDARY_TRAILLENGTH)
                    end
                end
            elseif(state=="attack3") then
                if(stateFrame==1) then
                    npc.I2 = math.floor(targetVector:GetAngleDegrees())
                    sfx:Play(SILENCE_ATTACK3.SFX)
                end
                if(stateFrame==1) then
                    for i=1, SILENCE_ATTACK3.BLACKHOLE_NUM do
                        local proj = fireProjectile(npc, Vector.Zero)
                        proj.Parent = npc
                        proj.SizeMulti = proj.SizeMulti*SILENCE_ATTACK3.BLACKHOLE_SCALEMOD
                        proj:AddScale(2)
                        proj.SpriteScale = proj.SpriteScale*SILENCE_ATTACK3.BLACKHOLE_SCALEMOD/2
                        proj.Color = Color(0,0,0,1,0.1,0,0.1)
                        proj:GetData().silenceBlackHole = true
                        proj:GetData().silenceBlackHoleSpeed = SILENCE_ATTACK3.BLACKHOLE_SPEED
                        proj:AddProjectileFlags(ProjectileFlags.BOUNCE)
                        spawnTrail(proj, SILENCE_ATTACK3.BLACKHOLE_TRAILLENGTH)
                    end
                end
                if(stateFrame>=2 and stateFrame<=SILENCE_ATTACK3.PROJ_NUM*2/SILENCE_ATTACK3.PROJ_AMOUNT and stateFrame%2==0) then
                    for i=0, SILENCE_ATTACK3.PROJ_AMOUNT do
                        local projDirection = Vector(1,0):Rotated(360*((stateFrame/2)/SILENCE_ATTACK3.PROJ_NUM)+npc.I2+360*(i/SILENCE_ATTACK3.PROJ_AMOUNT))
                        local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK3.PROJ_SPEED)
                        proj.Parent = npc
                        proj:GetData().silenceDelayedProj = 40
                        proj:GetData().silenceDelayedProjSpeed = SILENCE_ATTACK3.PROJ_SPEED
                        spawnTrail(proj, SILENCE_ATTACK3.TRAILLENGTH)
                    end
                end
            elseif(state=="attack4") then
                if(stateFrame<=150) then
                    if(stateFrame==1) then
                        npc.I2 = math.floor(targetVector:GetAngleDegrees())
                        sfx:Play(SILENCE_ATTACK4.SFX)
                    end
                    if(stateFrame%SILENCE_ATTACK4.PROJ_FREQUENCY==0) then
                        for i=1, SILENCE_ATTACK4.PROJ_NUM do
                            local projDirection = Vector(1,0):Rotated(stateFrame*SILENCE_ATTACK4.PROJ_ROTSPEED+npc.I2-45+(i-1)/(SILENCE_ATTACK4.PROJ_NUM)*360)
                            local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK4.PROJ_SPEED)
                            proj.Parent = npc
                            spawnTrail(proj, SILENCE_ATTACK4.TRAILLENGTH)
                        end
                    end
                    if(stateFrame%SILENCE_ATTACK4.SECONDARY_FREQUENCY==0) then
                        for i=1, SILENCE_ATTACK4.SECONDARY_NUM do
                            local projDirection = Vector(1,0):Rotated(stateFrame*10+(i-1)/(SILENCE_ATTACK4.SECONDARY_NUM)*360)
                            local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK4.SECONDARY_SPEED)
                            proj.Parent = npc
                            spawnTrail(proj, SILENCE_ATTACK4.SECONDARY_TRAILLENGTH)
                        end
                    end
                else
                    if(stateFrame%SILENCE_ATTACK4.THIRD_FREQ==0) then
                        for i=1, SILENCE_ATTACK4.THIRD_NUM do
                            local wall = rng:RandomInt(2)
                            local projDirection = Vector(1,0)
                            if(wall==1) then projDirection=Vector(-1,0) end
                            local proj = fireProjectile(npc, projDirection*SILENCE_ATTACK4.THIRD_SPEED)
                            proj.Parent = npc
                            local wallPos = room:GetTopLeftPos()+Vector(10, 40*(rng:RandomFloat()*(room:GetGridHeight()-2)+1))
                            if(wall==1) then wallPos.X = room:GetBottomRightPos().X-10 end
                            proj.Position=wallPos
                            spawnTrail(proj, SILENCE_ATTACK4.THIRD_TRAILLENGTH)
                        end
                    end
                end
            end

            if(stateFrame>=npc.I1) then
                if(sprite:GetAnimation()=="SilenceAttackLongLoop") then sprite:Play("SilenceAttackLongEnd", true) end

                if(state=="attack4") then
                    changePhase(npc, "reap1")
                    sprite:Play("SilenceDeath", true)
                end
                changeState(npc, "idle")
            end
        end
    elseif(phase=="reap1") then -- [[ REAP PRIME PHASE 1 ]]
        if(npc.HitPoints<REAP2_START_HP) then
            npc.HitPoints = REAP2_START_HP
            sprite:Play("Reap1Death", true)
            changeState(npc, "dying")
            npc.I1 = 999
        end

        if(state=="idle") then
            npc.Velocity = npc.Velocity*0.66
            if(data.reapTrail) then
                data.reapTrail:Remove()
                data.reapTrail = nil
            end
            if(((npc.I2~=-999 and ((data.stamina>0 and stateFrame>=15) or (stateFrame>=90))) or (npc.I2==-999 and stateFrame>=75))) then
                local attack = chooseAttack(npc)
                changeState(npc, "attack"..attack)
                npc.I1 = REAP1_ATTACKS[attack].Length
                npc.I2 = 0
                if(REAP1_ATTACKS[attack].ChangeState) then npc.State=5 end
                if(data.stamina<=0) then data.stamina=REAP1_BASESTAMINA end
                data.stamina = data.stamina-REAP1_ATTACKS[attack].StaminaCost
            end
        elseif(state=="dying") then
            npc.Velocity = npc.Velocity*0.66
        elseif(string.sub(state, 1, 6)=="attack") then
            if(state=="attack11") then
                if(stateFrame==1) then
                    sfx:Play(REAP1_ATTACK11.SFX1, 1.2, 0, false, 0.8)

                    if(data.reapTrail) then
                        data.reapTrail:Remove()
                        data.reapTrail = nil
                    end
                    local trail = spawnTrail(npc, 2, Vector(0,-15), Color(0.15,0.3,0.1,1,0,0,0)):ToEffect()
                    data.reapTrail = trail
                end
                npc.Velocity = npc.Velocity*0.80
                if((stateFrame-5)%20==10 and stateFrame>5) then
                    if((stateFrame+15)>npc.I1) then
                        if(data.reapTrail) then
                            data.reapTrail:Remove()
                            data.reapTrail = nil
                        end
                    end
                    sfx:Play(REAP1_ATTACK11.SFX2, 1.4, 0, false, 0.6)
                    npc.Velocity = targetVector*32
                    if(npc.Velocity.X>=0) then sprite:Play("Reap1AttackRight", true)
                    else sprite:Play("Reap1AttackLeft", true) end

                    local orbDist = (Vector(1,0.5)*REAP1_ATTACK11.PROJ_RADIUS)
                    local offset = math.floor(REAP1_ATTACK11.PROJ_NUM/2)
                    for i=0, REAP1_ATTACK11.PROJ_NUM do
                        local angle = i*(180/REAP1_ATTACK11.PROJ_NUM)
                        local rAngle = math.rad(angle)
                        local vel = Vector(math.sin(rAngle), math.cos(rAngle))
                        vel = (vel*orbDist):Rotated(targetVector:GetAngleDegrees())
                        local proj = fireProjectile(npc, Vector.Zero)

                        proj.Position = npc.Position+vel
                        proj:GetData().firingDelay = REAP1_ATTACK11.PROJ_DELAY
                        proj:GetData().delayedVel = targetVector*REAP1_ATTACK11.PROJ_SPEED
                    end
                end
            elseif(state=="attack12") then
                if(stateFrame==1) then
                    sfx:Play(REAP1_ATTACK12.SFX1, 1.5, 0, false, 1.1)

                    if(data.reapTrail) then
                        data.reapTrail:Remove()
                        data.reapTrail = nil
                    end
                    local trail = spawnTrail(npc, 2, Vector(0,-15), Color(0.15,0.3,0.1,1,0,0,0)):ToEffect()
                    data.reapTrail = trail
                end
                npc.Velocity = npc.Velocity*0.80
                if((stateFrame-5)%20==10 and stateFrame>5) then
                    if((stateFrame+15)>npc.I1) then
                        if(data.reapTrail) then
                            data.reapTrail:Remove()
                            data.reapTrail = nil
                        end
                    end
                    if(stateFrame<=75) then
                        sfx:Play(REAP1_ATTACK12.SFX2, 1.4, 0, false, 0.6)
                        npc.Velocity = targetVector*32
                        if(npc.Velocity.X>=0) then sprite:Play("Reap1AttackRight", true)
                        else sprite:Play("Reap1AttackLeft", true) end

                        local orbDist = (Vector(1,0.5)*REAP1_ATTACK12.PROJ_RADIUS)
                        local offset = math.floor(REAP1_ATTACK12.PROJ_NUM/2)
                        for i=0, REAP1_ATTACK12.PROJ_NUM do
                            local angle = i*(180/REAP1_ATTACK12.PROJ_NUM)
                            local rAngle = math.rad(angle)
                            local vel = Vector(math.sin(rAngle), math.cos(rAngle))
                            vel = (vel*orbDist):Rotated(targetVector:GetAngleDegrees())
                            local proj = fireProjectile(npc, Vector.Zero)

                            proj.Position = npc.Position+vel
                            proj:GetData().firingDelay = REAP1_ATTACK12.PROJ_DELAY
                            proj:GetData().delayedVel = targetVector*REAP1_ATTACK12.PROJ_SPEED
                        end

                        local proj = fireProjectile(npc, targetVector*24)
                        spawnTrail(proj, 0.5)
                        proj.Scale = 2
                        proj:GetData().serpentProjectile = true
                    end
                end
            elseif(state=="attack21") then
                npc.Velocity = npc.Velocity*0.75
                if(stateFrame==1) then
                    npc.I2 = 1
                    sfx:Play(REAP1_ATTACK21.SFX1, 2, 0, false, 1)
                    sfx:Play(REAP1_ATTACK21.SFX3, 1.3, 0, false, 0.75)

                    sprite:Play("Reap1Jump", true)
                end
                if((sprite:GetAnimation()=="Reap1Jump" and sprite:GetFrame()>=5) or sprite:GetAnimation()=="Reap1JumpIdle") then
                    npc.Velocity = targetVector*(npc.Position:Distance(targetPos)/3)
                end
                if(sprite:IsEventTriggered("Slam")) then
                    Game():ShakeScreen(2)

                    sfx:Play(REAP1_ATTACK21.SFX2, 1.4, 0, false, 0.6)
                    for i=1, REAP1_ATTACK21.PROJ_NUM do
                        local proj = fireProjectile(npc, Vector.FromAngle(i*(360/REAP1_ATTACK21.PROJ_NUM))*REAP1_ATTACK21.PROJ_SPEED)
                    end

                    for i=1,10 do
                        local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,npc.Position,Vector.FromAngle(rng:RandomFloat()*360)*(5+rng:RandomFloat()*4-2),npc):ToEffect()
                        dust.Color=Color(1,1,1,0.25,0,0,0)
                        dust:SetTimeout(20)
                        dust.SpriteScale = Vector(0.005,0.005)
                    end
                end
                if(sprite:IsEventTriggered("Jump")) then
                    if(npc.I2<=3) then
                        sprite:Play("Reap1Jump", true)
                        npc.I2=npc.I2+1
                    else
                        data.stateFrame=REAP1_ATTACKS[21].Length
                    end
                end
            elseif(state=="attack22") then
                npc.Velocity = npc.Velocity*0.75
                if(stateFrame==1) then
                    sfx:Play(REAP1_ATTACK22.SFX1, 1.5, 0, false, 1)
                    sprite:Play("Reap1Jump", true)
                end
                if((sprite:GetAnimation()=="Reap1Jump" and sprite:GetFrame()>=5) or sprite:GetAnimation()=="Reap1JumpIdle") then
                    npc.Velocity = targetVector*(npc.Position:Distance(targetPos)/3)
                end
                if(sprite:IsEventTriggered("Slam")) then
                    Game():ShakeScreen(2)

                    sfx:Play(REAP1_ATTACK22.SFX2, 1.4, 0, false, 0.6)
                    data.stateFrame=REAP1_ATTACKS[22].Length-50
                    sprite:Play("Reap1Blarg", true)
                    npc.I2 = math.floor(targetVector:GetAngleDegrees())
                    local laser = EntityLaser.ShootAngle(7,npc.Position,npc.I2,15,Vector.Zero,npc)
                    laser.Color = Color(0,0,0,0.5,0,1,0)

                    for i=1,10 do
                        local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,npc.Position,Vector.FromAngle(rng:RandomFloat()*360)*(5+rng:RandomFloat()*4-2),npc):ToEffect()
                        dust.Color=Color(1,1,1,0.25,0,0,0)
                        dust:SetTimeout(20)
                        dust.SpriteScale = Vector(0.005,0.005)
                    end
                end
                if(sprite:IsEventTriggered("Laser")) then
                    sfx:Play(REAP1_ATTACK22.SFX3, 1.6, 0, false, 1.1)
                    local laser = EntityLaser.ShootAngle(11,npc.Position,npc.I2,REAP1_ATTACK22.BRIM_DURATION,Vector.FromAngle(npc.I2)*20,npc)
                    laser.Color = Color(0,1,1,1,0,1,0)
                    laser.DisableFollowParent = true
                end
                if(sprite:IsPlaying("Reap1Blarg") and sprite:GetFrame()==18) then
                    Game():ShakeScreen(20)
                end
                if(stateFrame>=366 and stateFrame<=375 and stateFrame%3==0) then
                    local offset = (stateFrame-366)*(360/REAP1_ATTACK22.PROJ_NUM)/4
                    for i=1, REAP1_ATTACK22.PROJ_NUM do
                        local proj = fireProjectile(npc, Vector.FromAngle(i*(360/REAP1_ATTACK22.PROJ_NUM)+offset)*REAP1_ATTACK22.PROJ_SPEED)
                    end
                end
            elseif(state=="attack3") then
                npc.Velocity = npc.Velocity*0.75
                if(stateFrame%15==11 and stateFrame<31) then
                    sprite:Play("Reap1Groundpound", true)
                end
                if(sprite:IsEventTriggered("Groundpound")) then
                    for i=1,10 do
                        local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,npc.Position,Vector.FromAngle(rng:RandomFloat()*360)*(5+rng:RandomFloat()*4-2),npc):ToEffect()
                        dust.Color=Color(1,1,1,0.25,0,0,0)
                        dust:SetTimeout(20)
                        dust.SpriteScale = Vector(0.005,0.005)
                    end

                    sfx:Play(REAP1_ATTACK3.SFX2, 0.8)
                    sfx:Play(REAP1_ATTACK3.SFX1, 1.5, 0, false, 0.95)

                    for i=1, REAP1_ATTACK3.PROJ_NUM do
                        local angle = rng:RandomFloat()*360
                        local proj = Isaac.Spawn(9,9,0,npc.Position,Vector.FromAngle(angle)*Vector(rng:RandomFloat()+0.2,rng:RandomFloat()+0.2)*REAP1_ATTACK3.PROJ_SPEED,npc):ToProjectile()
                        proj.Color = Color(0.8,0.8,0.8,1,0,0,0)
                        proj.FallingAccel = -0.1
                        proj.FallingSpeed = 0
                        proj:GetData().explosiveRockProj = proj.Color
                    end
                end
                if(stateFrame==44) then
                    if(data.reapTrail) then
                        data.reapTrail:Remove()
                        data.reapTrail = nil
                    end
                    local trail = spawnTrail(npc, 2, Vector(0,-15), Color(0.15,0.3,0.1,1,0,0,0)):ToEffect()
                    data.reapTrail = trail
                end
                if(stateFrame>44 and (stateFrame-44)%15==5) then
                    if(stateFrame+15>npc.I1) then
                        if(data.reapTrail) then
                            data.reapTrail:Remove()
                            data.reapTrail = nil
                        end
                    end
                    sfx:Play(REAP1_ATTACK3.SFX3, 1.4, 0, false, 0.6)
                    sfx:Play(REAP1_ATTACK11.SFX1, 1.2, 0, false, 0.8)

                    npc.Velocity = targetVector*24
                    if(npc.Velocity.X>=0) then sprite:Play("Reap1AttackRight", true)
                    else sprite:Play("Reap1AttackLeft", true) end

                    for i=1, REAP1_ATTACK3.PROJ2_NUM do
                        local angle = targetVector:GetAngleDegrees()+REAP1_ATTACK3.PROJ2_ANGLE*(rng:RandomFloat()-0.5)
                        local speed = REAP1_ATTACK3.PROJ2_SPEED*(rng:RandomFloat()*0.4+0.8)
                        local proj = fireProjectile(npc, Vector.FromAngle(angle)*speed)
                    end
                end
            end

            if(stateFrame>=npc.I1) then
                changeState(npc, "idle")
            end
        end
    elseif(phase=="reap2") then
        if(npc.HitPoints<REAP3_START_HP) then
            npc.HitPoints = REAP3_START_HP
            sprite:Play("Reap2Death", true)
            changeState(npc, "dying")
            npc.I1 = 999
        end

        if(state=="idle") then
            npc.Velocity = npc.Velocity*0.66
            if((npc.I2~=-999 and stateFrame>=0) or stateFrame>=75) then
                local attack = 1
                if(data.stamina>0) then attack=chooseAttack(npc) end
                changeState(npc, "attack"..attack)
                npc.I1 = REAP2_ATTACKS[attack].Length
                npc.I2 = 0
                if(REAP2_ATTACKS[attack].ChangeState) then npc.State=5 end
                if(data.stamina<=0) then data.stamina=REAP2_BASESTAMINA end
                data.stamina = data.stamina-REAP2_ATTACKS[attack].StaminaCost
            end
        elseif(state=="dying") then
            npc.Velocity = npc.Velocity*0.66
        elseif(string.sub(state, 1, 6)=="attack") then
            if(state=="attack1") then
                if(stateFrame==1) then
                    sprite:Play("Reap2WatermelonHead", true)
                    npc.I2 = 0
                end
                if(sprite:IsEventTriggered("MelonExplode")) then
                    local bloodBurst = Isaac.Spawn(1000,2,3,npc.Position+Vector(0,1),Vector.Zero,npc):ToEffect()
                    bloodBurst:FollowParent(npc)
                    bloodBurst.SpriteOffset = Vector(0,-12)

                    local melon = fireProjectile(npc, targetVector*REAP2_ATTACK1.MELON_SPEED)
                    local mSprite = melon:GetSprite()
                    mSprite:Load("gfx/entities/npcs/reapprime/melonhead.anm2", true)
                    mSprite:Play("Idle", true)
                    melon.Color = Color(1,1,1,1,0,0,0)
                    melon.SpriteRotation = -90

                    melon.FallingAccel = REAP2_ATTACK1.MELON_FACCEL
                    melon.FallingSpeed = REAP2_ATTACK1.MELON_FSPEED
                    melon:AddProjectileFlags(ProjectileFlags.BOUNCE)
                    melon:GetData().isMelonProj = 0
                    melon:GetData().projSpriteRotation = 10
                    melon.Variant = 0
                    melon.SizeMulti = Vector(1,1)*2

                    if(npc.I2>0) then
                        melon.SizeMulti = Vector(1,1)
                        melon.SpriteScale = Vector(1,1)*0.75
                        melon:GetData().isMelonProj = 3
                        melon:GetData().projSpriteRotation = 10
                        melon.FallingSpeed = REAP2_ATTACK1.MELON_FACCEL*2
                    end
                    npc.I2 = npc.I2+1

                    sfx:Play(REAP2_ATTACK1.SFX2)
                end
                if(sprite:IsFinished("Reap2WatermelonHead")) then
                    if(npc.I2<2) then sprite:Play("Reap2WatermelonHead", true) end
                end
            elseif(state=="attack2") then
                if(stateFrame==1) then
                    sprite:Play("Reap2Blargh", true)
                    npc.I2 = 0
                end
                if(sprite:IsEventTriggered("Blargh")) then

                    sfx:Play(REAP2_ATTACK2.SFX2, 1.3,0,false,rng:RandomFloat()*0.3+0.7)

                    for i=1, REAP2_ATTACK2.PROJ_NUM do
                        local angle = targetVector:GetAngleDegrees()+REAP2_ATTACK2.PROJ_ANGLE*(rng:RandomFloat()-0.5)
                        local speed = REAP2_ATTACK2.PROJ_SPEED*(rng:RandomFloat()*0.8+0.2)
                        local proj = fireProjectile(npc, Vector.FromAngle(angle)*speed)

                        proj:GetData().isPopcornProj = math.max(0, npc.I1-stateFrame+rng:RandomInt(5)-2)
                    end

                    for i=1, REAP2_ATTACK2.TATER_NUM do
                        local pos = npc.Position+Vector.FromAngle(rng:RandomFloat()*360)*rng:RandomFloat()*320
                        local angle = (pos-npc.Position):GetAngleDegrees()
                        local speed = REAP2_ATTACK2.PROJ_SPEED*(npc.Position:Distance(pos)/480)
                        local proj = fireProjectile(npc, Vector.FromAngle(angle)*speed*(rng:RandomFloat()*0.4+0.9))
                        local pSprite = proj:GetSprite()
                        pSprite:Load("gfx/entities/npcs/reapprime/melonhead.anm2", true)
                        pSprite:Play("Idle2", true)
                        proj.FallingAccel = 1.5
                        proj.FallingSpeed = -20
                        proj.SpriteScale = proj.SpriteScale*1.25
                        proj.SizeMulti = proj.SizeMulti*1.25

                        proj:GetData().isHotPotatoProj = true
                        proj:GetData().projSpriteRotation = 15
                    end
                end
                if(sprite:IsFinished("Reap2Blargh") and npc.I2<1) then
                    sprite:Play("Reap2Blargh", true)
                    npc.I2=npc.I2+1
                end
            elseif(state=="attack3") then
                if(stateFrame==1) then
                    sprite:Play("Reap2Run", true)
                    sfx:Play(REAP2_ATTACK3.SFX1, 1.75, 0, false, rng:RandomFloat()*0.3+0.7)
                end
                if(stateFrame<=REAP2_ATTACK3.REAP_RUN_DURATION) then
                    npc.Velocity = h:lerp(npc.Velocity, targetVector*REAP2_ATTACK3.REAP_SPEED, 0.1)
                    if(rng:RandomFloat()<=REAP2_ATTACK3.FIRE_CHANCE) then
                        local flame = Isaac.Spawn(1000,REAP2_ATTACK3.FLAME_VARIANT,0,npc.Position,Vector.Zero,npc)
                        flame:GetData().isEnemyFire = 120
                    end
                    if(stateFrame%3==0) then
                        local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,npc.Position,Vector.FromAngle(rng:RandomFloat()*360)*2,npc):ToEffect()
                        dust.Color=Color(1,1,1,0.25,0.6,0.3,0)
                        dust:SetTimeout(20)
					    dust.SpriteScale = Vector(0.005,0.005)
                    end
                    sprite.FlipX = (npc.Velocity.X>0)
                else
                    npc.Velocity = npc.Velocity*0.6
                    if(stateFrame>REAP2_ATTACK3.REAP_RUN_DURATION) then
                        if(stateFrame==REAP2_ATTACK3.REAP_RUN_DURATION+1) then
                            data.stateFrame = npc.I1-20
                            sprite:Play("Reap2Idle", true)
                            sprite.FlipX = false
                        end
                        if(npc.Velocity:Length()<=0.1 and npc.I2==0) then
                            sprite:Play("Reap2Augh")
                            npc.I2=1
                        end
                        if(sprite:IsEventTriggered("Augh")) then
                            sfx:Play(REAP2_ATTACK3.SFX2, 1.75, 0, false, rng:RandomFloat()*0.2+1)

                            local flameNum = REAP2_ATTACK3.FLAME_NUM
                            for i=1, flameNum do
                                local angle = i*360/flameNum
                                local vel = Vector.FromAngle(angle+rng:RandomFloat()*30-15)*REAP2_ATTACK3.FLAME_SPEED
                                local flame = Isaac.Spawn(1000,REAP2_ATTACK3.FLAME_VARIANT,0,npc.Position,vel,npc)
                                flame:GetData().isEnemyFire = 120

                                local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,npc.Position,Vector.FromAngle(rng:RandomFloat()*360)*(5+rng:RandomFloat()*4-2),npc):ToEffect()
                                dust.Color=Color(1,1,1,0.25,0.6,0.3,0)
                                dust:SetTimeout(20)
                                dust.SpriteScale = Vector(0.005,0.005)
                            end
                        end
                    end
                end
            elseif(state=="attack4") then
                if(stateFrame<=REAP2_ATTACK4.TANGERINE_NUM*REAP2_ATTACK4.TANGERINE_COOLDOWN and stateFrame%(REAP2_ATTACK4.TANGERINE_COOLDOWN)==0) then
                    local tang = mod.ITEMS.OBNOXIOUSTANGERINE:spawnTangerine(npc)
                    local tData = tang:GetData()
                    tData.message = REAP2_ATTACK4.TANGERINE_MESSAGE
                    tData.isReapTangerine = true
                    tData.SFXvolume = 0.25

                    local tSprite = tang:GetSprite()
                    tSprite:ReplaceSpritesheet(0, "gfx/entities/npcs/reapprime/evilTangerines/tangerineReap1.png")
                    tSprite:ReplaceSpritesheet(1, "gfx/entities/npcs/reapprime/evilTangerines/tangerineReap1.png")
                    tSprite:LoadGraphics()
                end
                if(stateFrame%20==15) then
                    sprite:Play("Reap2Blargh", true)
                end
                if(sprite:IsEventTriggered("Blargh")) then
                    sfx:Play(REAP2_ATTACK4.SFX1, 1.5)

                    local projNum = REAP2_ATTACK4.SECONDARY_NUM
                    for i=1, projNum do
                        local dir = targetVector:Rotated(rng:RandomFloat()*30-15)
                        local proj = fireProjectile(npc, dir*REAP2_ATTACK4.SECONDARY_SPEED)
                    end
                end
            elseif(state=="attack5") then
                if(stateFrame==1) then
                    sprite:Play("Reap2Blargh", true)
                end
                if(sprite:IsEventTriggered("Blargh")) then
                    sfx:Play(REAP2_ATTACK5.SFX1, 1.5)

                    local pearNum = REAP2_ATTACK5.PEAR_NUM
                    local waitTable = {}
                    for i=1, pearNum do waitTable[i]=i*2 end
                    for i=1, pearNum do
                        local vel = Vector.FromAngle(i*360/pearNum+rng:RandomFloat()*50-25)*REAP2_ATTACK5.PEAR_SPEED*(rng:RandomFloat()*0.75+0.25)
                        local pear = Isaac.Spawn(5,REAP2_ATTACK5.PEAR_VARIANT,0,npc.Position,vel,npc):ToPickup()
                        pear.Wait = 9999
                        local chosenIndex = rng:RandomInt(#waitTable)+1
                        pear:GetData().burstPear = REAP2_ATTACK5.BURST_COOLDOWN+waitTable[chosenIndex]
                        table.remove(waitTable, chosenIndex)
                    end
                end
            end

            if(stateFrame>=npc.I1) then
                changeState(npc, "idle")
            end
        end
    elseif(phase=="reap3") then
        if(state=="idle") then
            --npc.Velocity = h:lerp(npc.Velocity, targetVector*REAP3_SPEED, 0.2)
            npc.Velocity = npc.Velocity*0.95
            if(sprite:IsEventTriggered("Move")) then npc.Velocity = targetVector*REAP3_SPEED2 end
            if(((npc.I2~=-999 and stateFrame>=60) or (npc.I2==-999 and stateFrame>=120))) then
                local attack=chooseAttack(npc)
                changeState(npc, "attack"..attack)
                npc.I1 = REAP3_ATTACKS[attack].Length
                npc.I2 = 0
                if(REAP3_ATTACKS[attack].ChangeState) then npc.State=5 end
            end
        elseif(string.sub(state, 1, 6)=="attack") then
            if(state=="attack1") then
                npc.Velocity = npc.Velocity*0.9
                if(stateFrame==1) then sprite:Play("Reap3Squish", true) end
                if(sprite:IsEventTriggered("Squish")) then
                    sfx:Play(REAP3_ATTACK1.SFX1, 2)

                    for i=1, REAP3_ATTACK1.PROJ_NUM do
                        local proj = fireProjectile(npc, targetVector:Rotated(rng:RandomFloat()*30-15)*REAP3_ATTACK1.PROJ_SPEED*(rng:RandomFloat()*0.75+0.75))
                        proj.FallingSpeed = -20+rng:RandomFloat()*10-5
                        proj.FallingAccel = 1.5+rng:RandomFloat()*0.75-0.25
                    end

                    local randNum = REAP3_ATTACK1.RANDOM_NUM
                    for i=1, randNum do
                        local proj = fireProjectile(npc, Vector.FromAngle(i*360/randNum + rng:RandomFloat()*30-15)*REAP3_ATTACK1.RANDOM_SPEED)
                    end
                end
            elseif(state=="attack2") then
                npc.Velocity = npc.Velocity*0.9
                if(stateFrame%20==1) then
                    sprite:Play("Reap3Spit", true)
                    npc.I2 = npc.I2+1
                end
                if(sprite:IsEventTriggered("Spit")) then
                    sfx:Play(REAP3_ATTACK2.SFX1, 2)

                    local spread = REAP3_ATTACK2.PROJ_SPREAD

                    local projNum = REAP3_ATTACK2.PROJ_NUM
                    local projSpeed = REAP3_ATTACK2.PROJ_SPEED
                    if(npc.I2>1) then
                        projNum = REAP3_ATTACK2.PROJ2_NUM
                        projSpeed = REAP3_ATTACK2.PROJ2_SPEED
                    end

                    for i=1, projNum do
                        local proj = fireProjectile(npc, targetVector:Rotated((i-projNum/2)*spread/projNum)*projSpeed)
                        proj:AddProjectileFlags(REAP3_ATTACK2.PROJ_FLAGS)
                        proj:GetData().backerSplitter = projSpeed
                    end
                end
            elseif(state=="attack3") then
                npc.Velocity = npc.Velocity*0.33
                if(stateFrame==1) then
                    npc.I2 = math.floor(targetVector:GetAngleDegrees())

                    sfx:Play(REAP3_ATTACK3.SFX1, 2)
                end
                if(stateFrame==REAP3_ATTACK3.PROJ_NUM-2) then sprite:Play("Reap3Squish") end
                if(stateFrame<=REAP3_ATTACK3.PROJ_NUM) then
                    local proj = fireProjectile(npc, Vector.Zero)
                    local dir = Vector.FromAngle((stateFrame-REAP3_ATTACK3.PROJ_NUM/2)*REAP3_ATTACK3.PROJ_SPREAD/REAP3_ATTACK3.PROJ_NUM+npc.I2)
                    proj.Position = npc.Position + dir*40
                    proj.Parent = npc
                    proj:GetData().reapDelayedProj = REAP3_ATTACK3.PROJ_NUM-stateFrame+5
                    proj:GetData().reapDelayedProjVel = dir*REAP3_ATTACK3.PROJ_SPEED
                end
            end

            if(stateFrame>=npc.I1) then
                changeState(npc, "idle")
            end
        end
    end

    if(data.stateFrame) then
        data.stateFrame = data.stateFrame+1
    end

    if(npc.ProjectileCooldown>0) then
        npc.ProjectileCooldown=npc.ProjectileCooldown-1
    end

    if(sprite:IsFinished("SilenceAttackShort")) then sprite:Play("SilenceIdle", true) end
    if(sprite:IsFinished("SilenceAttackLongIntro")) then sprite:Play("SilenceAttackLongLoop", true) end
    if(sprite:IsFinished("SilenceAttackLongEnd")) then sprite:Play("SilenceIdle", true) end
    if(sprite:IsFinished("SilenceDeath")) then
        sprite:Play("Reap1Idle", true)

        npc:SetSize(REAPPRIME_SIZE, REAPPRIME_SIZEMULT, REAPPRIME_GRIDCOLLPOINTS)
        music:Crossfade(Isaac.GetMusicIdByName("Genetically Modified Orthodoxy"), 2)
        data.stamina = REAP1_BASESTAMINA
        npc.I2 = -999
    end
    if(sprite:IsFinished("Reap1AttackRight")) then sprite:Play("Reap1Idle", true) end
    if(sprite:IsFinished("Reap1AttackLeft")) then sprite:Play("Reap1Idle", true) end
    if(sprite:IsFinished("Reap1Jump")) then sprite:Play("Reap1JumpIdle", true) end
    if(sprite:IsFinished("Reap1Slam")) then sprite:Play("Reap1Idle", true) end
    if(sprite:IsFinished("Reap1Blarg")) then sprite:Play("Reap1Idle", true) end
    if(sprite:IsFinished("Reap1Groundpound")) then sprite:Play("Reap1Idle", true) end
    if(sprite:IsFinished("Reap1Death")) then
        changePhase(npc, "reap2")
        sprite:Play("Reap2Idle", true)

        npc:SetSize(REAPPRIME_SIZE, REAPPRIME_SIZEMULT, REAPPRIME_GRIDCOLLPOINTS)
        data.stamina = REAP2_BASESTAMINA
        npc.I2 = -999
    end

    if(sprite:IsFinished("Reap2WatermelonHead")) then sprite:Play("Reap2Idle", true) end
    if(sprite:IsFinished("Reap2Augh")) then sprite:Play("Reap2Idle", true) end
    if(sprite:IsFinished("Reap2Death")) then
        changePhase(npc, "reap3")
        sprite:Play("Reap3Idle", true)

        npc:SetSize(REAP3_SIZE, REAP3_SIZEMULT, REAPPRIME_GRIDCOLLPOINTS)
        data.stamina = 0
        npc.I2 = -999
    end

    if(sprite:IsFinished("Reap3Spit")) then sprite:Play("Reap3Idle", true) end
    if(sprite:IsFinished("Reap3Squish")) then sprite:Play("Reap3Idle", true) end

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, funcs.preNpcUpdate, reapPrimeType)

--#endregion

--#region CHALLENGE_END_LOGIC
function funcs:postEntityRemove(entity)
    local sprite = entity:GetSprite()
    local data = entity:GetData()
    local room = Game():GetRoom()

    for i, proj in ipairs(Isaac.FindByType(9,4)) do
        proj:Die()
    end

    if(REAP_ISDEAD==false and entity.HitPoints<=0) then
        REAP_ISDEAD = true
        FADEOUT_FRAME = Game():GetFrameCount()
        if(mod.MARKS.CHALLENGES.PROLOGUE==1) then goto invalid end
        mod.MARKS.CHALLENGES.PROLOGUE=1

        local achTable = mod.UNLOCKS.CHALLENGES.PROLOGUE.ACHIEVEMENT
        for _, achievement in ipairs(achTable) do
            mod:showAchievement(achievement)
        end
        ::invalid::
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove, reapPrimeType)

--sfx:Play(SFX_REAP_DEATH)

function funcs:inputAction(entity,inputHook,buttonAction)
    if(REAP_ISDEAD) then
        if(inputHook<=1) then return false
        else return 0.0 end
    end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, funcs.inputAction)

local blackBg = Sprite()
blackBg:Load("gfx/black.anm2", true)
blackBg:Play("Main")
blackBg.Scale = Vector(3,3)
function funcs:postRender()
    if(FADEOUT_FRAME>0) then
        local dif = Game():GetFrameCount()-FADEOUT_FRAME

        if(dif>60) then
            Game():End(1)
            Game():Fadeout(1, 2)
            dif=-1
        elseif(dif~=-1) then
            blackBg.Color = Color(1,1,1,math.max(0,(dif-30)/30),0,0,0)
            blackBg:Render(Vector.Zero)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.postRender)

function funcs:postGameStarted(isCont)
    REAP_ISDEAD = false
    FADEOUT_FRAME = 0
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, funcs.postGameStarted)
--#endregion

---@param proj EntityProjectile
function funcs:postProjectileUpdate(proj)
    local data = proj:GetData()
    local rng = proj:GetDropRNG()
    local npc = proj.SpawnerEntity
    if(npc==nil or (npc and npc:ToNPC()==nil)) then return end
    npc=npc:ToNPC()
    if(data.silenceBlackHole) then
        local desiredVel = (proj.Parent.Target.Position-proj.Position):Normalized()*data.silenceBlackHoleSpeed
        proj.Velocity = proj.Velocity*0.8+desiredVel*0.2

        local color = cloneColor(proj.Color)
        local colorVal = math.sin(proj.FrameCount)*0.025+0.075
        color.RO=colorVal
        color.BO=colorVal

        proj.Color = color

        for _, tear in ipairs(Isaac.FindInRadius(proj.Position, proj.Size*(proj.SizeMulti.X+proj.SizeMulti.Y)/2, EntityPartition.TEAR)) do
            tear=tear:ToTear()
            proj.Velocity = proj.Velocity+(proj.Position-tear.SpawnerEntity.Position):Normalized()*10*tear.KnockbackMultiplier
            tear:Die()
        end

        if(proj.FrameCount>SILENCE_ATTACKS[3].Length) then proj:Die() end
    end
    if(data.silenceDelayedProj) then
        if(proj.FrameCount<=data.silenceDelayedProj) then proj.Velocity=proj.Velocity*0.8 end
        if(proj.FrameCount==data.silenceDelayedProj+1) then
            local offsetAngle = proj:GetDropRNG():RandomFloat()*15-7.5
            proj.Velocity = ((proj.Parent.Target.Position-proj.Position):Normalized()*data.silenceDelayedProjSpeed):Rotated(offsetAngle)
        end
    end
    if(data.firingDelay) then
        if(proj.FrameCount<data.firingDelay) then
            proj.Velocity = proj.Velocity*0.9
        elseif(proj.FrameCount>=data.firingDelay and proj.FrameCount<=data.firingDelay+20) then
            proj.Velocity = data.delayedVel*((proj.FrameCount-data.firingDelay+10)/30)
        end
    end
    if(data.serpentProjectile) then
        if(proj.FrameCount==1) then
            proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        end
        if(not Game():GetRoom():IsPositionInRoom(proj.Position, 20)) then
            proj.Velocity = Vector.Zero
            proj.Visible = false
            proj.Position = Game():GetRoom():GetClampedPosition(proj.Position, 22)
            data.deathFrame = proj.FrameCount
        end
        if(data.deathFrame) then
            local pDelay = REAP1_ATTACK12.PROJ2_DELAY
            local pNum = REAP1_ATTACK12.PROJ2_NUM
            local pAmount = REAP1_ATTACK12.PROJ2_AMOUNT
            local pSpeed = REAP1_ATTACK12.PROJ2_SPEED
            if(proj.FrameCount<=(data.deathFrame+pDelay*(pAmount-1))) then
                if(proj.FrameCount%pDelay==data.deathFrame%pDelay) then
                    for i=1, pNum do
                        local offset = (proj.FrameCount)*(360/pNum)/4
                        local proj2 = fireProjectile(npc, Vector.FromAngle(i*(360/pNum)+offset)*pSpeed)
                        proj2.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                        proj2.FallingAccel = -0.04
                        proj2.Position = proj.Position
                    end
                end
            else
                proj:Remove()
            end
        end
    end
    if(data.explosiveRockProj) then
        if(proj.FrameCount==30) then
            local offset = rng:RandomFloat()*360
            for i=1, REAP1_ATTACK3.PROJ3_NUM do
                local vel = Vector.FromAngle(i*(360/REAP1_ATTACK3.PROJ3_NUM)+offset)*REAP1_ATTACK3.PROJ3_SPEED
                local proj2 = Isaac.Spawn(9,9,0,proj.SpawnerEntity.Position,vel,proj.SpawnerEntity):ToProjectile()
                proj2.Color = Color(0.8,0.8,0.8,1,0,0,0)
                proj2.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                proj2.FallingAccel = 1
                proj2.FallingSpeed = -5
                proj2.Scale = 0.5
                proj2.Position = proj.Position
            end
            proj:Remove()
        end
    end
    if(type(data.isMelonProj)=="number") then
        if(proj.Height>-20) then
            if(data.isMelonProj<REAP2_ATTACK1.MELON_BOUNCES) then
                proj.FallingAccel = REAP2_ATTACK1.MELON_FACCEL
                proj.FallingSpeed = REAP2_ATTACK1.MELON_FSPEED
                proj.Height = -20

                data.isMelonProj = data.isMelonProj+1

                local burstEffect = Isaac.Spawn(1000,2,1,proj.Position,Vector.Zero,proj)
                sfx:Play(REAP2_ATTACK1.MELON_SFX1,0.8)

                local burstNum = REAP2_ATTACK1.MINIBURST_PROJ
                local angleOffset = rng:RandomFloat()*360
                for i=1, burstNum do
                    local vel = Vector.FromAngle(angleOffset+i*(360/burstNum))*(rng:RandomFloat()*0.5+0.75)
                    local proj2 = Isaac.Spawn(9,0,0,proj.Position,vel*REAP2_ATTACK1.MINIBURST_SPEED,proj):ToProjectile()
                    proj2.FallingAccel = 1
                    proj2.FallingSpeed = -10
                end

                local targetVel = Vector.FromAngle((npc.Target.Position-proj.Position):GetAngleDegrees())
                proj.Velocity = h:lerp(proj.Velocity, targetVel*REAP2_ATTACK1.MELON_SPEED, 0.4)

                local creep = Isaac.Spawn(1000,22,0,proj.Position,Vector.Zero,proj):ToEffect()
                creep.Scale = 1.5
            elseif(data.isMelonProj==REAP2_ATTACK1.MELON_BOUNCES) then
                local burstEffect = Isaac.Spawn(1000,2,3,proj.Position,Vector.Zero,proj)
                sfx:Play(REAP2_ATTACK1.MELON_SFX2,0.8)

                local burstNum = REAP2_ATTACK1.BURST_PROJ
                local angleOffset = rng:RandomFloat()*360
                for i=1, burstNum do
                    local vel = Vector.FromAngle(angleOffset+i*(360/burstNum))*(rng:RandomFloat()*0.5+0.75)
                    local proj2 = Isaac.Spawn(9,0,0,proj.Position,vel*REAP2_ATTACK1.BURST_SPEED,proj):ToProjectile()
                    proj2.FallingAccel = 1.5
                    proj2.FallingSpeed = -15+rng:RandomFloat()*10
                end

                local creep = Isaac.Spawn(1000,22,0,proj.Position,Vector.Zero,proj):ToEffect()
                creep.Scale = 3

                proj:Remove()
            end
        end
    end
    if(data.isPopcornProj) then
        proj.Velocity = proj.Velocity*0.95
        if(proj.FrameCount>=data.isPopcornProj) then
            sfx:Play(REAP2_ATTACK2.BURST_SFX,0.8)

            local burstNum = REAP2_ATTACK2.BURST_NUM
            local angleOffset = rng:RandomFloat()*360
            for i=1, burstNum do
                local specificOffset = rng:RandomFloat()*30-15
                local vel = Vector.FromAngle(specificOffset+angleOffset+i*(360/burstNum))*(rng:RandomFloat()+0.25)
                local proj2 = fireProjectile(npc, vel*REAP2_ATTACK2.BURST_SPEED)
                proj2.FallingAccel = 1.5
                proj2.FallingSpeed = -15+rng:RandomFloat()*10
                proj2.Position = proj.Position
            end

            proj:Remove()
        end
    end
    if(data.isHotPotatoProj) then
        if(proj.Height>-20) then
            Isaac.Explode(proj.Position, npc, 40)

            for i=0,3 do
                local jet = fj:spawnFireJet(npc, 1, proj.Position, 30, 40, 3, i*90, nil, Color(0.5,1,0.6,1))
                jet:GetData().fjIsPlayerFriendly = true
            end

            proj:Remove()
        end
    end
    if(data.projSpriteRotation) then
        proj.SpriteRotation = proj.SpriteRotation+data.projSpriteRotation
    end
    if(data.burstPearProj) then
        if(proj.Height>-20) then
            local projNum = REAP2_ATTACK5.BURST_NUM
            for i=1,projNum do
                local dir = Vector.FromAngle(i*360/projNum+rng:RandomFloat()*30-15)
                local proj2 = fireProjectile(npc, dir*REAP2_ATTACK5.BURST_SPEED)
                proj2.FallingAccel = 1.5
                proj2.FallingSpeed = -10+rng:RandomFloat()*5
                proj2.Position = proj.Position
            end

            proj:Remove()
        end
    end
    if(data.reapDelayedProj) then
        if(proj.FrameCount==data.reapDelayedProj) then
            proj.Velocity = data.reapDelayedProjVel
        end
    end
    if(proj.SpawnerEntity and proj.SpawnerType==reapPrimeType and proj.FrameCount>=300) then proj:Die() end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, funcs.postProjectileUpdate)

---@param proj EntityProjectile
function funcs:postProjRemove(proj)
    local data = proj:GetData()
    local npc = proj.SpawnerEntity
    if(npc==nil or (npc and npc:ToNPC()==nil)) then return end
    npc=npc:ToNPC()

    if(data.backerSplitter) then
        local player = npc.Target or Isaac.GetPlayer()
        local targetVector = (player.Position-proj.Position):Normalized()
        local proj2 = fireProjectile(npc, targetVector*data.backerSplitter)
        proj2.Position = proj.Position
        proj2:AddProjectileFlags(REAP3_ATTACK2.PROJ_FLAGS)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postProjRemove, EntityType.ENTITY_PROJECTILE)

function funcs:preProjectileCollision(proj, coll, _)
    local data = proj:GetData()
    if(data.silenceBlackHole) then
        if(coll.Type==1) then
            coll:TakeDamage(1,0,EntityRef(proj),0)
            return false
        elseif(coll.Type==2) then
            coll.Velocity = coll.Velocity+(proj.Position-coll.Position):Normalized()*10
            return false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, funcs.preProjectileCollision)

function funcs:postFlameUpdate(flame)
    local data = flame:GetData()
    local sprite = flame:GetSprite()
    if(data.dieFaster) then
        if(flame.FrameCount>=data.dieFaster and (not sprite:IsPlaying("Disappear"))) then sprite:Play("Disappear", true) end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, funcs.postFlameUpdate, 33)

function funcs:postTangerineRemove(effect)
    if(effect.Variant==REAP2_ATTACK4.TANG_VARIANT and effect.SubType==0) then
        if(effect:GetData().isReapTangerine) then
            if(effect.SpawnerEntity==nil or (effect.SpawnerEntity and effect.SpawnerEntity:ToNPC()==nil)) then return end
            local npc = effect.SpawnerEntity:ToNPC()
            local projNum = REAP2_ATTACK4.PROJ_NUM
            local rng = effect:GetDropRNG()
            for i=1,projNum do
                local dir = Vector.FromAngle(i*360/projNum+rng:RandomFloat()*30-15)
                local proj = fireProjectile(npc, dir*REAP2_ATTACK4.PROJ_SPEED)
                proj.FallingAccel = 1.5
                proj.FallingSpeed = -10+rng:RandomFloat()*5
                proj.Position = effect.Position
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postTangerineRemove, EntityType.ENTITY_EFFECT)

function funcs:postTangerineUpdate(effect)
    if(effect.SubType==0) then
        if(effect:GetData().isReapTangerine) then
            local sprite = effect:GetSprite()

            local maxFrames = REAP2_ATTACK4.TANGERINE_DURATION

            effect.SpriteOffset = Vector(effect.FrameCount%2, 0)

            if(effect.FrameCount==maxFrames-15) then
                sprite:ReplaceSpritesheet(0, "gfx/entities/npcs/reapprime/evilTangerines/tangerineReap2.png")
                sprite:ReplaceSpritesheet(1, "gfx/entities/npcs/reapprime/evilTangerines/tangerineReap2.png")
                sprite:LoadGraphics()
            elseif(effect.FrameCount==maxFrames-5) then
                sprite:ReplaceSpritesheet(0, "gfx/entities/npcs/reapprime/evilTangerines/tangerineReap3.png")
                sprite:ReplaceSpritesheet(1, "gfx/entities/npcs/reapprime/evilTangerines/tangerineReap3.png")
                sprite:LoadGraphics()
            elseif(effect.FrameCount==maxFrames) then
                effect:Remove()
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postTangerineUpdate, REAP2_ATTACK4.TANG_VARIANT)

---@param pickup EntityPickup
function funcs:postPearUpdate(pickup)
    local data = pickup:GetData()
    if(data.burstPear) then
        if(pickup.SpawnerEntity==nil or (pickup.SpawnerEntity and pickup.SpawnerEntity:ToNPC()==nil)) then return end

        local rng = pickup:GetDropRNG()
        local npc = pickup.SpawnerEntity:ToNPC()
        local player = npc.Target or Isaac.GetPlayer()

        if(pickup.FrameCount<=10) then pickup.SpriteScale = Vector(1,1)*pickup.FrameCount/10 end
        if(pickup.FrameCount>=data.burstPear-15) then
            local wTint = 1-(data.burstPear-pickup.FrameCount)/15
            pickup.Color = Color(1-wTint*0.7,1-wTint*0.4,1-wTint*0.8,1,0,0,0)
            --0.3,0.6,0.2
        end

        if(pickup.FrameCount==data.burstPear) then
            sfx:Play(REAP2_ATTACK5.SFX2)

            local playerPos = player.Position+player.Velocity*25+Vector.FromAngle(rng:RandomFloat()*360)*5
            local dist = (pickup.Position:Distance(playerPos)/480)
            local speed = REAP2_ATTACK5.PROJ_SPEED*dist
            local angle = (playerPos-pickup.Position):GetAngleDegrees()
            local proj = fireProjectile(npc,Vector.FromAngle(angle)*speed)
            proj.Position = pickup.Position
            proj.FallingAccel = 2
            proj.FallingSpeed = -35
            proj.Scale = 2
            proj:GetData().burstPearProj = true

            local effect = Isaac.Spawn(1000,EffectVariant.IMPACT,0,pickup.Position,Vector.Zero,pickup)
            effect.Color = Color(1,1,1,1,0.3,0.6,0.2)

            pickup:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPearUpdate, REAP2_ATTACK5.PEAR_VARIANT)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    local data = entity:GetData()
    local sprite = entity:GetSprite()
    local anim = sprite:GetAnimation()
    local frame = sprite:GetFrame()
    if(data.phase=="silence" and data.state=="attack4") then
        return false
    end
    if(data.phase=="reap1") then
        if((anim=="Reap1Jump") or (anim=="Reap1Slam" and frame<=9) or (anim=="Reap1JumpIdle")) then
            return false
        end
    end
    if(sprite:GetAnimation()=="Reap1Death") then
        return false
    end
    if(sprite:GetAnimation()=="Reap2Death") then
        return false
    end

    if(entity.HitPoints<=amount) then
        sfx:Play(SFX_REAP_DEATH, 1.5, 0, false, 0.9)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, reapPrimeType)

---@param npc EntityNPC
---@param collider Entity
function funcs:preNpcCollision(npc, collider, _)
    local data = npc:GetData()
    local sprite = npc:GetSprite()
    local anim = sprite:GetAnimation()
    local frame = sprite:GetFrame()
    if(data.phase=="reap1") then
        if(collider.Type==1) then
            if(anim=="Reap1JumpIdle") then sprite:Play("Reap1Slam", true) end
            return true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, funcs.preNpcCollision, reapPrimeType)

---@param tear EntityTear
---@param collider Entity
function funcs:preTearCollision(tear, collider, _)
    if(collider.Type==reapPrimeType) then
        collider = collider:ToNPC()
        local anim = collider:GetSprite():GetAnimation()
        local frame = collider:GetSprite():GetFrame()
        if((anim=="Reap1Jump") or (anim=="Reap1Slam" and frame<=9) or (anim=="Reap1JumpIdle")) then
            return true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, funcs.preTearCollision)

--[[ RENDER STUFF ]]--
--[[
local f = Font()
f:Load("font/pftempestasevencondensed.fnt")
function funcs:testRenderSHit()
    local npc = Isaac.FindByType(reapPrimeType)[1]
    local pos = Vector(60,50)

    local isDead = "false"
    if(REAP_ISDEAD) then isDead="true" end
    f:DrawStringScaled("IS DEAD:", pos.X, pos.Y+60, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(isDead, pos.X+60, pos.Y+60, 0.75, 0.75, KColor(1,1,0,1), 0, true)

    if(not npc) then return end
    local data = npc:GetData()
    f:DrawStringScaled("Phase:", pos.X, pos.Y, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(data.phase, pos.X+60, pos.Y, 0.75, 0.75, KColor(1,1,0,1), 0, true)

    f:DrawStringScaled("State:", pos.X, pos.Y+10, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(data.state, pos.X+60, pos.Y+10, 0.75, 0.75, KColor(1,1,0,1), 0, true)

    f:DrawStringScaled("Stateframe:", pos.X, pos.Y+20, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(data.stateFrame, pos.X+60, pos.Y+20, 0.75, 0.75, KColor(1,1,0,1), 0, true)

    f:DrawStringScaled("Stamina:", pos.X, pos.Y+30, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(data.stamina, pos.X+60, pos.Y+30, 0.75, 0.75, KColor(1,1,0,1), 0, true)

    f:DrawStringScaled("Animation:", pos.X, pos.Y+40, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(npc:GetSprite():GetAnimation(), pos.X+60, pos.Y+40, 0.75, 0.75, KColor(1,1,0,1), 0, true)

    f:DrawStringScaled("HP:", pos.X, pos.Y+50, 0.75, 0.75, KColor(1,1,1,1), 0, true)
    f:DrawStringScaled(npc.HitPoints .. " / " .. npc.MaxHitPoints, pos.X+60, pos.Y+50, 0.75, 0.75, KColor(1,1,0,1), 0, true)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.testRenderSHit)
]]

mod.ENTITIES.REAPPRIME = funcs