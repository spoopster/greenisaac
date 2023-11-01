local mod = jezreelMod

local waxGourd = mod.ENUMS.VEGETABLES.BEESWAX_GOURD

local LOCUSTS_SPAWNED_IN1_FRAME = 0
local MAX_LOCUSTS = 15

local funcs = {}

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    local player = source.Entity
    if(player and ((player.SpawnerEntity and player.SpawnerEntity:ToPlayer()) or player:ToPlayer())) then
        if(player:ToPlayer()) then player=player:ToPlayer()
        else player = player.SpawnerEntity:ToPlayer() end
        if(entity.HitPoints<=amount and entity:IsVulnerableEnemy()) then
            if(player:HasCollectible(waxGourd) and LOCUSTS_SPAWNED_IN1_FRAME<MAX_LOCUSTS) then
                local gourdNum = player:GetCollectibleNum(waxGourd)

                local locustsToSpawn = math.min(math.floor(entity.MaxHitPoints/((1+(1/2)^(gourdNum-1))*player.Damage)), gourdNum+4)

                if(LOCUSTS_SPAWNED_IN1_FRAME+locustsToSpawn>MAX_LOCUSTS) then locustsToSpawn = MAX_LOCUSTS-LOCUSTS_SPAWNED_IN1_FRAME end

                for _=1, locustsToSpawn do
                    local locust = Isaac.Spawn(3, 43, 3, entity.Position, Vector.Zero, player):ToFamiliar()
                    locust.Player = player
                end
                local puddle = Isaac.Spawn(1000, 94, 0, entity.Position, Vector(0,0), entity):ToEffect()
                puddle.Scale = 1.5^gourdNum
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

local function postUpdate(_)
    LOCUSTS_SPAWNED_IN1_FRAME=0
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)


mod.ITEMS.BEESWAXGOURD = funcs