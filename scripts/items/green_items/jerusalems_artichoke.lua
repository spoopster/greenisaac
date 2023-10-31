local mod = jezreelMod
local sfx = SFXManager()
local h = include("scripts/func")

local jerusalemsArtichoke = mod.ENUMS.VEGETABLES.JERUSALEMS_ARTICHOKE
local artichokeVar = Isaac.GetEntityVariantByName("Artichoke Spear")

local ARTICHOKE_COOLDOWN = 5*60
local ARTICHOKE_FINISH_COOL_SFX = 509
sfx:Preload(ARTICHOKE_FINISH_COOL_SFX)

local ARTICHOKE_SPEED = 30

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    local artichokeNum = player:GetCollectibleNum(jerusalemsArtichoke)
    if(artichokeNum<=0) then return end

    if(data.artichokeCooldown==nil) then data.artichokeCooldown=0 end

    if(data.artichokeCooldown>0) then
        data.artichokeCooldown=data.artichokeCooldown-1
        if(data.artichokeCooldown==0) then
            player:SetColor(Color(1,1,1,1,0.1,0.5,0.2),3,1,true,false)
            sfx:Play(ARTICHOKE_FINISH_COOL_SFX)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param player EntityPlayer
function funcs:postDoubletap(player)
    local data = player:GetData()
    local artichokeNum = player:GetCollectibleNum(jerusalemsArtichoke)
    if(artichokeNum<=0) then return end

    if(data.artichokeCooldown==nil or data.artichokeCooldown>0) then return end

    local vel = player:GetShootingJoystick()*ARTICHOKE_SPEED
    local tear = player:FireTear(player.Position, vel, true, true, false, player)

    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.05
    tear.TearFlags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL
    tear.CollisionDamage = 10
    tear.Scale = 1

    local sprite = tear:GetSprite()
    sprite:Load("gfx/entities/tears/artichoke/artichoke.anm2", true)
    sprite:Play("Idle", true)
    tear.SpriteRotation = tear.Velocity:GetAngleDegrees()
    tear:ChangeVariant(artichokeVar)

    tear.Color = Color(1,1,1)

    data.artichokeCooldown = ARTICHOKE_COOLDOWN
    local tData = tear:GetData()
    tData.cucumberTear = true
    tData.poppedTear = true
    tData.artichokeTarget = nil
    tData.artichokeTargetBlacklist = {}
end
mod:AddCallback("GREEN_POST_DOUBLETAP", funcs.postDoubletap)

---@param tear Entity
function funcs:postTearRemove(tear)
    tear=tear:ToTear()
    if(tear.Variant~=artichokeVar) then return end

    --SPAWN GIBS
    local gibs = Isaac.Spawn(1000,12,0,tear.Position,Vector.Zero,tear):ToEffect()
    gibs.SpriteOffset = Vector(0,-13.5)

    local col = Color(1,1,1)
    col:SetColorize(0.3,0.7,0.5,1)

    gibs.Color = col

    for i=1, 3 do
        gibs:Update()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postTearRemove, EntityType.ENTITY_TEAR)

local function getValidArtichokeTarget(tear, pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

    local invalidTargets = tear:GetData().artichokeTargetBlacklist or {}

	for i = 1, #entities do
        local ent = entities[i]
		if h:isValidEnemy(ent) and invalidTargets[tostring(GetPtrHash(ent))]==nil then
			local dist = (ent.Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = ent
			end
		end
	end
	return closestEnt
end

function funcs:postTearUpdate(tear)
    tear.SpriteRotation = tear.Velocity:GetAngleDegrees()

    tear.Velocity = tear.Velocity*0.975

    local data = tear:GetData()

    if(data.artichokeTarget) then
        tear.Velocity = tear.Velocity:Rotated((data.artichokeTarget.Position-tear.Position):GetAngleDegrees()-tear.Velocity:GetAngleDegrees())
    end

    if(data.artichokeTarget==nil) then
        local newTarget = getValidArtichokeTarget(tear, tear.Position)
        if(newTarget) then
            data.artichokeTargetBlacklist[tostring(GetPtrHash(newTarget))]=true

            tear.Velocity = tear.Velocity*0.95

            data.artichokeTarget = newTarget
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate, artichokeVar)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    local tear = source.Entity
    if(not (tear and tear:ToTear())) then return nil end

    if(tear.Variant~=artichokeVar) then return nil end
    if(tear:GetData().artichokeTarget==nil) then return nil end

    if(GetPtrHash(entity)~=GetPtrHash(tear:GetData().artichokeTarget)) then return nil end

    tear:GetData().artichokeTarget = nil
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

mod.ITEMS.JERUSALEMSARTICHOKE = funcs