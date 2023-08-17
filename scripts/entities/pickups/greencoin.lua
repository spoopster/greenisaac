local mod = jezreelMod
local sfx = SFXManager()

local greencoinSub = mod.PICKUPS.GREENCOIN

local REPLACE_CHANCE = 0.05

local funcs = {}

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    --PICKUP REPLACEMENT
    if(pickup.SubType~=greencoinSub and mod.MARKS.CHARACTERS.CAIN.UltraGreedier==1) then
        local seed = pickup.InitSeed%(math.ceil(1/REPLACE_CHANCE))
        if(seed==0) then
            pickup:Morph(5,20,greencoinSub,true)
        end
    end
    if(pickup.SubType==greencoinSub and mod.MARKS.CHARACTERS.CAIN.UltraGreedier==0) then
        pickup:Morph(5,20,1,true)
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
        if(collider.Type~=1) then return nil end
        if(pickup:GetSprite():GetAnimation()~="Idle") then return true end

        local sprite = pickup:GetSprite()
        if(collider.Type==1) then
            if(sprite:GetAnimation()=="Idle") then
                collider:ToPlayer():AddCoins(pickup:GetDropRNG():RandomInt(4)-1)
                sprite:Play("Collect", true)
                sfx:Play(234)
                pickup.SpriteScale = Vector.Zero
            end
            return true
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