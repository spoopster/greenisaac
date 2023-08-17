local mod = jezreelMod

local cursedGrapes = mod.ENUMS.VEGETABLES.CURSED_GRAPES
local greenD6 = mod.ENUMS.ITEMS.G6

local funcs = {}

local roomTypeWeight = {
    [RoomType.ROOM_DEFAULT] = 1/3,
    [RoomType.ROOM_SHOP] = 1,
    [RoomType.ROOM_TREASURE] = 4/5,
    [RoomType.ROOM_BOSS] = 1/10,
    [RoomType.ROOM_MINIBOSS] = 1/5,
    [RoomType.ROOM_SECRET] = 1/6,
    [RoomType.ROOM_SUPERSECRET] = 1/10,
    [RoomType.ROOM_ARCADE] = 1/4,
    [RoomType.ROOM_CURSE] = 1/3,
    [RoomType.ROOM_CHALLENGE] = 1/6,
    [RoomType.ROOM_LIBRARY] = 4/5,
    [RoomType.ROOM_SACRIFICE] = 3/5,
    [RoomType.ROOM_ISAACS] = 2/5,
    [RoomType.ROOM_BARREN] = 3/5,
    [RoomType.ROOM_CHEST] = 1/5,
    [RoomType.ROOM_DICE] = 2/5,
    [RoomType.ROOM_PLANETARIUM] = 1/7,
}

local function getRoomsWithWeight()
    local level = Game():GetLevel()
    local rooms = level:GetRooms()
    local roomsTable = {}
    for i = 1, #rooms do
        local descriptor = rooms:Get(i-1)
        local rType = descriptor.Data.Type
        if(roomTypeWeight[rType]) then
            if(roomsTable[rType]==nil) then roomsTable[rType]={} end

            roomsTable[rType][#roomsTable[rType]+1] = descriptor.SafeGridIndex
        end
    end

    local roomsWeight = {}

    for rType, roomList in pairs(roomsTable) do
        local weight = roomTypeWeight[rType]

        for i, roomId in ipairs(roomList) do
            local descriptor = level:GetRoomByIdx(roomId)

            local realWeight = weight/(#roomList*(10^(descriptor.VisitedCount)))
            if(descriptor.SafeGridIndex==level:GetCurrentRoomDesc().SafeGridIndex) then realWeight=0 end

            roomsWeight[#roomsWeight+1] = {GridIdx=roomId, Weight=realWeight}
        end
    end

    return roomsWeight
end

local function getRandomRoom(rng, roomsTable)
    local maxWeight = 0
    for i, roomData in ipairs(roomsTable) do maxWeight=maxWeight+roomData.Weight end

    local roll = rng:RandomFloat()*maxWeight

    local currentWeight = 0
    for i, roomData in ipairs(roomsTable) do
        currentWeight=currentWeight+roomData.Weight
        if(roll<currentWeight) then
            return roomData.GridIdx
        end
    end
end

function funcs:useItem(_, rng, player, _, slot, _)
    if(player:HasCollectible(cursedGrapes) and not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)) then
        local idx = getRandomRoom(rng, getRoomsWithWeight())

        player:AnimateTeleport()
        Game():StartRoomTransition(idx, -1, RoomTransitionAnim.TELEPORT, player)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenD6)

mod.ITEMS.CURSEDGRAPES = funcs