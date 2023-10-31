local mod = jezreelMod

local waxGourd = mod.ENUMS.VEGETABLES.BEESWAX_GOURD

local funcs = {}

function funcs:entityTakeDMG(entity, amount, flags, source, frames)
    local player = source.Entity
    if(player and ((player.SpawnerEntity and player.SpawnerEntity:ToPlayer()) or player:ToPlayer())) then
        if(player:ToPlayer()) then player=player:ToPlayer()
        else player = player.SpawnerEntity:ToPlayer() end
        if(entity.HitPoints<=amount and entity:IsVulnerableEnemy()) then
            if(player:HasCollectible(waxGourd)) then
                local gourdNum = player:GetCollectibleNum(waxGourd)
                for _=1, math.min(math.floor(entity.MaxHitPoints/((1+(1/2)^(gourdNum-1))*player.Damage)), gourdNum+4) do
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

mod.ITEMS.BEESWAXGOURD = funcs