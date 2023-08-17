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