local mod = jezreelMod
local sfx = SFXManager()

local greencoinSub = mod.PICKUPS.GREENCOIN
local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)

local REPLACE_CHANCE = 0.05

local BUMS = {
    [FamiliarVariant.BUM_FRIEND]=true,
	[FamiliarVariant.BUMBO]=true,
	[FamiliarVariant.SUPER_BUM]=true,
}

local funcs = {}

local function isAnyPlayerGreenCain()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:GetPlayerType()==greenCain) then return true end
    end
    return false
end

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    if(pickup.SubType==greencoinSub and (mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier==0 and not isAnyPlayerGreenCain())) then
        pickup:Morph(5,20,1,true)
    end

    --PICKUP REPLACEMENT
    if(pickup.SubType~=greencoinSub and mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier~=0) then
        local seed = pickup.InitSeed%(math.ceil(1/REPLACE_CHANCE))
        if(seed==0) then
            pickup:Morph(5,20,greencoinSub,true)
        end
    end

    if(pickup.SubType==greencoinSub) then
        pickup:GetSprite():Play("Appear", true)
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 20)

---@param pickup EntityPickup
function funcs:postPickupUpdate(pickup)
    if(pickup.SubType==greencoinSub) then
        local sprite = pickup:GetSprite()
        if(sprite:IsFinished("Collect")) then pickup:Remove() end
        if(sprite:IsFinished("Appear")) then sprite:Play("Idle", true) end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 20)

local function playerCollLogic(pickup, collider)
    if(collider.Type~=1) then return end

    local player = collider:ToPlayer()

    local sprite = pickup:GetSprite()

    local rng = pickup:GetDropRNG()
    local coinsToAdd = rng:RandomInt(4)-1
    local room = Game():GetRoom()

    player:AddCoins(coinsToAdd)
    sprite:Play("Collect", true)
    sfx:Play(234)
    pickup.SpriteScale = Vector.Zero

    if(player:HasTrinket(TrinketType.TRINKET_BLOODY_PENNY) and rng:RandomFloat()>0.75^coinsToAdd) then
        local heart = Isaac.Spawn(5,10,2,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_BURNT_PENNY) and rng:RandomFloat()>0.75^coinsToAdd) then
        local bomb = Isaac.Spawn(5,40,1,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_BUTT_PENNY)) then
        Game():Fart(player.Position)
    end
    if(player:HasTrinket(TrinketType.TRINKET_COUNTERFEIT_PENNY) and rng:RandomFloat()>0.5^coinsToAdd) then
        player:AddCoins(1)
    end
    if(player:HasTrinket(TrinketType.TRINKET_FLAT_PENNY) and rng:RandomFloat()>0.75^coinsToAdd) then
        local key = Isaac.Spawn(5,30,1,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_ROTTEN_PENNY)) then
        player:AddBlueFlies(1, player.Position, player)
    end
    if(player:HasTrinket(TrinketType.TRINKET_BLESSED_PENNY) and rng:RandomFloat()>(5/6)^coinsToAdd) then
        local soul = Isaac.Spawn(5,10,8,room:FindFreePickupSpawnPosition(pickup.Position,0),Vector.Zero,pickup)
    end
    if(player:HasTrinket(TrinketType.TRINKET_CHARGED_PENNY) and player:NeedsCharge() and rng:RandomFloat()<coinsToAdd/6) then
        local charge = player:GetActiveCharge()
        player:SetActiveCharge(charge + 1)
    end
    if(player:HasTrinket(TrinketType.TRINKET_CURSED_PENNY) and not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, UseFlag.USE_NOANIM)
    end
end

local function familiarCollLogic(pickup, collider)
    if(not (collider.Type==3 and BUMS[collider.Variant]==true)) then return end

    local familiar = collider:ToFamiliar()

    local sprite = pickup:GetSprite()

    local rng = pickup:GetDropRNG()
    local coinsToAdd = rng:RandomInt(4)-1

    familiar.Coins = math.max(0, familiar.Coins+coinsToAdd)
    sprite:Play("Collect", true)
    sfx:Play(234)
    pickup.SpriteScale = Vector.Zero
end

local function uGreedCollLogic(pickup, collider)
    if(not (collider.Type==406)) then return end

    local sprite = pickup:GetSprite()

    local rng = pickup:GetDropRNG()
    local coinsToAdd = rng:RandomInt(4)-1

    sprite:Play("Collect", true)
    sfx:Play(234)
    pickup.SpriteScale = Vector.Zero

    collider:AddHealth(coinsToAdd*4.375)
end

---@param pickup EntityPickup
---@param collider Entity
function funcs:prePickupCollision(pickup, collider, low)
    if(pickup.SubType==greencoinSub) then
        if(pickup.Wait>0) then return true end
        if(collider.Type==5) then return false end

        if(pickup:GetSprite():GetAnimation()~="Idle") then return true end

        playerCollLogic(pickup, collider)
        familiarCollLogic(pickup, collider)
        uGreedCollLogic(pickup, collider)

        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 20)

function funcs:postPickupRender(pickup, offset)
    if(pickup.SubType==greencoinSub) then
        if(pickup:GetSprite():GetAnimation()=="Collect") then
            pickup.SpriteScale = Vector(1,1)
            pickup:GetSprite():Render(Isaac.WorldToRenderPosition(pickup.Position)+offset)
            pickup.SpriteScale = Vector.Zero
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 20)

mod.ENTITIES.PICKUPS.GREENCOIN = funcs