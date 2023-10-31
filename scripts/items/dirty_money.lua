local mod = jezreelMod

local dirtyMoney = mod.ENUMS.ITEMS.DIRTY_MONEY
local dirtyMoneyDummy = mod.ENUMS.ITEMS.DIRTY_MONEY_DUMMY

local funcs = {}

local function getEffectiveItemNum(player)
    return player:GetCollectibleNum(dirtyMoney)+player:GetCollectibleNum(dirtyMoneyDummy)
end

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    if(entity.HitPoints<=amount and entity:IsVulnerableEnemy()) then
        for _, player in ipairs(Isaac.FindByType(1,0)) do
            player=player:ToPlayer()
            local numMoney = getEffectiveItemNum(player)
            if(numMoney>0) then
                local rng = player:GetCollectibleRNG(dirtyMoneyDummy)
                for j=1, numMoney do
                    if(rng:RandomFloat()<0.1) then
                        local coin = Isaac.Spawn(5,20,mod.PICKUPS.GREENCOIN,entity.Position,Vector(5,0):Rotated(rng:RandomFloat()*360),player)
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

mod.ITEMS.DIRTYMONEY = funcs