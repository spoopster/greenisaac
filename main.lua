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

local function fiendFolioIncompatibility()
    if(mod:getMenuData().ff_incompatibility==2 and FiendFolio) then
        Isaac.GetPlayer().BabySkin = 0
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, fiendFolioIncompatibility)

local FLASHBANG_FRAME = 0
local FLASHBANG_WHITE_DURATION = 30
local MAXFLASHBANG_FRAME = 90

local blackBg = Sprite()
blackBg:Load("gfx/black.anm2", true)
blackBg:Play("Main")
blackBg.Scale = Vector(3,3)
local function flashbangModeRender()
    if(not (mod.getMenuData().flashbangMode==2)) then return end
    if(FLASHBANG_FRAME>0) then
        local a = FLASHBANG_FRAME/(MAXFLASHBANG_FRAME-FLASHBANG_WHITE_DURATION)
        a=math.min(a,1)

        blackBg.Color = Color(1,1,1,a,1,1,1)
        blackBg:Render(Vector.Zero)

        FLASHBANG_FRAME=FLASHBANG_FRAME-1
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, flashbangModeRender)

local function postEffectInit(_, effect)
    if(not (mod.getMenuData().flashbangMode==2)) then return end
    FLASHBANG_FRAME=MAXFLASHBANG_FRAME
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, EffectVariant.BOMB_EXPLOSION)