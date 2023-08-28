local mod = jezreelMod
local json = require("json")
local funcs = {}

function mod.unlockAll()
    for character, unlockTable in pairs(mod.MARKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                local newVal = 2
                if(mark=="UltraGreed" or mark=="UltraGreedier") then newVal=1 end
                mod.MARKS.CHARACTERS[character][side][mark]=newVal
            end
        end
    end
    for challenge, unlock in pairs(mod.MARKS.CHALLENGES) do
        mod.MARKS.CHALLENGES[challenge]=1
    end
    mod:saveCommands()
end

function mod.lockAll()
    for character, unlockTable in pairs(mod.MARKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                mod.MARKS.CHARACTERS[character][side][mark]=0
            end
        end
    end
    for challenge, unlock in pairs(mod.MARKS.CHALLENGES) do
        mod.MARKS.CHALLENGES[challenge]=0
    end
    mod:saveCommands()
    print("Locked all the content in the mod!")
end

function funcs:executeCmd(comm, args)
    if(comm=="gr_unlockall") then
        mod.unlockAll()
        print("Unlocked all the content in the mod!")
    end
    if(comm=="gr_reset") then
        mod.lockAll()
        print("Locked all content in the mod!")
    end
    --[[
    if(comm=="gr_cache") then
        for i=0, Game():GetNumPlayers()-1 do
            local player = Isaac.GetPlayer(i)
            player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
        end
    end
    --]]
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, funcs.executeCmd)