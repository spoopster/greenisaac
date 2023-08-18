local mod = jezreelMod

local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local machinesEnum = mod.MACHINES

function mod.MACHINE_CALLBACKS:onDeath(machine)
	local sprite = machine:GetSprite()
	if(not (sprite:IsPlaying("Dying") or sprite:IsPlaying("Dead"))) then
		sprite:Play("Dying", true)
		Isaac.Explode(machine.Position, Isaac.GetPlayer(), 0)
	end
end