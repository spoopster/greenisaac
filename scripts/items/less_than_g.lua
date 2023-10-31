local mod = jezreelMod

local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local lesserThanG = mod.ENUMS.ITEMS.LESSER_THAN_G
local lesserThanGDummy = mod.ENUMS.ITEMS.LESSER_THAN_G_DUMMY

local baseSpawnChance = 1.2

local funcs = {}

local function getEffectiveItemNum(player)
    return player:GetCollectibleNum(lesserThanG)+player:GetCollectibleNum(lesserThanGDummy)
end

---@param entity Entity
function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    local player = entity:ToPlayer()
    local heartNum = getEffectiveItemNum(player)
    if(heartNum>0) then
        local rng = player:GetCollectibleRNG(lesserThanGDummy)
        if(rng:RandomFloat()<0.5) then
            local chance = baseSpawnChance^(heartNum-1)
            for i=1, math.floor(chance) do
                local subtype = rng:RandomInt(6)+1
                local blockbum = Isaac.Spawn(3, blockbumVar, subtype, player.Position, Vector.Zero, player)
            end
            chance = chance-math.floor(chance)
            if(rng:RandomFloat()<=chance) then
                local subtype = rng:RandomInt(6)+1
                local blockbum = Isaac.Spawn(3, blockbumVar, subtype, player.Position, Vector.Zero, player)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, 1)

mod.ITEMS.LESSERTHANG = funcs