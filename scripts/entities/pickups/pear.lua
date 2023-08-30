local mod = jezreelMod
local sfx = SFXManager()
local helper = include("scripts/func")

local pearVariant = mod.PICKUPS.PEAR
local confusingPear = mod.ENUMS.VEGETABLES.CONFUSING_PEAR
local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)
local greenIsaac = Isaac.GetPlayerTypeByName("Green Isaac", false)

local REPLACE_CHANCE = 0.01

local pearDrops = {
    {
        Weight=22.5,
        Drops={
            {Weight=41.2, Sfx=185, Condition=function(player) return player:CanPickRedHearts() end, Effect=function(player) -- RED HEART FULL
                player:AddHearts(3)
            end},
            {Weight=41.2, Sfx=185, Condition=function(player) return player:CanPickRedHearts() end, Effect=function(player) -- RED HEART HALF
                player:AddHearts(1)
            end},
            {Weight=6.6, Sfx=54, Condition=function(player) return player:CanPickSoulHearts() end, Effect=function(player)  -- SOUL HEART
                player:AddSoulHearts(2)
                if(player:GetHearts()>=1) then player:AddHearts(-1) end
            end},
            {Weight=1.7, Sfx=266, Effect=function(player) -- ETERNAL HEART
                player:AddEternalHearts(1)
            end},
            {Weight=1.8, Sfx=185, Condition=function(player) return player:CanPickRedHearts() end, Effect=function(player) -- DOUBLE RED HEART
                player:AddHearts(6)
            end},
            {Weight=0.5, Sfx=468, Condition=function(player) return player:CanPickBlackHearts() end, Effect=function(player) -- BLACK HEART
                player:AddBlackHearts(1)
            end},
            {Weight=0.4, Sfx=266, Condition=function(player) return player:CanPickGoldenHearts() end, Effect=function(player) -- GOLDEN HEART
                player:AddGoldenHearts(2)
            end},
            {Weight=2.1, Sfx=54, Condition=function(player) return player:CanPickSoulHearts() end, Effect=function(player) -- HALF SOUL HEART
                player:AddSoulHearts(1)
                if(player:CanPickRedHearts()) then
                    player:AddHearts(1)
                    sfx:Play(185)
                end
            end},
            {Weight=0.9, Sfx=468, Condition=function(player) return player:CanPickBlackHearts() end, Effect=function(player) -- BLACK HEART 2
                player:AddBlackHearts(2)
            end},
            {Weight=0.8, Condition=function(player) return player:CanPickRedHearts() or player:CanPickBlackHearts() end, Effect=function(player) -- BLENDED HEART
                if(player:GetHearts()<=player:GetEffectiveMaxHearts()-2) then
                    player:AddHearts(2)
                    sfx:Play(185)
                elseif(player:GetHearts()==player:GetEffectiveMaxHearts()-1) then
                    player:AddHearts(1)
                    player:AddBlackHearts(1)
                    sfx:Play(185)
                    sfx:Play(468)
                else
                    player:AddBlackHearts(2)
                    sfx:Play(468)
                end
            end},
            {Weight=0.5, Sfx=461, Condition=function(player) return player:CanPickBoneHearts() end, Effect=function(player) -- BONE HEART
                player:AddBoneHearts(1)
                if(player:CanPickRedHearts()) then
                    player:AddHearts(1)
                    sfx:Play(185)
                end
            end},
            {Weight=1.8, Sfx=497, Condition=function(player) return player:CanPickRottenHearts() end, Effect=function(player) -- ROTTEN HEARTS
                player:AddRottenHearts(1)
                if(player:CanPickSoulHearts()) then
                    player:AddSoulHearts(1)
                    sfx:Play(54)
                end
            end},
        },
    },
    {
        Weight=29.4,
        Drops={
            {Weight=92.6, Sfx=234, Effect=function(player) -- PENNY
                player:AddCoins(1)
            end},
            {Weight=4.9, Sfx=232, Effect=function(player) -- NICKEL
                player:AddCoins(4)
            end},
            {Weight=1, Sfx=199, Effect=function(player) -- DIME
                player:AddCoins(11)
            end},
            {Weight=0.9, Sfx=200, Effect=function(player) -- LUCKY PENNY
                player:AddCoins(2)
                player:DonateLuck(1)
            end},
            {Weight=0.3, Sfx=232, Effect=function(player) -- STICKY NICKEL
                player:AddCoins(6)
                Isaac.Spawn(4,3,0, player.Position, Vector.Zero, player)
            end},
            {Weight=0.5, Sfx=199, Effect=function(player) -- GOLDEN PENNY
                player:AddCoins(5+player:GetCollectibleRNG(confusingPear):RandomInt(16))
            end},
        },
    },
    {
        Weight=23.1,
        Drops={
            {Weight=96.1, Sfx=58, Effect=function(player) -- KEY
                player:AddKeys(1)
            end},
            {Weight=1.9, Sfx=204, Effect=function(player) -- GOLDEN KEY
                player:AddGoldenKey()
                if(player:GetNumKeys()>=1) then player:AddKeys(-1) end
            end},
            {Weight=2, Sfx=58, Effect=function(player) -- CHARGED KEY
                player:AddKeys(1)
                helper:addBatteryCharge(player, 6)
            end},
        },
    },
    {
        Weight=22.3,
        Drops={
            {Weight=75.2, Sfx=201, Effect=function(player) -- BOMB
                player:AddBombs(1)
            end},
            {Weight=12.3, Sfx=201, Effect=function(player) -- DOUBLE BOMB
                player:AddBombs(3)
            end},
            {Weight=10, Effect=function(player) -- TROLL BOMB
                Isaac.Spawn(4,3,0, player.Position, Vector.Zero, player)
            end},
            {Weight=0.9, Sfx=470, Effect=function(player) -- GOLDEN BOMB
                player:AddGoldenBomb()
                player:AddBombs(1)
            end},
            {Weight=1.7, Effect=function(player) -- SUPERTROLL BOMB
                Isaac.Spawn(4,4,0, player.Position, Vector.Zero, player)
            end},
            {Weight=0.1, Effect=function(player) -- GOLDEN TROLL BOMB
                Isaac.Spawn(4,18,0, player.Position, Vector.Zero, player)
            end},
        },
    },
    {
        Weight=23.1,
        Drops={
            {Weight=16.6, Effect=function(player) -- LIL BATTERY
                return helper:addBatteryCharge(player, 6)
            end},
            {Weight=82.5, Effect=function(player) -- MICRO BATTERY
                return helper:addBatteryCharge(player, 2)
            end},
            {Weight=1, Sfx=58, Effect=function(player) -- GIGA BATTERY
                local isOk = false
                for j=0,3 do
                    if(player:GetActiveItem(j)~=0) then
                        player:SetActiveCharge(99, j)
                        isOk=true
                    end
                end

                return isOk
            end},
        },
    },
}

local funcs = {}

local function getRandomPearDropType(pickup)
    local rng = pickup:GetDropRNG()

    local typeWeight = 0
    for _, t in ipairs(pearDrops) do typeWeight=typeWeight+t.Weight end
    local selWeight = rng:RandomFloat()*typeWeight
    local curWeight = 0

    for _, t in ipairs(pearDrops) do
        curWeight=curWeight+t.Weight
        if(selWeight<curWeight) then return t end
    end
end

local function getRandomPearDrop(player, pickup)
    local rng = pickup:GetDropRNG()

    local t = getRandomPearDropType(pickup)

    local maxWeight = 0
    for _, drop in ipairs(t.Drops) do maxWeight=maxWeight+drop.Weight end
    local selWeight = rng:RandomFloat()*maxWeight
    local curWeight = 0

    for _, drop in ipairs(t.Drops) do
        curWeight=curWeight+drop.Weight
        if(selWeight<curWeight) then return drop end
    end
end

local function isAnyPlayerGreen()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        local t=player:ToPlayer():GetPlayerType()
        if(t==greenCain or t==greenIsaac) then return true end
    end
    return false
end

local function isValidToPear(pickup)
    if(mod.PEAR_WHITELIST[pickup.Variant]~=true) then return false end
    if(mod.PEAR_BLACKLIST[pickup.Variant] and mod.PEAR_BLACKLIST[pickup.Variant][pickup.SubType]==true) then return true end

    return true
end

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    if(pickup.Variant==pearVariant and not (mod.MARKS.CHARACTERS.CAIN.A.BlueBaby~=0 or isAnyPlayerGreen() or helper:anyPlayerHas(mod.ENUMS.VEGETABLES.CONFUSING_PEAR))) then
        while(not isValidToPear(pickup)) do
            pickup:Morph(5,0,0,true,false,true)
        end
    end

    --PICKUP REPLACEMENT
    if(pickup.Variant~=pearVariant and not pickup:IsShopItem() and mod.MARKS.CHARACTERS.CAIN.A.BlueBaby~=0) then
        if(isValidToPear(pickup)) then
            local seed = pickup.InitSeed%(math.ceil(1/REPLACE_CHANCE))
            if(seed==0) then
                local shopId = pickup.ShopItemId
                pickup:Morph(5,pearVariant,0,true,false,true)
                pickup.ShopItemId = shopId
            end
        end
    end

    if(pickup.Variant==pearVariant) then
        pickup:GetSprite():Load("gfx/entities/pickups/pear/pear.anm2", true)
        pickup:GetSprite():Play("Idle", true)
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit)

---@param pickup EntityPickup
function funcs:postPickupUpdate(pickup)
    if(pickup:GetSprite():IsFinished("Collect")) then
        pickup:Die()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, pearVariant)

---@param pickup EntityPickup
---@param collider Entity
function funcs:prePickupCollision(pickup, collider, low)
    if(pickup.Wait>0) then return true end
    if(collider.Type==5) then return false end
    if(collider.Type~=1) then return true end
    if(pickup:GetSprite():GetAnimation()~="Idle") then return true end

    for i=1, math.max(helper:allPlayersCollNum(confusingPear), 1) do
        local isOk = false
        local player = collider:ToPlayer()
        while(isOk==false) do
            local drop = getRandomPearDrop(player, pickup)

            if(drop.Condition and drop.Condition(player)==false) then
                isOk=false
                goto invalidDrop
            end
            do
                local ok = drop.Effect(player)
                isOk=true
                if(ok~=nil) then isOk=ok end
                if(drop.Sfx) then sfx:Play(drop.Sfx) end
            end
            ::invalidDrop::
        end
    end
    pickup:GetSprite():Play("Collect", true)
    pickup.SpriteScale = Vector.Zero
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, pearVariant)

function funcs:postPickupRender(pickup, offset)
    if(pickup:GetSprite():GetAnimation()=="Collect") then
        pickup.SpriteScale = Vector(1,1)
        pickup:GetSprite():Render(Isaac.WorldToRenderPosition(pickup.Position)+offset)
        pickup.SpriteScale = Vector.Zero
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, pearVariant)

mod.ENTITIES.PICKUPS.PEAR = funcs