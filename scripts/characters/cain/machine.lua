local mod = jezreelMod

local slotVar = Isaac.GetEntityVariantByName("Green Slot")
local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local machines = mod.MACHINE_CALLBACKS
local machinesEnum = mod.MACHINES

local funcs = {}

function funcs:machineCheck()
	for _, machine in ipairs(Isaac.FindByType(6)) do
		if(machine.Variant~=slotVar) then
			local data = machine:GetData()
			if(data.greenifyMachine) then
				if(data.greenifyMachine>0) then
					data.greenifyMachine=data.greenifyMachine-1
					machine.Color = Color(1,1,1,1,0,1-(data.greenifyMachine)/15,0)
				end
				if(data.greenifyMachine==1) then
					local subtype = machine.Variant
					if(type(machinesEnum[subtype])=="table") then
						if(machinesEnum[subtype].Type=="Machine") then
							local greenMachine = Isaac.Spawn(6,slotVar,subtype,machine.Position,Vector.Zero,machine)
							greenMachine:GetData().originalMachine = machine
							machines:onInit(greenMachine)
							machines:onUpdate(greenMachine)
						end
						if(machinesEnum[subtype].Type=="Beggar") then
							local player = data.collidedPlayer
							if(player and player:ToPlayer()) then
								player = player:ToPlayer()
								local blockbum = Isaac.Spawn(3, blockbumVar, machinesEnum[subtype].SubType, machine.Position, Vector.Zero, player):ToFamiliar()
								blockbum.Player = player
							end

							machine:Remove()
							machine:Update()
						end
					end
				end
			end
		end
		if(machine.Variant==slotVar) then
			if(machine.FrameCount==1) then
				if(machine:GetData().originalMachine~=nil) then
					local ogMachine = machine:GetData().originalMachine

					ogMachine:Remove()
					ogMachine:Update()
				else
					machines:onInit(machine)
				end
			end
			machines:onUpdate(machine)

			for _, p in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER, 0)) do
				local player = p:ToPlayer()
				local vect = machine.TargetPosition-machine.Position
				if(player
				and player.EntityCollisionClass==4
				and ((player.Position-machine.Position):LengthSquared()<=(player.Size+machine.Size)^2)
				and (math.sqrt(vect.X*vect.X+vect.Y*vect.Y)>0.01)) then
					machines:onCollision(machine, player)
				end
			end

			for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
				if(((effect.Variant==EffectVariant.BOMB_EXPLOSION)
				or (effect.Variant==EffectVariant.REVERSE_EXPLOSION)
				or (effect.Variant==EffectVariant.MAMA_MEGA_EXPLOSION)) and effect.FrameCount<=1) then
					local scale = effect:ToEffect().Scale*96
					if((effect.Position-machine.Position):LengthSquared()<=(scale+machine.Size-10)^2) then
						machines:onDeath(machine)
					end
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, funcs.machineCheck)

function funcs:machineInit()
	for _, machine in pairs(Isaac.FindByType(6, slotVar)) do
		if(machine.FrameCount==0 and machine:GetData().originalMachine==nil) then
			machines:onInit(machine)
		end
		machines:onUpdate(machine)
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.machineInit)

---@param effect EntityEffect
function funcs:overlayUpdate(effect, offset)
	if(type(effect:GetData())=="number") then return end
	if(effect:GetData().isMachineOverlay==true) then
		local spawner = effect.SpawnerEntity
		local sprite = effect:GetSprite()
		if(spawner~=nil) then
			local spawnSprite = spawner:GetSprite()
			sprite:SetFrame(spawnSprite:GetAnimation(), spawnSprite:GetFrame())
			effect.Position=spawner.Position
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, funcs.overlayUpdate)

mod.MACHINES.UNIVERSAL = funcs