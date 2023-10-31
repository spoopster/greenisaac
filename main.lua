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

local imports = {
    "scripts.enums",
    "scripts.custom_callbacks",
    "scripts.saves",
    "scripts.func",

    "scripts.characters.cain.cain",
    "scripts.characters.isaac.isaac",
    "scripts.characters.jezreel.jezreel",

    "scripts.characters.isaac.the_g6",

    "scripts.items.green_items.sad_cucumber",
    "scripts.items.green_items.hot_potato",
    "scripts.items.green_items.pizzaberry",
    "scripts.items.green_items.mildly_spicy_pepper",
    "scripts.items.green_items.leak",
    "scripts.items.green_items.single_pea",
    "scripts.items.green_items.broccoli_man",
    "scripts.items.green_items.ancient_carrot",
    "scripts.items.green_items.obnoxious_tangerine",
    "scripts.items.green_items.4_dimensional_apple",
    "scripts.items.green_items.confusing_pear",
    "scripts.items.green_items.popped_corn",
    "scripts.items.green_items.watermelon",
    "scripts.items.green_items.radish",
    "scripts.items.green_items.jolly_mint",
    "scripts.items.green_items.beeswax_gourd",
    "scripts.items.green_items.grass_clippings",
    "scripts.items.green_items.key_lime",
    "scripts.items.green_items.bananarang",
    "scripts.items.green_items.spiky_durian",
    "scripts.items.green_items.the_onion",
    --"scripts.items.green_items.billion_dollar_lime",
    "scripts.items.green_items.pomegrenade",
    "scripts.items.green_items.blue_berry",
    "scripts.items.green_items.lemon_battery",
    "scripts.items.green_items.eco_friendly_options",
    --"scripts.items.green_items.rosemary_bead",
    "scripts.items.green_items.holly_berry",
    "scripts.items.green_items.jerusalems_artichoke",
    "scripts.items.green_items.sweet_potato",
    "scripts.items.green_items.missiletoe",
    "scripts.items.green_items.uriels_hand",
    "scripts.items.green_items.really_spicy_pepper",
    "scripts.items.green_items.deviled_eggplant",
    "scripts.items.green_items.moms_chives",
    "scripts.items.green_items.hemoguava",
    "scripts.items.green_items.ricin_flask",
    "scripts.items.green_items.bloody_orange",
    "scripts.items.green_items.dragonfruit_bombs",
    "scripts.items.green_items.cursed_grapes",
    "scripts.items.green_items.starfruit",
    "scripts.items.green_items.demeter",
    "scripts.items.green_items.dads_tobacco",
    "scripts.items.green_items.natural_gift",
    "scripts.items.green_items.yellowberry",
    "scripts.items.green_items.elderberry",
    "scripts.items.green_items.honeyberry",
    "scripts.items.green_items.bearberry",
    "scripts.items.green_items.coffeeberry",
    "scripts.items.green_items.blackcurrant",
    "scripts.items.green_items.redcurrant",
    "scripts.items.green_items.crowberry",
    "scripts.items.green_items.barberry",
    "scripts.items.green_items.kram_berry",
    "scripts.items.green_items.clump_of_hay",
    "scripts.items.green_items.scallion",
    "scripts.items.green_items.baby_carrot",
    "scripts.items.green_items.pyre_lantern",
    "scripts.items.green_items.cherry_on_top",
    "scripts.items.green_items.olive_oil",
    "scripts.items.green_items.unicorn_radish",
    "scripts.items.green_items.jadeberry",
    "scripts.items.green_items.pearry",
    "scripts.items.green_items.grayberry",
    "scripts.items.green_items.fcukberry",

    "scripts.characters.cain.machines.oninit",
    "scripts.characters.cain.machines.ondeath",
    "scripts.characters.cain.machines.onupdate",
    "scripts.characters.cain.machines.oncollision",
    "scripts.characters.cain.machine",

    "scripts.characters.cain.green_sack",

    "scripts.items.dirty_money",
    "scripts.items.less_than_g",
    "scripts.items.pondering_orb",
    "scripts.items.brotherly_love",
    "scripts.items.satans_bet",
    "scripts.items.golden_eye",
    "scripts.items.green_stake",
    "scripts.items.wheel_of_fortune",

    "scripts.characters.jezreel.green_thumb",

    "scripts.characters.green_costume_remove",
    "scripts.characters.locked_char_disable",

    "scripts.challenges.biblically_accurate",
    "scripts.challenges.prologue",

    "scripts.entities.blockbums.abel",
    "scripts.entities.blockbums.seth",
    "scripts.entities.blockbums.basic",
    "scripts.entities.blockbums.devil",
    "scripts.entities.blockbums.key",
    "scripts.entities.blockbums.bomb",
    "scripts.entities.blockbums.battery",
    "scripts.entities.blockbums.rotten",
    "scripts.entities.pickups.greencoin",
    "scripts.entities.pickups.pear",
    "scripts.entities.pickups.potato_magnet",
    "scripts.entities.pickups.sharp_stick",
    "scripts.entities.pickups.weird_gummy",
    "scripts.entities.pickups.broken_dice",
    "scripts.entities.pickups.glass_penny",
    "scripts.entities.pickups.flowering_jade",
    "scripts.entities.green_isaac_boss",
    "scripts.entities.reap_prime",
    "scripts.entities.orb_glow",
    "scripts.entities.patch",

    "scripts.items.guns_n_roses",
    "scripts.items.jezreels_curse",
    "scripts.items.lil_silence",

    "scripts.commands",

    "scripts.compat.eid",
    "scripts.compat.the_future",

    "scripts.dss.dss",
    "scripts.dss.sillies.ff_incompat",
    "scripts.dss.sillies.flashbang",
}
for _, val in ipairs(imports) do include(val) end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)