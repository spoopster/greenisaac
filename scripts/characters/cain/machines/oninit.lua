local mod = jezreelMod

---@param machine Entity
function mod.MACHINE_CALLBACKS:onInit(machine)
    local machinesEnum = mod.MACHINES
    if(machinesEnum[machine.SubType]==nil) then machine.SubType=1 end

	local sprite = machine:GetSprite()
    sprite:Load("gfx/entities/slots/slot", true)
    sprite:ReplaceSpritesheet(0, machinesEnum[machine.SubType].Sprite)
    sprite:LoadGraphics()
	sprite:Play("Intitiate", true)
    machine:Update()
    machine.SizeMulti = Vector(1,0.5)
    machine:GetData().magnetCharges = 0

    if(type(machinesEnum[machine.SubType].Overlay)=="number") then
        local greenOverlay = Isaac.Spawn(1000,machinesEnum[machine.SubType].Overlay,0,machine.Position,Vector.Zero,machine):ToEffect()
        greenOverlay:GetData().isMachineOverlay = true
        greenOverlay.DepthOffset = machine.DepthOffset+5
        machine:GetData().hasOverlay = true
        machine:GetData().overlayEffect = greenOverlay
    end
end