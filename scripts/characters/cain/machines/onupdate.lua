local mod = jezreelMod
local sfx = SFXManager()
sfx:Preload(255)
sfx:Preload(249)

local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local machinesEnum = mod.MACHINES
local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)

local function getPayout(machine)
	local maxWeight = 0
	local currentWeight = 0
	local dropTable = machinesEnum[machine.SubType].DropTable
	for i=1, #dropTable do maxWeight = maxWeight+dropTable[i].Weight end

	local payoutRNG = machine:GetDropRNG():RandomFloat()

	for i=1, #dropTable do
		currentWeight = currentWeight+dropTable[i].Weight
		if(payoutRNG<currentWeight/maxWeight) then
			return dropTable[i]
		end
	end
end

---@param machine Entity
function mod.MACHINE_CALLBACKS:onUpdate(machine)
	local sprite = machine:GetSprite()
	local data = machine:GetData()
	local room = Game():GetRoom()
	local rng=machine:GetDropRNG()

	if(sprite:GetAnimation()=="") then
        sprite:Play("Initiate", true)
		data.magnetCharges=0
    end

	if(sprite:IsFinished("Wiggle")) then
		local rand = rng:RandomFloat()
		local payChance = machinesEnum[machine.SubType].PayoutChance

		local greenCainBirthRightNum = 0
		for _, player in ipairs(Isaac.FindByType(1,0)) do
			player = player:ToPlayer()

			if(player:GetPlayerType()==greenCain and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then greenCainBirthRightNum=greenCainBirthRightNum+1 end
		end

		payChance=payChance*1.5^greenCainBirthRightNum

		if(rand<payChance or (rand<payChance*1.5 and data.magnetCharges>0)) then
			sprite:Play("PrizeGood", true)
		else
			sprite:Play("PrizeBad", true)
		end
		rand = rng:RandomFloat()
		if(rand<1/100 or (rand<1/20 and data.magnetCharges>0)) then
			mod.MACHINE_CALLBACKS:onDeath(machine)
			if(rand<1/100) then
				local subtype = machinesEnum[machine.SubType].BlockbumID
				if(machine:GetDropRNG():RandomFloat()<0.5) then subtype=subtype+3 end
				local blockbum = Isaac.Spawn(3, blockbumVar, subtype, machine.Position+Vector(0,10), Vector.Zero, machine)
				local item = Isaac.Spawn(5,100,machinesEnum[machine.SubType].PayoutItem,machine.Position+Vector(0,40),Vector.Zero,machine)
			end
		end
		if(data.magnetCharges>0) then
			data.magnetCharges=data.magnetCharges-1
		end
	end
	if(sprite:IsFinished("PrizeBad") or sprite:IsFinished("PrizeGood") or sprite:IsFinished("Initiate")) then
		sprite:Play("Idle", true)
	end
	if(sprite:GetAnimation()=="Idle") then
		if(data.magnetCharges>0) then
			sprite:Play("Wiggle", true)
		end
	end
	if(sprite:IsFinished("Dying")) then
		sprite:Play("Dead", true)
	end
	if(sprite:IsEventTriggered("Explode")) then
		Isaac.Explode(machine.Position, Isaac.GetPlayer(), 30)
	end
	if(sprite:IsEventTriggered("Prize")) then
		local payout = getPayout(machine)
		local count = payout.Count
		if(count>=0) then
			for i=1, payout.Count do
				local pickup = Isaac.Spawn(payout.Type, payout.Variant, payout.SubType, machine.Position, Vector(0,5):Rotated(rng:RandomFloat()*90-45), machine)
			end
		else
			count=-count
			for i=1, rng:RandomInt(count)+1 do
				local pickup = Isaac.Spawn(payout.Type, payout.Variant, payout.SubType, machine.Position, Vector(0,5):Rotated(rng:RandomFloat()*90-45), machine)
			end
		end
		sfx:Play(249)
		sfx:Play(255)
	end
	if(sprite:IsEventTriggered("Buzzer")) then
		sfx:Play(249)
	end

	if(data.hasOverlay==true) then
		local overlay = data.overlayEffect

		overlay.Position=machine.Position
	end
end