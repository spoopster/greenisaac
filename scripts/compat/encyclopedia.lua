local mod = jezreelMod

local greenBreakfast = mod.ENUMS.ITEMS.GREEN_BREAKFAST
local greenD6 = mod.ENUMS.ITEMS.G6
local greenIsaac = Isaac.GetPlayerTypeByName("Green Isaac", false)
local vegetables = mod.ENUMS.VEGETABLES

if Encyclopedia then
    local greenPool = Encyclopedia.GetItemPoolIdByName("Green")
    Encyclopedia.AddItemPoolSprite(greenPool, Encyclopedia.RegisterSprite("gfx/encyclopedia/green_pool.anm2", "Idle", 0))
    local greenDesc = {
        GREEN_D6 = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Delirium as Green Isaac!"},
                {str = "Rerolls items into items from the Green pool, which consists of various vegetables, fruits and plants."},
                {str = "Can't reroll items from the Green pool!"},
            },
        },
        GREEN_BREAKFAST = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Does nothing."},
            },
            { -- Trivia
                {str = "Trivia", fsize = 2, clr = 3, halign = 0},
                {str = "In the April Fools version of the mod, Green Isaac was planned to only start with 2 max hearts, and Green Breakfast would give him a 3rd, effectively making his health unchanged compared to normal Isaac."},
            },
        },
        SAD_CUCUMBER = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Isaac as Green Isaac!"},
                {str = "Tear delay -10% (Tears up)."},
                {str = "You shoot an additional tear above and below your tears."},
                {str = "These bonus tears deal 25% of the main tear's damage."}
            },
            { -- Synergies
                {str = "Synergies", fsize = 2, clr = 3, halign = 0},
                {str = "Sad Cucumber: For every copy of the item, grants an extra tear above and below your main tear."},
            },
        },
        HOT_POTATO = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Damage x1.2."},
                {str = "+0.3 speed."},
                {str = "When you collide with an enemy, you create a large explosion, and lose 1 Hot Potato."}
            },
        },
        PIZZA_BERRY = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Satan as Green Isaac!"},
                {str = "Damage x1.1."},
                {str = "Grants half of a full red heart container."},
                {str = "Heals 1 additional half heart of health."},
            },
        },
        MILDLY_SPICY_PEPPER = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str="+0.2 shotspeed up."},
                {str="Tears spawn fire on the ground as they travel."},
                {str="These fires last 2 seconds, deal 2 damage and don't block projectiles."},
            },
            { -- Synergies
                {str = "Synergies", fsize = 2, clr = 3, halign = 0},
                {str="Popped Corn: When tears pop, they spawn a few flames as well"},
                {str="Leek: Leek puddle tears have a chance to spawn a flame"},
            },
        },
        LEAK = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Tear delay -10% (Tears up)."},
                {str = "When an enemy dies, 33% chance to spawn a puddle of pee in its place."},
                {str = "The puddle shoots arcing tears in random directions that deal 1.5 damage."},
                {str = "Chance to spawn a pee puddle gets higher the more copies of the item you have, using the formula: chance>(2/3)^(numLeek)"},
            },
        },
        SINGLE_PEA = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Pea familiar that flies around the room diagonally."},
                {str = "When shot it spawns a burst of 5 tears that slow down quickly."},
                {str = "When colliding with an enemy, it spawns a large burst of tears at its position."},
            },
            { -- Trivia
                {str = "Trivia", fsize = 2, clr = 3, halign = 0},
                {str = "The pea's name is Juan."},
            },
        },
        BROCCOLI_MAN = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Boss Rush as Green Isaac!"},
                {str = "Broccoli familiar that spawns in a random position in the room."},
                {str = "It deals 9 damage per second to all enemies colliding with it."}
            },
        },
        ANCIENT_CARROT = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Mother as Green Isaac!"},
                {str = "Damage x1.2."},
                {str = "Tear delay -10% (Tears up)."},
                {str = "+1 luck."},
                {str = "Range +30%."},
                {str = "+0.3 shotspeed."},
                {str = "+0.2 speed"},
                {str = "Gives the Retro Vision effect for 60 seconds."},
            },
            { -- Trivia
                {str = "Trivia", fsize = 2, clr = 3, halign = 0},
                {str = "This sprite was originally made in 2021, truly ancient!"},
            },
        },
        OBNOXIOUS_TANGERINE = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Ultra Greed as Green Isaac!"},
                {str = "When used, spawns a Pear pickup."},
                {str = "Every 4-6 seconds or when used, spawns an obnoxious dialogue box that blocks vision."},
            },
            { -- Trivia
                {str = "Trivia", fsize = 2, clr = 3, halign = 0},
                {str = "The dialogue box is stylized to look like Hotline Miami's dialogue boxes."},
                {str = "This item was a mistake!"},
            },
        },
        FOUR_DIMENSIONAL_APPLE = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating The Lamb as Green Isaac!"},
                {str = "Gives 4 non-euclidean apple familiars that orbit the player in a square pattern"},
                {str = "When a tear is fired into one of the apples, a copy of the tear is fired from all other apples."},
                {str = "For every copy of the item, you get 4 more apples"},
            },
        },
        CONFUSING_PEAR = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating ??? as Green Isaac!"},
                {str = "All non-consumable pickups are replaced by Pears."},
                {str = "Pears act as random pickups."},
                {str = "For every copy of the item, Pears give an extra random pickup drop."},
            },
        },
        POPPED_CORN = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "After about 2/3rds of a second, or when colliding with an obstacle or enemy, your tears pop into a burst of tears."},
                {str = "The amount of tears spawned when a tear pops starts at 6, and increases by 2 for every additional copy of the item."},
            },
        },
        WATERMELON = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Tears have a 1/30 change to be replaced by a rolling melon."},
                {str = "If a melon hits an enemy, it explodes, dealing heavy knockback to enemies, and leaves a puddle of water on the ground."},
                {str = "If it misses, it leaves a puddle of water on the ground with no additional effect."},
                {str = "The change to shoot a melon increases with every copy of the item."},
            },
        },
        RADISH = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Damage x1.3."},
                {str = "Tear delay +20% (Tears down)."},
                {str = "+3 luck."},
                {str = "Range +20%."},
                {str = "+0.2 shotspeed."},
                {str = "+0.2 speed"},
            },
        },
        JOLLY_MINT = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Killing an enemy spawns an ice block in its place"},
                {str = "Ice blocks block projectiles and enemies from walking through them."},
                {str = "They can be destroyed in 1 shot."},
                {str = "Tears have a 33% chance to slow enemies."},
            },
        },
        BEESWAX_GOURD = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Mega Satan as Green Isaac!"},
                {str = "Killing an enemy spawns a puddle of slippery creep in its place and an amount of slowing locusts proportional to the enemy's health."},
                {str = "The amount of locusts spawned is equal to: (enemy's Max HP)/(player Damage*2), rounded down."},
            },
        },
        GRASS_CLIPPINGS = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Heals half of a red heart"},
                {str = "+0.1 speed."},
                {str = "The speed increase is capped at 4 instead of 2."},
            },
        },
        KEY_LIME = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating The Beast as Green Isaac!"},
                {str = "Using the Green D6 spawns a key for every item in the room."},
                {str = "Also spawns an extra key for every additional copy of the item."},
            },
        },
        BANANARANG = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Using the Green D6 fires a piercing, bouncy bananarang at the nearest enemy."},
                {str = "The bananarang can be later picked back up, recharging the Green D6."},
            },
        },
        SPIKY_DURIAN = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Hush as Green Isaac!"},
                {str = "Using the Green D6 fires spikes in a circle around the player."},
                {str = "It also gives a small fear aura for the room, proportional in size to how many copies of the item you have."},
            },
        },
        THE_ONION = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "- Unlocked by beating Ultra Greedier as Green Isaac!"},
                {str = "5% Tear delay down#\1 10% Range up#\2 -0.1 Shot speed down#Tears have a small chance to pierce enemies#Tears have a small chance to become spectral#Tears have a chance to confuse enemies"},
                {str = "Tear delay -5% (Tears up)."},
                {str = "Tear range +10%."},
                {str = "-0.1 shotspeed."},
                {str = "Tears have a 5% chance to pierce enemies."},
                {str = "Tears have a 5% chance to be spectral."},
                {str = "Tears have a 10% chance to confuse enemies."},
            },
        },
    }
    local modClass = "Green Isaac"
    Encyclopedia.AddItem({Pools={Encyclopedia.ItemPools.POOL_SECRET}, ID=greenD6, WikiDesc=greenDesc.GREEN_D6, Class=modClass})
    Encyclopedia.AddItem({Pools={}, ID=greenBreakfast, WikiDesc=greenDesc.GREEN_BREAKFAST, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.SAD_CUCUMBER, WikiDesc=greenDesc.SAD_CUCUMBER, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.HOT_POTATO, WikiDesc=greenDesc.HOT_POTATO, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.PIZZA_BERRY, WikiDesc=greenDesc.PIZZA_BERRY, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.MILDLY_SPICY_PEPPER, WikiDesc=greenDesc.MILDLY_SPICY_PEPPER, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.LEAK, WikiDesc=greenDesc.LEAK, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.SINGLE_PEA, WikiDesc=greenDesc.SINGLE_PEA, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.BROCCOLI_MAN, WikiDesc=greenDesc.BROCCOLI_MAN, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.ANCIENT_CARROT, WikiDesc=greenDesc.ANCIENT_CARROT, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.OBNOXIOUS_TANGERINE, WikiDesc=greenDesc.OBNOXIOUS_TANGERINE, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.FOUR_DIMENSIONAL_APPLE, WikiDesc=greenDesc.FOUR_DIMENSIONAL_APPLE, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.CONFUSING_PEAR, WikiDesc=greenDesc.CONFUSING_PEAR, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.POPPED_CORN, WikiDesc=greenDesc.POPPED_CORN, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.WATERMELON, WikiDesc=greenDesc.WATERMELON, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.RADISH, WikiDesc=greenDesc.RADISH, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.JOLLY_MINT, WikiDesc=greenDesc.JOLLY_MINT, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.BEESWAX_GOURD, WikiDesc=greenDesc.BEESWAX_GOURD, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.GRASS_CLIPPINGS, WikiDesc=greenDesc.GRASS_CLIPPINGS, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.KEY_LIME, WikiDesc=greenDesc.KEY_LIME, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.BANANARANG, WikiDesc=greenDesc.BANANARANG, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.SPIKY_DURIAN, WikiDesc=greenDesc.SPIKY_DURIAN, Class=modClass})
    Encyclopedia.AddItem({Pools={greenPool}, ID=vegetables.THE_ONION, WikiDesc=greenDesc.THE_ONION, Class=modClass})

    Encyclopedia.AddCharacter({
        ModName = "Green Isaac",
        Name = "Green Isaac",
        ID = greenIsaac,
        WikiDesc = {
            { -- Start Data
            {str = "Start Data", fsize = 2, clr = 3, halign = 0},
            {str = "Items:"},
            {str = "- The Green D6"},
            {str = "Stats:"},
            {str = "- HP: 3 Red Hearts"},
            {str = "- Speed: 1.00"},
            {str = "- Tear Rate: 2.73"},
            {str = "- Damage: 3.50"},
            {str = "- Range: 6.50"},
            {str = "- Shot Speed: 1.00"},
            {str = "- Luck: 0.00"},
        },
        { -- Birthright
            {str = "Birthright", fsize = 2, clr = 3, halign = 0},
            {str = "Green Isaac gains an inherent 9 Volt effect on his Green D6."},
        },
        { -- Trivia
            {str = "Trivia", fsize = 2, clr = 3, halign = 0},
            {str = "Green Isaac's appearance is based on the Oni from Ao Oni, a japanese horror game."},
        },
        }
    })
end