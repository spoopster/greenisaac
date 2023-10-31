local mod = jezreelMod

---GREEN_POST_COLLECTIBLE_GET
local function postPeffectUpdate(_, player)
    local data = player:GetData()

    local queuedItem = player.QueuedItem
    data.heldItemConfig = queuedItem.Item or data.heldItemConfig

    if not (not queuedItem.Item and data.heldItemConfig) then return end

    local itemId = data.heldItemConfig.ID

    Isaac.RunCallbackWithParam("GREEN_POST_COLLECTIBLE_GET", itemId, player, itemId)

    data.heldItemConfig = nil
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)

---GREEN_POST_DOUBLETAP

local DIRECTION_FLUSH_MOD = 10
local LAST_FIRE_DIRECTIONS = {}

local function cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key] = cloneTable(val)
        else
            tClone[key]=val
        end
    end
    return tClone
end

local function updateFireDirections(player)
    local playerPtr = GetPtrHash(player)
    if not LAST_FIRE_DIRECTIONS[playerPtr] then
        LAST_FIRE_DIRECTIONS[playerPtr] = {
            Direction.NO_DIRECTION,
            Direction.NO_DIRECTION,
            Direction.NO_DIRECTION,
        }
    end

    local lastFireDirections = LAST_FIRE_DIRECTIONS[playerPtr]
    local tableClone = cloneTable(lastFireDirections)

    local fireDirection = player:GetFireDirection()
    if lastFireDirections[1] ~= fireDirection or Game():GetFrameCount() % DIRECTION_FLUSH_MOD == 0 then
        for i = 1, #lastFireDirections do
            lastFireDirections[i + 1] = tableClone[i]
        end
        lastFireDirections[#lastFireDirections] = nil

        lastFireDirections[1] = fireDirection
    end
end

local function shouldActivateDoubletap(player)
    local playerPtr = GetPtrHash(player)
    local fireDirections = LAST_FIRE_DIRECTIONS[playerPtr]

    if fireDirections[1] == fireDirections[3] and fireDirections[2] == Direction.NO_DIRECTION and fireDirections[3] ~= Direction.NO_DIRECTION then
        return true
    end

    return false
end

local function postPlayerUpdate(_, player)
    updateFireDirections(player)

    if shouldActivateDoubletap(player) then
        Isaac.RunCallback("GREEN_POST_DOUBLETAP", player)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)