local mod = jezreelMod

local function spawnHelper(machine)
    local room = Game():GetRoom()
    local idx = room:GetGridIndex(machine.Position)
    room:SpawnGridEntity(idx, 1, 0, 3, 0)
    local gridEnt = room:GetGridEntity(idx)
    gridEnt:GetSaveState().VarData=0
    gridEnt:GetSprite().Scale = Vector.Zero
end

---@param machine Entity
function mod.MACHINE_CALLBACKS:onInit(machine)
    local machinesEnum = mod.MACHINES
	local sprite = machine:GetSprite()
    sprite:Load("gfx/entities/slots/slot", true)
    sprite:ReplaceSpritesheet(0, machinesEnum[machine.SubType].Sprite)
    sprite:LoadGraphics()
	sprite:Play("Intitiate", true)
    machine:Update()
    machine.SizeMulti = Vector(1,0.5)

    local gridEnt = Game():GetRoom():GetGridEntity(Game():GetRoom():GetGridIndex(machine.Position))
    if(gridEnt==nil or (gridEnt and gridEnt:GetSaveState().SpawnSeed~=3)) then
        spawnHelper(machine)
    else
        gridEnt:GetSprite().Scale = Vector.Zero
    end

    machine:GetData().helperGrid = Game():GetRoom():GetGridEntity(Game():GetRoom():GetGridIndex(machine.Position))
    machine:GetData().magnetCharges = 0

    if(type(machinesEnum[machine.SubType].Overlay)=="number") then
        local greenOverlay = Isaac.Spawn(1000,machinesEnum[machine.SubType].Overlay,0,machine.Position,Vector.Zero,machine):ToEffect()
        greenOverlay:GetData().isMachineOverlay = true
        greenOverlay.DepthOffset = machine.DepthOffset+5
        machine:GetData().hasOverlay = true
        machine:GetData().overlayEffect = greenOverlay
    end
end