local mod = jezreelMod
local h = include("scripts/func")

local greenD6 = mod.ENUMS.ITEMS.G6

local validGreens = {}
local veggies = mod.ENUMS.VEGETABLES
local BASE_WEIGHTMOD = 1/10
local BASE_GENERICCHANCE = 1/3

local GENERICCHANCE_MODS = {
    [ItemPoolType.POOL_SECRET] = 1/10,
    [ItemPoolType.POOL_ANGEL] = 1/10,
    [ItemPoolType.POOL_DEVIL] = 1/10,
    [ItemPoolType.POOL_BOSS] = 0,
    [ItemPoolType.POOL_PLANETARIUM] = 0,
}

mod.GREEN_ITEMPOOLS = {
    ["GENERIC"] = {
        {ID=veggies.SAD_CUCUMBER, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.HOT_POTATO, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.LEAK, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.SINGLE_PEA, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.RADISH, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.MILDLY_SPICY_PEPPER, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.OBNOXIOUS_TANGERINE, BASEWEIGHT=1, WEIGHT=1, WEIGHTMOD=1/100},
        {ID=veggies.BROCCOLI_MAN, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.THE_ONION, BASEWEIGHT=1, WEIGHT=1},
    },
    [ItemPoolType.POOL_TREASURE] = {
        {ID=veggies.POMEGRENADE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BLUE_BERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.WATERMELON, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.POPPED_CORN, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.FOUR_DIMENSIONAL_APPLE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BABY_CARROT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.PYRE_LANTERN, BASEWEIGHT=1, WEIGHT=1},

        {ID=veggies.KEY_LIME, BASEWEIGHT=1/2, WEIGHT=1/2},
        {ID=veggies.CHERRY_ON_TOP, BASEWEIGHT=1/2, WEIGHT=1/2},

        {ID=veggies.ANCIENT_CARROT, BASEWEIGHT=1/5, WEIGHT=1/5},
        {ID=veggies.CONFUSING_PEAR, BASEWEIGHT=1/10, WEIGHT=1/10},
    },
    [ItemPoolType.POOL_SHOP] = {
        {ID=veggies.LEMON_BATTERY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BANANARANG,  BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BEESWAX_GOURD,  BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.JOLLY_MINT,  BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.ECO_FRIENDLY_OPTIONS,  BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.OLIVE_OIL,  BASEWEIGHT=1, WEIGHT=1},

        {ID=veggies.CHERRY_ON_TOP, BASEWEIGHT=1/2, WEIGHT=1/2},
        {ID=veggies.KEY_LIME, BASEWEIGHT=1/2, WEIGHT=1/2},
    },
    [ItemPoolType.POOL_CURSE] = {
        {ID=veggies.CURSED_GRAPES, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.SPIKY_DURIAN, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.DRAGONFRUIT_BOMBS, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BLOODY_ORANGE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.HEMOGUAVA, BASEWEIGHT=1, WEIGHT=1},

        {ID=veggies.DEVILED_EGGPLANT, BASEWEIGHT=1/4, WEIGHT=1/4},
        {ID=veggies.MOMS_CHIVES, BASEWEIGHT=1/3, WEIGHT=1/3},
        {ID=veggies.RICIN_FLASK, BASEWEIGHT=1/2, WEIGHT=1/2},
    },
    [ItemPoolType.POOL_ANGEL] = {
        {ID=veggies.UNICORNRADISH, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.JERUSALEMS_ARTICHOKE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.SWEET_POTATO, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.MISSILETOE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.URIELS_HAND, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.JOLLY_MINT, BASEWEIGHT=1, WEIGHT=1},
    },
    [ItemPoolType.POOL_DEVIL] = {
        {ID=veggies.REALLY_SPICY_PEPPER, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.DEVILED_EGGPLANT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.MOMS_CHIVES, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.RICIN_FLASK, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BLOODY_ORANGE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.DRAGONFRUIT_BOMBS, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.HEMOGUAVA, BASEWEIGHT=1/2, WEIGHT=1/2},
        {ID=veggies.CURSED_GRAPES, BASEWEIGHT=1/2, WEIGHT=1/2},
    },
    [ItemPoolType.POOL_SECRET] = {
        {ID=veggies.CONFUSING_PEAR, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.ANCIENT_CARROT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.DADS_TOBACCO, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.NATURAL_GIFT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.FOUR_DIMENSIONAL_APPLE, BASEWEIGHT=1/4, WEIGHT=1/4},
    },
    [ItemPoolType.POOL_BOSS] = {
        {ID=veggies.YELLOWBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.PIZZABERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.ELDERBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.HONEYBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BEARBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.COFFEEBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BLACKCURRANT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.REDCURRANT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.CROWBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BARBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.GRASS_CLIPPINGS, BASEWEIGHT=1, WEIGHT=1},
    },
    [ItemPoolType.POOL_PLANETARIUM] = {
        {ID=veggies.DEMETER, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.STARFRUIT, BASEWEIGHT=1, WEIGHT=1},
    },

    [ItemPoolType.POOL_ULTRA_SECRET] = {
        {ID=veggies.BARBERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.BLOODY_ORANGE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.CHERRY_ON_TOP, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.HOLLY_BERRY, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.DRAGONFRUIT_BOMBS, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.POMEGRENADE, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.REALLY_SPICY_PEPPER, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.REDCURRANT, BASEWEIGHT=1, WEIGHT=1},
        {ID=veggies.SWEET_POTATO, BASEWEIGHT=1, WEIGHT=1},
    },
}

local SPECIFICITEM_OVERRIDES = {
    [CollectibleType.COLLECTIBLE_PONY] = veggies.SCALLION,
    [CollectibleType.COLLECTIBLE_WHITE_PONY] = veggies.SCALLION,

    [CollectibleType.COLLECTIBLE_LUMP_OF_COAL] = veggies.KRAM_BERRY,
    [CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS] = veggies.KRAM_BERRY,

    [CollectibleType.COLLECTIBLE_CUBE_OF_MEAT] = veggies.CLUMP_OF_HAY,
    [CollectibleType.COLLECTIBLE_BALL_OF_BANDAGES] = veggies.CLUMP_OF_HAY,
}

local DEFAULTPOOLS = {
    [ItemPoolType.POOL_GREED_ANGEL] = ItemPoolType.POOL_ANGEL,
    [ItemPoolType.POOL_GREED_BOSS] = ItemPoolType.POOL_BOSS,
    [ItemPoolType.POOL_GREED_CURSE] = ItemPoolType.POOL_CURSE,
    [ItemPoolType.POOL_GREED_DEVIL] = ItemPoolType.POOL_DEVIL,
    [ItemPoolType.POOL_GREED_GOLDEN_CHEST] = ItemPoolType.POOL_GOLDEN_CHEST,
    [ItemPoolType.POOL_GREED_LIBRARY] = ItemPoolType.POOL_LIBRARY,
    [ItemPoolType.POOL_GREED_SECRET] = ItemPoolType.POOL_SECRET,
    [ItemPoolType.POOL_GREED_TREASURE] = ItemPoolType.POOL_TREASURE,
    [ItemPoolType.POOL_GREED_TREASUREL] = ItemPoolType.POOL_TREASURE,
    [ItemPoolType.POOL_BABY_SHOP] = ItemPoolType.POOL_SHOP,
}

local funcs = {}

local function getRandomGreenIDFromTable(rng, table)
    local maxWeight = 0
    for _, item in pairs(table) do maxWeight=maxWeight+item.WEIGHT*(item.WEIGHTMOD or BASE_WEIGHTMOD)^h:allPlayersCollNum(item.ID) end

    local chosenWeight = rng:RandomFloat()*maxWeight
    local currWeight = 0

    for i, item in pairs(table) do
        currWeight=currWeight+item.WEIGHT*(item.WEIGHTMOD or BASE_WEIGHTMOD)^h:allPlayersCollNum(item.ID)

        if(chosenWeight<currWeight) then
            print(item.ID .. " " .. item.WEIGHT*(item.WEIGHTMOD or BASE_WEIGHTMOD)^h:allPlayersCollNum(item.ID) .. " " .. tostring(validGreens[item.ID]))

            return item.ID
        end
    end
end

local function canBeConverted(pickup)
    if(pickup.Type~=EntityType.ENTITY_PICKUP) then return false end
    if(pickup.Variant~=100) then return false end
    if(pickup.SubType==0) then return false end

    if(mod:isGreenItem(pickup)) then return false end

    return true
end

local function entryExistsInTable(entry, table)
    for _, val in pairs(table) do
        if(entry==val) then return true end
    end

    return false
end

function mod:isGreenItem(pickup)
    if(entryExistsInTable(pickup.SubType, mod.ENUMS.VEGETABLES)) then return true end

    return false
end

function mod:getGreenItem(rng)
    local item = 0

    local poolForRoom = Game():GetItemPool():GetPoolForRoom(Game():GetRoom():GetType(), Game():GetSeeds():GetStartSeed())
    if(DEFAULTPOOLS[poolForRoom]) then poolForRoom=DEFAULTPOOLS[poolForRoom] end
    if(not mod.GREEN_ITEMPOOLS[poolForRoom]) then poolForRoom=ItemPoolType.POOL_TREASURE end

    local genericChance = BASE_GENERICCHANCE
    if(GENERICCHANCE_MODS[poolForRoom]) then genericChance=genericChance*GENERICCHANCE_MODS[poolForRoom] end

    if(rng:RandomFloat()<genericChance) then
        item = getRandomGreenIDFromTable(rng, mod.GREEN_ITEMPOOLS["GENERIC"])
    else
        item = getRandomGreenIDFromTable(rng, mod.GREEN_ITEMPOOLS[poolForRoom])
    end

    return item
end

local function isGreenItemValid(id)
    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                if(mod.MARKS.CHARACTERS[character][side][mark]==1) then goto invalid end

                if(unlock.TYPE=="VEGETABLE" and unlock.ID==id) then
                    return false
                end

                ::invalid::
            end
        end
    end

    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:GetPlayerType()==PlayerType.PLAYER_CAIN_B) then -- REMOVE "CONFUSING PEAR" FOR TAINTED CAIN
            if(id==veggies.CONFUSING_PEAR) then return false end
        end
    end

    return true
end

function funcs:postGameStarted(isCont)
    for key, val in pairs(veggies) do
        validGreens[val]=isGreenItemValid(val)
    end

    for pool, items in pairs(mod.GREEN_ITEMPOOLS) do
        for item, itemDat in pairs(items) do

            mod.GREEN_ITEMPOOLS[pool][item].WEIGHT = mod.GREEN_ITEMPOOLS[pool][item].BASEWEIGHT
            if(validGreens[itemDat.ID]==false) then
                mod.GREEN_ITEMPOOLS[pool][item].WEIGHT = 0
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, funcs.postGameStarted)

---@param rng RNG
---@param player EntityPlayer
---@param slot ActiveSlot
function funcs:useGreenD6(_, rng, player, _, slot, _)
    local items = Isaac.FindByType(5,100)

    for i=1, #items do
        local item = items[i]:ToPickup()
        if(not canBeConverted(item)) then goto invalidItem end
        do
            local st = item.SubType

            local gItem = 0
            if(SPECIFICITEM_OVERRIDES[st]) then
                gItem=SPECIFICITEM_OVERRIDES[st]
            else
                gItem = mod:getGreenItem(rng)
            end

            item:Morph(5,100,gItem, true, false, false)
        end
        ::invalidItem::
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.LATE, funcs.useGreenD6, greenD6)

mod.ITEMS.GREEND6 = funcs