local mod = jezreelMod

local broccoliMan = mod.ENUMS.VEGETABLES.BROCCOLI_MAN
local broccoliVariant = Isaac.GetEntityVariantByName("Broccoli Man")
local funcs = {}

function funcs:familiarInit(familiar)
    local room = Game():GetRoom()
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()
    sprite:Play("Idle", true)
    familiar.SpriteOffset = Vector(-1,1)
    data.broccoliCollisionCool = 0
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, broccoliVariant)

function funcs:familiarUpdate(familiar)
    local data = familiar:GetData()
    familiar.Velocity = familiar.Velocity*0.8
    if(data.broccoliCollisionCool>0) then
        data.broccoliCollisionCool=data.broccoliCollisionCool-1
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, broccoliVariant)

function funcs:peffectUpdate(player)
    local broccoliNum = player:GetCollectibleNum(broccoliMan)+player:GetEffects():GetCollectibleEffectNum(broccoliMan)
	player:CheckFamiliar(broccoliVariant,broccoliNum,player:GetCollectibleRNG(broccoliMan),Isaac.GetItemConfig():GetCollectible(broccoliMan))
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, funcs.peffectUpdate)

function funcs:familiarCollision(familiar, collider, low)
    local data = familiar:GetData()
    if(collider:IsVulnerableEnemy() and data.broccoliCollisionCool==0) then
        collider:TakeDamage(3, 0, EntityRef(familiar.Player), 0)
        data.broccoliCollisionCool=10
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.familiarCollision, broccoliVariant)

function funcs:postNewRoom()
    local room = Game():GetRoom()

    local broccoliMen = Isaac.FindByType(3, broccoliVariant)
    for i, man in ipairs(broccoliMen) do
        local spawnPos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(10),0,true,false)
        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, spawnPos, Vector.Zero, man)
        pickup = pickup:ToPickup()
        pickup.AutoUpdatePrice = false
        pickup.Price = 1000
        pickup.Visible = false
        pickup:GetData().broccoliPickup = true
        man.Position = spawnPos
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

---@param pickup EntityPickup
function funcs:postPickupUpdate(pickup)
    if(pickup:GetData().broccoliPickup==true and pickup.FrameCount==3) then
        pickup:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate)

mod.ITEMS.BROCCOLIMAN = funcs