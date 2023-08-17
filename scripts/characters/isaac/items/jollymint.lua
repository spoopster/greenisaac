local mod = jezreelMod
local h = include("scripts/func")

local jollyMint = mod.ENUMS.VEGETABLES.JOLLY_MINT
local iceVariant = Isaac.GetEntityTypeByName("Jolly Ice")

local funcs = {}

function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    if(player:HasCollectible(jollyMint)) then
        if(tear:GetDropRNG():RandomFloat()>0.75) then
            tear:AddTearFlags(TearFlags.TEAR_SLOW)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

function funcs:entityTakeDMG(entity,amount,flags,source,frames)
    return false
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, iceVariant)

function funcs:spawnIce(entity, amount, flags, source, frames)
    local player = source.Entity
    if(not (player and ((player.SpawnerEntity and player.SpawnerEntity:ToPlayer()) or player:ToPlayer()))) then return nil end

    if(player:ToPlayer()) then player=player:ToPlayer()
    else player = player.SpawnerEntity:ToPlayer() end

    if(not (h:isValidEnemy(entity))) then return nil end

    if(entity.HitPoints>amount) then return nil end
    if(entity.Type==iceVariant) then return nil end
    if(player:GetCollectibleNum(jollyMint)<=0) then return nil end

    local iceBlock = Isaac.Spawn(iceVariant, 0, 0, entity.Position, Vector.Zero, player):ToNPC()
    iceBlock.CanShutDoors = false
    if(iceBlock:GetDropRNG():RandomInt(2)==0) then
        iceBlock:GetSprite():Play("Spawn2")
        iceBlock:GetSprite().PlaybackSpeed = (math.random(30) + 80)/50
    else
        iceBlock:GetSprite():Play("Spawn3")
        iceBlock:GetSprite().PlaybackSpeed = (math.random(30) + 80)/50
    end
    iceBlock:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    iceBlock:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
    iceBlock.Parent = player

end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.spawnIce)

function funcs:npcUpdate(npc)
    local sprite = npc:GetSprite()
    if(npc.ProjectileCooldown>0) then
        npc.ProjectileCooldown = npc.ProjectileCooldown-1
    end

    --[[if npc:HasMortalDamage() then
        local icePoof = Isaac.Spawn(1000, 145, 0, npc.Position, Vector.Zero, npc.Parent)
        icePoof.Color = Color(1,1,1,1,0.25,0.25,0.3)
        icePoof.SpriteScale = Vector(1,1)*1.2
        npc:Remove()
        SFXManager():Play(498, 1, 2, false, 1, 0)
        SFXManager():Play(496, 1, 2, false, 1, 0)
    end]]
    if sprite:IsFinished(sprite:GetAnimation()) then
        local bullets = Isaac.FindInRadius(npc.Position, npc.Size, EntityPartition.BULLET)
        for _, bullet in ipairs(bullets) do bullet:Die() end

        if(npc.ProjectileCooldown==0) then
            local player = npc.SpawnerEntity:ToPlayer()

            local stackBonus = (1.5^((player:GetCollectibleNum(jollyMint))-1))
            local enemies = Isaac.FindInRadius(npc.Position, npc.Size*stackBonus, EntityPartition.ENEMY)
            for _, enemy in ipairs(enemies) do
                if(enemy.Type~=iceVariant) then
                    enemy:TakeDamage(player.Damage/3*stackBonus, 0, EntityRef(npc),10)
                    npc.ProjectileCooldown = 15
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, funcs.npcUpdate, iceVariant)

function funcs:preNpcCollision(npc, collider, low)
    if(collider.Type==1) then return true end
    if(collider.Type==EntityType.ENTITY_TEAR) then return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, funcs.preNpcCollision, iceVariant)

function funcs:preTearCollision(tear, collider, low)
    if(collider.Type==iceVariant) then return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, funcs.preTearCollision)

mod.ITEMS.JOLLYMINT = funcs