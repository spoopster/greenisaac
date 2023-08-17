local mod = jezreelMod

local challengeId = Isaac.GetChallengeIdByName("Biblically Accurate")
local jezreelId = Isaac.GetPlayerTypeByName("Jezreel", false)
local greenThumbId = mod.ENUMS.ITEMS.GREEN_THUMB

local newRoomCooldown = -1

local SPAWN_COOLDOWN = 15

local s = {}

local funcs = {}

local function sign(number)
    return (number > 0 and 1) or (number == 0 and 0) or -1
end-- NOTE TO SELF: math.sign does not exist
    -- i totally did not spend half an hour wondering why it wasnt working and only then realized math.sign isnt real
    -- nuh uh

local function jezreelHasBirthright()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType()==jezreelId) then
            return true
        end
    end
    return false
end

function funcs:postPlayerInit(player)
    if(Game().Challenge==challengeId) then
        if(player:GetPlayerType()==PlayerType.PLAYER_ISAAC) then
            player:ChangePlayerType(jezreelId)
            player:SetPocketActiveItem(greenThumbId, 2, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    if(Game().Challenge==challengeId) then
        if(entity:GetData().isInvincibleEnemy==true) then
            return false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

function funcs:preEntityDevolve(entity)
    if(Game().Challenge==challengeId) then
        if(entity:GetData().isInvincibleEnemy==true) then
            return true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_DEVOLVE, funcs.preEntityDevolve)

function funcs:postUpdate()
    --[[
        s={[1]="",}
    local k=0
    local id = 1
    for i, entity in ipairs(Isaac.GetRoomEntities()) do
        if(type(entity:GetData())~="table") then
            s[id] = s[id]..type(entity:GetData()).."-"..entity.Type.."."..entity.Variant.."."..entity.SubType.." ("..math.floor(entity.Position.X*100)/100 ..",".. math.floor(entity.Position.Y*100)/100 ..")  "..entity:GetData().." "
            k=k+1
            if(k%6==0) then
                id=id+1
                s[id]=""
            end
        end
    end
    ]] -- IGNORE THIS it exists literally only because i keep getting an error UNFIXABLE i DONT KNOW

    if(Game().Challenge==challengeId) then
        if(newRoomCooldown==0) then
            local room = Game():GetRoom()
            local enterSlot = Game():GetLevel().EnterDoor
            local centerPos = room:GetCenterPos()
            local spawnPos = centerPos
            local iMax = 1
            if(jezreelHasBirthright()==true) then iMax=2 end
            for i=1, iMax do
                if(enterSlot and enterSlot~=-1) then
                    local slotPos = room:GetDoorSlotPosition(enterSlot)
                    spawnPos = Vector(slotPos.X-(40+20*(i-1))*sign(slotPos.X-centerPos.X), slotPos.Y-(40+20*(i-1))*sign(slotPos.Y-centerPos.Y))
                end
                local enemy = Isaac.Spawn(811,0,1,spawnPos,Vector.Zero, nil):ToNPC()
                enemy.CanShutDoors = false
                enemy:GetData().isInvincibleEnemy = true
                enemy:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                enemy:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
                local sprite = enemy:GetSprite()
                sprite:Load("gfx/entities/npcs/reapgaper/reapgaper.anm2", true)

                local poof = Isaac.Spawn(1000,15,0,spawnPos,Vector.Zero, nil)
            end
        end
        if(newRoomCooldown>=0) then newRoomCooldown=newRoomCooldown-1 end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, funcs.postUpdate)

function funcs:postNewRoom()
    if(Game().Challenge==challengeId) then
        newRoomCooldown=SPAWN_COOLDOWN
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:postEntityRemove(entity)
    if(Game().Challenge==challengeId) then
        if(entity:GetData().isInvincibleEnemy==true) then
            newRoomCooldown=SPAWN_COOLDOWN
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

function funcs:postRender()
    for i, val in ipairs(s) do
        Isaac.RenderText(val,55,40+i*10,1,1,1,1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.postRender)

mod.CHALLENGES.BIBLICALLY_ACCURATE = funcs