local mod = jezreelMod
local sfx = SFXManager()
sfx:Preload(249)

local machinesEnum = mod.MACHINES

local function isMachineSpriteBusy(sprite)
	return (not sprite:IsPlaying("Idle"))
end

function mod.MACHINE_CALLBACKS:onCollision(machine, player)
	local sprite = machine:GetSprite()

	if(isMachineSpriteBusy(sprite)) then
		return
	end
	local price = machinesEnum[machine.SubType].Price
	if(price=="Heart") then
		if(not player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(machine), 0)) then
			return
		end
	else
		if(player:GetNumCoins()>0) then
			player:AddCoins(-1)
		else
			return
		end
	end
	sfx:Play(249)
    sprite:Play("Wiggle", true)
end