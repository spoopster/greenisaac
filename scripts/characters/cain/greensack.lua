local mod = jezreelMod
local sfx = SFXManager()

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

local greenSack = Isaac.GetItemIdByName("Green Sack")
local slotVar = Isaac.GetEntityVariantByName("Green Slot")

sfx:Preload(187)

local idToCard = {
    [1]=mod.CONSUMABLES.SHARP_STICK,
    [2]=mod.CONSUMABLES.WEIRD_GUMMY,
    [3]=mod.CONSUMABLES.POTATO_MAGNET,
    [4]=mod.CONSUMABLES.BROKEN_DICE,
    [5]=mod.CONSUMABLES.GLASS_PENNY,
    [6]=mod.CONSUMABLES.FLOWERING_JADE,
}
local cardToId = {
    [mod.CONSUMABLES.SHARP_STICK]=1,
    [mod.CONSUMABLES.WEIRD_GUMMY]=2,
    [mod.CONSUMABLES.POTATO_MAGNET]=3,
    [mod.CONSUMABLES.BROKEN_DICE]=4,
    [mod.CONSUMABLES.GLASS_PENNY]=5,
    [mod.CONSUMABLES.FLOWERING_JADE]=6,
}
local dirToAction = {
    [1]=ButtonAction.ACTION_SHOOTDOWN,
    [2]=ButtonAction.ACTION_SHOOTLEFT,
    [3]=ButtonAction.ACTION_SHOOTUP,
    [4]=ButtonAction.ACTION_SHOOTRIGHT,
}

local funcs = {}

local function findSlotSpawnPos(pos)
    local room = Game():GetRoom()
    local freePos = nil
    local dist = 1
    pos = room:GetGridPosition(room:GetGridIndex(pos))

    local slotGrids = {}
    for _, entity in ipairs(Isaac.FindByType(6,slotVar)) do
        slotGrids[room:GetGridIndex(entity.Position)]=1
    end

    while(dist<=6 and freePos==nil) do
        for i=-dist, dist do
            for j=-dist, dist do
                local newPos = pos+Vector(j,i)*40
                if((math.abs(i)>dist-1 or math.abs(j)>dist-1) and room:IsPositionInRoom(newPos,0) and room:GetGridCollisionAtPos(newPos)==0) then
                    if(slotGrids[room:GetGridIndex(newPos)]==nil) then return newPos end
                end
            end
        end
        dist=dist+1
    end
    return nil
end

function funcs:useItem(item, rng, player, flags, slot, varData)
    local data = player:GetData()
    if(data.usingSack==true) then
        player:AnimateCollectible(greenSack, "HideItem", "PlayerPickup")
        data.usingSack = nil
    else
        player:AnimateCollectible(greenSack, "LiftItem", "PlayerPickup")
        data.usingSack = true
    end
    return{
        Discharge = false,
        Remove = false,
        ShowAnim = false,
    }
end

mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.LATE, funcs.useItem, greenSack)

function funcs:prePlayerCollision(player, collider, low)
    if(collider.Type==5 and collider.Variant==300) then
        if(type(cardToId[collider.SubType])=="number" and player:GetData().usingSack==true) then
            if(collider:GetSprite():GetAnimation()=="Idle") then
                local pickups = player:GetData().sackPickups
                local id = -1
                if(pickups[2]==0) then id=2
                elseif(pickups[3]==0) then id=3
                elseif(pickups[4]==0) then id=4 end
                if(id==-1) then
                    local pickup = Isaac.Spawn(5,300,idToCard[pickups[2]],player.Position+Vector(0,20),Vector.Zero, player)
                    pickups[2]=pickups[3]
                    pickups[3]=pickups[4]
                    pickups[4]=cardToId[collider.SubType]
                else
                    pickups[id]=cardToId[collider.SubType]
                end

                collider:GetSprite():Play("Collect", true)
            else
                return true
            end

            return true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, funcs.prePlayerCollision, 0)

function funcs:postPlayerRender(player, offset)
    local data = player:GetData()
    if(data.usingSack==true) then
        local arrow = Sprite()
        arrow:Load("gfx/entities/effects/pointer/pointer.anm2", true)
        arrow:Play("Arrow", true)
        for i=1,4 do
            local arrowRender = player.Position+Vector(35,0):Rotated(i*90)+Vector(0,-25)
            arrow.Rotation = (i+1)*90
            arrow:Render(Isaac.WorldToRenderPosition(arrowRender)+offset)
        end

        local modToSubtype = {[1]=3, [2]=1, [3]=2, }

        local pickup = Sprite()
        pickup:Load("gfx/entities/effects/pointer/pointer.anm2", true)
        for i=1,4 do
            local renderPos = player.Position+Vector(55,0):Rotated(i*90)+Vector(0,-25)
            if(i==1) then pickup:SetFrame("Slot", modToSubtype[data.sackPickups[i]%(#modToSubtype)+1] or 0)
            else pickup:SetFrame("Pickup", data.sackPickups[i] or 0) end
            pickup:Render(Isaac.WorldToRenderPosition(renderPos)+offset)

            if(not Game():IsPaused()) then
                if(Input.IsActionPressed(dirToAction[i], player.ControllerIndex)) then
                    if(i==1) then
                        if(data.sackPickups[i]>0) then
                            local room = Game():GetRoom()
                            local spawnPos = findSlotSpawnPos(player.Position)
                            if(spawnPos==nil) then
                                sfx:Play(187)
                            else
                                local rng = player:GetDropRNG()
                                local subtype = modToSubtype[data.sackPickups[i]%(#modToSubtype)+1] or 1
                                local slot = Isaac.Spawn(6,slotVar,subtype, spawnPos, Vector.Zero, player)
                                data.sackPickups[i]=data.sackPickups[i]-1
                            end
                        end
                        player:AnimateCollectible(greenSack, "HideItem", "PlayerPickup")
                    else
                        if(data.sackPickups[i]~=0) then
                            player:UseCard(idToCard[data.sackPickups[i]], 0)
                            player:AnimateCard(idToCard[data.sackPickups[i]], "UseItem")
                            data.sackPickups[i]=0
                        else
                            player:AnimateCollectible(greenSack, "HideItem", "PlayerPickup")
                        end
                    end
                    data.usingSack=nil
                end
            end
        end

        local renderPos = Isaac.WorldToRenderPosition(player.Position+Vector(3,26))+offset
        local text = ""..data.sackPickups[1]
        if(data.sackPickups[1]==0) then text="X" end
        f:DrawStringScaled(text, renderPos.X, renderPos.Y, 1, 1, KColor(1,1,1,1), 0, true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, funcs.postPlayerRender)

function funcs:inputAction(entity, hook, action)
    if(hook==InputHook.IS_ACTION_TRIGGERED and action==ButtonAction.ACTION_DROP) then
        if(entity and entity:ToPlayer()) then
            if(entity:GetData().usingSack==true) then
                return false
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, funcs.inputAction, InputHook.IS_ACTION_TRIGGERED)

function funcs:postNewRoom()
    for i=0,Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(i)
        if(player:GetData().usingSack==true) then
            player:GetData().usingSack=nil
            player:AnimateCollectible(greenSack, "HideItem", "PlayerPickup")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    entity=entity:ToPlayer()
    if(entity and entity:GetData().usingSack==true) then
        entity:GetData().usingSack=nil
        entity:AnimateCollectible(greenSack, "HideItem", "PlayerPickup")
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, 1)

mod.ITEMS.GREENSACK = funcs