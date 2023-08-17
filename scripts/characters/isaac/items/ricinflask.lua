local mod = jezreelMod
local h = include("scripts/func")

local ricinFlask = mod.ENUMS.VEGETABLES.RICIN_FLASK

local possibleDebuffs = EntityFlag.FLAG_FREEZE | EntityFlag.FLAG_POISON | EntityFlag.FLAG_SLOW | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_MIDAS_FREEZE |
                        EntityFlag.FLAG_FEAR | EntityFlag.FLAG_BURN | EntityFlag.FLAG_SHRINK | EntityFlag.FLAG_CONTAGIOUS | EntityFlag.FLAG_BLEED_OUT | EntityFlag.FLAG_MAGNETIZED |
                        EntityFlag.FLAG_BAITED | EntityFlag.FLAG_WEAKNESS

local poisonChance = 1

local funcs = {}

---@param entity Entity
function funcs:entityTakeDMG(entity, amount, flags)
    if(not h:isValidEnemy(entity)) then return nil end
    if(entity:HasEntityFlags(EntityFlag.FLAG_POISON)) then return nil end
    if(flags & DamageFlag.DAMAGE_POISON_BURN ~= 0) then return nil end

    local itemNum = h:allPlayersCollNum(ricinFlask)
    if(itemNum>0) then
        if(Isaac.GetPlayer():GetCollectibleRNG(ricinFlask):RandomFloat()>(1-poisonChance)^itemNum) then
            entity:AddPoison(EntityRef(nil), 60, amount)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

---@param entity Entity
function funcs:upgradeDebuffs(entity, amount, flags, source, frames)
    if(not h:isValidEnemy(entity)) then return nil end
    if(entity:GetEntityFlags() & possibleDebuffs == 0) then return nil end

    local itemNum = h:allPlayersCollNum(ricinFlask)
    if(itemNum<=0) then return nil end

    local data = entity:GetData()

    if(data.tookRicinDamage==nil) then
        data.tookRicinDamage=true

        local newDamage = amount*(1.5^(math.sqrt(itemNum)))
        entity:TakeDamage(newDamage-amount, flags, source, frames)
    else
        data.tookRicinDamage=nil
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.upgradeDebuffs)

mod.ITEMS.RICINFLASK = funcs