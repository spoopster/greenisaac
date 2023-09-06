local mod = jezreelMod

local challengeId = Isaac.GetChallengeIdByName("Biblically Accurate")
local jezreelId = Isaac.GetPlayerTypeByName("Jezreel", false)
local greenThumbId = mod.ENUMS.ITEMS.GREEN_THUMB

local funcs = {}

function funcs:postPlayerInit(player)
    if(Game().Challenge==challengeId) then
        if(player:GetPlayerType()==PlayerType.PLAYER_ISAAC) then
            player:ChangePlayerType(jezreelId)
            player:SetPocketActiveItem(greenThumbId, 2, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

function mod:unlockLogic(npc)
    if(Game():GetVictoryLap()~=0) then return end
    if(Game().Challenge~=challengeId) then return end

    if((Game():GetLevel():GetStage()==LevelStage.STAGE3_2) and npc.Type==EntityType.ENTITY_MOM and npc.Variant==0) then --mom unlock
        if(mod.MARKS.CHALLENGES.BIBLICALLY_ACCURATE==1) then goto invalid end
        mod.MARKS.CHALLENGES.BIBLICALLY_ACCURATE=1

        local achTable = mod.UNLOCKS.CHALLENGES.BIBLICALLY_ACCURATE.ACHIEVEMENT
        for _, achievement in ipairs(achTable) do
            mod:showAchievement(achievement)
        end

        for i, entity in ipairs(Isaac.GetRoomEntities()) do
            if(entity:GetData().isInvincibleEnemy==true) then entity:Remove() end
        end

        ::invalid::
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.unlockLogic)

mod.CHALLENGES.BIBLICALLY_ACCURATE = funcs