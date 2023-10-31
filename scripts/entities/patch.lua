local mod = jezreelMod
local sfx = SFXManager()

local h = include("scripts/func")
local fj = include("scripts/firejet")

local IS_PATCH_MODE_ENABLED = true

local patchBossId = Isaac.GetEntityTypeByName("Patch 2.9.1 (BOSS)")
local patchApparitionVar = Isaac.GetEntityVariantByName("Patch 2.9.1 (APPARITION)")

--#region JUMPSCARE

local IS_JUMPSCARING = false
local JUMPSCARE_FRAMES = 0

local JUMPSCARE_SPRITE = Sprite()
JUMPSCARE_SPRITE:Load("gfx/entities/effects/patch/jumpscare.anm2", true)

local JUMPSCARE_DURATION = 5
local JUMPSCARE_FADEOUT = 20
local JUMPSCARE_SFX = Isaac.GetSoundIdByName("JumpscareScream")
sfx:Preload(JUMPSCARE_SFX)

local JUMPSCARES = {"jumpscare1", "jumpscare2", "jumpscare3", "jumpscare4", "jumpscare5", "jumpscare6"}

local function makeJumpscare(jumpscareId)
    local chosenJumpscare = jumpscareId or 1
    if(jumpscareId==nil) then
        chosenJumpscare = JUMPSCARES[Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_2SPOOKY):RandomInt(#JUMPSCARES)+1]
    end

    JUMPSCARE_SPRITE:ReplaceSpritesheet(0,"gfx/entities/effects/patch/"..chosenJumpscare..".png")
    JUMPSCARE_SPRITE:LoadGraphics()
    JUMPSCARE_SPRITE:Play("Idle", true)

    IS_JUMPSCARING = true
    JUMPSCARE_FRAMES = 0

    sfx:Play(JUMPSCARE_SFX)
end

local function getShaderParams(_, shaderName)
    if(shaderName=="GreenIsaacEmptyShader") then
        if(IS_JUMPSCARING) then
            if(not Game():IsPaused()) then
                JUMPSCARE_FRAMES = JUMPSCARE_FRAMES+0.5
            end

            local opacity = 1
            if(JUMPSCARE_FRAMES>JUMPSCARE_DURATION) then
                opacity = opacity*(JUMPSCARE_FADEOUT-JUMPSCARE_FRAMES+JUMPSCARE_DURATION)/JUMPSCARE_FADEOUT
            end

            JUMPSCARE_SPRITE.Color = Color(1,1,1,opacity)

            JUMPSCARE_SPRITE.Scale = Vector(Isaac.GetScreenWidth()/480, Isaac.GetScreenHeight()/270)
            JUMPSCARE_SPRITE:Render(Vector.Zero)

            if(JUMPSCARE_FRAMES>=JUMPSCARE_DURATION+JUMPSCARE_FADEOUT) then
                IS_JUMPSCARING=false
                JUMPSCARE_FRAMES=0
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, getShaderParams)

--#endregion

--#region APPARITION

local APPARITION_BASE_OPACITY = 0.75
local FADEIN_DURATION = 0.2
local FADEOUT_DURATION = 0.1

local FADEIN_MAXDUR = 10
local FADEOUT_MAXDUR = 8

local BASE_APPARITION_APPEAR_CHANCE = 0
local CLEARED_ROOM_APPEAR_MOD = 1/3
local APPARITION_APPEAR_CHANCES = {
    [LevelStage.STAGE1_1] = 0,
    [LevelStage.STAGE1_2] = 0.05,
    [LevelStage.STAGE2_1] = 0.15,
    [LevelStage.STAGE2_2] = 0.2,
    [LevelStage.STAGE3_1] = 0.3,
    [LevelStage.STAGE3_2] = 0.45,
    [LevelStage.STAGE4_1] = 0.6,
    [LevelStage.STAGE4_2] = 0.3,
    [LevelStage.STAGE4_3] = 0.3,
    [LevelStage.STAGE5] = 0.45,
    [LevelStage.STAGE6] = 0.6,
    [LevelStage.STAGE7] = 0.75,
    [LevelStage.STAGE8] = 0.03,
}

local APPARITION_DURATIONS = {
    [LevelStage.STAGE1_1] = {1, 5},
    [LevelStage.STAGE1_2] = {2, 9},
    [LevelStage.STAGE2_1] = {4, 12},
    [LevelStage.STAGE2_2] = {4, 16},
    [LevelStage.STAGE3_1] = {6, 25},
    [LevelStage.STAGE3_2] = {8, 30},
    [LevelStage.STAGE4_1] = {15, 30},
    [LevelStage.STAGE4_2] = {20, 35},
    [LevelStage.STAGE4_3] = {25, 45},
    [LevelStage.STAGE5] = {30, 65},
    [LevelStage.STAGE6] = {30, 90},
    [LevelStage.STAGE7] = {35, 100},
    [LevelStage.STAGE8] = {5, 15},
}

local APPARITION_PROJECTILEBURST_REQ = {
    [LevelStage.STAGE4_1] = 3,
    [LevelStage.STAGE4_3] = 1,
    [LevelStage.STAGE5] = 4,
    [LevelStage.STAGE6] = 5,
    [LevelStage.STAGE7] = 6 ,
}

local APPARITION_JUMPSCARE_REQ = {
    [LevelStage.STAGE2_2] = 0.0001,
    [LevelStage.STAGE3_1] = 0.001,
    [LevelStage.STAGE3_2] = 0.01,
    [LevelStage.STAGE4_1] = 0.03,
    [LevelStage.STAGE4_2] = 0.02,
    [LevelStage.STAGE4_3] = 0.02,
    [LevelStage.STAGE5] = 0.02,
    [LevelStage.STAGE6] = 0.03,
    [LevelStage.STAGE7] = 0.05,
    [LevelStage.STAGE8] = 0.01,
}

--TARGET AND PUMPKINHEAD APPARITION
local TARGET_APPARITION_HEADS_NUM = 6
local HEAD_START_DISTANCE = 200
local TARGET_FOLLOW_DURATION = 60
local HEAD_DASH_DURATION = 15
local PUMPKIN_BURST_PROJSPEED = 7
local FOLLOW_SLOWDOWN_DURATION = 10

--DASH APPARITION
local DASH_WAIT_DURATION = 40
local DASH_DURATION = 15
local DASH_DISAPPEAR_DURATION = 10

local function shortestPlayerDistanceToPos(pos)
    local shortestPos = 2^32
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        shortestPos = math.min(shortestPos, player.Position:Distance(pos))
    end

    return shortestPos
end

local function getApparitionPosition(rng)
    local room = Game():GetRoom()

    local pos = room:GetRandomPosition(10)
    local shouldRecalcDist = rng:RandomFloat()

    if((shortestPlayerDistanceToPos(pos)>40*8)
    or (shortestPlayerDistanceToPos(pos)>40*5 and shouldRecalcDist<0.7)
    or (shortestPlayerDistanceToPos(pos)<40*2)) then
        return getApparitionPosition(rng)
    else
        return pos
    end
end

local function createPatchApparition(rng)
    local pos = getApparitionPosition(rng)

    local apparition = Isaac.Spawn(EntityType.ENTITY_EFFECT, patchApparitionVar, 0, pos, Vector.Zero, nil):ToEffect()

    if(rng:RandomFloat()<(APPARITION_JUMPSCARE_REQ[Game():GetLevel():GetStage()] or 0)) then
        makeJumpscare()
    end

    return apparition
end

---@param effect EntityEffect
local function apparitionInit(_, effect)
    local rng = effect:GetDropRNG()
    local sprite = effect:GetSprite()

    effect.Color = Color(1,1,1,0)

    if(effect.SubType==0) then
        sprite:Play("Idle", true)
        sprite:Stop()

        sprite:SetLastFrame()
        local framesNum = sprite:GetFrame()+1
        sprite:SetFrame(rng:RandomInt(framesNum))

        local timeoutClamps = APPARITION_DURATIONS[Game():GetLevel():GetStage()] or APPARITION_DURATIONS[LevelStage.STAGE1_1]
        effect.LifeSpan = rng:RandomInt(timeoutClamps[2]-timeoutClamps[1])+timeoutClamps[1]+1
    elseif(effect.SubType==1) then
        sprite:Play("Blank", true)
        effect.Rotation = rng:RandomFloat()*360

        for i=1, TARGET_APPARITION_HEADS_NUM do
            local relPos = Vector.FromAngle(i*360/TARGET_APPARITION_HEADS_NUM+effect.Rotation)*HEAD_START_DISTANCE
            local patchHead = Isaac.Spawn(EntityType.ENTITY_EFFECT, patchApparitionVar, 2, effect.Position+relPos, Vector.Zero, effect.SpawnerEntity):ToEffect()
            patchHead.Parent = effect
            patchHead.State = 0
        end
        effect.State = 0
        effect.Visible = false
    elseif(effect.SubType==2) then
        sprite:Play("HeadLaugh", true)
    elseif(effect.SubType==3) then
        sprite:Play("Idle", true)
        sprite:Stop()

        local room = Game():GetRoom()

        local roomPos = {Left=room:GetTopLeftPos().X-75, Right=room:GetBottomRightPos().X+75, Top=room:GetTopLeftPos().Y, Bottom=room:GetBottomRightPos().Y}

        local pos1 = Vector(roomPos.Left, roomPos.Top+rng:RandomFloat()*(roomPos.Bottom-roomPos.Top))
        local pos2 = Vector(roomPos.Right, roomPos.Top+rng:RandomFloat()*(roomPos.Bottom-roomPos.Top))

        local spawnOnLeft = rng:RandomFloat()<0.5
        if(spawnOnLeft) then
            effect.Position = pos1
            effect.TargetPosition = pos2
        else
            effect.Position = pos2
            effect.TargetPosition = pos1
            sprite.FlipX = true
        end

        local tracer = Isaac.Spawn(7,7,0,effect.Position,Vector.Zero,effect):ToLaser()
        tracer.Parent = effect
        tracer.Angle = (effect.TargetPosition-effect.Position):GetAngleDegrees()
        tracer.Timeout = 100

        tracer.Color = Color(1,0.9,0,0,1,0,0)

        tracer:GetData().patchTracer = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, apparitionInit, patchApparitionVar)

local function makeApparitions(_)
    if(IS_PATCH_MODE_ENABLED~=true) then return end
    local rng = Isaac.GetPlayer():GetCollectibleRNG(CollectibleType.COLLECTIBLE_2SPOOKY)

    local enemyNum = #Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 40*20, EntityPartition.ENEMY)
    local chanceMod = (enemyNum<=0 and CLEARED_ROOM_APPEAR_MOD) or 1

    local spawnApparitionRoll = rng:RandomFloat()
    local chanceToAppear = (APPARITION_APPEAR_CHANCES[Game():GetLevel():GetStage()] or BASE_APPARITION_APPEAR_CHANCE)*chanceMod*1/30

    if(spawnApparitionRoll<chanceToAppear) then
        createPatchApparition(rng)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, makeApparitions)

---@param effect EntityEffect
local function apparitionUpdate(_, effect)
    local sprite = effect:GetSprite()
    if(effect.SubType==0) then
        if(effect.FrameCount>=effect.LifeSpan) then
            local projNum = APPARITION_PROJECTILEBURST_REQ[Game():GetLevel():GetStage()] or 0

            local angleOffset = effect:GetDropRNG():RandomFloat()*360

            for i=1, projNum do
                local vel = Vector.FromAngle(i*360/projNum+angleOffset)*12
                if(projNum==1) then vel=Vector.Zero end

                local proj = Isaac.Spawn(9,0,0,effect.Position,vel,effect):ToProjectile()
                proj.FallingAccel = -0.02
                proj.FallingSpeed = 0
            end

            effect:Remove()
        end
    elseif(effect.SubType==1) then
        if(not effect.Target) then effect.Target = Isaac.GetPlayer() end
        if(effect.FrameCount<TARGET_FOLLOW_DURATION) then
            effect.State = 0
            local newPos = h:lerp(effect.Position, effect.Target.Position, 0.2)
            local speedMod = 1
            if(effect.FrameCount>=TARGET_FOLLOW_DURATION-FOLLOW_SLOWDOWN_DURATION) then
                speedMod = (TARGET_FOLLOW_DURATION-effect.FrameCount)/FOLLOW_SLOWDOWN_DURATION
            end

            effect.Velocity = (newPos-effect.Position)*speedMod
        elseif(effect.FrameCount==TARGET_FOLLOW_DURATION) then
            effect.State = 1
            effect.Velocity = Vector.Zero
        elseif(effect.FrameCount<TARGET_FOLLOW_DURATION+HEAD_DASH_DURATION) then
            effect.State = 2
        elseif(effect.FrameCount==TARGET_FOLLOW_DURATION+HEAD_DASH_DURATION) then
            effect.State = 3

            Isaac.Explode(effect.Position, effect.SpawnerEntity or effect, 1)
            for i=1, TARGET_APPARITION_HEADS_NUM do
                local angle = (i+0.5)*360/TARGET_APPARITION_HEADS_NUM+effect.Rotation
                for j=0,2 do
                    local jMod = 1+j*0.5

                    local proj = Isaac.Spawn(9,4,0,effect.Position,Vector.FromAngle(angle)*PUMPKIN_BURST_PROJSPEED*jMod,effect):ToProjectile()
                    proj.FallingAccel = -0.05
                    proj.FallingSpeed = 0

                    local col = Color(1,0.5,0,1)
                    col:SetOffset(0.8,0.3,0.1)
                    proj.Color = col
                    proj.Scale = jMod
                end
            end

            effect:Remove()
        end
    elseif(effect.SubType==2) then
        if(not (effect.Parent and effect.Parent:ToEffect())) then
            effect:Remove()
            return
        end
        local parent = effect.Parent:ToEffect()

        effect.State = parent.State

        if(effect.State==0) then
            effect.Velocity = parent.Velocity
        elseif(effect.State==1) then
            effect.Velocity = (parent.Position-effect.Position)/HEAD_DASH_DURATION
        elseif(effect.State==2) then
            if(effect.FrameCount%3==0) then
                local proj = Isaac.Spawn(9,4,0,effect.Position,Vector.Zero,effect):ToProjectile()
                proj.FallingAccel = -0.01
                proj.FallingSpeed = 0

                local col = Color(1,0.5,0,1)
                col:SetOffset(0.8,0.3,0.1)
                proj.Color = col
            end
        elseif(effect.State==3) then
            effect:Remove()
        end
    elseif(effect.SubType==3) then
        if(effect.FrameCount==DASH_WAIT_DURATION) then
            effect.Velocity = (effect.TargetPosition-effect.Position)/(DASH_DURATION-5)
        elseif(effect.FrameCount>DASH_WAIT_DURATION and effect.FrameCount<=DASH_WAIT_DURATION+DASH_DURATION) then
            effect.Velocity = effect.Velocity*0.94

            sprite:Play("Dash", true)
        elseif(effect.FrameCount>=DASH_WAIT_DURATION+DASH_DURATION+1) then
            if(effect.FrameCount==DASH_WAIT_DURATION+DASH_DURATION+1) then
                sprite:Play("Idle", true)
                sprite:Stop()
            end
            effect.Velocity = effect.Velocity*0.5
        end
        if(effect.FrameCount==DASH_WAIT_DURATION+DASH_DURATION+DASH_DISAPPEAR_DURATION+1) then
            effect:Remove()
        end

        if(effect.FrameCount>=DASH_WAIT_DURATION and effect.FrameCount<=DASH_WAIT_DURATION+DASH_DURATION) then
            local proj = Isaac.Spawn(9,4,0,effect.Position,Vector.Zero,effect):ToProjectile()
            proj.FallingAccel = -0.01
            proj.FallingSpeed = 0

            local col = Color(1,0.5,0,1)
            col:SetOffset(0.8,0.3,0.1)
            proj.Color = col
        end
        if(effect.FrameCount>=JUMPSCARE_DURATION+JUMPSCARE_FADEOUT) then effect:Remove() end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, apparitionUpdate, patchApparitionVar)

---@param effect EntityEffect
local function apparitionRender(_, effect)
    local col = {R=1,G=1,B=1,A=APPARITION_BASE_OPACITY,RO=0,GO=0,BO=0}

    if(effect.SubType==0) then
        local fadeinDur = math.min(math.floor(effect.LifeSpan*FADEIN_DURATION), FADEIN_MAXDUR)
        local fadeoutDur = math.min(math.floor(effect.LifeSpan*FADEOUT_DURATION), FADEOUT_MAXDUR)

        if(effect.FrameCount<fadeinDur) then
            col.A = col.A*(effect.FrameCount/fadeinDur)
        elseif(effect.FrameCount>effect.LifeSpan-fadeoutDur) then
            col.A = col.A*((effect.LifeSpan-effect.FrameCount)/fadeoutDur)
        end
    elseif(effect.SubType==2) then
        if(effect.State==0 and effect.FrameCount<TARGET_FOLLOW_DURATION and effect.FrameCount>=TARGET_FOLLOW_DURATION-FOLLOW_SLOWDOWN_DURATION) then
            local offset = (TARGET_FOLLOW_DURATION-effect.FrameCount)/FOLLOW_SLOWDOWN_DURATION

            col.RO = offset
            col.GO = offset*0.8
            col.BO = offset*0.5
        end
        if(effect.FrameCount<20) then
            col.A = col.A*(effect.FrameCount/20)
        end
    elseif(effect.SubType==3) then
        if(effect.FrameCount<DASH_WAIT_DURATION) then col.A=col.A*0.1 end
        if(effect.FrameCount>=DASH_WAIT_DURATION and effect.FrameCount<DASH_WAIT_DURATION+4) then
            col.A = col.A*(effect.FrameCount-DASH_WAIT_DURATION)/4
        end
        if(effect.FrameCount>DASH_WAIT_DURATION+DASH_DURATION and effect.FrameCount<=DASH_WAIT_DURATION+DASH_DURATION+DASH_DISAPPEAR_DURATION) then
            col.A = col.A*(1-(effect.FrameCount-DASH_WAIT_DURATION-DASH_DURATION)/DASH_DISAPPEAR_DURATION)
        end
    end

    effect.Color = Color(col.R,col.G,col.B,col.A,col.RO,col.GO,col.BO)
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, apparitionRender, patchApparitionVar)

---@param tracer EntityLaser
local function postTracerUpdate(_, tracer)
    if(not tracer:GetData().patchTracer) then return end

    local color = Color(1,0.9,0,0.4,1,0,0)

    if(tracer.FrameCount<8) then
        color.A = color.A*(tracer.FrameCount/8)
    elseif(tracer.FrameCount<=DASH_WAIT_DURATION and tracer.FrameCount>DASH_WAIT_DURATION-5) then
        color.A = color.A*((DASH_WAIT_DURATION-tracer.FrameCount)/5)
    end

    tracer.Color = color

    if(tracer.FrameCount==DASH_WAIT_DURATION) then tracer:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, postTracerUpdate, LaserVariant.TRACTOR_BEAM)

--#endregion

--#region BOSS

local BOSS_HP = 850

local PATCH_ATTACKCHANCE = 1/3
local PATCH_SPEED = 7

local PATCH_ATTACK_LENGTHS = {
    [1]=60,
    [2]=125,
    [3]=TARGET_FOLLOW_DURATION+HEAD_DASH_DURATION+45,
    [4]=DASH_WAIT_DURATION+DASH_DURATION+DASH_DISAPPEAR_DURATION+25,
    [5]=180,
}

---@param npc EntityNPC
local function patchInit(_, npc)
    npc:GetSprite():Play("Appear", true)

    local data = npc:GetData()
    data.phase = "appear"
    data.state = "idle"
    data.stateFrame = 0
    data.lastAttack = 0

    data.movementPos = npc.Position

    npc.Target = npc:GetPlayerTarget()
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, patchInit, patchBossId)

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
    local rng = npc:GetDropRNG()
    local attack = nil
    while(attack==npc:GetData().lastAttack or attack==nil) do
        attack = rng:RandomInt(5)+1
    end
    return attack
end

local function fireProjectile(npc, velocity)
    local proj = Isaac.Spawn(9,4,0,npc.Position,velocity,npc):ToProjectile()
    proj.FallingAccel = -0.1
    proj.FallingSpeed = 0
    proj.Color = Color(1,1,1,1)
    return proj
end

---@param npc EntityNPC
local function patchUpdate(_, npc)
    local rng = npc:GetDropRNG()
    local data = npc:GetData()
    local sprite = npc:GetSprite()

    local phase = data.phase
    local state = data.state
    local stateFrame = data.stateFrame

    if(npc.FrameCount%30==0) then
        npc.Target = npc:GetPlayerTarget()
    end

    local targetPos = npc.Target.Position
    local targetVector = Vector(1,0):Rotated((targetPos-npc.Position):GetAngleDegrees())

    if(phase=="phase1") then
        if(state=="idle") then
            npc.Velocity = h:lerp(npc.Velocity, (data.movementPos-npc.Position):Normalized()*PATCH_SPEED, 0.07)
            if(npc.Position:Distance(data.movementPos or npc.Position)<10 or npc.FrameCount%60==0) then
                data.movementPos = Game():GetRoom():GetRandomPosition(10)
            end

            if(stateFrame>0 and (stateFrame>=120 or (stateFrame%40==0 and rng:RandomFloat()<PATCH_ATTACKCHANCE))) then
                local attack = chooseAttack(npc)
                changeState(npc, "attack"..attack)
                npc.I1 = PATCH_ATTACK_LENGTHS[attack]
                data.lastAttack = attack

                if(npc.HitPoints<npc.MaxHitPoints-BOSS_HP) then
                    makeJumpscare("jumpscare2")

                    npc:Remove()
                end
            end
        elseif(string.sub(state, 1, 6)=="attack") then
            if(state=="attack1") then
                npc.Velocity = npc.Velocity*0.8

                if(stateFrame==1) then
                    npc.I2 = 0
                    sprite:Play("Shoot", true)

                    sfx:Play(623,1.3,1,false,1.5)
                end
                if(sprite:IsEventTriggered("Shoot")) then
                    npc.I2 = npc.I2+1

                    local pos = targetPos+Vector.FromAngle(rng:RandomFloat()*360)*rng:RandomFloat()*240
                    pos = Game():GetRoom():GetClampedPosition(pos, 20)

                    local angle = (pos-npc.Position):GetAngleDegrees()
                    local speed = 20*(npc.Position:Distance(pos)/480)
                    if(speed>10) then speed=10 end

                    local proj = fireProjectile(npc, Vector.FromAngle(angle)*speed*(rng:RandomFloat()*0.4+0.9))
                    proj.FallingAccel = 1.5
                    proj.FallingSpeed = -25
                    proj.SpriteScale = proj.SpriteScale*1.25
                    proj.SizeMulti = proj.SizeMulti*1.25

                    local col = Color(1,0.5,0,1)
                    col:SetOffset(0.8,0.3,0.1)
                    proj.Color = col

                    proj:GetData().isLobbedFireProj = (npc.I2>=3 and 1) or 0
                end
            elseif(state=="attack2") then
                npc.Velocity = npc.Velocity*0.7

                if(stateFrame==1) then
                    sfx:Play(626,1.3,1,false,1.3)
                    sfx:Play(642,1.5,1,false,0.9)

                    sprite:Play("FlyUp", true)
                end
                if(stateFrame>20 and stateFrame<npc.I1-50 and stateFrame%3==0) then
                    local pos = Game():GetRoom():GetRandomPosition(10)

                    local proj = fireProjectile(npc, Vector.Zero)
                    proj.Visible = false
                    proj.Height = -300
                    proj.Position = Vector.Zero

                    proj:GetData().realPos = pos
                    proj.Visible = true

                    local col = Color(1,0.5,0,1)
                    col:SetOffset(0.8,0.3,0.1)
                    proj.Color = col

                    proj.FallingAccel = 1
                    proj:GetData().explodingProjectile = true

                    local target = Isaac.Spawn(1000,30,0,pos,Vector.Zero,npc):ToEffect()
                    target:GetSprite():Play("Blink", true)
                    target.Color = Color(0.5,0.4,0,1,0.5,0.4,0)
                    target.Timeout = 35
                    target.SpriteScale = Vector(1,1)*0.75
                end
                if(stateFrame==npc.I1-40) then
                    sfx:Play(627,1.3,1,false,1.3)
                    sfx:Play(641,1.5)

                    sprite:Play("FlyDown", true)
                end
            elseif(state=="attack3") then
                npc.Velocity = npc.Velocity*0.7
                if(stateFrame==1) then
                    sfx:Play(629,1.3,1,false,1.5)

                    sprite:Play("CrossedArmsStart", true)
                    local tracker = Isaac.Spawn(EntityType.ENTITY_EFFECT, patchApparitionVar, 1, npc.Target.Position, Vector.Zero, npc):ToEffect()
                    tracker.Target = npc.Target
                end
            elseif(state=="attack4") then
                npc.Velocity = npc.Velocity*0.7
                if(stateFrame==1) then
                    sfx:Play(637,1.3,1,false,1.4)

                    sprite:Play("CrossedArmsStart", true)
                    for i=1, 8 do
                        local apparition = Isaac.Spawn(EntityType.ENTITY_EFFECT, patchApparitionVar, 3, Vector.Zero, Vector.Zero, npc):ToEffect()
                    end
                end
            elseif(state=="attack5") then
                npc.Velocity = npc.Velocity*0.7
                if(stateFrame==1) then
                    sprite:Play("ThrowHead", true)
                end
                if(sprite:IsEventTriggered("FireHeads")) then
                    sfx:Play(634,1.3,1,false,1.4)

                    local lastFrame = -1

                    for i=1, 2 do
                        local vel = targetVector:Rotated(rng:RandomFloat()*180-90)*12
                        local proj = fireProjectile(npc, vel)
                        proj:AddProjectileFlags(ProjectileFlags.BOUNCE)

                        local pSprite = proj:GetSprite()
                        pSprite:Load("gfx/entities/npcs/patch/head_projectiles.anm2", true)
                        pSprite:Play("Idle", true)

                        pSprite:SetLastFrame()
                        local framesNum = pSprite:GetFrame()+1

                        local frame = -1

                        local function isPossibleHeadFrame(frame)
                            if(frame==-1) then return false end
                            if(frame==lastFrame) then return false end
                            if(frame==0 and h:isAnyPlayerCertainType(Isaac.GetPlayerTypeByName("Green Isaac"))) then return false end
                            if(frame==1 and h:isAnyPlayerCertainType(Isaac.GetPlayerTypeByName("Green Cain"))) then return false end

                            return true
                        end

                        while(isPossibleHeadFrame(frame)==false) do
                            frame = rng:RandomInt(framesNum)
                        end

                        lastFrame = frame

                        pSprite:SetFrame(frame)
                        pSprite:Stop()

                        proj.FallingAccel = -0.1
                        proj:GetData().deadGreenHeadProj = true
                    end
                end
            end

            if(stateFrame>=npc.I1) then
                changeState(npc, "idle")

                if(sprite:GetAnimation()=="CrossedArmsIdle") then
                    sprite:Play("CrossedArmsEnd", true)
                end
            end
        end
    end

    if(data.stateFrame) then
        data.stateFrame = data.stateFrame+1
    end

    if(npc.ProjectileCooldown>0) then
        npc.ProjectileCooldown=npc.ProjectileCooldown-1
    end

    if(sprite:IsFinished("Appear")) then
        sprite:Play("Idle", true)
        changePhase(npc, "phase1")
    end
    if(sprite:IsFinished("Shoot")) then sprite:Play("Idle", true) end
    if(sprite:IsFinished("FlyUp")) then sprite:Play("FlyingIdle", true) end
    if(sprite:IsFinished("FlyDown")) then sprite:Play("Idle", true) end
    if(sprite:IsFinished("CrossedArmsStart")) then sprite:Play("CrossedArmsIdle", true) end
    if(sprite:IsFinished("CrossedArmsEnd")) then sprite:Play("Idle", true) end
    if(sprite:IsFinished("ThrowHead")) then sprite:Play("Idle", true) end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, patchUpdate, patchBossId)

local function postProjectileRemove(_, proj)
    if(not (proj.SpawnerEntity and proj.SpawnerEntity:ToNPC())) then return end
    proj = proj:ToProjectile()
    local npc = proj.SpawnerEntity:ToNPC()
    local rng = proj:GetDropRNG()
    local data = proj:GetData()

    if(data.isLobbedFireProj) then
        for i=0,3 do
            local jet = fj:spawnFireJet(npc, 1, proj.Position, 30, 40, 3, i*90+(data.isLobbedFireProj)*45, nil)
        end
    end
    if(data.explodingProjectile) then
        local JET_NUM = 10
        for i=1,JET_NUM do
            local DIST = 55
            local angle = i*360/JET_NUM

            local pos = Game():GetRoom():GetClampedPosition(proj.Position+Vector.FromAngle(angle)*DIST, 10)

            local jet = fj:spawnFireJet(npc, 1, pos, 1, 0, 0, 0, nil)
        end
    end
    if(data.deadGreenHeadProj) then
        local PROJ_NUM = 12
        for i=1, PROJ_NUM do
            local vel = Vector.FromAngle(i*360/PROJ_NUM+rng:RandomFloat()*20-10)*(5+rng:RandomFloat()*4-2)

            local proj2 = Isaac.Spawn(9,0,0,proj.Position,vel,proj):ToProjectile()
            proj2.FallingAccel = 1
            proj2.FallingSpeed = -10
        end

        sfx:Play(28)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, postProjectileRemove, EntityType.ENTITY_PROJECTILE)

local function postProjectileUpdate(_, proj)
    if(not (proj.SpawnerEntity and proj.SpawnerEntity:ToNPC())) then return end
    local npc = proj.SpawnerEntity:ToNPC()
    local rng = proj:GetDropRNG()
    local data = proj:GetData()

    if(data.explodingProjectile) then
        if(proj.FrameCount==1) then proj.Position = data.realPos or Vector.Zero end
    end
    if(data.deadGreenHeadProj) then
        proj.FlipX = false
        data.bounces = data.bounces or 0
        data.prevVel = data.prevVel or proj.Velocity

        proj.SpriteRotation = proj.SpriteRotation+3

        if(proj.FrameCount%6==0) then
            local proj2 = Isaac.Spawn(9,0,0,proj.Position,Vector.Zero,proj):ToProjectile()
            proj2.FallingAccel = -0.07
            proj2.FallingSpeed = 0
        end

        if(data.prevVel.X~=proj.Velocity.X or data.prevVel.Y~=proj.Velocity.Y) then
            data.bounces = data.bounces+1

            local PROJ_NUM = 4
            for i=1, PROJ_NUM do
                local vel = Vector.FromAngle(i*360/PROJ_NUM+rng:RandomFloat()*20-10)*(5+rng:RandomFloat()*2-1)

                local proj2 = Isaac.Spawn(9,0,0,proj.Position,vel,proj):ToProjectile()
                proj2.FallingAccel = 1
                proj2.FallingSpeed = -10
            end

            sfx:Play(77, 0.8)
        end
        if(not Game():GetRoom():IsPositionInRoom(proj.Position, -10)) then
            data.bounces = 10
        end

        data.prevVel = proj.Velocity

        if(data.bounces>=6) then proj:Remove() end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, postProjectileUpdate)

local function prePatchCollision(_, npc, collider, low)
    local sprite = npc:GetSprite()

    if(sprite:GetAnimation()=="FlyingIdle") then return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, prePatchCollision, patchBossId)

local function preTearCollision(_, tear, collider, low)
    if(collider.Type==patchBossId) then
        collider = collider:ToNPC()
        local sprite = collider:GetSprite()
        if(sprite:GetAnimation()=="FlyingIdle") then return true end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, preTearCollision)

local function postNewRoom(_)
    if(not IS_PATCH_MODE_ENABLED) then return end
    if(Game():GetRoom():GetType()~=RoomType.ROOM_BOSS) then return end

    local isXLFloor = Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= 0
    local isLastBossRoom = Game():GetRoom():IsCurrentRoomLastBoss()

    if(Game():GetLevel():GetStage()==LevelStage.STAGE4_2 and ((not isXLFloor) or (isXLFloor and isLastBossRoom))) then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            entity = entity:ToNPC()
            if(entity and entity:IsBoss()) then entity:Remove() end
        end
        local patch = Isaac.Spawn(patchBossId, 0, 0, Game():GetRoom():GetCenterPos(), Vector.Zero, nil)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

--#endregion