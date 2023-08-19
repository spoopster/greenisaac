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
    if(pickup.SubType~=greencoinSub and mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier==1) then
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

---@param pickup EntityPickup
---@param collider Entity
function funcs:prePickupCollision(pickup, collider, low)
    if(pickup.SubType==greencoinSub) then
        if(pickup.Wait>0) then return true end
        if(collider.Type==5) then return false end

        if(collider.Type==1 or (collider.Type==3 and BUMS[collider.Variant]==true)) then
            if(pickup:GetSprite():GetAnimation()~="Idle") then return true end

            local player = collider:ToPlayer()
            local familiar = collider:ToFamiliar()

            local sprite = pickup:GetSprite()
            if(player) then
                if(sprite:GetAnimation()=="Idle") then
                    player:AddCoins(pickup:GetDropRNG():RandomInt(4)-1)
                    sprite:Play("Collect", true)
                    sfx:Play(234)
                    pickup.SpriteScale = Vector.Zero
                end
                return true
            elseif(familiar) then
                if(sprite:GetAnimation()=="Idle") then
                    familiar.Coins = math.max(0, familiar.Coins+pickup:GetDropRNG():RandomInt(4)-1)
                    sprite:Play("Collect", true)
                    sfx:Play(234)
                    pickup.SpriteScale = Vector.Zero
                end
                return true
            end
        end
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