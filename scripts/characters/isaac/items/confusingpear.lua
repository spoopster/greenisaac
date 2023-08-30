local mod = jezreelMod
local helper = include("scripts/func")

local confusingPear = mod.ENUMS.VEGETABLES.CONFUSING_PEAR
local pearVariant = mod.PICKUPS.PEAR
mod.PEAR_WHITELIST = {
    [PickupVariant.PICKUP_HEART]=true,
    [PickupVariant.PICKUP_COIN]=true,
    [PickupVariant.PICKUP_BOMB]=true,
    [PickupVariant.PICKUP_KEY]=true,
    [PickupVariant.PICKUP_LIL_BATTERY]=true,
}
mod.PEAR_BLACKLIST = {
    [PickupVariant.PICKUP_BOMB]={
        [BombSubType.BOMB_TROLL]=true,
        [BombSubType.BOMB_SUPERTROLL]=true,
        [BombSubType.BOMB_GOLDENTROLL]=true,
        [BombSubType.BOMB_GIGA]=true,
    },
}


local funcs = {}

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    if(pickup:IsShopItem()) then return end
    if(mod.PEAR_WHITELIST[pickup.Variant]~=true) then return end
    if(mod.PEAR_BLACKLIST[pickup.Variant] and mod.PEAR_BLACKLIST[pickup.Variant][pickup.SubType]==true) then return end

    if(helper:anyPlayerHas(confusingPear) and not pickup:GetData().spawnedByPear) then
        local shopId = pickup.ShopItemId
        pickup:Morph(5,pearVariant,0,true,false,true)
        pickup.ShopItemId = shopId
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit)

mod.ITEMS.CONFUSINGPEAR = funcs