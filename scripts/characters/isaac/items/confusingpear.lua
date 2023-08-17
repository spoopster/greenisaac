local mod = jezreelMod
local helper = include("scripts/func")

local confusingPear = mod.ENUMS.VEGETABLES.CONFUSING_PEAR
local pearVariant = mod.PICKUPS.PEAR
mod.PEAR_BLACKLIST = {
    [pearVariant] = false,
    [40] = {
        [3]=false,
        [5]=false,
    },
    [41] = false,
    [42] = false,
    [50] = false,
    [51] = false,
    [52] = false,
    [53] = false,
    [54] = false,
    [55] = false,
    [56] = false,
    [57] = false,
    [58] = false,
    [60] = false,
    [69] = false,
    [70] = false,
    [100] = false,
    [110] = false,
    [150] = false,
    [300] = false,
    [340] = false,
    [350] = false,
    [360] = false,
    [370] = false,
    [380] = false,
    [390] = false,
}

local funcs = {}

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    if((not pickup:IsShopItem()) and ((type(mod.PEAR_BLACKLIST[pickup.Variant])~="table" and mod.PEAR_BLACKLIST[pickup.Variant]~=false) or
    (type(mod.PEAR_BLACKLIST[pickup.Variant])=="table" and mod.PEAR_BLACKLIST[pickup.Variant][pickup.SubType]~=false))) then
        if(helper:anyPlayerHas(confusingPear) and not pickup:GetData().spawnedByPear) then
            local shopId = pickup.ShopItemId
            pickup:Morph(5,pearVariant,0,true,false,true)
            pickup.ShopItemId = shopId
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit)

mod.ITEMS.CONFUSINGPEAR = funcs