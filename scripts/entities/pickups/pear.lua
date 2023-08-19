local mod = jezreelMod
local sfx = SFXManager()
local helper = include("scripts/func")

local pearVariant = mod.PICKUPS.PEAR
local confusingPear = mod.ENUMS.VEGETABLES.CONFUSING_PEAR
local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)
local greenIsaac = Isaac.GetPlayerTypeByName("Green Isaac", false)

local REPLACE_CHANCE = 0.01

local funcs = {}

local function isAnyPlayerGreen()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        local t=player:ToPlayer():GetPlayerType()
        if(t==greenCain or t==greenIsaac) then return true end
    end
    return false
end

local function isValidToPear(pickup)
    return (type(mod.PEAR_BLACKLIST[pickup.Variant])~="table" and mod.PEAR_BLACKLIST[pickup.Variant]~=false) or (type(mod.PEAR_BLACKLIST[pickup.Variant])=="table" and mod.PEAR_BLACKLIST[pickup.Variant][pickup.SubType]~=false)
end

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    if(pickup.Variant==pearVariant and (mod.MARKS.CHARACTERS.CAIN.A.BlueBaby==0 and not isAnyPlayerGreen())) then
        while(not isValidToPear(pickup)) do
            pickup:Morph(5,0,0,true,false,true)
        end
    end

    --PICKUP REPLACEMENT
    if(pickup.Variant~=pearVariant and not pickup:IsShopItem() and mod.MARKS.CHARACTERS.CAIN.A.BlueBaby==1) then
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
            local roll = pickup:GetDropRNG():RandomFloat()*100
            local subRoll = pickup:GetDropRNG():RandomFloat()*100
            isOk=true
            if(roll<=22.411) then
                if(player:CanPickRedHearts() and subRoll<=41.27) then
                    player:AddHearts(3)
                    sfx:Play(185)
                elseif(player:CanPickRedHearts() and subRoll<=82.59) then
                    player:AddHearts(1)
                    sfx:Play(185)
                elseif(player:CanPickSoulHearts() and subRoll<=89.2) then
                    player:AddSoulHearts(2)
                    if(player:GetHearts()>=1) then player:AddHearts(-1) end
                    sfx:Play(54)
                elseif(subRoll<=90.88) then
                    player:AddEternalHearts(1)
                    sfx:Play(266)
                elseif(player:CanPickRedHearts() and subRoll<=92.64) then
                    player:AddHearts(6)
                    sfx:Play(185)
                elseif(player:CanPickBlackHearts() and subRoll<=93.17) then
                    player:AddBlackHearts(1)
                    sfx:Play(468)
                elseif(player:CanPickGoldenHearts() and subRoll<=93.75) then
                    player:AddGoldenHearts(2)
                    sfx:Play(465)
                elseif(player:CanPickSoulHearts() and subRoll<=95.93) then
                    player:AddSoulHearts(1)
                    if(player:CanPickRedHearts()) then
                        player:AddHearts(1)
                        sfx:Play(185)
                    end
                    sfx:Play(54)
                elseif(player:CanPickBlackHearts() and subRoll<=96.83) then
                    player:AddBlackHearts(2)
                    sfx:Play(468)
                elseif((player:CanPickRedHearts() or player:CanPickBlackHearts()) and subRoll<=97.67) then
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
                elseif(player:CanPickBoneHearts() and subRoll<=98.18) then
                    player:AddBoneHearts(1)
                    sfx:Play(461)
                    if(player:CanPickRedHearts()) then
                        player:AddHearts(1)
                        sfx:Play(185)
                    end
                elseif(player:CanPickRottenHearts()) then
                    player:AddRottenHearts(1)
                    sfx:Play(497)
                    if(player:CanPickSoulHearts()) then
                        player:AddSoulHearts(1)
                        sfx:Play(54)
                    end
                else
                    isOk=false
                end
            elseif(roll<=51.752) then
                if(subRoll<=92.66) then
                    player:AddCoins(1)
                    sfx:Play(234)
                elseif(subRoll<=97.51) then
                    player:AddCoins(4)
                    sfx:Play(232)
                elseif(subRoll<=98.35) then
                    player:AddCoins(11)
                    sfx:Play(199)
                elseif(subRoll<=99.27) then
                    player:AddCoins(2)
                    player:DonateLuck(1)
                    sfx:Play(200)
                elseif(subRoll<=99.55) then
                    player:AddCoins(6)
                    local troll = Isaac.Spawn(4,3,0, pickup.Position, Vector.Zero, pickup)
                    sfx:Play(232)
                else
                    player:AddCoins(5+pickup:GetDropRNG():RandomInt(16))
                    sfx:Play(199)
                end
            elseif(roll<=74.869) then
                if(subRoll<=96.16) then
                    player:AddKeys(1)
                    sfx:Play(58)
                elseif(subRoll<=98.04) then
                    player:AddGoldenKey()
                    if(player:GetNumKeys()>=1) then player:AddKeys(-1) end
                    sfx:Play(204)
                else
                    player:AddKeys(1)
                    helper:addBatteryCharge(player, 6)
                    sfx:Play(58)
                end
            elseif(roll<=97.123) then
                if(subRoll<=75.18) then
                    player:AddBombs(1)
                    sfx:Play(201)
                elseif(subRoll<=87.46) then
                    player:AddBombs(3)
                    sfx:Play(201)
                elseif(subRoll<=97.29) then
                    local troll = Isaac.Spawn(4,3,0, pickup.Position, Vector.Zero, pickup)
                elseif(subRoll<=98.17) then
                    player:AddGoldenBomb()
                    player:AddBombs(1)
                    sfx:Play(470)
                elseif(subRoll<=99.88) then
                    local troll = Isaac.Spawn(4,4,0, pickup.Position, Vector.Zero, pickup)
                else
                    local troll = Isaac.Spawn(4,18,0, pickup.Position, Vector.Zero, pickup)
                end
            else
                if(subRoll<=16.56) then
                    isOk=helper:addBatteryCharge(player, 6)
                elseif(subRoll<=99) then
                    isOk=helper:addBatteryCharge(player, 2)
                else
                    isOk = false
                    for j=0,3 do
                        if(player:GetActiveItem(j)~=0) then
                            player:SetActiveCharge(99, j)
                            isOk=true
                        end
                    end
                end
            end
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