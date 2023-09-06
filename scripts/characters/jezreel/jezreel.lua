local mod = jezreelMod

local greenThumbId = mod.ENUMS.ITEMS.GREEN_THUMB

local jezreelId = Isaac.GetPlayerTypeByName("Jezreel", false)

local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

local SPAWN_COOLDOWN = 30

local funcs = {}

local function sign(number)
    return (number > 0 and 1) or (number == 0 and 0) or -1
end-- NOTE TO SELF: math.sign does not exist
    -- i totally did not spend half an hour wondering why it wasnt working and only then realized math.sign isnt real
    -- nuh uh

---@param player EntityPlayer
function funcs:onCache(player, flags)
    if(player:GetPlayerType()==jezreelId) then
        if(flags&CacheFlag.CACHE_SPEED==CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.2
        end
        if(flags&CacheFlag.CACHE_FLYING==CacheFlag.CACHE_FLYING) then
            if(player.CanFly) then
                player:AddNullCostume(flyingGreenCharCostume)
                player:TryRemoveNullCostume(greenCharCostume)
            else
                player:AddNullCostume(greenCharCostume)
                player:TryRemoveNullCostume(flyingGreenCharCostume)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.onCache)

function funcs:postPlayerInit(player)
    if(player:GetPlayerType()==jezreelId) then
        if(player:GetActiveItem(2)~=greenThumbId and player:GetActiveItem(3)~=greenThumbId) then
            player:SetPocketActiveItem(greenThumbId, ActiveSlot.SLOT_POCKET, true)
        end

        local data = player:GetData()

        data.newRoomCooldown = -1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    if(entity:GetData().isJezreelsTormentor==true) then
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

function funcs:preEntityDevolve(entity)
    if(entity:GetData().isJezreelsTormentor==true) then
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, funcs.preEntityDevolve)

function funcs:preNpcCollision(npc, collider)
    if(npc:GetData().isJezreelsTormentor==true) then
        if(collider.Type==2) then return true end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, funcs.preNpcCollision)

function funcs:preTearCollision(tear, collider)
    if(collider:GetData().isJezreelsTormentor==true) then
        collider.Velocity = collider.Velocity*0.75+tear.Velocity*0.25

        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, funcs.preTearCollision)

function funcs:postPlayerUpdate(player)
    if(player:GetPlayerType()==jezreelId) then
        local data = player:GetData()
        if(data.newRoomCooldown==0) then
            local room = Game():GetRoom()
            local enterSlot = Game():GetLevel().EnterDoor
            local centerPos = room:GetCenterPos()
            local spawnPos = centerPos
            local iMax = 1+(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 1 or 0)
            for i=1, iMax do
                if(enterSlot and enterSlot~=-1) then
                    local slotPos = room:GetDoorSlotPosition(enterSlot)
                    spawnPos = Vector(slotPos.X-(40+20*(i-1))*sign(slotPos.X-centerPos.X), slotPos.Y-(40+20*(i-1))*sign(slotPos.Y-centerPos.Y))
                end
                local enemy = Isaac.Spawn(811,0,1,spawnPos,Vector.Zero, player):ToNPC()
                enemy.CanShutDoors = false
                enemy:GetData().isJezreelsTormentor = true
                enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
                local sprite = enemy:GetSprite()
                sprite:Load("gfx/entities/npcs/reapgaper/reapgaper.anm2", true)

                local poof = Isaac.Spawn(1000,15,0,spawnPos,Vector.Zero, nil)
            end
        end
        if(data.newRoomCooldown>=0) then data.newRoomCooldown=data.newRoomCooldown-1 end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

function funcs:postNewRoom()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:GetPlayerType()==jezreelId) then
            player:GetData().newRoomCooldown = SPAWN_COOLDOWN
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:postEntityRemove(entity)
    if(entity:GetData().isJezreelsTormentor==true) then
        local player = Isaac.GetPlayer():ToPlayer()
        if(entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer()) then player = entity.SpawnerEntity:ToPlayer() end
        player:GetData().newRoomCooldown=SPAWN_COOLDOWN*3
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

mod.CHARACTERS.JEZREEL = funcs