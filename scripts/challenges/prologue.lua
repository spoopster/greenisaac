local mod = jezreelMod

local challengeId = Isaac.GetChallengeIdByName("PROLOGUE")
local greenIsaacId = Isaac.GetPlayerTypeByName("Green Isaac", false)
local bossGreenIsaacId = Isaac.GetEntityTypeByName("Reap Prime")
local gunsnrosesId = Isaac.GetItemIdByName("Guns n' Roses (REVOLVER)")

local playerDied = false

local roomNumbers = {
    START = 12902,
    BASEMENT = 12903,
    CAVES = 12904,
    DEPTHS = 12905,
    WOMB = 12906,
    SHEOL = 12907,
    DARKROOM = 12908,
}
local itemsToAdd = {
    [roomNumbers.DEPTHS]={CollectibleType.COLLECTIBLE_SAD_ONION, CollectibleType.COLLECTIBLE_MEAT},
    [roomNumbers.WOMB]={CollectibleType.COLLECTIBLE_PENTAGRAM},
    [roomNumbers.SHEOL]={CollectibleType.COLLECTIBLE_CRICKETS_HEAD},
    [roomNumbers.DARKROOM]={CollectibleType.COLLECTIBLE_RAW_LIVER, CollectibleType.COLLECTIBLE_WAFER, CollectibleType.COLLECTIBLE_BELT},
}
local itemsToRemove = {
    [roomNumbers.START]={CollectibleType.COLLECTIBLE_SAD_ONION, CollectibleType.COLLECTIBLE_MEAT, CollectibleType.COLLECTIBLE_PENTAGRAM,
                         CollectibleType.COLLECTIBLE_CRICKETS_HEAD, CollectibleType.COLLECTIBLE_RAW_LIVER, CollectibleType.COLLECTIBLE_WAFER, CollectibleType.COLLECTIBLE_BELT},
    [roomNumbers.SHEOL]={CollectibleType.COLLECTIBLE_PENTAGRAM},
    [roomNumbers.DARKROOM]={CollectibleType.COLLECTIBLE_SAD_ONION, CollectibleType.COLLECTIBLE_MEAT,
                            CollectibleType.COLLECTIBLE_CRICKETS_HEAD},
}
local entitySpawns = { -- i have to do this shit because i hate my life
    [roomNumbers.BASEMENT] = {
        [21] =  {Type = EntityType.ENTITY_GAPER,        Variant = 0,        SubType = 0},
        [23] =  {Type = EntityType.ENTITY_GAPER,        Variant = 0,        SubType = 0},
        [35] =  {Type = EntityType.ENTITY_CYCLOPIA,     Variant = 0,        SubType = 0},
        [39] =  {Type = EntityType.ENTITY_CYCLOPIA,     Variant = 0,        SubType = 0},
        [65] =  {Type = EntityType.ENTITY_CLOTTY,       Variant = 2,        SubType = 0},
        [69] =  {Type = EntityType.ENTITY_CLOTTY,       Variant = 2,        SubType = 0},
        [77] =  {Type = EntityType.ENTITY_HORF,         Variant = 0,        SubType = 0},
        [87] =  {Type = EntityType.ENTITY_HORF,         Variant = 0,        SubType = 0},
        [107]=  {Type = EntityType.ENTITY_HORF,         Variant = 0,        SubType = 0},
        [117]=  {Type = EntityType.ENTITY_HORF,         Variant = 0,        SubType = 0},
        [155]=  {Type = EntityType.ENTITY_MINISTRO,     Variant = 0,        SubType = 0},
        [159]=  {Type = EntityType.ENTITY_MINISTRO,     Variant = 0,        SubType = 0},
        [182]=  {Type = EntityType.ENTITY_HORF,         Variant = 0,        SubType = 0},
        [192]=  {Type = EntityType.ENTITY_HORF,         Variant = 0,        SubType = 0},
    },
    [roomNumbers.CAVES] = {
        [35] =  {Type = EntityType.ENTITY_HOST,         Variant = 0,        SubType = 0},
        [36] =  {Type = EntityType.ENTITY_SKINNY,       Variant = 1,        SubType = 0},
        [39] =  {Type = EntityType.ENTITY_HOST,         Variant = 0,        SubType = 0},
        [49] =  {Type = EntityType.ENTITY_BONY,         Variant = 0,        SubType = 0},
        [55] =  {Type = EntityType.ENTITY_BONY,         Variant = 0,        SubType = 0},
        [68] =  {Type = EntityType.ENTITY_SKINNY,       Variant = 1,        SubType = 0},
        [140]=  {Type = EntityType.ENTITY_FATTY,        Variant = 1,        SubType = 0},
        [144]=  {Type = EntityType.ENTITY_FATTY,        Variant = 1,        SubType = 0},
        [181]=  {Type = EntityType.ENTITY_WALL_CREEP,   Variant = 0,        SubType = 0},
        [193]=  {Type = EntityType.ENTITY_WALL_CREEP,   Variant = 0,        SubType = 0},
    },
    [roomNumbers.DEPTHS] = {
        [35] =  {Type = EntityType.ENTITY_HALF_SACK,    Variant = 0,        SubType = 0},
        [39] =  {Type = EntityType.ENTITY_HALF_SACK,    Variant = 0,        SubType = 0},
        [49] =  {Type = EntityType.ENTITY_NULLS,        Variant = 0,        SubType = 0},
        [52] =  {Type = EntityType.ENTITY_DINGA,        Variant = 0,        SubType = 0},
        [55] =  {Type = EntityType.ENTITY_NULLS,        Variant = 0,        SubType = 0},
        [78] =  {Type = EntityType.ENTITY_BOIL,         Variant = 0,        SubType = 0},
        [86] =  {Type = EntityType.ENTITY_BOIL,         Variant = 0,        SubType = 0},
        [140]=  {Type = EntityType.ENTITY_WIZOOB,       Variant = 1,        SubType = 0},
        [144]=  {Type = EntityType.ENTITY_WIZOOB,       Variant = 1,        SubType = 0},
        [168]=  {Type = EntityType.ENTITY_MEGA_CLOTTY,  Variant = 0,        SubType = 0},
        [176]=  {Type = EntityType.ENTITY_MEGA_CLOTTY,  Variant = 0,        SubType = 0},
    },
    [roomNumbers.WOMB] = {
        [25] =  {Type = EntityType.ENTITY_COD_WORM,         Variant = 0,        SubType = 0},
        [38] =  {Type = EntityType.ENTITY_HOST,             Variant = 1,        SubType = 0},
        [55] =  {Type = EntityType.ENTITY_MEMBRAIN,         Variant = 0,        SubType = 0},
        [72] =  {Type = EntityType.ENTITY_COD_WORM,         Variant = 0,        SubType = 0},
        [92] =  {Type = EntityType.ENTITY_GLOBIN,           Variant = 1,        SubType = 0},
        [109]=  {Type = EntityType.ENTITY_FLESH_MOBILE_HOST,Variant = 0,        SubType = 0},
        [173]=  {Type = EntityType.ENTITY_MEATBALL,         Variant = 0,        SubType = 0},
        [183]=  {Type = EntityType.ENTITY_EYE,              Variant = 0,        SubType = 0},
        [193]=  {Type = EntityType.ENTITY_EYE,              Variant = 0,        SubType = 0},
    },
    [roomNumbers.SHEOL] = {
        [84] = {Type = EntityType.ENTITY_WHIPPER,       Variant = 0,        SubType = 0},
        [86] = {Type = EntityType.ENTITY_WHIPPER,       Variant = 1,        SubType = 0},
        [98] = {Type = EntityType.ENTITY_WHIPPER,       Variant = 0,        SubType = 0},
        [152]= {Type = EntityType.ENTITY_SHADY,         Variant = 0,        SubType = 0},
        [159]= {Type = EntityType.ENTITY_BIGSPIDER,     Variant = 0,        SubType = 0},
        [176]= {Type = EntityType.ENTITY_SUCKER,        Variant = 0,        SubType = 0},
        [178]= {Type = EntityType.ENTITY_BIGSPIDER,     Variant = 0,        SubType = 0},
    },
    [roomNumbers.DARKROOM] = {
        [29] = {Type=bossGreenIsaacId, Variant=0, SubType=0},
    },
}
local roomCooldown = 0
local maxRoomCooldown = 0

local reviveCooldown = 0

local ROOM_SWITCH_COOLDOWN = 15

local funcs = {}

function funcs:postPlayerInit(player)
    if(Game().Challenge==challengeId) then
        if(player:GetPlayerType()==PlayerType.PLAYER_ISAAC) then
            player:ChangePlayerType(greenIsaacId)
            player:SetPocketActiveItem(gunsnrosesId, ActiveSlot.SLOT_POCKET, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

function funcs:postGameStarted(isCont)
    if(Game().Challenge==challengeId) then
        if(not isCont) then
            Isaac.ExecuteCommand("stage 3a")
            Isaac.ExecuteCommand("goto x.default."..roomNumbers.START)
        end
        if(isCont) then
            local stage = Game():GetLevel():GetAbsoluteStage()
            if(stage~=3 and stage~=11) then
                Isaac.ExecuteCommand("stage 3a")
                Isaac.ExecuteCommand("goto x.default."..roomNumbers.START)
            end
            if(stage==3) then
                Isaac.ExecuteCommand("goto x.default."..roomNumbers.START)
            end
            if(stage==11) then Isaac.ExecuteCommand("goto x.default."..roomNumbers.DARKROOM) end

            for i=0,Game():GetNumPlayers()-1 do
                local player = Isaac.GetPlayer(i)
                if(stage==3) then
                    player:AddMaxHearts(6-player:GetMaxHearts(),true)
                end

                player:AddHearts(24)
            end

            roomCooldown = ROOM_SWITCH_COOLDOWN
            maxRoomCooldown = roomCooldown
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, funcs.postGameStarted)

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    if(Game().Challenge==challengeId) then
        local room = Game():GetRoom()
        local roomData = Game():GetLevel():GetCurrentRoomDesc().Data

        if(playerDied==true) then
            if(reviveCooldown==5) then
                playerDied=false
                player:AddHearts(24)
                Isaac.ExecuteCommand("goto x.default."..roomData.Variant)
            end
        end

        local door = room:GetDoor(DoorSlot.UP0)
        if(door and door:IsOpen() and door.Position:Distance(player.Position)<=18 and roomCooldown<=0) then
            local nextRoomIndex = roomData.Variant+1
            if(nextRoomIndex==roomNumbers.DARKROOM) then Isaac.ExecuteCommand("stage 11") end
            if(nextRoomIndex>roomNumbers.DARKROOM) then nextRoomIndex=roomNumbers.DARKROOM end

            Isaac.ExecuteCommand("goto x.default."..nextRoomIndex)
            roomCooldown = ROOM_SWITCH_COOLDOWN
            if(nextRoomIndex==roomNumbers.DARKROOM) then roomCooldown=math.floor(ROOM_SWITCH_COOLDOWN*1.5) end
            maxRoomCooldown=roomCooldown

            Game():StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.FADE, Isaac.GetPlayer())
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

function funcs:postEntityKill(player)
    if(Game():GetLevel():GetCurrentRoomDesc().Data.Variant==roomNumbers.DARKROOM) then
        player=player:ToPlayer()
        player:UseCard(Card.CARD_SOUL_LAZARUS, UseFlag.USE_NOANIM|UseFlag.USE_NOANNOUNCER)
        reviveCooldown=ROOM_SWITCH_COOLDOWN*4.5
        roomCooldown=reviveCooldown
        maxRoomCooldown=reviveCooldown
        playerDied=true --FUCK
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, funcs.postEntityKill, EntityType.ENTITY_PLAYER)

function funcs:postNewRoom()
    if(Game().Challenge==challengeId) then
        local room = Game():GetRoom()
        local roomDesc = Game():GetLevel():GetCurrentRoomDesc()
        local roomData = roomDesc.Data
        local roomVar = roomData.Variant
        if(entitySpawns[roomVar]) then
            if(room:IsClear()) then
                for gridIdx, entDat in pairs(entitySpawns[roomVar]) do
                    local entity = Isaac.Spawn(entDat.Type, entDat.Variant, entDat.SubType, room:GetGridPosition(gridIdx), Vector.Zero, nil)
                    local poof = Isaac.Spawn(1000,15,0,room:GetGridPosition(gridIdx), Vector.Zero, nil)
                end
            end
        end
        if(roomVar==roomNumbers.DARKROOM) then room:RemoveDoor(3) end
        local pos = Vector(room:GetCenterPos().X, room:GetDoorSlotPosition(DoorSlot.DOWN0).Y-60)
        for _, player in ipairs(Isaac.FindByType(1,0)) do
            player=player:ToPlayer()
            player.Position = pos
            if(roomVar==roomNumbers.START) then
                player:AddHearts(24)
            end
            if(itemsToAdd[roomVar]) then
                for _, item in pairs(itemsToAdd[roomVar]) do
                    if(not player:HasCollectible(item)) then player:AddCollectible(item) end
                end
            end
            if(itemsToRemove[roomVar]) then
                for _, item in pairs(itemsToRemove[roomVar]) do
                    if(player:HasCollectible(item)) then player:RemoveCollectible(item) end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:postNewLevel()
    if(Game().Challenge==challengeId) then
        Game():GetLevel():RemoveCurses(127) -- removes all curses
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, funcs.postNewLevel)

function funcs:postRender()
    if(Game().Challenge==challengeId) then
        if(roomCooldown>0) then
            local bgRender = Sprite()
            bgRender:Load("gfx/black.anm2", true)
            bgRender:Play("Main", true)

            if(reviveCooldown>0) then
                if(not Game():IsPaused()) then
                    reviveCooldown = reviveCooldown-0.5
                end
                roomCooldown = reviveCooldown
            end

            local opacity=1
            if(roomCooldown>=maxRoomCooldown-5) then opacity=(maxRoomCooldown-roomCooldown)/5 end
            if(roomCooldown<=5) then opacity=roomCooldown/5 end
            bgRender.Color = Color(1,1,1,opacity,0,0,0)

            bgRender:Render(Vector.Zero)

            roomCooldown=roomCooldown-0.5 -- i WOULD make it check if the game is paused but then the room transition
                                            -- LITERALLY does NOT WORK GOD FUCK
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.postRender)

mod.CHALLENGES.PROLOGUE = funcs