local mod = jezreelMod

local greenSack = mod.ENUMS.ITEMS.GREEN_SACK
local slotVar = Isaac.GetEntityVariantByName("Green Slot")
local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")

local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)

local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

mod.CONSUMABLES = {
    SHARP_STICK = Isaac.GetCardIdByName("Sharp Stick"),
    POTATO_MAGNET = Isaac.GetCardIdByName("Potato Magnet"),
    WEIRD_GUMMY = Isaac.GetCardIdByName("Weird Gummy"),
    BROKEN_DICE = Isaac.GetCardIdByName("Broken G6"),
    GLASS_PENNY = Isaac.GetCardIdByName("Glass Penny"),
    FLOWERING_JADE = Isaac.GetCardIdByName("Flowering Jade"),
}
mod.PICKUPS = {
    GREENCOIN = 1287,
    PEAR = Isaac.GetEntityVariantByName("Pear"),
}
mod.MACHINES = {
    --SLOTS--
    [1] = { -- SLOT
        Type = "Machine",
        Sprite = "gfx/entities/slots/slot.png",
        PayoutChance = 0.5,
        BlockbumID = 1,
        Price = "Coin",
        MaxPayout = 25,
        PayoutItem = mod.ENUMS.ITEMS.DIRTY_MONEY_DUMMY,
        DropTable = {
            [1]={Type=5, Variant=10, SubType=0, Count=1, Weight=4.7},
            [2]={Type=5, Variant=20, SubType=0, Count=1, Weight=5.7},
            [3]={Type=5, Variant=20, SubType=0, Count=2, Weight=2.9},
            [4]={Type=5, Variant=30, SubType=0, Count=1, Weight=1.6},
            [5]={Type=5, Variant=40, SubType=0, Count=1, Weight=2.3},
            [6]={Type=5, Variant=mod.PICKUPS.PEAR, SubType=0, Count=1, Weight=5},
            [7]={Type=5, Variant=300, SubType=mod.CONSUMABLES.POTATO_MAGNET, Count=1, Weight=0.2},
            [8]={Type=5, Variant=300, SubType=mod.CONSUMABLES.FLOWERING_JADE, Count=1, Weight=0.1},
            [9]={Type=5, Variant=10, SubType=0, Count=2, Weight=2.2},
            [10]={Type=5, Variant=20, SubType=0, Count=3, Weight=1.4},
            [11]={Type=5, Variant=30, SubType=0, Count=2, Weight=0.8},
            [12]={Type=5, Variant=40, SubType=0, Count=2, Weight=1.1},
        },
    },
    [2] = { -- BLOOD
        Type = "Machine",
        Sprite = "gfx/entities/slots/blood.png",
        PayoutChance = 1,
        BlockbumID = 2,
        Price = "Heart",
        MaxPayout = 15,
        PayoutItem = mod.ENUMS.ITEMS.LESSER_THAN_G_DUMMY,
        DropTable = {
            [1]={Type=5, Variant=20, SubType=0, Count=2, Weight=0.66},
            [2]={Type=5, Variant=20, SubType=0, Count=3, Weight=0.33},
            [3]={Type=5, Variant=20, SubType=0, Count=1, Weight=1},
            [4]={Type=5, Variant=mod.PICKUPS.GREENCOIN, SubType=0, Count=1, Weight=0.66},
            [5]={Type=5, Variant=mod.PICKUPS.GREENCOIN, SubType=0, Count=2, Weight=0.33},
            [6]={Type=5, Variant=300, SubType=mod.CONSUMABLES.SHARP_STICK, Count=1, Weight=0.5},
        },
    },
    [3] = { -- FORTUNE
        Type = "Machine",
        Sprite = "gfx/entities/slots/fortune.png",
        Overlay = Isaac.GetEntityVariantByName("Orb Glow"),
        PayoutChance = 0.2,
        BlockbumID = 3,
        Price = "Coin",
        MaxPayout = 25,
        PayoutItem = mod.ENUMS.ITEMS.PONDERING_ORB_DUMMY,
        DropTable = {
            [1]={Type=5, Variant=300, SubType=mod.CONSUMABLES.SHARP_STICK, Count=1, Weight=1},
            [2]={Type=5, Variant=300, SubType=mod.CONSUMABLES.GLASS_PENNY, Count=1, Weight=0.5},
            [3]={Type=5, Variant=300, SubType=mod.CONSUMABLES.BROKEN_DICE, Count=1, Weight=0.5},
            [4]={Type=5, Variant=300, SubType=mod.CONSUMABLES.WEIRD_GUMMY, Count=1, Weight=1},
            [5]={Type=5, Variant=300, SubType=mod.CONSUMABLES.FLOWERING_JADE, Count=1, Weight=0.2},
            [6]={Type=5, Variant=300, SubType=mod.CONSUMABLES.POTATO_MAGNET, Count=1, Weight=0.5},
        },
    },
    --BEGGARS--
    [4] = {Type = "Beggar", SubType=1},
    [5] = {Type = "Beggar", SubType=2},
    [6] = {Type = "Beggar", SubType=1},
    [7] = {Type = "Beggar", SubType=3},
    [9] = {Type = "Beggar", SubType=4},
    [13] = {Type = "Beggar", SubType=5},
    [15] = {Type = "Beggar", SubType=2},
    [18] = {Type = "Beggar", SubType=6},
}
local consumables = mod.CONSUMABLES
local varToId = {
    [consumables.SHARP_STICK]=2,
    [consumables.WEIRD_GUMMY]=3,
    [consumables.POTATO_MAGNET]=4,
    [consumables.BROKEN_DICE]=5,
    [consumables.GLASS_PENNY]=6,
    [consumables.FLOWERING_JADE]=7,
}
local idToVar = {
    [2]=consumables.SHARP_STICK,
    [3]=consumables.WEIRD_GUMMY,
    [4]=consumables.POTATO_MAGNET,
    [5]=consumables.BROKEN_DICE,
    [6]=consumables.GLASS_PENNY,
    [7]=consumables.FLOWERING_JADE,
}

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerInit(player)
    if(player:GetPlayerType()==greenCain) then
        if(player:GetActiveItem(2)~=greenSack and player:GetActiveItem(3)~=greenSack) then
            player:SetPocketActiveItem(greenSack, ActiveSlot.SLOT_POCKET, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

---@param player EntityPlayer
function funcs:onCache(player, flags)
    if(player:GetPlayerType()==greenCain) then
        if(flags&CacheFlag.CACHE_SPEED==CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.3
        end
        if(flags&CacheFlag.CACHE_DAMAGE==CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*1.2
        end
        if(flags&CacheFlag.CACHE_RANGE==CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange*(9/13)
        end
        if(flags&CacheFlag.CACHE_LUCK==CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck+1
        end
        if(flags&CacheFlag.CACHE_FLYING==CacheFlag.CACHE_FLYING) then
            if(player.CanFly) then
                player:AddNullCostume(flyingGreenCharCostume)
                player:TryRemoveNullCostume(greenCharCostume)
            else
                player:AddNullCostume(greenCharCostume)
                player:TryRemoveNullCostume(flyingGreenCharCostume)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.onCache)

function funcs:prePlayerCollision(player, collider, low)
    if(player:GetPlayerType()==greenCain) then
        if(collider.Type==6) then
            if(type(mod.MACHINES[collider.Variant])=="table") then
                if(collider:GetData().greenifyMachine==nil) then
                    collider:GetData().greenifyMachine = 15
                    collider:GetData().collidedPlayer = player
                end
            end
        end
        if(collider.Type==5 and collider.Variant==300) then
            if(type(varToId[collider.SubType])=="number" and player:GetData().usingSack==true) then
                if(collider:GetSprite():GetAnimation()=="Idle") then
                    local pickups = player:GetData().sackPickups
                    local id = -1
                    if(pickups[2]==0) then id=2
                    elseif(pickups[3]==0) then id=3
                    elseif(pickups[4]==0) then id=4 end
                    if(id==-1) then
                        local pickup = Isaac.Spawn(5,300,idToVar[pickups[2]],player.Position+Vector(0,20),Vector.Zero, player)
                        pickups[2]=pickups[3]
                        pickups[3]=pickups[4]
                        pickups[4]=varToId[collider.SubType]
                    else
                        pickups[id]=varToId[collider.SubType]
                    end
                end

                return true
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, funcs.prePlayerCollision, 0)

---@param tear EntityTear
function funcs:postIsaacFireTear(tear)
    local player = tear.SpawnerEntity:ToPlayer()
    if(not (player)) then return end
    if(player:GetPlayerType()==greenCain) then
        tear.Color = Color(0.2,0.6,0.5,1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postIsaacFireTear)

--- MONEY MAKING METHOD TWO ---
function funcs:preSpawnCleanAward(rng, spawnPos)
    local roomType = Game():GetLevel():GetCurrentRoomDesc().Data.Type
    if(roomType==5) then
        for _, player in ipairs(Isaac.FindByType(1,0)) do
            player=player:ToPlayer()
            if(player:GetPlayerType()==greenCain) then
                local data = player:GetData()
                for _=1, 7 do
                    local coin = Isaac.Spawn(5,20,1,Game():GetRoom():FindFreePickupSpawnPosition(spawnPos,0),Vector.Zero,player)
                end
                data.sackPickups[1] = data.sackPickups[1]+3
                player:AnimateCollectible(greenSack)
            end
        end
    end
    if(roomType==1) then
        local luck = (math.max(0,math.min(10,Isaac.GetPlayer().Luck)))
        local pickupSpawnChance = (rng:RandomFloat()*luck*0.1)+rng:RandomFloat()
        local cainCount = 0
        for _, player in ipairs(Isaac.FindByType(1,0)) do
            player=player:ToPlayer()
            if(player:GetPlayerType()==greenCain) then
                cainCount=cainCount+1

                if(pickupSpawnChance>0.22) then
                    if(rng:RandomFloat()<0.5) then
                        local greenCoin = Isaac.Spawn(5,20,mod.PICKUPS.GREENCOIN,Game():GetRoom():FindFreePickupSpawnPosition(spawnPos,0),Vector.Zero,nil)
                    end
                end
            end
        end
        if(cainCount>0) then return true end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, funcs.preSpawnCleanAward)

mod.CHARACTERS.CAIN = funcs