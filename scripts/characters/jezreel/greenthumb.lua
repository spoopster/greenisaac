local mod = jezreelMod

local greenThumbId = mod.ENUMS.ITEMS.GREEN_THUMB

local greenItempool = {
    [1] = CollectibleType.COLLECTIBLE_JELLY_BELLY,
    [2] = CollectibleType.COLLECTIBLE_ROTTEN_BABY,
    [3] = CollectibleType.COLLECTIBLE_CHEMICAL_PEEL,
    [4] = CollectibleType.COLLECTIBLE_DOLLAR,
    [5] = CollectibleType.COLLECTIBLE_COMMON_COLD,
    [6] = CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID,
    [7] = CollectibleType.COLLECTIBLE_GNAWED_LEAF,
    [8] = CollectibleType.COLLECTIBLE_D4,
    [9] = CollectibleType.COLLECTIBLE_MUTANT_SPIDER,
    [10] = CollectibleType.COLLECTIBLE_BOBS_BRAIN,
    [11] = CollectibleType.COLLECTIBLE_BOBS_CURSE,
    [12] = CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD,
    [13] = CollectibleType.COLLECTIBLE_SAD_ONION,
    [14] = CollectibleType.COLLECTIBLE_1UP,
    [15] = CollectibleType.COLLECTIBLE_TOXIC_SHOCK,
    [16] = CollectibleType.COLLECTIBLE_SERPENTS_KISS,
    [17] = CollectibleType.COLLECTIBLE_COUPON,
    [18] = CollectibleType.COLLECTIBLE_MYSTERY_GIFT,
    [19] = CollectibleType.COLLECTIBLE_SINUS_INFECTION,
    [20] = CollectibleType.COLLECTIBLE_PAUSE,
}
local greenItems = {}

local funcs = {}

function funcs:postGameStarted(isCont)
    greenItems={}
    for i=1,#greenItempool do
        local item = greenItempool[i]
        if(Isaac.GetItemConfig():GetCollectible(item):IsAvailable()==false) then
            item=-1
        end
        greenItems[i]=item
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, funcs.postGameStarted)

function funcs:useItem(items, rng, player, flags, slot, data)
    for _, item in ipairs(Isaac.FindByType(5,100)) do
        if(item.SubType~=0) then
            item=item:ToPickup()
            local id = -1
            while(id==-1) do
                local rand = rng:RandomInt(#greenItems)+1
                id = greenItems[rand]
            end
            item:Morph(5,100,id,true)
        end
    end
    return {
        Discharge=true,
        ShowAnim=true,
        Remove=false,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenThumbId)

mod.ITEMS.GREEN_THUMB = funcs