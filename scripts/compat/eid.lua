local mod = jezreelMod

local greenBreakfast = mod.ENUMS.ITEMS.GREEN_BREAKFAST
local greenD6 = mod.ENUMS.ITEMS.G6
local vegetables = mod.ENUMS.VEGETABLES

if EID then
    local greenText = "{{Collectible"..greenD6.."}} {{ColorGreen}}This is a green item!{{CR}}#"
    EID:addCollectible(greenD6, "Rerolls items into various vegetables, fruits and plants", "Green D6", "en_us")
    EID:addCollectible(greenBreakfast, "Does nothing", "Green Breakfast", "en_us")
    EID:addCollectible(vegetables.SAD_CUCUMBER, greenText.."\1 +10% Tear delay down#Tears are accompanied by an extra tear to the left and right", "Sad Cucumber", "en_us")
    EID:addCollectible(vegetables.HOT_POTATO, greenText.."\1 +20% Damage multiplier#\1 +0.3 Speed up#Touching an enemy makes you blow up and removes the item", "Hot Potato", "en_us")
    EID:addCollectible(vegetables.PIZZA_BERRY, greenText.."\1 +10% Damage multiplier#\1 +0.5 Health up#{{Heart}} Heals 1 Red Heart", "Pizza Berry", "en_us")
    EID:addCollectible(vegetables.MILDLY_SPICY_PEPPER, greenText.."\1 +0.2 Shot speed up#{{Burning}} Tears spawn fires on the ground as they travel", "Mildly Spicy Pepper", "en_us")
    EID:addCollectible(vegetables.LEAK, greenText.."\1 +10% Tear delay down#Killing an enemy has a 33% chance to spawn a puddle of pee that randomly bubbles tears", "Leak", "en_us")
    EID:addCollectible(vegetables.SINGLE_PEA, greenText.."Pea familiar that diagonally moves around the room#When the pea collides with a tear it spawns 5 tears in a circle around itself#When the pea collides with an enemy it spawns a burst of tears around itself", "Single Pea", "en_us")
    EID:addCollectible(vegetables.BROCCOLI_MAN, greenText.."Broccoli familiar that spawns in a random position in the room#It deals 3 damage every third of a second to all enemies it collides with", "Broccoli Man", "en_us")
    EID:addCollectible(vegetables.ANCIENT_CARROT, greenText.."\1 20% Damage multiplier#\1 10% Tear delay down#\1 +1 Luck up#\1 +30% Range up#\1 +0.3 Shot speed up#\1 +0.2 Speed up#!!! Retro Vision effect for 60 seconds", "Ancient Carrot", "en_us")
    EID:addCollectible(vegetables.OBNOXIOUS_TANGERINE, greenText.."When used, spawns a Pear pickup#\2 Every 4-6 seconds, spawns an obnoxious dialogue box that blocks vision", "Obnoxious Tangerine", "en_us")
    EID:addCollectible(vegetables.FOUR_DIMENSIONAL_APPLE, greenText.."Gives 4 non-euclidean apple orbitals#When one of them collides with a tear or projectile, all other apples will fire a copy of it", "4-Dimensional Apple", "en_us")
    EID:addCollectible(vegetables.CONFUSING_PEAR, greenText.."All non-consumable pickups are replaced with Pears", "Confusing Pear", "en_us")
    EID:addCollectible(vegetables.POPPED_CORN, greenText.."After 0.66 seconds, tears fired will pop into a burst of 6 tears", "Popped Corn", "en_us")
    EID:addCollectible(vegetables.WATERMELON, greenText.."Tears have a 1/30 chance to turn into a watermelon Bowling Ball#Bowling balls explode and inflict heavy knockback when they hit enemies", "Watermelon", "en_us")
    EID:addCollectible(vegetables.RADISH, greenText.."\1 30% Damage multiplier#\2 20% Tear delay up#\1 +3 Luck up#\1 +20% Range up#\1 +0.2 Shot speed up#\1 +0.2 Speed up", "Radish", "en_us")
    EID:addCollectible(vegetables.JOLLY_MINT, greenText.."Killing an enemy spawns an ice block that blocks projectiles and hinders enemies#{{Slow}} Tears have a 33% chance to Slow enemies", "Jolly Mint", "en_us")
    EID:addCollectible(vegetables.BEESWAX_GOURD, greenText.."Killing an enemy spawns locusts proportional to the enemy's health, and a puddle of slippery creep#{{Slow}} The locust inflicts Slow on enemies", "Beeswax Gourd", "en_us")
    EID:addCollectible(vegetables.GRASS_CLIPPINGS, greenText.."{{HalfHeart}} Heals half of a Red Heart#\1 +0.1 Speed up#!!! The Speed increase is {{ColorYellow}}NOT{{CR}} capped at 2", "Grass Clippings", "en_us")
    EID:addCollectible(vegetables.KEY_LIME, greenText.."Using the Green D6 spawns 1 {{Key}} for every item in the room", "Key Lime", "en_us")
    EID:addCollectible(vegetables.BANANARANG, greenText.."Using the Green D6 fires a bouncy Bananarang projectile at the nearest enemy#You can pick it back up, recharging your D6", "Bananarang", "en_us")
    EID:addCollectible(vegetables.SPIKY_DURIAN, greenText.."Using the Green D6 fires 8 spikes in a circle around Isaac and gives him a {{Fear}} Fear aura for the current room", "Spiky Durian", "en_us")
    EID:addCollectible(vegetables.THE_ONION, greenText.."\1 +5% Tear delay down#\1 +10% Range up#\2 -0.1 Shot speed down#Tears have a small chance to pierce enemies#Tears have a small chance to become spectral#Tears have a chance to confuse enemies", "The Onion", "en_us")
end