local mod = jezreelMod

local greenD6 = mod.ENUMS.ITEMS.G6
local funcs = {}

local function canBeConverted(pickup)
    if(pickup.Type~=EntityType.ENTITY_PICKUP) then return false end
    if(pickup.Variant~=100) then return false end
    if(pickup.SubType==0) then return false end

    if(mod:isGreenItem(pickup)) then return false end

    return true
end

function mod:isGreenItem(pickup)
    if((pickup.SubType>=mod.ENUMS.VEGETABLES_NUM[1] and pickup.SubType<=mod.ENUMS.VEGETABLES_NUM[#mod.ENUMS.VEGETABLES_NUM])) then return true end

    return false
end

function mod:getGreenItem(rng)
    local rand = 0
    while(mod.VEGETABLES[rand]==-1) do
        rand = rng:RandomInt(#mod.VEGETABLES)+1
    end

    return rand
end

---@param rng RNG
---@param player EntityPlayer
---@param slot ActiveSlot
function funcs:useGreenD6(_, rng, player, _, slot, _)
    local items = Isaac.FindByType(5,100)

    for i=1, #items do
        local item = items[i]:ToPickup()
        if(not canBeConverted(item)) then goto invalidItem end
        local gItem = mod:getGreenItem(rng)
        item:Morph(5,100,mod.VEGETABLES[gItem], true, false, false)
        if(gItem==9) then
            mod.VEGETABLES[9]=-1
        end
        ::invalidItem::
    end

    local discharge = true
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        discharge = false
        player:SetActiveCharge(1, slot)
    end

    return {
        Discharge = discharge,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.LATE, funcs.useGreenD6, greenD6)

mod.ITEMS.GREEND6 = funcs