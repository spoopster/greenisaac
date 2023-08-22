jezreelMod = RegisterMod("greenisaac", 1)
local mod = jezreelMod

mod.ITEMS = {}
mod.MACHINE_CALLBACKS = {}
mod.ENTITIES = {
    PICKUPS = {},
    BLOCKBUMS = {},
}
mod.CHARACTERS = {}
mod.CHALLENGES = {}

local imports = include("imports")
imports:Init(mod)


local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

---@param player EntityPlayer
local function onCache(_, player, flags)
    if(flags&CacheFlag.CACHE_FLYING==CacheFlag.CACHE_FLYING) then
        player:TryRemoveNullCostume(greenCharCostume)
        player:TryRemoveNullCostume(flyingGreenCharCostume)
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.EARLY, onCache)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)