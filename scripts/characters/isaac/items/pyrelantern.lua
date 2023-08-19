local mod = jezreelMod
local h = include("scripts/func")
local fj = include("scripts/firejet")

local pyreLantern = mod.ENUMS.VEGETABLES.PYRE_LANTERN
local pyreVariant = Isaac.GetEntityVariantByName("Pyre Lantern")

local LANTERN_NUM = 3
local LANTERN_GEYSER_NUM = 10
local LANTERN_GEYSER_SPEED = 3

local LANTERN_JET_DAMAGE = 5

local funcs = {}

---@param familiar EntityFamiliar
function funcs:familiarInit(familiar)
    local room = Game():GetRoom()
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()
    sprite:Play("Idle", true)
    --familiar.SpriteOffset = Vector(-1,1)
    familiar.Velocity = Vector.Zero
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, pyreVariant)

---@param familiar EntityFamiliar
function funcs:familiarUpdate(familiar)
    familiar.Velocity = Vector.Zero
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, pyreVariant)

function funcs:familiarCollision(familiar, collider, low)
    local data = familiar:GetData()
    if((collider.Type==1 and GetPtrHash(collider)==GetPtrHash(familiar.Player)) or h:isValidEnemy(collider)) then
        local player = familiar.Player
        local rng = player:GetCollectibleRNG(pyreLantern)
        local birthrightMod = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

        Isaac.Explode(familiar.Position, player, ((birthrightMod and 25) or 15))

        for i=1, LANTERN_GEYSER_NUM do
            local vel = Vector.FromAngle(rng:RandomFloat()*360)*LANTERN_GEYSER_SPEED*(rng:RandomFloat()*0.5+0.5)
            local tear = player:FireTear(player.Position, vel, true, true, false, player)

            tear.FallingSpeed = -20
            tear.FallingAcceleration = 1.5
            tear.TearFlags = TearFlags.TEAR_NORMAL
            tear.CollisionDamage = ((birthrightMod and 6) or 3.5)
            tear.Scale = rng:RandomFloat()*0.5+0.5

            tear.Color = Color(0.6,0.3,0,1,0,0,0)
            tear.Position = familiar.Position
        end

        for i=0,3 do
            local jet = fj:spawnFireJet(player, LANTERN_JET_DAMAGE*((birthrightMod and 1.5) or 1), familiar.Position, 5, 45, 3, i*90, nil, nil)
            jet:GetData().fjIsPlayerFriendly = true
        end

        familiar:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.familiarCollision, pyreVariant)

function funcs:postNewRoom()
    local room = Game():GetRoom()

    for _, pyre in ipairs(Isaac.FindByType(3,pyreVariant)) do
        pyre:Remove()
    end

    if(h:isRoomClear()) then return end

    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        for i=1, player:GetCollectibleNum(pyreLantern)*LANTERN_NUM do
            local spawnPos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(10),0,true,false)

            local pyre = Isaac.Spawn(3,pyreVariant,0,spawnPos,Vector.Zero,player):ToFamiliar()
            pyre:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

            local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, 10, 0, spawnPos, Vector.Zero, pyre)
            pickup = pickup:ToPickup()
            pickup.AutoUpdatePrice = false
            pickup.Price = 1000
            pickup.Visible = false
            pickup.Timeout = 1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ITEMS.PYRELANTERN = funcs