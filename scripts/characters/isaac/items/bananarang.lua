local mod = jezreelMod
local helper = include("scripts/func")

local greenD6 = mod.ENUMS.ITEMS.G6
local bananarang = mod.ENUMS.VEGETABLES.BANANARANG
local bananaVariant = Isaac.GetEntityVariantByName("Bananarang")

local BANANA_SPEED = 18

local funcs = {}

function funcs:useItem(_, rng, player, _, slot, _)
    local items = Isaac.FindByType(5,100)
    local data = player:GetData()

    local closest = helper:closestEnemy(player.Position)
    if(closest) then
        local angle = (closest.Position-player.Position):GetAngleDegrees()
        local nanas = player:GetData().spawnableBananas or 0
        for _=1, nanas do
            local banana = Isaac.Spawn(2, bananaVariant, slot, player.Position, Vector(BANANA_SPEED,0):Rotated(angle+rng:RandomFloat()*30-15), player):ToTear()
        end
        data.spawnableBananas = 0
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenD6)

function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    local hash = GetPtrHash(player)
    local spawnableNanas = player:GetCollectibleNum(bananarang)*3
    if(spawnableNanas~=0) then
        for i, nana in ipairs(Isaac.FindByType(2, bananaVariant)) do
            if(nana.SpawnerEntity and GetPtrHash(nana.SpawnerEntity)==hash) then
                spawnableNanas = spawnableNanas-1
            end
        end
        data.spawnableBananas = spawnableNanas
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:postTearUpdate(tear)
    --if(tear.Variant~=bananaVariant) then return end
    local player = tear.SpawnerEntity
    local data = tear:GetData()
    tear.SpriteRotation = tear.FrameCount*40
    if(data.prevVel and data.prevVel:GetAngleDegrees()~=tear.Velocity:GetAngleDegrees()) then
        local closest = helper:closestEnemy(tear.Position)
        if(closest) then
            local angle = (closest.Position-tear.Position):GetAngleDegrees()
            local velAngle = tear.Velocity:GetAngleDegrees()

            if((angle+360)%360>(velAngle+360)%360+15) then
                angle = velAngle+15
            end
            if((angle+360)%360<(velAngle+360)%360-15) then
                angle = velAngle-15
            end
            tear.Velocity = Vector(15,0):Rotated(angle)
        else
            tear.Velocity = tear.Velocity:Rotated(tear:GetDropRNG():RandomFloat()*20-10)
        end
    end
    if(data.slot<=ActiveSlot.SLOT_POCKET2 and tear.FrameCount>30) then
        if(player) then
            local players = Isaac.FindInRadius(tear.Position, tear.Size+15, 32)
            local playerHash = GetPtrHash(player)
            for i, pl in ipairs(players) do
                if(GetPtrHash(pl)==playerHash) then
                    pl = pl:ToPlayer()
                    local item = pl:GetActiveItem(data.slot)
                    if(item~=0) then
                        local config = Isaac.GetItemConfig():GetCollectible(item)

                        if(pl:GetBatteryCharge(data.slot)==0) then pl:SetActiveCharge(config.MaxCharges, data.slot) end
                    end
                    tear:Remove()
                end
            end
        end
    end
    data.prevVel = tear.Velocity
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate, bananaVariant)

---@param tear EntityTear
function funcs:postTearInit(tear)
    local data = tear:GetData()
    local spawner = tear.SpawnerEntity
    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
    tear.TearFlags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_BOUNCE
    tear:GetSprite():Load("gfx/entities/tears/banana/bananarang.anm2", true)
    tear:GetSprite():Play("Spin", true)

    if(spawner and spawner.Type==EntityType.ENTITY_TEAR) then
        tear.CollisionDamage = spawner.CollisionDamage
    elseif(spawner and spawner.Type==EntityType.ENTITY_PLAYER) then
        tear.CollisionDamage = spawner:ToPlayer().Damage/2
    else
        tear.CollisionDamage = 3
    end

    data.prevVel = tear.Velocity
    data.poppedTear = true
    data.slot = tear.SubType

    if(tear.SubType>ActiveSlot.SLOT_POCKET2) then tear.FallingAcceleration = -0.09 end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, funcs.postTearInit, bananaVariant)

function funcs:postTearRemove(tear)
    if(tear.Variant~=bananaVariant) then return end
    tear = tear:ToTear()

    local tear2 = Isaac.Spawn(2,0,0,tear.Position+tear.Velocity,Vector.Zero,nil):ToTear()
    tear2.Height = tear.Height
    local col = Color(1,1,1,1,0,0,0)
    col:SetColorize(1,1,0.2,1)
    tear2.Color = col

    tear2:Die()
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postTearRemove, EntityType.ENTITY_TEAR)

-- CURSED GRAPES SYNERGY --
local GRAPE_NANNER_CHANCE = 2/3
local GRAPE_NANNER_NUM = 2

local cursedGrapes = mod.ENUMS.VEGETABLES.CURSED_GRAPES
function funcs:postNewRoomGrapes()
    if(helper:isRoomClear()) then return end
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local rng = player:GetCollectibleRNG(cursedGrapes)

        local chance = (1-GRAPE_NANNER_CHANCE)^(player:GetCollectibleNum(cursedGrapes))

        if(rng:RandomFloat()>chance and player:HasCollectible(cursedGrapes) and player:HasCollectible(bananarang)) then
            for j=1, GRAPE_NANNER_NUM*player:GetCollectibleNum(bananarang) do
                local vel = Vector.FromAngle(rng:RandomFloat()*360)*BANANA_SPEED
                local banana = Isaac.Spawn(2, bananaVariant, 0, player.Position, vel, nil):ToTear()
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoomGrapes)

mod.ITEMS.BANANARANG = funcs