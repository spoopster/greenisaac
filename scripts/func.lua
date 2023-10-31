local mod = jezreelMod

local funcs = {}

function funcs:anyPlayerHas(item)
    for i = 0, Game():GetNumPlayers()-1 do
        if(Isaac.GetPlayer(i):HasCollectible(item)) then return true end
    end
    return false
end

function funcs:allPlayersCollNum(item)
    local num = 0
    for i = 0, Game():GetNumPlayers()-1 do
        num = num+Isaac.GetPlayer(i):GetCollectibleNum(item)
    end
    return num
end

function funcs:isAnyPlayerCertainType(id)
    for i = 0, Game():GetNumPlayers()-1 do
        if(Isaac.GetPlayer(i):GetPlayerType()==id) then return true end
    end
    return false
end

local function canChargeActive(player, slot, extraCharge)
    player = player:ToPlayer()
    local charge = player:GetActiveCharge(slot)+player:GetBatteryCharge(slot)
    local canCharge1 = player:FullCharge(slot, false)
    player:SetActiveCharge(charge+extraCharge, slot)
    local canCharge2 = player:FullCharge(slot, false)
    player:SetActiveCharge(charge, slot)
    return (canCharge1 or canCharge2)
end

function funcs:addBatteryCharge(player, charge)
    for i=0,3 do
        if(player:GetActiveItem(i)~=0 and canChargeActive(player, i, charge)) then
            local config = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(i))
            local newCharge = player:GetActiveCharge(i)+player:GetBatteryCharge(i)+charge
            if(player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)) then
                player:SetActiveCharge(newCharge, i)
            else
                player:SetActiveCharge(math.min(newCharge, config.MaxCharges), i)
            end
            return true
        end
    end
    return false
end

function funcs:isRoomClear()
    return (Game():GetRoom():IsClear() and not Game():GetRoom():IsAmbushActive())
end

function funcs:hasGreenIsaacBirthright(player)
    return (player:GetPlayerType()==Isaac.GetPlayerTypeByName("Green Isaac", false) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
end

---@param entity Entity
function funcs:isFriendly(entity)
    if(entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then return true end
    return false
end

---@param entity Entity
function funcs:isValidEnemy(entity)
    return (entity:IsEnemy() and entity:IsVulnerableEnemy() and not funcs:isFriendly(entity))
end

function funcs:closestEnemy(pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if funcs:isValidEnemy(entities[i]) then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end
	return closestEnt
end

function funcs:lerp(a,b,f)
    return a*(1-f)+b*f
end

---@param pos Vector
function funcs:closestPlayer(pos)
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

function funcs:getHearts(player)
    local hearts = {
        Red = player:GetHearts()/2,
        Soul = player:GetSoulHearts()/2,
        Black = 0,
        Rotten = player:GetRottenHearts(),
        Bone = player:GetBoneHearts(),
        Golden = player:GetGoldenHearts(),
        Eternal = player:GetEternalHearts(),
    }

    local bHearts = (player:GetBlackHearts()+1)
    local realBHearts = math.log(bHearts) / math.log(2)

    hearts.Black = realBHearts

    return hearts
end

function funcs:sign(num)
    if(num>0) then return 1
    elseif(num==0) then return 0 end
    return -1
end

--Classes
local game = Game()

--Constants
local DISAPPEAR_ANIM = "Disappear"
local CHARGING_ANIM = "Charging"
local CHARGED_ANIM = "Charged"

local RENDER_NUM_TO_OFFSET = Vector(12, 0)

--Variables
local registeredChargebars = {}
local renderedChargebarNum = {}

--Function (helper)
local function GetChargebarSprite(playerPtr, gfx)
    if not registeredChargebars[playerPtr] then
        registeredChargebars[playerPtr] = {}
    end

    if not registeredChargebars[playerPtr][gfx] then
        local sprite = Sprite()
        sprite:Load(gfx, true)
        sprite:Play(DISAPPEAR_ANIM, true)
        sprite:SetLastFrame()
        registeredChargebars[playerPtr][gfx] = sprite
    end

    return registeredChargebars[playerPtr][gfx]
end

local function UpdateAndEnforceAnimation(sprite, animation)
    sprite:Update()
    if sprite:GetAnimation() ~= animation then
        sprite:Play(animation, true)
    end
end

local function UpdateSpriteAnimation(chargebarSprite, completionPercent, shouldDisappear)
    if shouldDisappear then
        UpdateAndEnforceAnimation(chargebarSprite, DISAPPEAR_ANIM)
    elseif completionPercent > 1.13 then
        UpdateAndEnforceAnimation(chargebarSprite, CHARGED_ANIM)
    else
        chargebarSprite:SetFrame(CHARGING_ANIM, math.floor(completionPercent * 100))
    end
end

local function GetRenderPosition(player, playerPtr)
    local screenPosition = Isaac.WorldToScreen(player.Position)

    if game:GetRoom():IsMirrorWorld() then
        screenPosition = Vector(-screenPosition.X, screenPosition.Y)
    end

    return screenPosition + renderedChargebarNum[playerPtr] * RENDER_NUM_TO_OFFSET
end

local function ShouldRender(sprite)
    return sprite:GetAnimation() ~= DISAPPEAR_ANIM or not sprite:IsFinished()
end

--Function (callback)
local function PostRender()
    renderedChargebarNum = {}
end

--Function (core)
function funcs:RenderChargebar(player, gfx, offset, completionPercent, shouldDisappear)
    local playerPtr = GetPtrHash(player)
    local chargebarSprite = GetChargebarSprite(playerPtr, gfx)

    if not renderedChargebarNum[playerPtr] then
        renderedChargebarNum[playerPtr] = 0
    end

    UpdateSpriteAnimation(chargebarSprite, completionPercent, shouldDisappear)

    if not ShouldRender(chargebarSprite) then return end

    chargebarSprite:Render(GetRenderPosition(player, playerPtr) + offset)
    renderedChargebarNum[playerPtr] = renderedChargebarNum[playerPtr] + 1
end

--Init
mod:AddCallback(ModCallbacks.MC_POST_RENDER, PostRender)

return funcs