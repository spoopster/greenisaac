local mod = jezreelMod

if EID then
    --[[
    local sprite = Sprite()
    sprite:Load("gfx/ui/greenQualityIcon.anm2", true)
    EID:addIcon("Quality4039", "Idle", 1, 9, 9, 1, 5, sprite) -- add quality GREEN
    ]] -- THIS IS UNUSED LOL!

    local vegetables = mod.ENUMS.VEGETABLES
    local items = mod.ENUMS.ITEMS

    local greenBreakfast = items.GREEN_BREAKFAST
    local greenD6 = items.G6


    local g6Icon = "{{Collectible"..greenD6.."}}"
    local THIS_IS_A_GREEN_ITEM = g6Icon.." {{ColorGreen}}This is a green item!{{CR}}#"

    local EID_DESCRIPTIONS = {
        [greenD6] = {
            IsGreen = false, Name = "The G6",
            Desc = {
                "Rerolls items into items from the Green Pool",
                "Has different pools for different special rooms",
            },
        },
        [greenBreakfast] = {
            IsGreen = false, Name = "Green Breakfast",
            Desc = {
                "Does absolutely nothing",
            },
        },
        [vegetables.SAD_CUCUMBER] = {
            IsGreen = true, Name = "Sad Cucumber",
            Desc = {
                "\1 Tear delay x0.9",
                "\1 Tears are accompanied by an extra tear to the left and right",
            },
        },
        [vegetables.HOT_POTATO] = {
            IsGreen = true, Name = "Hot Potato",
            Desc = {
                "\1 Damage x1.2",
                "\1 +0.3 speed up",
                "{{Warning}} Touching an enemy makes you explode and removes one Hot Potato {{Collectible"..vegetables.HOT_POTATO.."}}",
            },
        },
        [vegetables.PIZZABERRY] = {
            IsGreen = true, Name = "Pizzaberry",
            Desc = {
                "\1 Damage x1.1",
                "\1 +0.5 health up",
                "{{Heart}} Heals 1 Red Heart",
            },
        },
        [vegetables.MILDLY_SPICY_PEPPER] = {
            IsGreen = true, Name = "Mildly Spicy Pepper",
            Desc = {
                "\1 Your tears now pierce enemies",
                "{{Burning}} Tears spawn fires on the ground as they travel",
                "The fires deal half of your damage and disappear after 2 seconds or upon contact with an enemy",
            },
        },
        [vegetables.LEAK] = {
            IsGreen = true, Name = "Leak",
            Desc = {
                "\1 Tear delay x0.9",
                "Killing an enemy has a 1/3 chance to spawn a puddle of pee that bubbles tears around",
            },
        },
        [vegetables.SINGLE_PEA] = {
            IsGreen = true, Name = "Single Pea",
            Desc = {
                "Pea familiar that moves diagonally around the room",
                "When colliding with a tear, fires 5 tears in a circle",
                "When colliding with an enemy, fires 4 tears in a circle",
                "The tears it spawns do 3.5 damage"
            },
            BirthrightDescMods = {
                {Old="fires 5", New="fires {{ColorLime}}7{{CR}}"},
                {Old="fires 4", New="fires {{ColorLime}}6{{CR}}"},
                {Old="3.5 damage", New="{{ColorLime}}6{{CR}} damage"},
            }
        },
        [vegetables.BROCCOLI_MAN] = {
            IsGreen = true, Name = "Broccoli Man",
            Desc = {
                "Broccoli familiar that appears in a random position each room",
                "It deals 9 damage per second to all enemies it collides with",
            },
            BirthrightDescMods = {
                {Old="deals 9", New="deals {{ColorLime}}18{{CR}}"},
            }
        },
        [vegetables.ANCIENT_CARROT] = {
            IsGreen = true, Name = "Ancient Carrot",
            Desc = {
                "\1 Damage x1.2",
                "\1 Tear delay x0.9",
                "\1 +1 luck up",
                "\1 +4 range up",
                "\1 +0.3 speed up",
                "\1 +0.2 shotspeed up",
                "{{Warning}} Makes the game look greener",
            },
        },
        [vegetables.OBNOXIOUS_TANGERINE] = {
            IsGreen = true, Name = "Obnoxious Tangerine",
            Desc = {
                "On use, spawns a Pear pickup",
                "\2 Every 4-6 seconds, spawns an obnoxious dialogue box that blocks your vision",
            },
        },
        [vegetables.FOUR_DIMENSIONAL_APPLE] = {
            IsGreen = true, Name = "4-Dimensional Apple",
            Desc = {
                "Gives 4 non-euclidean apple orbitals",
                "When one of them collides with a tear, all other apples will fire a copy of that tear",
            },
            BirthrightDescMods = {
                {Old="Gives 4", New="Gives {{ColorLime}}6{{CR}}"},
            }
        },
        [vegetables.CONFUSING_PEAR] = {
            IsGreen = true, Name = "Confusing Pear",
            Desc = {
                "All non-consumable pickups are replaced with Pears",
            },
        },
        [vegetables.POPPED_CORN] = {
            IsGreen = true, Name = "Popped Corn",
            Desc = {
                "After 0.66 seconds, your tears will pop into a burst of 3 tears",
            },
        },
        [vegetables.WATERMELON] = {
            IsGreen = true, Name = "Watermelon",
            Desc = {
                "Tears have a 1/20 chance to turn into a watermelon",
                "Watermelons roll on the ground and explode upon contact with enemies",
            },
        },
        [vegetables.RADISH] = {
            IsGreen = true, Name = "Radish",
            Desc = {
                "\1 Damage x1.3",
                "\2 Tear delay x1.2",
                "\1 +3 luck up",
                "\1 +2 range up",
                "\1 +0.2 speed up",
                "\1 +0.1 shotspeed up",
            },
        },
        [vegetables.JOLLY_MINT] = {
            IsGreen = true, Name = "Jolly Mint",
            Desc = {
                "Upon death, enemies spawn an ice block on top of them",
                "Ice blocks block projectiles and enemies, and do 2/3rds of your damage per second",
                "Players can pass through the ice blocks",
                "{{Slow}} Tears have a 1/4 chance to Slow enemies",
            },
        },
        [vegetables.BEESWAX_GOURD] = {
            IsGreen = true, Name = "Beeswax Gourd",
            Desc = {
                "Killing an enemy spawns locusts proportional to the enemy's health, and a puddle of slippery creep",
                "{{Slow}} The locust inflicts Slow on enemies",
            },
        },
        [vegetables.GRASS_CLIPPINGS] = {
            IsGreen = true, Name = "Grass Clippings",
            Desc = {
                "{{HalfHeart}} Heals half of a Red Heart",
                "\1 +0.1 Speed up",
                "{{Warning}} The speed gained from this is {{ColorYellow}}NOT{{CR}} capped at 2.0"
            },
        },
        [vegetables.KEY_LIME] = {
            IsGreen = true, Name = "Key Lime",
            Desc = {
                "Using the G6 spawns 1 key for every item in the room",
            },
        },
        [vegetables.BANANARANG] = {
            IsGreen = true, Name = "Bananarang",
            Desc = {
                "Using the G6 fires 3 bouncy bananas at the nearest enemy",
                "You can pick it back up, recharging your G6",
            },
        },
        [vegetables.SPIKY_DURIAN] = {
            IsGreen = true, Name = "Spiky Durian",
            Desc = {
                "Using the G6 fires 8 spikes around you and gives you a {{Fear}} Fear aura for the current room",
            },
        },
        [vegetables.THE_ONION] = {
            IsGreen = true, Name = "The Onion",
            Desc = {
                "\1 Tear delay x0.95",
                "\1 +0.5 range up",
                "\2 -0.1 shotspeed up",
                "1/20 chance for tears to pierce enemies",
                "1/20 chance for tears to become spectral",
                "1/10 chance for tears to {{Confusion}} confuse enemies",
            },
        },
        [vegetables.POMEGRENADE] = {
            IsGreen = true, Name = "Pomegrenade",
            Desc = {
                "You shoot out 2 lobbing grenades that explode into a puddle of creep and a geyser of tears",
            },
        },
        [vegetables.BLUE_BERRY] = {
            IsGreen = true, Name = "Blue Berry",
            Desc = {
                "You gain a suicidal blueberry familiar every room",
                "If you touch him while he's suiciding grants either a coin or a heart",
                "Otherwise his lifeless corpse remains in the room until you leave",
            },
        },
        [vegetables.LEMON_BATTERY] = {
            IsGreen = true, Name = "Lemon Battery",
            Desc = {
                "You gain a damage up depending on how much your active item is charged",
                "{{Blank}} Different charge times grant different bonuses:",
                "0 and 1 room charges: x1.1 damage up",
                "2 room charges: x1.2 damage up",
                "3 room charges: x1.3 damage up",
                "4 and 5 room charges: x1.4 damage up",
                "6 and 12 room charges: x1.5 damage up",
                "Any other charge amount: 1.3x damage up",
            },
        },
        [vegetables.ECO_FRIENDLY_OPTIONS] = {
            IsGreen = true, Name = "Eco-Friendly Options",
            Desc = {
                "For all items in {{TreasureRoom}} Treasure Rooms, you can choose between the original item or a Green Item",
            },
        },
        [vegetables.HOLLY_BERRY] = {
            IsGreen = true, Name = "Holly Berry",
            Desc = {
                "Taking damage fires revelations lasers in the diagonal directions",
                "\1 Tears have a 1/6 chance to gain the {{Collectible331}} Godhead effect",
            },
        },
        [vegetables.JERUSALEMS_ARTICHOKE] = {
            IsGreen = true, Name = "Jerusalem's Artichoke",
            Desc = {
                "Double-tapping a fire key shoots out an artichoke spear at the nearest enemy",
                "After it hits the target, it changes its target to the next closest enemy until it has no more valid targets"
            },
        },
        [vegetables.SWEET_POTATO] = {
            IsGreen = true, Name = "Sweet Potato",
            Desc = {
                "Gives you various stats",
                "{{Blank}} The stats are based on your health and different hearts give different stats:",
                "{{Heart}} +1.05x damage, +0.5 range, +0.1 speed",
                "{{SoulHeart}} +1.15x damage",
                "{{BlackHeart}} +1.25x damage",
                "{{EmptyBoneHeart}} +1.15x tears",
                "{{GoldenHeart}} +1.2x tears",
                "{{RottenHeart}} +1.15x damage, -0.2 shotspeed",
                "{{EthernalHeart}} +1.3x damage, +1.3x tears, +2 range, +0.2 speed, +0.2 shotspeed",
            },
        },
        [vegetables.MISSILETOE] = {
            IsGreen = true, Name = "Missiletoe",
            Desc = {
                "Enemies all have a mistletoe above their head, which has a 1/3 chance to make them explode on death",
                "After taking enough damage, the mistletoe disappears and makes the enemy explode",
                "After 12 seconds, the mistletoe disappears with no explosion",
            },
        },
        [vegetables.URIELS_HAND] = {
            IsGreen = true, Name = "Uriel's Hand",
            Desc = {
                "Fires a 6-way tech laser that leaves yellow creep on the ground, along with a holy blast at the player's position",
            },
        },
        [vegetables.REALLY_SPICY_PEPPER] = {
            IsGreen = true, Name = "Really Spicy Pepper",
            Desc = {
                "Gives a chance to shoot out a lobbing tear that leaves a cross of firejets behind when it lands",
            },
        },
        [vegetables.DEVILED_EGGPLANT] = {
            IsGreen = true, Name = "Deviled Eggplant",
            Desc = {
                "{{Weakness}} Gives you a chance to weaken enemies for 5 seconds",
                "{{Blank}} The chance is based on your health and different hearts give different chances:",
                "{{Heart}} +1% chance",
                "{{SoulHeart}} +2% chance",
                "{{BlackHeart}} +3% chance",
                "{{EmptyBoneHeart}} +4% chance",
                "{{GoldenHeart}} +5% chance",
                "{{RottenHeart}} +3% chance",
                "{{EthernalHeart}} +10% chance",
            },
        },
        [vegetables.MOMS_CHIVES] = {
            IsGreen = true, Name = "Mom's Chives",
            Desc = {
                "Gives you 3 orbital chives that get closer and farther to you",
                "When at minimum distance, deals 80 damage per second, and at maximum distance deals 30 damage per second",
            },
            BirthrightDescMods = {
                {Old="you 3", New="you {{ColorLime}}5{{CR}}"},
                {Old="deals 80", New="deals {{ColorLime}}120{{CR}}"},
                {Old="deals 30", New="deals {{ColorLime}}45{{CR}}"},
            }
        },
        [vegetables.HEMOGUAVA] = {
            IsGreen = true, Name = "Hemoguava",
            Desc = {
                "Using the G6 gives you a blood trail and makes you hemorrhage blood around you every 0.8 seconds",
            },
        },
        [vegetables.RICIN_FLASK] = {
            IsGreen = true, Name = "Ricin Flask",
            Desc = {
                "{{Poison}} When an enemy takes damage, 1/12 chance to poison it",
                "\1 If an enemy has ANY debuff, it takes 2x damage from any source",
            },
        },
        [vegetables.BLOODY_ORANGE] = {
            IsGreen = true, Name = "Bloody Orange",
            Desc = {
                "While moving, you leave behind blood creep",
                "{{Blank}} In uncleared rooms, every 5 seconds:",
                "Leave behind a big puddle of blood creep",
                "Shoot 5 tears that continuously spiral around the big blood creep",
            },
        },
        [vegetables.DRAGONFRUIT_BOMBS] = {
            IsGreen = true, Name = "Dragonfruit Bombs",
            Desc = {
                "Bombs leave behind a cross of firejets when they explode",
                "Grants an infernal aura that sets enemies near you on fire",
            },
        },
        [vegetables.CURSED_GRAPES] = {
            IsGreen = true, Name = "Cursed Grapes",
            Desc = {
                "Using the G6 teleports you to a random room",
                "All other \"Using the G6...\" items instead have a chance to activate a weaker version of their effect every room",
            },
        },
        [vegetables.STARFRUIT] = {
            IsGreen = true, Name = "Starfruit",
            Desc = {
                "When an entity takes damage, it spawns a star at its position",
                "Stars can be default, or have a 1/4 chance to inflict a random debuff on enemies",
            },
        },
        [vegetables.DEMETER] = {
            IsGreen = true, Name = "Demeter",
            Desc = {
                "{{Blank}} Entering the {{TreasureRoom}} Treasure Room for the first time:",
                "Grants 2 blockbums",
                "4 random hearts that have a 50% chance to instead be Pears",
            },
        },
        [vegetables.DADS_TOBACCO] = {
            IsGreen = true, Name = "Dad's Tobacco",
            Desc = {
                "{{Chargeable}} While shooting, you charge up a hunk of tobacco",
                "When charged, you can shoot out a lobbing hunk of tobacco along with some spit",
                "The hunk of tobacco bursts into creep and more spit",
            },
        },
        [vegetables.NATURAL_GIFT] = {
            IsGreen = true, Name = "Natural Gift",
            Desc = {
                "\1 All stats from \"-berry\" items are 1.5x better",
                "All secondary effects from \"-berry\" items are 2x better",
            },
        },
        [vegetables.YELLOWBERRY] = {
            IsGreen = true, Name = "Yellowberry",
            Desc = {
                "\1 +1.5 range up",
                "\1 +0.1 shotspeed up",
                "Tears have a 1/15 chance to become bouncy banana tears",
            },
        },
        [vegetables.ELDERBERRY] = {
            IsGreen = true, Name = "Elderberry",
            Desc = {
                "\1 +1 range up",
                "\2 -0.1 speed down",
                "Gold chests have a 1/10 chance to become old chests",
            },
        },
        [vegetables.HONEYBERRY] = {
            IsGreen = true, Name = "Honeyberry",
            Desc = {
                "\1 +1 luck up",
                "\1 +0.15 speed up",
                "Taking damage spawns 2 locusts",
                "{{Slow}} The locusts slow enemies",
            },
        },
        [vegetables.BEARBERRY] = {
            IsGreen = true, Name = "Bearberry",
            Desc = {
                "\1 Damage x1.35",
                "Taking damage has a 1/6 chance to activate {{Collectible704}} Bearzerk!",
            },
        },
        [vegetables.COFFEEBERRY] = {
            IsGreen = true, Name = "Coffeeberry",
            Desc = {
                "\1 +0.2 shotspeed up",
                "\1 +0.2 speed up",
                "{{Blank}} Taking damage has a 15% chance to:",
                "\2 Speeds up the room",
                "Spawns a random pill",
            },
        },
        [vegetables.BLACKCURRANT] = {
            IsGreen = true, Name = "Blackcurrant",
            Desc = {
                "\1 Tear delay x0.8",
                "\1 +0.75 luck up",
                "\2 Range x0.75",
                "{{BlackHeart}} +1 black heart",
            },
        },
        [vegetables.REDCURRANT] = {
            IsGreen = true, Name = "Redcurrant",
            Desc = {
                "\1 Tear delay x0.8",
                "\1 +0.75 luck up",
                "\2 Range x0.75",
                "\1 +1 empty heart container",
            },
        },
        [vegetables.CROWBERRY] = {
            IsGreen = true, Name = "Crowberry",
            Desc = {
                "\1 Damage x1.2",
                "\1 +0.15 speed up",
                "On room clear, 1/3 chance to spawn a random coin, key, heart or bomb",
            },
        },
        [vegetables.BARBERRY] = {
            IsGreen = true, Name = "Barberry",
            Desc = {
                "\1 +2 range up",
                "\1 +0.15 shotspeed up",
                "{{Poison}} When an enemy takes damage, 1/20 chance to get poisoned",
            },
        },
        [vegetables.KRAM_BERRY] = {
            IsGreen = true, Name = "Kram Berry",
            Desc = {
                "Taking damage fires brimstone lasers in the cardinal directions",
                "\1 Tears have a 1/3 chance to gain the {{Collectible132}} Lump of Coal effect",
            },
        },
        [vegetables.CLUMP_OF_HAY] = {
            IsGreen = true, Name = "Clump of Hay",
            Desc = {
                "LVL1: Orbital, deals 50 damage per second",
                "LVL2: Shooting orbital, deals 50 damage per second",
                "LVL3: Haything that slams down on enemies, deals 25 damage per second",
                "Any further copies grant extra LVL3 haythings",
            },
            BirthrightDescMods = {
                {Old="deals 50", New="deals {{ColorLime}}100{{CR}}"},
                {Old="deals 25", New="deals {{ColorLime}}50{{CR}}"},
            }
        },
        [vegetables.SCALLION] = {
            IsGreen = true, Name = "Scallion",
            Desc = {
                "Spawns a horde of piercing scallion head tears that sweep across the room",
                "The scallion tears leave behind tears as they move",
            },
        },
        [vegetables.BABY_CARROT] = {
            IsGreen = true, Name = "Baby Carrot",
            Desc = {
                "\1 +0.1 shotspeed up",
                "Tears have 1/3 chance to become piercing and point at the nearest enemy",
            },
        },
        [vegetables.PYRE_LANTERN] = {
            IsGreen = true, Name = "Pyre Lantern",
            Desc = {
                "Spawns 3 jack-o-lanterns in random positions every uncleared room",
                "On collisions with players or enemies, the lanterns explode in a burst of firejets and a tear geyser",
                "The explosions deal 15 damage, tears deal 3.5 and firejets deal 5",
            },
            BirthrightDescMods = {
                {Old="explosions deal 15", New="explosions deal {{ColorLime}}25{{CR}}"},
                {Old="tears deal 3.5", New="tears deal {{ColorLime}}6{{CR}}"},
                {Old="firejets deal 5", New="firejets deal {{ColorLime}}7.5{{CR}}"},
            }
        },
        [vegetables.CHERRY_ON_TOP] = {
            IsGreen = true, Name = "Cherry on Top",
            Desc = {
                "\1 Stats are rounded up in different increments:",
                "Speed and shotspeed in increments of 0.25",
                "Tears in increments of 0.5",
                "Damage, luck and range in increments of 1",
            },
        },
        [vegetables.OLIVE_OIL] = {
            IsGreen = true, Name = "Olive Oil",
            Desc = {
                "Covers the room in slippery oil creep for 10 seconds",
                "\1 Damage x2 while standing on the creep",
            },
        },
        [vegetables.UNICORNRADISH] = {
            IsGreen = true, Name = "Unicornradish",
            Desc = {
                "\1 While not shooting, slowly gain speed in uncleared rooms",
                "After gaining 1 speed from the bonus, become invincible for 5",
                "While invincible, deal contact damage and leave behind holy light blasts and tear bursts"
            },
        },
        [vegetables.JADEBERRY] = {
            IsGreen = true, Name = "Jadeberry",
            Desc = { "{{Coin}} Spawns 9 Greencoin" },
        },
        [vegetables.PEARRY] = {
            IsGreen = true, Name = "Pearry",
            Desc = { "Spawns 4 Pears" },
        },
        [vegetables.GRAYBERRY] = {
            IsGreen = true, Name = "Grayberry",
            Desc = { "\1 +0.25 speed up" },
        },
        [vegetables.FCUKBERRY] = {
            IsGreen = true, Name = "Fcukberry",
            Desc = {
                "\1 +1 health up",
                "{{Heart}} Heals 1 red heart",
                "Spawns a portal to a random room",
            },
        },
        [items.GREEN_SACK] = {
            IsGreen = false, Name = "Green Sack",
            Desc = {
                "You can store up to 3 green consumables in the sack, used by pressing the respective arrow key",
                "The bottom slot is used for storing green slot machines, used by pressing the DOWN key"
            },
        },
        [items.GUNS_N_ROSES_REVOLVER] = {
            IsGreen = false, Name = "Guns n' Roses - Revolver Form",
            Desc = {
                "Fire basic bullets",
                "Holding down the use button charges up a laser",
                "Press the DROP key to switch to \"Shotgun Form\""
            },
        },
        [items.GUNS_N_ROSES_SHOTGUN] = {
            IsGreen = false, Name = "Guns n' Roses - Shotgun Form",
            Desc = {
                "Fire a burst of short-range bullets",
                "Holding down the use button charges up a lobbed grenade",
                "Press the DROP key to switch to \"Nailgun Form\""
            },
        },
        [items.GUNS_N_ROSES_NAILGUN] = {
            IsGreen = false, Name = "Guns n' Roses - Nailgun Form",
            Desc = {
                "Fire quick, low-damage, homing bullets",
                "You have limited ammo that recharges while not firing",
                "Press the DROP key to switch to \"Railgun Form\""
            },
        },
        [items.GUNS_N_ROSES_RAILGUN] = {
            IsGreen = false, Name = "Guns n' Roses - Railgun Form",
            Desc = {
                "Fire a high-damage laser",
                "The laser has a very long cooldown",
                "Press the DROP key to switch to \"Revolver Form\""
            },
        },
        [items.DIRTY_MONEY] = {
            IsGreen = false, Name = "Dirty Money",
            Desc = {
                "Enemies have a 10% chance to leave behind a greencoin on death",
            },
        },
        [items.PONDERING_ORB] = {
            IsGreen = false, Name = "Pondering Orb",
            Desc = {
                "When using an active item, you fire out a circle of tears proportional to the number of charges",
            },
        },
        [items.LESSER_THAN_G] = {
            IsGreen = false, Name = "<G",
            Desc = {
                "When taking damage, you have a 50% chance to spawn a blockbum, and a further 20% chance to spawn a second one",
            },
        },
        [items.DIRTY_MONEY_DUMMY] = {
            IsGreen = false, Name = "Dirty Money",
            Desc = {
                "Enemies have a 10% chance to leave behind a greencoin on death",
            },
        },
        [items.PONDERING_ORB_DUMMY] = {
            IsGreen = false, Name = "Pondering Orb",
            Desc = {
                "When using an active item, you fire out a circle of tears proportional to the number of charges",
            },
        },
        [items.LESSER_THAN_G_DUMMY] = {
            IsGreen = false, Name = "<G",
            Desc = {
                "When taking damage, you have a 50% chance to spawn a blockbum, and a further 20% chance to spawn a second one",
            },
        },
        [items.BROTHERLY_LOVE] = {
            IsGreen = false, Name = "Brotherly Love",
            Desc = {
                "Gives an invincible Abel blockbum",
                "A second copy gives a Seth blockbum",
            },
        },
        [items.SATANS_BET] = {
            IsGreen = false, Name = "Satan's Bet",
            Desc = {
                "Every room, gives a bet",
                "If you fail the bet, you lose a certain amount of money",
                "At the end of the room, for every unfailed bet, you gain some money depending on the bet's difficulty",
            },
        },
        [items.GOLDEN_EYE] = {
            IsGreen = false, Name = "Golden Eye",
            Desc = {
                "All pickups have a 7.5% chance to falsely appear as golden",
                "Doubles the chance for pickups to be golden",
            },
        },
        [items.GREEN_STAKE] = {
            IsGreen = false, Name = "Green Stake",
            Desc = {
                "At the start of each floor, you can put up to 10 counters on this item",
                "When taking damage, you lose half of the counters, rounded down",
                "For every counter lost, you lose 2 coins",
                "At the start of the next floor, you gain 3 coins for each counter remaining on the item",
            },
        },
        [items.WHEEL_OF_FORTUNE] = {
            IsGreen = false, Name = "Wheel of Fortune",
            Desc = {
                "You spawn a controllable car that explodes upon contact with an enemy",
            },
        },
        [items.JEZREELS_CURSE] = {
            IsGreen = false, Name = "Jezreel's Curse",
            Desc = {
                "Your blue flies are replaced by Flower Buds",
                "Flower Buds deal 3x your damage on contact with an enemy",
            },
        },
        [items.LIL_SILENCE] = {
            IsGreen = false, Name = "Lil Silence",
            Desc = {
                "You gain a mini Silence familiar",
                "He fires 4 tears in a cross shape, rotating each time he fires",
                "Every 6-th shot, he fires an 8-way shot of tears",
            },
        },
        [items.GREEN_THUMB] = {
            IsGreen = false, Name = "Green Thumb",
            Desc = {
                "Rerolls items into green items",
            },
        },
    }

    local cards = mod.CONSUMABLES

    EID_CARDS = {
        [cards.SHARP_STICK] = {
            Name = "Sharp Stick",
            Desc = {
                "Activates a {{Collectible486}} Dull Razor effect",
                "Spawns a blockbum",
            },
        },
        [cards.POTATO_MAGNET] = {
            Name = "Potato Magnet",
            Desc = {
                "All green slot machines are activated twice for free",
                --"All pickups in the room have a chance to be doubled. The chance starts at 100% but is halved every time one is doubled",
                "Every chest in the room has a 50% chance to be opened for free",
            },
        },
        [cards.WEIRD_GUMMY] = {
            Name = "Weird Gummy",
            Desc = {
                "Activates a {{Collectible582}} Wavy Cap effect",
            },
        },
        [cards.BROKEN_DICE] = {
            Name = "Broken G6",
            Desc = {
                "All pickups in the room turn into greencoin, depending on how valuable the pickup is, and each of the greencoin has a 50% chance to instead be a Pear",
                "If greencoin aren't unlocked and none of the players are Green Cain, they're replaced by random coins",
                "If Pears aren't unlocked and none of the players are a green character, they're replaced by random pickups",
            },
        },
        [cards.GLASS_PENNY] = {
            Name = "Glass Penny",
            Desc = {
                "Activates a {{Collectible485}} Crooked Penny effect",
            },
        },
        [cards.FLOWERING_JADE] = {
            Name = "Flowering Jade",
            Desc = {
                "Activates a "..g6Icon.." G6 effect",
            },
        },
    }

    for key, val in pairs(EID_CARDS) do
        local sprite = Sprite()
        sprite:Load("gfx/ui/eidCards.anm2", true)
        sprite:Play(val.Name, true)

        EID:addIcon("Card"..key, val.Name.." Icon", -1, 9, 9, -1, 0, sprite)
    end

    local function turnTextTableIntoDesc(table)
        local s=""

        if(table.IsGreen==true) then s=s..THIS_IS_A_GREEN_ITEM.."#" end
        for _, text in ipairs(table.Desc) do
            s=s..tostring(text).."#"
        end
        s=string.sub(s,0,-2)

        return s
    end

    local function modifyDescriptionValues(desc, values)
        local newDesc = desc
        for i, tab in ipairs(values) do
            newDesc = newDesc:gsub(tab.Old, tab.New)
        end

        return newDesc
    end

    local function canBRightMod(entity, id)
        return (entity.ObjType==5 and entity.ObjVariant==100 and entity.ObjSubType==id) and EID:PlayersHaveCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end
    local function birthrightModCallback(entity)
        local brightMods = EID_DESCRIPTIONS[entity.ObjSubType].BirthrightDescMods
        if(not brightMods) then return entity end
        entity.Description = modifyDescriptionValues(turnTextTableIntoDesc(EID_DESCRIPTIONS[entity.ObjSubType]), brightMods)

        return entity
    end

    for key, data in pairs(EID_DESCRIPTIONS) do
        EID:addCollectible(key, turnTextTableIntoDesc(data), data.Name, "en_us")

        if(data.BirthrightDescMods) then
            EID:addDescriptionModifier(data.Name.." Birthright", function(entity) if(canBRightMod(entity, key)) then return true end end, birthrightModCallback)
        end
    end

    for key, data in pairs(EID_CARDS) do
        EID:addCard(key, turnTextTableIntoDesc(data), data.Name, "en_us")
    end
end