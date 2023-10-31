local mod = jezreelMod
local sfx = SFXManager()

local isaacType = Isaac.GetEntityTypeByName("Green Isaac (OLD)")
local isaacVar = Isaac.GetEntityVariantByName("Green Isaac (OLD)")
sfx:Preload(137)

local funcs = {}

local function changeState(npc, state)
    local data = npc:GetData()
    data.state = state
    data.stateFrame = 0
end

local function changePhase(npc, phase)
    npc:GetData().phase = phase
    npc:GetData().lastAttack = 0
    changeState(npc, "idle")
end

local function closestPlayer(pos)
	local entities = Isaac.FindByType(1)
	local closestEnt = Isaac.GetPlayer()
	local closestDist = 2^32
	for i = 1, #entities do
		if not entities[i]:IsDead() then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]:ToPlayer()
			end
		end
	end
	return closestEnt
end

local function initIsaac(npc)
    local sprite = npc:GetSprite()
    local data = npc:GetData()

    sprite:Play("Idle1", true)
    data.phase = "idle inactive"
    data.state = "idle"
    data.subState = 0
    data.stateFrame = 0
    data.lastAttack = 0
    data.lastAttack2 = 0
    data.wallFired = 0
    data.skyId = 0
    data.grids = {}
    data.whimperOffset = 15
    npc.State = 4
    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    npc.Target = closestPlayer(npc.Position)

    npc.MaxHitPoints = 1200
    npc.HitPoints = npc.MaxHitPoints
    npc.Position = Game():GetRoom():GetCenterPos()
end

local function chooseAttack(npc)
    local phase = npc:GetData().phase
    local rng = npc:GetDropRNG()
    local attack = 1
    if(phase=="idle active") then
        attack = rng:RandomInt(3)+1
        while(attack==npc:GetData().lastAttack) do
            attack = rng:RandomInt(3)+1
        end
    end
    if(phase=="standing idle") then
        attack = rng:RandomInt(3)+1
        while(attack==npc:GetData().lastAttack) do
            attack = rng:RandomInt(3)+1
        end
    end
    if(phase=="standing active") then
        if(npc:GetData().subState==1) then
            attack = rng:RandomInt(2)+3
        else
            attack = rng:RandomInt(2)+1
        end
    end
    npc:GetData().lastAttack = attack
    return "attack" .. attack
end

local function fireTear(npc, velocity)
    local proj = Isaac.Spawn(9,4,0,npc.Position,velocity,npc):ToProjectile()
    proj.FallingAccel = -0.1
    proj.FallingSpeed = 0
    proj.Color = Color(0.3,0.6,0.2,1,0,0,0)
    return proj
end

---@param npc EntityNPC
function funcs:isaacInit(npc)
    if(npc.Variant==isaacVar) then
        initIsaac(npc)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, funcs.isaacInit, isaacType)

---@param npc EntityNPC
function funcs:isaacAI(npc)
    if(npc.Variant~=isaacVar) then return nil end
    local sprite = npc:GetSprite()
    local data = npc:GetData()
    local rng = npc:GetDropRNG()
    local phase = data.phase
    local state = data.state
    local stateFrame = data.stateFrame
    if(npc.FrameCount%30==0) then
        npc.Target = closestPlayer(npc.Position)
    end
    if(npc.FrameCount==data.whimperOffset) then
        sfx:Play(143)
        data.whimperOffset=npc.FrameCount+rng:RandomInt(60)+60
    end
    if(sprite:IsFinished("Transition1")) then
        sprite:Play("Idle2", true)
    end
    if(sprite:IsFinished("AttackBig1") or sprite:IsFinished("AttackSmall1")) then
        sprite:Play("Idle1", true)
    end
    if(sprite:IsFinished("TeleportDisappear")) then
        sprite:Play("Invisible", true)
        npc.Visible = false
        npc.Position = Vector.Zero
    end
    if(sprite:IsPlaying("TeleportAppear") and npc.Visible==false) then
        npc.Visible = true
        npc.Position = Game():GetRoom():GetCenterPos()
    end
    if(sprite:IsFinished("TeleportAppear")) then
        sprite:Play("Idle2", true)
    end
    if(sprite:IsFinished("Attack2")) then
        sprite:Play("Idle2", true)
    end
    if(not sprite:IsPlaying("Invisible") and npc.Position:Distance(Game():GetRoom():GetCenterPos())>5) then
        npc.Position = Game():GetRoom():GetCenterPos()
    end

    local targetPos = npc.Target.Position
    local targetVector = Vector(1,0):Rotated((targetPos-npc.Position):GetAngleDegrees())

    if(phase=="idle inactive" and npc.HitPoints<npc.MaxHitPoints) then
        changePhase(npc, "idle active")
        npc.I1 = 15
        npc.I2 = 90
    end
    if(phase=="idle active" and npc.HitPoints<npc.MaxHitPoints-300) then
        changePhase(npc, "standing idle")
        sprite:Play("Transition1", true)
        npc.I1 = 30
        npc.I2 = 90
        for i, proj in ipairs(Isaac.FindByType(9,4)) do
            proj:Die()
        end
    end
    if(phase=="standing idle" and npc.HitPoints<npc.MaxHitPoints-700) then
        if(data.grids) then
            for key, val in pairs(data.grids) do
                local room = Game():GetRoom()
                local number = tonumber(key, 10)
                if(number=="fail") then number=0 end
                local gridEnt = room:GetGridEntity(number)
                if(gridEnt) then
                    room:RemoveGridEntity(number, 0, true)
                    gridEnt:Update()
                    for j=1, 2 do
                        local particle = Isaac.Spawn(1000, 4, 0, room:GetGridPosition(number), Vector(rng:RandomFloat()*3+2,0):Rotated(rng:RandomFloat()*360), npc)
                    end
                end
            end
            data.grids = {}
        end
        changePhase(npc, "standing active")
        npc.I1 = 30
        npc.I2 = 90
        for i, proj in ipairs(Isaac.FindByType(9,4)) do
            if(not proj:ToProjectile():HasProjectileFlags(ProjectileFlags.CONTINUUM)) then
                proj:Die()
            end
        end
    end

    if(phase=="idle inactive") then
        npc.Velocity=Vector.Zero
    elseif(phase=="idle active") then
        if(state=="idle") then
            if(npc.I1<=0) then
                for i=1,2 do
                    local proj = fireTear(npc, targetVector:Rotated(rng:RandomFloat()*20-10)*7)
                end
                npc.I1=15
            else
                npc.I1 = npc.I1-1
            end
            if(npc.I2<=0) then
                npc.ProjectileCooldown=15
                changeState(npc, "pre attack")
            else
                npc.I2=npc.I2-1
            end
        elseif(state=="pre attack") then
            if(npc.ProjectileCooldown==0) then
                changeState(npc, chooseAttack(npc))
                if(data.state=="attack1") then npc.I1=16 end
                if(data.state=="attack2") then
                    npc.I1=71
                    npc.I2=rng:RandomInt(360)
                end
                if(data.state=="attack3") then
                    npc.I1=150
                end
            end
        elseif(state=="attack1") then
            if(npc.I1==16) then
                sprite:Play("AttackBig1", true)
            end
            if(npc.I1>0) then
                if(npc.I1<=10) then
                    if(npc.I1%2==0) then
                        for i=1, 6 do
                            local proj = fireTear(npc, Vector(6,0):Rotated(360*i/6+npc.I1*2))
                        end
                        for i=1, 6 do
                            local proj = fireTear(npc, Vector(6,0):Rotated(360*i/6-npc.I1*2+180))
                        end
                    end
                end
                npc.I1=npc.I1-1
            else
                for i=1, 12 do
                    local proj = fireTear(npc, Vector(10,0):Rotated(360*i/12+30))
                    local proj2 = fireTear(npc, Vector(5,0):Rotated(360*i/12+30))
                end
                --sprite:Play("AttackSmall1", true)
                changeState(npc, "idle")
                npc.I2 = 90
                npc.I1 = 30
            end
        elseif(state=="attack2") then
            if(npc.I1>0) then
                if(npc.I1==71) then
                    sprite:Play("AttackBig1", true)
                end
                if(npc.I1==65) then
                    for i=1, 43 do
                        if(not ((i>=12 and i<=16) or (i>=28 and i<=32))) then
                            local proj = fireTear(npc, Vector(10,0):Rotated(360*i/48+npc.I2))
                            proj:AddProjectileFlags(ProjectileFlags.CURVE_LEFT)
                            proj:GetData().projDecelerate = true
                            proj:GetData().projFallTimer = 50
                        end
                    end
                else
                    if(npc.I1==34) then
                        sprite:Play("AttackBig1", true)
                    end
                    if(npc.I1<=20 and npc.I1>=10 and npc.I1%2==0) then
                        for i=1, 43 do
                            if(not ((i>=12 and i<=16) or (i>=28 and i<=32))) then
                                local proj = fireTear(npc, Vector(10,0):Rotated(360*i/48+npc.I2-40))
                                proj.Position = proj.Position+Vector(80,0):Rotated(360*i/48+npc.I2-40)
                            end
                        end
                    end
                    if(npc.I1%8==0 and npc.I1>=8) then
                        for i=0, 2 do
                            local proj = fireTear(npc, Vector(10,0):Rotated(360*(14+i*16)/48+npc.I2-40))
                        end
                    end
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                npc.I2 = 90
                npc.I1 = 15
            end
        elseif(state=="attack3") then
            if(npc.I1>0) then
                if(npc.I1==150) then
                    for i=1, 12 do
                        local proj = fireTear(npc, Vector.Zero)
                        local pData = proj:GetData()
                        pData.projDecelerate = true
                        pData.spinProj = true
                        pData.spinAngle = 360*i/12
                        pData.spinDeg = 8
                        pData.spawnerProj = true
                        pData.angleOffset = 0
                        pData.projFallTimer = 150
                        pData.updateRadius = true
                        pData.radius = Vector(1,1)
                        pData.basePos = npc.Position
                        pData.projDir = 3
                        pData.spawnVel = Vector(7,0)
                    end
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                npc.I2=90
                npc.I1=15
            end
        end

        npc.Velocity=Vector.Zero
    elseif(phase=="standing idle") then
        if(npc.FrameCount%5==0 and data.wallFired<=15) then
            local room = Game():GetRoom()
            for i=-1,1,2 do
                local proj = fireTear(npc, Vector(0,6*i))
                proj:AddProjectileFlags(ProjectileFlags.CONTINUUM)
                local posOffset = Vector(rng:RandomFloat()*40-20, rng:RandomFloat()*10-5)
                if(i==-1) then
                    proj.Position=room:GetBottomRightPos()+Vector(-40,0)-posOffset
                else
                    proj.Position=room:GetTopLeftPos()+Vector(40,0)+posOffset
                end
                proj:GetData().wallProj = true
                proj:GetData().wallVelocity = proj.Velocity
                proj:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            end
            data.wallFired = data.wallFired+1
        end
        if(state=="idle") then
            if(npc.I1<=0) then
                for i=1,3 do
                    local proj = fireTear(npc, targetVector:Rotated(rng:RandomFloat()*20-10)*7)
                end
                npc.I1=15
            else
                npc.I1 = npc.I1-1
            end
            if(npc.I2<=0) then
                npc.ProjectileCooldown=15
                changeState(npc, "pre attack")
            else
                if(npc.I2==40) then
                    local room = Game():GetRoom()
                    local widthId = rng:RandomInt(room:GetGridWidth()-6)+3
                    while(widthId==data.skyId) do
                        widthId = rng:RandomInt(room:GetGridWidth()-6)+3
                    end
                    data.skyId=widthId
                    for i=1, room:GetGridHeight()-2 do
                        widthId = widthId+room:GetGridWidth()
                        local sky = Isaac.Spawn(1000, 19, 2, room:GetGridPosition(widthId), Vector.Zero, npc):ToEffect()
                        sky.Color = Color(1,10,1,1,0,2,0)
                    end
                end
                npc.I2=npc.I2-1
            end
        elseif(state=="pre attack") then
            if(npc.ProjectileCooldown==0) then
                changeState(npc, chooseAttack(npc))
                if(data.state=="attack1") then npc.I1=332 end
                if(data.state=="attack2") then npc.I1=67 end
                if(data.state=="attack3") then
                    npc.I1 = 120
                end
            end
        elseif(state=="attack1") then
            if(npc.I1>0) then
                if(npc.I1>=300) then
                    if(npc.I1==330) then
                        sprite:Play("Attack2", true)
                    end
                    if(npc.I1<=330 and npc.I1>300 and npc.I1%3==0) then
                        for i=0,3 do
                            local proj = fireTear(npc, Vector.Zero)
                            proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
                            local pData = proj:GetData()
                            pData.wallProj = true
                            pData.spinProj = true
                            pData.spinAngle = i*90
                            pData.spinDeg = 1.5
                            pData.basePos = proj.Position
                            pData.radius = 10*(npc.I1-300)
                            pData.angleOffset = (330-npc.I1)
                            pData.projFallTimer = 310
                            proj.Position = Vector(10*(npc.I1-300), 0):Rotated(pData.spinAngle)
                            pData.radius = Vector(1,1)*pData.radius
                            proj.Velocity = Vector.Zero
                            proj:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                        end
                    end
                else
                    if(npc.I1%30==0) then
                        sprite:Play("Attack2", true)
                        for i=1, 11 do
                            local proj = fireTear(npc, Vector(8,0):Rotated(360*i/11))
                        end
                    end
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                npc.I2 = 90
                npc.I1 = 30
            end
        elseif(state=="attack2") then
            if(npc.I1>0) then
                local room = Game():GetRoom()
                if(npc.I1==65) then
                    sprite:Play("Attack2", true)
                    local gridId = room:GetGridWidth()-6
                    npc.I2=1
                    if(targetPos.X<room:GetCenterPos().X) then
                        gridId=5
                        npc.I2=2
                    end
                    for i=1, math.floor((room:GetGridWidth()-2)/3) do
                        local gridIdx = gridId+(rng:RandomInt(room:GetGridHeight()-2)+1)*room:GetGridWidth()
                        while(data.grids[""..gridIdx]~=nil) do
                            gridIdx = gridId+(rng:RandomInt(room:GetGridHeight()-2)+1)*room:GetGridWidth()
                        end
                        data.grids[""..gridIdx]=1

                        local gridEnt = Isaac.GridSpawn(3, 0, room:GetGridPosition(gridIdx), false)
                        sfx:Play(137, 1)

                        for j=1, 2 do
                            local particle = Isaac.Spawn(1000, 4, 0, room:GetGridPosition(gridIdx), Vector(rng:RandomFloat()*3+2,0):Rotated(rng:RandomFloat()*360), npc)
                        end
                    end
                end
                if(npc.I1<=50 and npc.I1>=40 and npc.I1%2==0) then
                    for i=1, room:GetGridHeight()-2 do
                        local gridIdx = 1+room:GetGridWidth()*i
                        local proj = fireTear(npc, Vector(12,0))
                        proj.Position = room:GetGridPosition(gridIdx)-Vector(15,0)
                        if(npc.I2==2) then
                            gridIdx = room:GetGridWidth()*(i+1)-2
                            proj.Velocity = Vector(-12, 0)
                            proj.Position = room:GetGridPosition(gridIdx)+Vector(15,0)
                        end
                    end
                end
                npc.I1=npc.I1-1
            else
                for key, val in pairs(data.grids) do
                    local room = Game():GetRoom()
                    local number = tonumber(key, 10)
                    if(number=="fail") then number=0 end
                    local gridEnt = room:GetGridEntity(number)
                    if(gridEnt) then
                        room:RemoveGridEntity(number, 0, true)
                        gridEnt:Update()
                        for j=1, 2 do
                            local particle = Isaac.Spawn(1000, 4, 0, room:GetGridPosition(number), Vector(rng:RandomFloat()*3+2,0):Rotated(rng:RandomFloat()*360), npc)
                        end
                    end
                end
                data.grids = {}
                changeState(npc, "idle")
                npc.I2 = 90
                npc.I1 = 30
            end
        elseif(state=="attack3") then
            if(npc.I1>0) then
                if(npc.I1==120) then
                    sprite:Play("Attack2", true)
                    for i=1, 4 do
                        local proj = fireTear(npc, Vector.Zero)
                        local pData = proj:GetData()
                        pData.projDecelerate = true
                        pData.spinProj = true
                        pData.spinAngle = 360*i/4+45
                        pData.spinDeg = 12
                        pData.spawnerProj = true
                        pData.angleOffset = 0
                        pData.projFallTimer = 120
                        pData.updateRadius = true
                        pData.radius = Vector(1,1)
                        pData.basePos = npc.Position
                        pData.projDir = 2*math.sqrt(2)
                        pData.spawnVel = Vector(8,0)
                    end
                    for i=1, 4 do
                        local proj = fireTear(npc, Vector.Zero)
                        local pData = proj:GetData()
                        pData.projDecelerate = true
                        pData.spinProj = true
                        pData.spinAngle = 360*i/4
                        pData.spinDeg = 12
                        pData.spawnerProj = true
                        pData.angleOffset = 0
                        pData.projFallTimer = 120
                        pData.updateRadius = true
                        pData.radius = Vector(1,1)
                        pData.basePos = npc.Position
                        pData.projDir = 2
                        pData.spawnVel = Vector(8,0)
                    end
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                npc.I2=90
                npc.I1=20
            end
        end
    elseif(phase=="standing active") then
        if(state=="idle") then
            if(npc.I1<=0) then
                for i=1,3 do
                    local proj = fireTear(npc, targetVector:Rotated(rng:RandomFloat()*20-10)*7)
                end
                npc.I1=15
            else
                npc.I1 = npc.I1-1
            end
            if(npc.I2<=0) then
                npc.ProjectileCooldown=16
                changeState(npc, "pre attack")
            else
                npc.I2=npc.I2-1
            end
        elseif(state=="pre attack") then
            if(npc.ProjectileCooldown==15) then
                data.subState=math.abs(data.subState-1)
                --data.subState = 0
                if(data.subState==1) then
                    sprite:Play("TeleportDisappear", true)
                end
            end
            if(npc.ProjectileCooldown==0) then
                changeState(npc, chooseAttack(npc))
                if(data.state=="attack1") then
                    npc.I1=132
                end
                if(data.state=="attack2") then
                    npc.I1=152
                end
                if(data.state=="attack3") then
                    npc.I1=74
                    npc.I2 = rng:RandomInt(4)
                end
                if(data.state=="attack4") then
                    npc.I1=152
                end
            end
        elseif(state=="attack1") then
            local room = Game():GetRoom()
            local roomW = room:GetGridWidth()
            local roomH = room:GetGridHeight()
            if(npc.I1>0) then
                if(npc.I1<=130 and npc.I1>=10 and npc.I1%4==0) then
                    local target = Isaac.Spawn(1000,30,0,room:GetRandomPosition(20),Vector.Zero,npc):ToEffect()
                    target:GetSprite():Play("Blink", true)
                    target.Color = Color(0,0.8,0,1,0,0.8,0)

                    local proj = fireTear(npc, Vector.Zero)
                    proj.Position = target.Position
                    proj.FallingSpeed = 10
                    proj.FallingAccel = 4
                    proj.Scale = 2
                    proj.Height = -1000
                    proj:GetData().carpetBomb = true
                    proj:GetData().targetDaddy = target
                    proj:GetData().wallProj = true
                    proj:AddProjectileFlags(ProjectileFlags.EXPLODE)
                end
                if(npc.I1<=120 and npc.I1%12==0) then
                    local sky = Isaac.Spawn(1000,19,2,room:GetRandomPosition(20),Vector.Zero,npc)
                    sky.Color = Color(1,10,1,0.33,0,2,0)
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                npc.I2 = 90
                npc.I1 = 30
            end
        elseif(state=="attack2") then
            local room = Game():GetRoom()
            local roomW = room:GetGridWidth()
            local roomH = room:GetGridHeight()
            if(npc.I1>0) then
                if(npc.I1<=150 and npc.I1>=50 and npc.I1%8==0) then
                    local pear = Isaac.Spawn(5,20,1,room:GetRandomPosition(20),Vector.Zero,npc):ToPickup()
                    pear:GetSprite():Load("gfx/entities/npcs/isaac/pear.anm2", true)
                    pear:GetSprite():Play("Idle", true)
                    pear:GetSprite():LoadGraphics()
                    pear.SpriteScale = Vector(0.08, 0.08)
                    pear.Color = Color(1,1,1,1,0,0.5,0)
                    pear.Wait = 9999
                    pear:GetData().deathTimer = 60
                end
                if(npc.I1<=150 and npc.I1%20==0) then
                    local sky = Isaac.Spawn(1000,19,2,room:GetRandomPosition(20),Vector.Zero,npc)
                    sky.Color = Color(1,10,1,0.33,0,2,0)
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                npc.I2 = 90
                npc.I1 = 30
            end
        elseif(state=="attack3") then
            local room = Game():GetRoom()
            local roomW = room:GetGridWidth()
            local roomH = room:GetGridHeight()
            if(npc.I1>0) then
                if(npc.I1%6==0 and npc.I1>30) then
                    local gridId = 8-(npc.I1/6-5)
                    local gridId2 = roomW-(gridId+1)
                    local checker = npc.I2
                    if(gridId%4>=2) then checker=(npc.I2+2)%4 end
                    for i=1,roomH-2 do
                        gridId=gridId+roomW
                        gridId2=gridId2+roomW
                        if(checker==4) then checker=0 end
                        if(checker<2) then
                            local sky1 = Isaac.Spawn(1000, 19, 2, room:GetGridPosition(gridId), Vector.Zero, npc):ToEffect()
                            sky1.Color = Color(1,10,1,0.33,0,2,0)
                            local sky2 = Isaac.Spawn(1000, 19, 2, room:GetGridPosition(gridId2), Vector.Zero, npc):ToEffect()
                            sky2.Color = Color(1,10,1,0.33,0,2,0)
                            if(npc.I1<=42) then
                                if(i==roomH-3) then
                                    sky1.Position=sky1.Position+Vector(0,-10)
                                    sky2.Position=sky2.Position+Vector(0,-10)
                                end
                            end
                        end
                        checker = checker+1
                    end
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                sprite:Play("TeleportAppear", true)
                npc.I2 = 0
                npc.I1 = 30
            end
        elseif(state=="attack4") then
            local room = Game():GetRoom()
            local roomW = room:GetGridWidth()
            local roomH = room:GetGridHeight()
            if(npc.I1>0) then
                if(npc.I1==150) then
                    for i=1, 8 do
                        local proj = fireTear(npc, Vector.Zero)
                        local pData = proj:GetData()
                        pData.projDecelerate = true
                        pData.spinProj = true
                        pData.spinAngle = 360*i/8
                        pData.spinDeg = 24
                        pData.spawnerProj = true
                        pData.angleOffset = 0
                        pData.projFallTimer = 150
                        pData.updateRadius = true
                        pData.radius = Vector(1,1)
                        pData.basePos = room:GetCenterPos()
                        pData.center = room:GetCenterPos()
                        pData.projDir = 1
                        pData.spawnVel = Vector(7,0)
                    end
                end
                if(npc.I1<=120 and npc.I1%6==0) then
                    local sky = Isaac.Spawn(1000,19,2,room:GetGridPosition(room:GetRandomTileIndex(rng:RandomInt(10000))),Vector.Zero,npc)
                    sky.Color = Color(1,10,1,0.33,0,2,0)
                end
                npc.I1=npc.I1-1
            else
                changeState(npc, "idle")
                sprite:Play("TeleportAppear", true)
                npc.I2 = 0
                npc.I1 = 30
            end
        end
    end

    if(data.stateFrame) then
        data.stateFrame = data.stateFrame+1
    end

    if(npc.ProjectileCooldown>0) then
        npc.ProjectileCooldown=npc.ProjectileCooldown-1
    end

    if(npc.FrameCount>1) then
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, funcs.isaacAI, isaacType)

function funcs:isaacKill(entity)
    if(entity.Variant~=isaacVar) then return end
    local sprite = entity:GetSprite()
    local data = entity:GetData()

    for i, proj in ipairs(Isaac.FindByType(9,4)) do
        proj:Die()
    end
    --[[local zaza = Isaac.Spawn(5,100,Isaac.GetItemIdByName("#THE_WEED"),Game():GetRoom():GetCenterPos(),Vector.Zero,entity)]]
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, funcs.isaacKill, isaacType)

function funcs:projectileUpdate(proj)
    local data = proj:GetData()
    if(data.projDecelerate) then
        proj.Velocity = proj.Velocity*0.9
    end
    if(data.updateRadius) then
        data.radius = data.radius+data.projDir*(math.max(0,(30-proj.FrameCount)/30))*Vector(1,1)
    end
    if(data.projFallTimer) then
        if(data.projFallTimer<=0) then
            proj.FallingAccel = 2
            if(proj:HasProjectileFlags(ProjectileFlags.BOUNCE_FLOOR)) then
                proj:Die()
            end
        else
            data.projFallTimer=data.projFallTimer-1
        end
    end
    if(data.spinProj) then
        local rad = data.radius
        local xNew = math.cos(math.rad((proj.FrameCount-30+data.angleOffset)*data.spinDeg+data.spinAngle))*rad.X + data.basePos.X
        local yNew = math.sin(math.rad((proj.FrameCount-30+data.angleOffset)*data.spinDeg+data.spinAngle))*rad.Y + data.basePos.Y
        proj.Position = Vector(xNew,yNew)
    end
    if(data.spawnerProj) then
        local npc = proj.SpawnerEntity:ToNPC()
        if(proj.FrameCount%10==0 and proj.FrameCount>=30) then
            local centerPos = data.center
            if(data.center==nil) then centerPos=npc.Position end
            local proj2 = fireTear(npc, data.spawnVel:Rotated((proj.Position-centerPos):GetAngleDegrees()))
            proj2.Position = proj.Position
            if(data.spawnVel:Length()<1) then
                proj2:GetData().projFallTimer = 60
            end
        end
    end
    if(data.spawnerProj2) then
        local npc = proj.SpawnerEntity:ToNPC()
        if(proj.FrameCount%3==0) then
            local proj2 = fireTear(npc, Vector.Zero)
            proj2.Position = proj.Position
            proj2:GetData().projFallTimer = 60
        end
    end
    if(data.carpetBomb) then
        if(proj.Height>=0) then
            proj:Die()
            data.targetDaddy:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, funcs.projectileUpdate, ProjectileVariant.PROJECTILE_TEAR)

function funcs:projCollision(proj, coll, _)
    if(proj:GetData().wallProj==true) then
        coll:TakeDamage(1,0,EntityRef(proj),0)
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, funcs.projCollision, ProjectileVariant.PROJECTILE_TEAR)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    if(entity.Variant~=isaacVar) then return nil end
    source = source.Entity
    if(source and source.Type==1000 and source.Variant==19) then
        if(source.SpawnerEntity and GetPtrHash(source.SpawnerEntity)==GetPtrHash(entity)) then
            return false
        end
    end
    if(entity:GetSprite():IsPlaying("Invisible")) then
        return false
    end
    if(source and source.Type==9 and source.Variant==4) then
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, isaacType)

function funcs:pearProjUpdate(pickup)
    if(pickup:GetSprite():GetFilename()=="gfx/isaac/pear.anm2") then
        local sprite = pickup:GetSprite()
        local data = pickup:GetData()
        if(data.deathTimer) then
            if(data.deathTimer<=pickup.FrameCount) then
                sprite:Play("Pickup", true)
                local npc = pickup.SpawnerEntity
                if(npc and npc:ToNPC()) then
                    npc = npc:ToNPC()
                    local offSet = npc:GetDropRNG():RandomFloat()*360
                    local iMax = npc:GetDropRNG():RandomInt(4)+3
                    for i=1,iMax do
                        local proj = fireTear(npc, Vector(8,0):Rotated(360*i/iMax+offSet))
                        proj.Position = pickup.Position
                        proj:GetData().projFallTimer = 120
                    end
                end
                data.deathTimer = nil
            end
        end
        if(sprite:IsFinished("Pickup")) then
            pickup:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.pearProjUpdate)

mod.ENTITIES.GREENISAAC = funcs