local mod = jezreelMod
local h = include("scripts/func")

local deviledEggplant = mod.ENUMS.VEGETABLES.DEVILED_EGGPLANT

local heartChances = {
    Red=0.01,
    Soul=0.02,
    Black=0.01,
    Bone=0.04,
    Golden=0.05,
    Rotten=0.03,
    Eternal=0.1,
}

local WEAKNESS_DURATION = 5*30

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local eggplantNum = player:GetCollectibleNum(deviledEggplant)
    if(eggplantNum<=0) then return end
    local data = player:GetData()

    if(data.eggplantWeakChance==nil) then data.eggplantWeakChance=0 end

    local weakChance = 0

    local hearts = h:getHearts(player)

    for heart, num in pairs(hearts) do
        weakChance = weakChance+heartChances[heart]*num
    end

    weakChance = math.max((1-weakChance),0)^eggplantNum

    data.eggplantWeakChance = weakChance
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    local player = source.Entity
    if(not (player and ((player.SpawnerEntity and player.SpawnerEntity:ToPlayer()) or player:ToPlayer()))) then return nil end

    if(player:ToPlayer()) then player=player:ToPlayer()
    else player = player.SpawnerEntity:ToPlayer() end

    if(player:GetData().eggplantWeakChance==nil) then return nil end

    if(not (h:isValidEnemy(entity))) then return nil end

    if(entity:HasEntityFlags(EntityFlag.FLAG_WEAKNESS)) then return nil end

    local rng = player:GetCollectibleRNG(deviledEggplant)
    if(rng:RandomFloat()>player:GetData().eggplantWeakChance) then
        entity:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
        entity:GetData().eggplantWeakDuration = WEAKNESS_DURATION
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

function funcs:npcUpdate(npc)
    if(not (npc:GetData().eggplantWeakDuration)) then return end

    local data = npc:GetData()

    if(data.eggplantWeakDuration<=0) then
        data.eggplantWeakDuration=nil

        npc:ClearEntityFlags(EntityFlag.FLAG_WEAKNESS)

        return
    end

    if(data.eggplantWeakDuration>0) then data.eggplantWeakDuration=data.eggplantWeakDuration-1 end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, funcs.npcUpdate)

mod.ITEMS.DEVILEDEGGPLANT = funcs