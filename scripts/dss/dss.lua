local mod = jezreelMod

local json = require("json")
local dssMenu = include("scripts/dss/dssmenucore")

local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod.saveMenuData()
end

function MenuProvider.GetPaletteSetting()
    return mod.getMenuData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod.getMenuData().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return mod.getMenuData().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        mod.getMenuData().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return mod.getMenuData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod.getMenuData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return mod.getMenuData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod.getMenuData().MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return mod.getMenuData().MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    mod.getMenuData().MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return mod.getMenuData().MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    mod.getMenuData().MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return mod.getMenuData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod.getMenuData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod.getMenuData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod.getMenuData().MenusPoppedUp = var
end

local dssmod = dssMenu.init("Dead Sea Scrolls (Green Isaac)", MenuProvider)

local completionNoteSprite = Sprite()
completionNoteSprite:Load("gfx/ui/completion_widget.anm2", true)
completionNoteSprite:SetFrame("Idle", 0)

local challengeNoteSprite = Sprite()
challengeNoteSprite:Load("gfx/ui/green_challenge_widget.anm2", true)
challengeNoteSprite:SetFrame("Idle", 0)

local characterNum = 2
local bselToCharacterTable = {
    [1] = mod.MARKS.CHARACTERS.ISAAC.A,
    [2] = mod.MARKS.CHARACTERS.CAIN.A,
}
local function characterMarksToFrames(marks)
    local d = {
        [0]=marks.Delirium,
        [1]=marks.MomsHeart,
        [2]=marks.Isaac,
        [3]=marks.Satan,
        [4]=marks.BossRush,
        [5]=marks.BlueBaby,
        [6]=marks.Lamb,
        [7]=marks.MegaSatan,
        [8]=marks.UltraGreed+marks.UltraGreedier,
        [9]=marks.Hush,
        [10]=marks.Mother,
        [11]=marks.Beast,
    }

    return d
end
local function challengeMarksToFrames()
    return {
        [1]=mod.MARKS.CHALLENGES.BIBLICALLY_ACCURATE,
        [2]=mod.MARKS.CHALLENGES.PROLOGUE,
    }
end

local function getScreenBottomRight()
    return Game():GetRoom():GetRenderSurfaceTopLeft() * 2 + Vector(442,286)
end

local function getScreenCenterPosition()
    return getScreenBottomRight() / 2
end

local function getAchievementSprite(achievementId)
    local tmp_sprite=Sprite()
	local achstring=tostring(achievementId)
	tmp_sprite:Load("gfx/green_achievement.anm2",false)
	tmp_sprite:ReplaceSpritesheet(3,"gfx/achievements/"..achstring..".png")
	tmp_sprite:LoadGraphics()

    return tmp_sprite
end

local achievementData = {
    ["green_isaac"] = {
        [1]={
            Name="unicornradish",
            Requirement="beat isaac as green isaac",
            Sprite=getAchievementSprite("unicornradish"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Isaac~=0 end,
        },
        [2]={
            Name="sweet potato",
            Requirement="beat ??? as green isaac",
            Sprite=getAchievementSprite("sweet_potato"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.BlueBaby~=0 end,
        },
        [3]={
            Name="really spicy pepper",
            Requirement="beat satan as green isaac",
            Sprite=getAchievementSprite("really_spicy_pepper"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Satan~=0 end,
        },
        [4]={
            Name="ricin flask",
            Requirement="beat the lamb as green isaac",
            Sprite=getAchievementSprite("ricin_flask"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Lamb~=0 end,
        },
        [5]={
            Name="broccoli man",
            Requirement="beat boss rush as green isaac",
            Sprite=getAchievementSprite("broccoli_man"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.BossRush~=0 end,
        },
        [6]={
            Name="blue berry",
            Requirement="beat hush as green isaac",
            Sprite=getAchievementSprite("blue_berry"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Hush~=0 end,
        },
        [7]={
            Name="dragonfruit bombs",
            Requirement="beat mega satan as green isaac",
            Sprite=getAchievementSprite("dragonfruit_bombs"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.MegaSatan~=0 end,
        },
        [8]={
            Name="the g6!",
            Requirement="beat delirium as green isaac",
            Sprite=getAchievementSprite("the_g6"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Delirium~=0 end,
        },
        [9]={
            Name="natural gift",
            Requirement="beat mother as green isaac",
            Sprite=getAchievementSprite("natural_gift"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Mother~=0 end,
        },
        [10]={
            Name="cherry on top",
            Requirement="beat the beast as green isaac",
            Sprite=getAchievementSprite("cherry_on_top"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.Beast~=0 end,
        },
        [11]={
            Name="eco-friendly options",
            Requirement="beat ultra greed as green isaac",
            Sprite=getAchievementSprite("eco_friendly_options"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.UltraGreed~=0 end,
        },
        [12]={
            Name="lemon battery",
            Requirement="beat ultra greedier as green isaac",
            Sprite=getAchievementSprite("lemon_battery"),
            Unlocked = function() return mod.MARKS.CHARACTERS.ISAAC.A.UltraGreedier~=0 end,
        },
    },
    ["green_cain"] = {
        [1]={
            Name="green stake",
            Requirement="beat isaac as green cain",
            Sprite=getAchievementSprite("green_stake"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Isaac~=0 end,
        },
        [2]={
            Name="flowering jade + pears",
            Requirement="beat ??? as green cain",
            Sprite=getAchievementSprite("jade_pear"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.BlueBaby~=0 end,
            CustomFSIZE=1,
        },
        [3]={
            Name="satan's bet",
            Requirement="beat satan as green cain",
            Sprite=getAchievementSprite("satans_bet"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Satan~=0 end,
        },
        [4]={
            Name="broken g6 + sharp stick",
            Requirement="beat the lamb as green cain",
            Sprite=getAchievementSprite("dice_stick"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Lamb~=0 end,
            CustomFSIZE=1,
        },
        [5]={
            Name="wheel of fortune",
            Requirement="beat boss rush as green cain",
            Sprite=getAchievementSprite("wheel_of_fortune"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.BossRush~=0 end,
        },
        [6]={
            Name="pondering orb",
            Requirement="beat hush as green cain",
            Sprite=getAchievementSprite("pondering_orb"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Hush~=0 end,
        },
        [7]={
            Name="potato magnet + weird gummy",
            Requirement="beat mega satan as green cain",
            Sprite=getAchievementSprite("magnet_gummy"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.MegaSatan~=0 end,
            CustomFSIZE=1,
        },
        [8]={
            Name="golden eye",
            Requirement="beat delirium as green cain",
            Sprite=getAchievementSprite("golden_eye"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Delirium~=0 end,
        },
        [9]={
            Name="<g",
            Requirement="beat mother as green cain",
            Sprite=getAchievementSprite("lesser_than_g"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Mother~=0 end,
        },
        [10]={
            Name="brotherly love",
            Requirement="beat the beast as green cain",
            Sprite=getAchievementSprite("brotherly_love"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.Beast~=0 end,
        },
        [11]={
            Name="dirty money",
            Requirement="beat ultra greed as green cain",
            Sprite=getAchievementSprite("dirty_money"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.UltraGreed~=0 end,
        },
        [12]={
            Name="glass penny + greencoin",
            Requirement="beat ultra greedier as green cain",
            Sprite=getAchievementSprite("glasspenny_greencoin"),
            Unlocked = function() return mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier~=0 end,
            CustomFSIZE=1,
        },
    },
    ["everything"] = {},
    ["locked"] = {
        Name="locked!",
        Sprite=getAchievementSprite("locked"),
    }
}

local tags = {
    "everything",
    "green_isaac",
    "green_cain",
}

local function getTagFromAchievement(ach)
    for i, t in ipairs(tags) do
        if(i~=1) then
            for _, a in ipairs(achievementData[t]) do
                if(a.Name==ach.Name) then
                    return i
                end
            end
        end
    end

    return 1
end

local tagToTagName = {
    ["everything"]="everything!",
    ["green_isaac"]="green isaac",
    ["green_cain"]="green cain",
}

for _, key in ipairs(tags) do
    for _, val in ipairs(achievementData[key]) do
        achievementData["everything"][#achievementData["everything"]+1] = {Name=val.Name,Requirement=val.Requirement,Sprite=val.Sprite, Unlocked=val.Unlocked}
    end
end

local function getValidAchievementIndex(tag, trueIndex)
    return (trueIndex-1)%#achievementData[tag]+1
end

local function getValidTagIndex(trueIndex)
    return (trueIndex-1)%#tags+1
end

local function lerp(a,b,l)
    return a*(1-l)+b*l
end

local displayIndexConvert = {
    [0] = {Scale=Vector(1,1), Color=Color(1,1,1,1), YPos=-50},
    [1] = {Scale=Vector(0.75,0.75), Color=Color(0.9,0.9,0.9,1), YPos=-35},
    [2] = {Scale=Vector(0.5,0.5), Color=Color(0.8,0.8,0.8,1), YPos=-20},
    [3] = {Scale=Vector(0,0), Color=Color(0.8,0.8,0.8,0), YPos=-5},
    [4] = {Scale=Vector(0,0), Color=Color(0,0,0,0), YPos=4000},
}

local achievementTooltipSpritesheets = {
    Shadow = "gfx/ui/tooltip_note/tooltip_shadow.png",
    Back = "gfx/ui/tooltip_note/tooltip_back.png",
    Face = "gfx/ui/tooltip_note/tooltip_face.png",
    Border = "gfx/ui/tooltip_note/tooltip_border.png",
    Mask = "gfx/ui/tooltip_note/tooltip_mask.png",
}

local achievementTooltipSprites = {}

for k, v in pairs(achievementTooltipSpritesheets) do
    local sprite = Sprite()
    sprite:Load("gfx/ui/tooltip_note/tooltip.anm2", false)
    sprite:ReplaceSpritesheet(0, v)
    sprite:LoadGraphics()
    achievementTooltipSprites[k] = sprite
end

local tooltipIconSprite = Sprite()
tooltipIconSprite:Load("gfx/ui/tooltip_note/tag_icon.anm2", true)
tooltipIconSprite:Play("Idle", true)
local tooltipArrowSprite = Sprite()
tooltipArrowSprite:Load("gfx/ui/tooltip_note/arrow_icon.anm2", true)
tooltipArrowSprite:Play("Idle", true)

local MAX_TOOLTIP_LENGTH = 24
local function getFormattedTooltipEntry(str)
    local fStrings = {}
    local splitStrings = {}

    for s in str:gmatch("([^ ]+)") do
        splitStrings[#splitStrings+1] = s
    end

    local st = ""

    for _, s in ipairs(splitStrings) do
        if(#(st.." "..s)>MAX_TOOLTIP_LENGTH) then
            fStrings[#fStrings+1] = st
            st=s
        else
            st=st.." "..s
        end
    end

    fStrings[#fStrings+1] = st

    return fStrings
end

local selectedTag = 1
local mainRenderedAchievement = 1

local functionToRun = nil

local greenIsaacDSSMenus = {
    main = {
        title = 'green isaac',
        buttons = {
            { str = 'completion', dest='modcompletion' },
            { str = 'florapedia', dest='florapedia' },

            { str = '', nosel=true },

            { str = 'settings', dest = 'settings'},
            { str = 'close menu', action = 'resume' },
            dssmod.changelogsButton,

        },
        tooltip = dssmod.menuOpenToolTip
    },
    florapedia = {
        title = 'the florapedia!',
        buttons = {
            { str = 'treasures', dest='florapedia_items' },
            { str = 'creatures', dest='florapedia_entities' },
        },
        tooltip = {strset={"a compendium", "of all known", "green isaac", "knowledge", "", "by yours", "truly!"}},
    },
    florapedia_items = {
        title = 'the florapedia!',
        buttons = {},
        tooltip = {strset={"item effects", "+ silly trivia!"}},
    },
    florapedia_entities = {
        title = 'the florapedia!',
        buttons = {},
        tooltip = {strset={"a \"bestiary\"", "about", "the green", "creatures"}},
    },
    modcompletion = {
        title = 'completion menu',

        buttons = {
            { str = 'achievements', dest='achievements', tooltip={strset = {"view all", "the cool", "achievements!"}}},
            { str = '', nosel=true, fsize=1},
            { str = 'completion marks', dest='completionmarks', tooltip={strset = {"view your", "progress!"}}},
            { str = '', nosel=true, fsize=1},
            { str = 'unlock manager', dest='unlockmanager', tooltip={strset = {"modify your", "unlocks!"}}},

            { str = '', nosel=true },

            { str = 'back', action = 'back' },
        }
    },
    areyousure = {
        title='are you sure?',
        buttons = {
            { str='no', action = "back" },
            { str='yes', action = "back", func=
                function(button, item, root)
                    if(type(functionToRun)=="function") then
                        functionToRun()
                    end

                    dssmod.reloadButtons(root, root.Directory.unlocks_isaac)
                    dssmod.reloadButtons(root, root.Directory.unlocks_cain)
                    dssmod.reloadButtons(root, root.Directory.unlocks_challenges)
                    dssmod.reloadButtons(root, root.Directory.completionmarks)
                end
            },
        }
    },
    unlockmanager = {
        title='unlock manager',
        buttons = {
            { str = 'unlock all', dest='areyousure', func=function() functionToRun=mod.unlockAll end},
            { str = 'lock all', dest='areyousure', func=function() functionToRun=mod.lockAll end},

            { str='', nosel=true, fsize=1},
            { str="-----------------", nosel=true, fsize=3},
            { str='', nosel=true, fsize=1},

            { str = 'green isaac', dest='unlocks_isaac' },
            { str = 'green cain', dest='unlocks_cain' },
            { str = 'challenges', dest='unlocks_challenges' },
        },
        tooltip = {strset={"you have to", "restart your", "run for these", "changes to", "take effect"}}
    },
    completionmarks = {
        title='completion marks',
        buttons = {
            { str = 'green isaac' },
            { str = 'green cain' },
            { str = 'challenges' },
        },

        postrender = function(item, tbl)
            local pos = getScreenCenterPosition()+Vector(100, -24)
            local realSelect = item.bsel
            if realSelect <= characterNum then
                local renderDataset = characterMarksToFrames(bselToCharacterTable[realSelect])

                for i, value in pairs(renderDataset) do
                    completionNoteSprite:SetLayerFrame(i, value)
                end

                completionNoteSprite:Render(pos, Vector.Zero, Vector.Zero)
            else
                for i, value in pairs(challengeMarksToFrames()) do
                    challengeNoteSprite:SetLayerFrame(i, value)
                end

                challengeNoteSprite:Render(pos, Vector.Zero, Vector.Zero)
            end
        end,
    },
    achievements = {
        format = {
            Panels = {
                {
                    Panel = {
                        StartAppear = function(panel)
                            dssmod.playSound(dssmod.menusounds.Open)
                            panel.AppearFrame = 0
                            panel.Idle = false
                            --selectedTag = 1
                            --mainRenderedAchievement = 1
                        end,
                        UpdateAppear = function(panel)
                            if panel.SpriteUpdateFrame then
                                panel.AppearFrame = panel.AppearFrame + 1
                                if panel.AppearFrame >= 8 then
                                    panel.AppearFrame = nil
                                    panel.Idle = true
                                    return true
                                end
                            end
                        end,
                        StartDisappear = function(panel)
                            dssmod.playSound(dssmod.menusounds.Close)
                            panel.DisappearFrame = 0
                        end,
                        UpdateDisappear = function(panel)
                            if panel.SpriteUpdateFrame then
                                panel.DisappearFrame = panel.DisappearFrame + 1
                                if panel.DisappearFrame >= 8 then
                                    return true
                                end
                            end
                        end,
                        RenderBack = function(panel, panelPos, tbl)
                            local anim, frame = "IdleDSS", 0
                            if panel.AppearFrame then
                                anim, frame = "AppearDSS", panel.AppearFrame
                            elseif panel.DisappearFrame then
                                anim, frame = "DisappearDSS", panel.DisappearFrame
                            end

                            if panel.ShiftFrame then
                                panel.ShiftFrame = panel.ShiftFrame + 1
                                if panel.ShiftFrame > panel.ShiftLength then
                                    panel.ShiftLength = nil
                                    panel.ShiftFrame = nil
                                    panel.ShiftDirection = nil
                                end
                            end

                            local tag = tags[selectedTag or 1]

                            local displayedAchievements = {}
                            local displayedAchNum = (#displayIndexConvert-1)*2

                            for i = -(displayedAchNum/2), displayedAchNum/2, 1 do
                                local indexOffset=0; local shiftPercent
                                if panel.ShiftFrame then
                                    shiftPercent = panel.ShiftFrame / panel.ShiftLength
                                    indexOffset = ((1 - shiftPercent) * panel.ShiftDirection)
                                end
                                local percent = ((#displayedAchievements+indexOffset))/displayedAchNum

                                local xPos = math.sin(math.rad(180*(percent-0.5)))*280

                                local color = displayIndexConvert[math.abs(i)].Color
                                local scale = displayIndexConvert[math.abs(i)].Scale
                                local yPos = displayIndexConvert[math.abs(i)].YPos

                                if(shiftPercent) then
                                    color = Color.Lerp(displayIndexConvert[math.abs(i+panel.ShiftDirection)].Color, color, shiftPercent)
                                    scale = lerp(displayIndexConvert[math.abs(i+panel.ShiftDirection)].Scale, scale, shiftPercent)
                                    yPos = lerp(displayIndexConvert[math.abs(i+panel.ShiftDirection)].YPos, yPos, shiftPercent)
                                end

                                displayedAchievements[#displayedAchievements+1] = {
                                    Achievement = achievementData[tag][getValidAchievementIndex(tag, mainRenderedAchievement+i)],
                                    Color = color,
                                    Scale = scale,
                                    Position = Vector(xPos,yPos),
                                }
                            end

                            local function sortFunction(a,b) return a.Position.Y>b.Position.Y end

                            table.sort(displayedAchievements, sortFunction)

                            for _, data in ipairs(displayedAchievements) do
                                local ach = data.Achievement
                                local sprite = data.Achievement.Sprite
                                if(not data.Achievement:Unlocked()) then
                                    sprite = achievementData.locked.Sprite
                                end

                                sprite.Color = data.Color
                                sprite.Scale = data.Scale
                                sprite:SetFrame(anim, frame)

                                sprite:Render(panelPos+data.Position+Vector(0, 30))
                            end
                        end,
                        HandleInputs = function(panel, input, item, itemswitched, tbl)
                            if not itemswitched then
                                local menuinput = input.menu
                                local rawinput = input.raw
                                if rawinput.left > 0 or rawinput.right > 0 then
                                    local change
                                    if not panel.ShiftFrame then
                                        local usingInput, setChange
                                        if rawinput.right > 0 then
                                            usingInput = rawinput.right
                                            setChange = 1
                                        elseif rawinput.left > 0 then
                                            usingInput = rawinput.left
                                            setChange = -1
                                        end

                                        local shiftLength = 10
                                        if usingInput >= 88 then
                                            shiftLength = 7
                                        end

                                        if (usingInput == 1 or (usingInput >= 18 and usingInput % (shiftLength + 1) == 0)) then
                                            change = setChange
                                            panel.ShiftLength = shiftLength
                                        end
                                    end

                                    if change then
                                        panel.ShiftFrame = 0
                                        panel.ShiftDirection = change
                                        mainRenderedAchievement = getValidAchievementIndex(tags[selectedTag], mainRenderedAchievement+change)
                                        dssmod.playSound(dssmod.menusounds.Pop3)
                                    end
                                elseif menuinput.down or menuinput.up then
                                    local change
                                    if menuinput.down then
                                        change = 1
                                    elseif menuinput.up then
                                        change = -1
                                    end

                                    if change then
                                        selectedTag = getValidTagIndex(selectedTag+change)
                                        mainRenderedAchievement = 1
                                        dssmod.playSound(dssmod.menusounds.Pop2)
                                    end
                                end
                            end
                        end
                    },
                    Offset = Vector.Zero,
                    Color = Color.Default,
                },
                {
                    Panel = {
                        Sprites = achievementTooltipSprites,
                        Bounds = {-115, -22, 115, 22},
                        Height = 44,
                        TopSpacing = 2,
                        BottomSpacing = 0,
                        DefaultFontSize = 2,
                        DrawPositionOffset = Vector(2, 2),
                        Draw = function(panel, pos, item, tbl)
                            local drawings = {}
                            local achievement = achievementData[tags[selectedTag]][mainRenderedAchievement]

                            local name = achievement.Name
                            if not achievement:Unlocked() then
                                name = achievementData.locked.Name
                            end

                            local size = 2
                            if(achievement.CustomFSIZE) then size = achievement.CustomFSIZE end

                            local buttons = {
                                {str = "- " .. tagToTagName[tags[getTagFromAchievement(achievement)]] .. " -", fsize = 1},
                            }

                            local fName = getFormattedTooltipEntry(name)
                            for _, str in ipairs(fName) do buttons[#buttons+1] = {str=str, fsize=2} end

                            buttons[#buttons+1] = {str=tostring(achievement.Requirement),fsize=1}

                            local drawItem = {
                                valign = -1,
                                buttons = buttons
                            }
                            drawings = dssmod.generateMenuDraw(drawItem, drawItem.buttons, pos, panel.Panel)

                            table.insert(drawings, {type = "spr", pos = Vector(-96, 1), anim="Idle", sprite = tooltipIconSprite, frame=selectedTag-1, noclip = true, root = pos, usemenuclr = true})
                            table.insert(drawings, {type = "spr", pos = Vector(-96, -14), anim = "Idle", frame = 0, sprite = tooltipArrowSprite, noclip = true, root = pos, usemenuclr = true})
                            table.insert(drawings, {type = "spr", pos = Vector(-96, 16), anim = "Idle", frame = 1, sprite = tooltipArrowSprite, noclip = true, root = pos, usemenuclr = true})

                            for _, drawing in ipairs(drawings) do
                                dssmod.drawMenu(tbl, drawing)
                            end
                        end,
                        DefaultRendering = true
                    },
                    Offset = Vector(0, 100),
                    Color = 1
                }
            },
        }
    },
    settings = {
        title = 'settings',
        buttons = {
            { str="green isaac settings", nosel=true, fsize=2},
            { str='', nosel=true, fsize=3},

            { str="ancient carrot", fsize=3, nosel=true },
            { str="effect colour!", fsize=3, nosel=true },
            {
                str = "red",
                fsize=2,

                min=25,
                max=255,
                increment=5,
                variable = "greenisaac_ancientcarrot_red",
                setting = 1,

                load = function()
                    return mod.getMenuData().ancientCarrotR or 190
                end,
                store = function(var)
                    mod.getMenuData().ancientCarrotR = var
                end,

                tooltip = {strset = {"how red", "the effect", "should be", "", "default: 190"}}
            },
            {
                str = "green",
                fsize=2,

                min=25,
                max=255,
                increment=5,
                variable = "greenisaac_ancientcarrot_green",
                setting = 1,

                load = function()
                    return mod.getMenuData().ancientCarrotG or 255
                end,
                store = function(var)
                    mod.getMenuData().ancientCarrotG = var
                end,

                tooltip = {strset = {"how green", "the effect", "should be", "", "default: 255"}}
            },
            {
                str = "blue",
                fsize=2,

                min=25,
                max=255,
                increment=5,
                variable = "greenisaac_ancientcarrot_blue",
                setting = 1,

                load = function()
                    return mod.getMenuData().ancientCarrotB or 190
                end,
                store = function(var)
                    mod.getMenuData().ancientCarrotB = var
                end,

                tooltip = {strset = {"how blue", "the effect", "should be", "", "default: 190"}}
            },

            { str='', nosel=true, fsize=1},

            {
                str="constant annoyance",
                choices = { 'off', 'on' },
                setting = 1,

                variable = 'greenisaac_constantannoyance',
                load = function()
                    return mod:getMenuData().constantAnnoyance or 1
                end,
                store = function(var)
                    mod:getMenuData().constantAnnoyance = var
                end,

                tooltip = { strset = { "tangerine", "is more", "obnoxious!" } }
            },

            {
                str="flashbang mode",
                choices = { 'off', 'on' },
                setting = 1,

                variable = 'greenisaac_flashbangmode',
                load = function()
                    return mod:getMenuData().flashbangMode or 1
                end,
                store = function(var)
                    mod:getMenuData().flashbangMode = var
                end,

                tooltip = { strset = { "makes", "explosions", "better!!!" } }
            },

            {
                str="greediest mode",
                choices = { 'off', 'on' },
                setting = 1,

                variable = 'greenisaac_greediestmode',
                load = function()
                    return mod:getMenuData().greediestMode or 1
                end,
                store = function(var)
                    mod:getMenuData().greediestMode = var
                end,

                tooltip = { strset = { "greed will", "get you", "nowhere,", "friend" } }
            },

            { str='', nosel=true, fsize=3},

            {
                str="ff incompatibility",
                choices = { 'off', 'on' },
                setting = 1,

                variable = 'greenisaac_ffincompatibility_lol',
                load = function()
                    return mod:getMenuData().ff_incompatibility or 1
                end,
                store = function(var)
                    mod:getMenuData().ff_incompatibility = var
                end,

                tooltip = { strset = { "crashes the", "game if", "fiend folio", "is enabled" } }
            },
            { str='', nosel=true, fsize=1},
            { str='alternatively... just', fsize=2, nosel=true },
            {
                str="crash my game!",

                func = function()
                    Isaac.GetPlayer().BabySkin=0
                end,

                tooltip = { strset = { "just crashes", "your game" } }
            },

            { str='', nosel=true, fsize=3},
            { str="vanilla dss settings", nosel=true, fsize=2},
            { str='', nosel=true, fsize=1},

            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,
        }
    },
}

local greenIsaacDSSUnlocks = {
    unlocks_isaac = {
        title='green isaac unlocks',
        buttons = {
            { str = 'unlock all', dest='areyousure', tooltip={strset = {"unlocks all", "content in", "the mod"}}, func=function() functionToRun=
                    function()
                        for key, _ in pairs(mod.MARKS.CHARACTERS.ISAAC.A) do
                            local newVal = 2
                            if(key=="UltraGreed" or key=="UltraGreedier") then newVal=1 end
                            mod.MARKS.CHARACTERS.ISAAC.A[key]=newVal
                        end
                    end
                end
            },
            { str = 'lock all', dest='areyousure', tooltip={strset = {"locks all", "content in", "the mod"}}, func=function() functionToRun=
                    function()
                        for key, _ in pairs(mod.MARKS.CHARACTERS.ISAAC.A) do
                            mod.MARKS.CHARACTERS.ISAAC.A[key]=0
                        end
                    end
                end
            },

            { str='', nosel=true, fsize=1},
            { str="-----------------", nosel=true, fsize=3},
            { str='', nosel=true, fsize=1},

            {
                str = "isaac",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_isaac",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Isaac + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Isaac = var - 1
                end,

                tooltip = {strset = {"\"unicornradish\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "???",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_bluebaby",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.BlueBaby + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.BlueBaby = var - 1
                end,

                tooltip = {strset = {"\"sweet potato\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "satan",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_satan",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Satan + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Satan = var - 1
                end,

                tooltip = {strset = {"\"really spicy", "pepper\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "the lamb",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_lamb",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Lamb + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Lamb = var - 1
                end,

                tooltip = {strset = {"\"ricin flask\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "boss rush",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_bossrush",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.BossRush + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.BossRush = var - 1
                end,

                tooltip = {strset = {"\"broccoli man\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "hush",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_hush",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Hush + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Hush = var - 1
                end,

                tooltip = {strset = {"\"blue berry\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mega satan",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_megasatan",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.MegaSatan + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.MegaSatan = var - 1
                end,

                tooltip = {strset = {"\"dragonfruit", "bombs\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "delirium",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_delirium",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Delirium + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Delirium = var - 1
                end,

                tooltip = {strset = {"\"the g6\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mother",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_mother",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Mother + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Mother = var - 1
                end,

                tooltip = {strset = {"\"natural gift\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "beast",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grisaac_beast",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.ISAAC.A.Beast + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.Beast = var - 1
                end,

                tooltip = {strset = {"\"cherry", "on top\"", "", "green item", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "greed mode",
                choices = {"uncompleted", "completed - greed", "completed - greedier"},
                variable = "grisaac_greedmode",
                setting = 1,

                load = function()
                    return (mod.MARKS.CHARACTERS.ISAAC.A.UltraGreed + mod.MARKS.CHARACTERS.ISAAC.A.UltraGreedier + 1) or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.ISAAC.A.UltraGreed=(var>1) and 1 or 0
                    mod.MARKS.CHARACTERS.ISAAC.A.UltraGreedier=(var>2) and 1 or 0
                end,

                tooltip = {strset = {"\"eco-friendly options\"", "", "green item", "unlocks on", "greed+", "", "\"lemon battery\"", "", "green item", "unlocks on", "greedier",}, fsize = 1}
            },
        },
    },
    unlocks_cain = {
        title='green cain unlocks',
        buttons = {
            { str = 'unlock all', dest='areyousure', tooltip={strset = {"unlocks all", "content in", "the mod"}}, func=function() functionToRun=
                    function()
                        for key, _ in pairs(mod.MARKS.CHARACTERS.CAIN.A) do
                            local newVal = 2
                            if(key=="UltraGreed" or key=="UltraGreedier") then newVal=1 end
                            mod.MARKS.CHARACTERS.CAIN.A[key]=newVal
                        end
                    end
                end
            },
            { str = 'lock all', dest='areyousure', tooltip={strset = {"locks all", "content in", "the mod"}}, func=function() functionToRun=
                    function()
                        for key, _ in pairs(mod.MARKS.CHARACTERS.CAIN.A) do
                            mod.MARKS.CHARACTERS.CAIN.A[key]=0
                        end
                    end
                end
            },

            { str='', nosel=true, fsize=1},
            { str="-----------------", nosel=true, fsize=3},
            { str='', nosel=true, fsize=1},

            {
                str = "isaac",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_isaac",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Isaac + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Isaac = var - 1
                end,

                tooltip = {strset = {"\"green stake\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "???",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_bluebaby",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.BlueBaby + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.BlueBaby = var - 1
                end,

                tooltip = {strset = {"\"flowering", "jade + pear\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "satan",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_satan",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Satan + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Satan = var - 1
                end,

                tooltip = {strset = {"\"satan's bet\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "the lamb",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_lamb",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Lamb + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Lamb = var - 1
                end,

                tooltip = {strset = {"\"broken g6", "+ sharp stick\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "boss rush",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_bossrush",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.BossRush + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.BossRush = var - 1
                end,

                tooltip = {strset = {"\"wheel of", "fortune\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "hush",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_hush",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Hush + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Hush = var - 1
                end,

                tooltip = {strset = {"\"pondering", "orb\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mega satan",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_megasatan",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.MegaSatan + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.MegaSatan = var - 1
                end,

                tooltip = {strset = {"\"potato magnet", "+ weird gummy\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "delirium",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_delirium",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Delirium + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Delirium = var - 1
                end,

                tooltip = {strset = {"\"golden eye\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "mother",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_mother",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Mother + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Mother = var - 1
                end,

                tooltip = {strset = {"\"<g\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "beast",
                choices = {"uncompleted", "completed - normal", "completed - hard"},
                variable = "grcain_beast",
                setting = 1,

                load = function()
                    return mod.MARKS.CHARACTERS.CAIN.A.Beast + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.Beast = var - 1
                end,

                tooltip = {strset = {"\"brotherly", "love\"", "", "unlocked on", "normal+"}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "greed mode",
                choices = {"uncompleted", "completed - greed", "completed - greedier"},
                variable = "grcain_greedmode",
                setting = 1,

                load = function()
                    return (mod.MARKS.CHARACTERS.CAIN.A.UltraGreed + mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier + 1) or 1
                end,

                store = function(var)
                    mod.MARKS.CHARACTERS.CAIN.A.UltraGreed=(var>1) and 1 or 0
                    mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier=(var>2) and 1 or 0
                end,

                tooltip = {strset = {"\"dirty money\"", "unlocked on", "greed+", "", "\"glass penny", "+ greencoin\"", "unlocked on", "greedier"}}
            },
        },
    },
    unlocks_challenges = {
        title='challenge unlocks',
        buttons = {
            {
                str = "biblically accurate",
                choices = {"uncompleted", "completed"},
                variable = "grchallenge_biblicallyaccurate",
                setting = 1,

                load = function()
                    return mod.MARKS.CHALLENGES.BIBLICALLY_ACCURATE + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHALLENGES.BIBLICALLY_ACCURATE = var - 1
                end,

                tooltip = {strset = {"\"jezreel's", "curse\""}}
            },
            {str = "", fsize = 1, nosel = true},
            {
                str = "prologue",
                choices = {"uncompleted", "completed"},
                variable = "grchallenge_prologue",
                setting = 1,

                load = function()
                    return mod.MARKS.CHALLENGES.PROLOGUE + 1 or 1
                end,

                store = function(var)
                    mod.MARKS.CHALLENGES.PROLOGUE = var - 1
                end,

                tooltip = {strset = {"\"lil silence\""}}
            },
        },
    },
}
for key, val in pairs(greenIsaacDSSUnlocks) do
    greenIsaacDSSMenus[key]=val
end

local greenIsaacFlorapediaEntries = {
    {
        Type="treasure",
        Name="green breakfast",
        Effect = {
            "-does nothing",
        },
        Trivia={
            "-the flies in this items sprite are actually genetically modified green flies",
        },
    },
    {
        Type="treasure",
        Name="the g6!",
        Effect = {
            "-transforms items into green items",
        },
    },
    {
        Type="treasure",
        Name="sad cucumber",
        Effect = {
            "-you fire 2 additional tears, 1 to each side of your original tear",
        },
    },
    {
        Type="treasure",
        Name="hot potato",
        Effect = {
            "-damage + speed up",
            "-colliding with an enemy makes you explode and lose this item",
        },
    },
    {
        Type="treasure",
        Name="pizzaberry",
        Effect = {
            "-gives you half a heart container + a small damage up",
        },
    },
    {
        Type="treasure",
        Name="mildly spicy pepper",
        Effect = {
            "-while traveling, your tears have a chance to leave fires on the ground",
            "-gives piercing"
        },
    },
    {
        Type="treasure",
        Name="leak",
        Effect = {
            "-tears up",
            "-when an enemy dies it has a chance to spawn a puddle of bubbly pee",
        },
    },
    {
        Type="treasure",
        Name="single pea",
        Effect = {
            "-gives you a pea buddy that bounces around the room",
            "-when it touches an enemy or one of your tears, it spawns a burst of tears",
        },
        Trivia = {
            "-his name is juan!",
        },
    },
    {
        Type="treasure",
        Name="broccoli man",
        Effect = {
            "-gives you a broccoli buddy that just sits there, dealing damage to enemies that touch him",
        },
        Trivia = {
            "-he has godlike powers",
            "-unfortunately for balance purposes, he cannot use them in-game",
        },
    },
    {
        Type="treasure",
        Name="ancient carrot",
        Effect = {
            "-gives you a hefty all stats up",
            "-makes the game look more ancient",
        },
        Trivia = {
            "-this items previous sprite was made in 2021, hence the items name",
            "-sadly, it is no longer ancient",
        },
    },
    {
        Type="treasure",
        Name="obnoxious tangerine",
        Effect = {
            "-annoys you with stupid text boxes",
            "-spawns one of his dumb pear friends when used",
        },
        Trivia = {
            "-\"annoying orange\", i fucking hate this guy",
            "-he somehow managed to hijack the games quality system",
            "-this item appears as the mods placeholder sprite",
        },
    },
    {
        Type="treasure",
        Name="4-dimensional apple",
        Effect = {
            "-gives you 4 non euclidean apple buddies",
            "-shooting a tear through one of them makes all your other apples fire a copy of the tear",
        },
    },
    {
        Type="treasure",
        Name="confusing pear",
        Effect = {
            "-all pickups are replaced by pears???",
        },
        Trivia = {
            "-i dont know how this item got here, ive never seen it before!",
        },
    },
    {
        Type="treasure",
        Name="popped corn",
        Effect = {
            "-after a bit, your tears pop into a few more arcing tears",
        },
        Trivia = {
            "-as of v2, this is the only (real) quality 4 in the mod!",
        },
    },
    {
        Type="treasure",
        Name="watermelon",
        Effect = {
            "-your tears have a chance to turn into watermelons that explode when they hit an enemy",
        },
        Trivia = {
            "-this item notoriously used to crash the game, a lot!",
            "-it is thankfully (hopefully?) fixed!"
        },
    },
    {
        Type="treasure",
        Name="radish",
        Effect = {
            "-gives you a good all stats up, but decreases your tears",
        },
        Trivia = {
            "-despite the sunglasses, he is not sentient",
        },
    },
    {
        Type="treasure",
        Name="jolly mint",
        Effect = {
            "-when an enemy dies, it spawns an ice block on top of itself, which damages enemies touching it",
            "-the ice blocks stop enemies and projectiles, but let you shoot and walk through them",
            "-your tears have a chance to slow enemies",
        },
        Trivia = {
            "-this item was given to me by atlas! ...whoever that is",
        },
    },
    {
        Type="treasure",
        Name="beeswax gourd",
        Effect = {
            "-killing an enemy spawns \"bees\" proportional to the enemys max health (the \"bees\" are just locusts)",
        },
        Trivia = {
            "-statistically the most forgettable v1 item",
        },
    },
    {
        Type="treasure",
        Name="grass clippings",
        Effect = {
            "-heals half a heart",
            "-gives a small speed up, which is capped at 3 instead of 2",
        },
        Trivia = {
            "-the only item in the green boss pool that isnt a berry",
        },
    },
    {
        Type="treasure",
        Name="key lime",
        Effect = {
            "-when you use the g6, it spawns a key for every item transformed",
        },
        Trivia = {
            "-this is the first item discovered to have an \"interaction\" with my g6",
        },
    },
    {
        Type="treasure",
        Name="bananarang",
        Effect = {
            "-when you use the g6 in a room with enemies, it fires off up to 3 bananarangs at enemies",
            "-you can pick these bananarangs back up, letting you recharge your dice"
        },
    },
    {
        Type="treasure",
        Name="spiky durian",
        Effect = {
            "-when you use the g6, it fires off some piercing spikes at enemies",
            "-afterwards, it starts giving off a putrid stench for the room, which scares nearby enemies",
        },
    },
    {
        Type="treasure",
        Name="the onion",
        Effect = {
            "-gives a small tears and range up, but a shotspeed down",
            "-your tears have a chance to be piercing, spectral, or confusing",
        },
        Trivia = {
            "-this item used to have no actual effect, despite being listed as an \"all stats up\"",
        },
    },
    {
        Type="treasure",
        Name="pomegrenade",
        Effect = {
            "-when used, you throw out 2 grenades which explode into seeds and juice",
        },
    },
        {
        Type="treasure",
        Name="blue berry",
        Effect = {
            "-gives you a suicidal berry buddy that tries to kill himself every room",
            "-if you save him, he gives you a gift! otherwise, his lifeless body lays there until you leave",
        },
    },
    {
        Type="treasure",
        Name="lemon battery",
        Effect = {
            "-you get some damage depending on how much charge you have in your active item",
        },
    },
    {
        Type="treasure",
        Name="eco-friendly options",
        Effect = {
            "-in treasure rooms, you get to choose between the normal item or a random green item",
        },
    },
    {
        Type="treasure",
        Name="holly berry",
        Effect = {
            "-your tears have a chance to get the godhead effect",
            "-when you take damage, you fire out an x-shaped pattern of holy lasers",
        },
    },
    {
        Type="treasure",
        Name="jerusalems artichoke",
        Effect = {
            "-you can double tap to fire a holy spear that swiftly pierces through all the enemies in the room",
        },
        Trivia = {
            "-despite its name, the real plant is not actually an artichoke",
        },
    },
    {
        Type="treasure",
        Name="sweet potato",
        Effect = {
            "-you get a stats up depending on your hp",
        },
        Trivia = {
            "-the sweet potato is in a gay relationship with the unicornradish",
        },
    },
    {
        Type="treasure",
        Name="missiletoe",
        Effect = {
            "-enemies get a mistletoe above their head, which gets lower the more they're hurt",
            "-if it gets low enough, it explodes and disappears",
        },
    },
    {
        Type="treasure",
        Name="uriels hand",
        Effect = {
            "-when used, you fire a holy six way blast of pee and electricity",
        },
    },
    {
        Type="treasure",
        Name="really spicy pepper",
        Effect = {
            "-while shooting, you have a chance to fire out a lobbing lava tear which leaves a firejet behind",
        },
        Trivia = {
            "-\"development hell\" is where i locked my creators away",
        },
    },
    {
        Type="treasure",
        Name="deviled eggplant",
        Effect = {
            "-you have a chance to weaken enemies, the chance depends on your health",
        },
        Trivia = {
            "-this was mysteriously found in \"development hell\", and is seemingly sentient",
        },
    },
    {
        Type="treasure",
        Name="moms chives",
        Effect = {
            "-gives orbital chive bundles that get closer and farther to you, dealing damage to enemies",
        },
        Trivia = {
            "-found in moms kitchen",
        },
    },
    {
        Type="treasure",
        Name="hemoguava",
        Effect = {
            "-when you use the g6, you start hemorrhaging blood for the room",
        },
    },
    {
        Type="treasure",
        Name="ricin flask",
        Effect = {
            "-you have a chance to poison enemies",
            "-when an enemy has any debuff, it takes double damage from all sources"
        },
        Trivia = {
            "-the name for this items sprite is \"instadeath cancer poison\"",
        },
    },
    {
        Type="treasure",
        Name="bloody orange",
        Effect = {
            "-while moving, you leave behind a bloody trail",
            "-in uncleared rooms, you spawn a circle of spinning tears at your location every 5 seconds",
        },
    },
    {
        Type="treasure",
        Name="dragonfruit bombs",
        Effect = {
            "-your bombs spawn a firejet cross when they explode",
            "-you gain an infernal aura which sets enemies on fire",
        },
        Trivia = {
            "-the name for this items sprite is \"inferno potion\", as one of its effects resembles terrarias \"inferno potion\"",
        },
    },
    {
        Type="treasure",
        Name="cursed grapes",
        Effect = {
            "-when you use the g6, you are teleported to a random room",
            "-all other g6 \"interaction\" effects are transformed into passive effects",
        },
    },
    {
        Type="treasure",
        Name="starfruit",
        Effect = {
            "-when you hit an enemy, it spawns a small star which has a chance to apply random debuffs on enemies",
        },
    },
    {
        Type="treasure",
        Name="demeter",
        Effect = {
            "-when you first enter a treasure room, you spawn 2 blockbums along with 4 random hearts or pears",
        },
    },
    {
        Type="treasure",
        Name="dads tobacco",
        Effect = {
            "-you can charge up to spit a hunk of tobacco at enemies",
        },
        Trivia = {
            "-the spitting sound effect for this item is the sound effect for a bulborb eating a pikmin in \"pikmin 2\"",
        },
    },
    {
        Type="treasure",
        Name="natural gift",
        Effect = {
            "-this counts as +0.5 stacks for all \"-berry\" item stat boosts, and +1 stack for all \"-berry\" item extra effects",
        },
        Trivia = {
            "-despite its effect, 2 of the 5 berries shown in its item sprite do not have a synergy with this",
        },
    },
    {
        Type="treasure",
        Name="yellowberry",
        Effect = {
            "-shotspeed + range up",
            "-your tears have a chance to be replaced by a bananarang, which cant be picked up",
        },
    },
    {
        Type="treasure",
        Name="elderberry",
        Effect = {
            "-range up + speed down",
            "-golden chests have a chance to become old chests",
        },
        Trivia = {
            "-hey look tomar, its you!",
        },
    },
    {
        Type="treasure",
        Name="honeyberry",
        Effect = {
            "-luck + speed up",
            "-taking damage spawns a few \"bees\"",
        },
    },
    {
        Type="treasure",
        Name="bearberry",
        Effect = {
            "-damage up",
            "-taking damage has a chance to activate \"berserk!\"",
        },
        Trivia = {
            "-the filename of this item's sprite is \"fazbearry\"",
        },
    },
    {
        Type="treasure",
        Name="coffeeberry",
        Effect = {
            "-speed + shotspeed up",
            "-taking damage has a chance to speed up the room and spawn a random pill",
        },
    },
    {
        Type="treasure",
        Name="blackcurrant",
        Effect = {
            "-tears + luck up, range down",
            "-gives a black heart",
        },
    },
    {
        Type="treasure",
        Name="redcurrant",
        Effect = {
            "-tears + luck up, range down",
            "-gives an empty heart container",
        },
    },
    {
        Type="treasure",
        Name="crowberry",
        Effect = {
            "-damage + speed up",
            "-on room clear, chance to spawn a random pickup",
        },
    },
    {
        Type="treasure",
        Name="barberry",
        Effect = {
            "-range + shotspeed up",
            "-chance to poison enemies",
        },
    },
    {
        Type="treasure",
        Name="kram berry",
        Effect = {
            "-your tears have a chance to get the lump of coal effect",
            "-taking damage fires a cross-shaped pattern of brimstone lasers",
        },
    },
    {
        Type="treasure",
        Name="clump of hay",
        Effect = {
            "-gives an orbital hayboy that gets stronger if you have a 2nd copy of the item",
            "-3+ copies of the item replaces the orbital with a bouncy hayboy",
        },
        Trivia = {
            "-the hay is actually green magdalenes hair",
        },
    },
    {
        Type="treasure",
        Name="scallion",
        Effect = {
            "-when used, spawns a sweeping horde of scallion stallions that trample enemies",
        },
    },
    {
        Type="treasure",
        Name="baby carrot",
        Effect = {
            "-your tears have a chance to gain piercing and point at the nearest enemy",
        },
    },
    {
        Type="treasure",
        Name="pyre lantern",
        Effect = {
            "-every room, you spawn 3 pumpkin buddies that explode when you or an enemy touch them",
        },
    },
    {
        Type="treasure",
        Name="olive oil",
        Effect = {
            "-when used, covers the room in slippery oil, which doubles your damage",
        },
        Trivia = {
            "-if used in a room with water, gives you flight for the room",
        },
    },
    {
        Type="treasure",
        Name="unicornradish",
        Effect = {
            "-while not shooting in an uncleared room, you slowly charge up holy badassery",
            "-when fully charged, you become invincible and spawn holy beams of light and tears",
        },
        Trivia = {
            "-the unicornradish is in a gay relationship with the sweet potato",
        },
    },
    {
        Type="treasure",
        Name="jadeberry",
        Effect = {
            "-spawns 9 greencoin when picked up",
        },
    },
    {
        Type="treasure",
        Name="pearry",
        Effect = {
            "-spawns 4 pears when picked up",
        },
    },
    {
        Type="treasure",
        Name="grayberry",
        Effect = {
            "-speed up",
        },
    },
    {
        Type="treasure",
        Name="fcukberry",
        Effect = {
            "-health up",
            "-spawns a portal when picked up",
        },
    },
    {
        Type="treasure",
        Name="green sack",
        Effect = {
            "-you can store green consumables and green slot machines in this bag, and use them with the arrow keys",
        },
        Trivia = {
            "-this is green cain's signature item",
        },
    },
    {
        Type="treasure",
        Name="guns n roses",
        Effect = {
            "-has 4 different forms, with different firing types",
        },
        Trivia = {
            "-my special gun!",
            "-reference to the band of the same name (lucia i see you!)",
        },
    },
    {
        Type="treasure",
        Name="green thumb",
        Effect = {
            "-turns items green",
        },
        Trivia = {
            "-this is \"jezreel's\" signature item",
        },
    },
    {
        Type="treasure",
        Name="dirty money",
        Effect = {
            "-enemies have a chance to leave behind a greencoin on death",
        },
        Trivia = {
            "-this is my very own currency stamped with my face! it comes in the forms of bills and coins",
            "-conversion factor is questionable",
        },
    },
    {
        Type="treasure",
        Name="pondering orb",
        Effect = {
            "-using an active item spawns tears in a circle around you",
        },
    },
    {
        Type="treasure",
        Name="<g",
        Effect = {
            "-taking damage spawns 1 or 2 blockbums",
        },
        Trivia = {
            "-my heart???",
        },
    },
    {
        Type="treasure",
        Name="brotherly love",
        Effect = {
            "-gives an invincible blockbum familiar",
        },
        Trivia={
            "-the blockbum given by this item is named \"abel\"",
            "-stacking this item alternates between giving \"abel\" and a secondary blockbum named \"seth\"",
        },
    },
    {
        Type="treasure",
        Name="satans bet",
        Effect = {
            "-every room you get an unholy bet from the devil himself",
            "-if you win, he gives you money, otherwise lose some money"
        },
    },
    {
        Type="treasure",
        Name="golden eye",
        Effect = {
            "-pickups have double the chance to be golden",
            "-pickups have a chance to be \"falsely golden\", appearing as gold but showing the true appearance when you get close to it",
        },
        Trivia = {
            "-this is luna's eye",
        },
    },
    {
        Type="treasure",
        Name="green steak",
        Effect = {
            "-you can bet up to 10 counters every floor, and you lose half your counters when you take damage, along with 2 coins for every counter lost",
            "-next floor, you get 3 coins for each counter kept"
        },
    },
    {
        Type="treasure",
        Name="wheel of fortune",
        Effect = {
            "-on use, spawns a controllable car which blows up when touching any enemy or obstacle",
        },
        Trivia = {
            "-this is me and green cain's greenmobile!",
        },
    },
    {
        Type="treasure",
        Name="jezreels curse",
        Effect = {
            "-your flies are replaced by flower buds, which deal triple your damage",
        },
        Trivia = {
            "-jezreel was originally a fake character created for the april fools release of my mod!",
        },
    },
    {
        Type="treasure",
        Name="lil silence",
        Effect = {
            "-gives you a silence buddy which fires a spiral of tears",
        },
        Trivia = {
            "-his name is young sheldon!",
        },
    },
    {
        Type="creature",
        Name="green isaac",
        Info = {
            "-i start with the g6!",
        },
        Trivia = {
            "-i am an affront to nature!",
        },
    },
    {
        Type="creature",
        Name="green cain",
        Info = {
            "-he starts with the green sack, and 1 slot machine bagged inside it!",
        },
        Trivia = {
            "his crime list consists of:",
            "-23 counts of aggravated assault",
            "-43 counts of premeditated murder",
            "-2 counts of presidential assassination",
            "-5 counts of arson",
            "-12 counts of bank robbery",
            "-8 counts of tax evasion",
            "-56 counts of bombing matters",
            "-257 counts of coercion",
            "-1 count of luring someone to their death with money on a string under a large anvil tied to a tree",
            "-145 counts of counterfeiting",
            "-83 counts of credit card fraud",
            "-1 count of cyberbullying",
            "-35 counts of drug smuggling",
            "-19 counts of embezzlement",
            "-57 counts of extortion",
            "-2 counts of falsely claiming citizenship",
            "-58 counts of forced labor",
            "-2 counts of kidnapping",
            "-137 days of torture",
            "-1 count of genocide (look up k-pg)",
            "-2572 counts of illegal possession of firearms",
            "-1593 counts of larceny",
            "-3 counts of money laundering",
            "-0 counts of shoplifting",
            "-472 counts of homicide",
            "-he is my best friend!",
        },
    },
    {
        Type="creature",
        Name="jezreel",
        Info = {
            "-he starts with the green thumb, and a sense of impending doom",
        },
        Trivia = {
            "-jezreel was originally a fake character created for the april fools release of my mod, the only reason he was replaced by me was because he was late to show up for the mod",
            "-the reap gaper eternally torments him in every waking moment for making this mistake",
            "-i pity him",
        },
    },
    {
        Type="creature",
        Name="silence",
        Info = {
            "-powerful boss monster used as a disguise by reap prime",
        },
        Trivia = {
            "-he is a \"green\" version of skinless hush, referencing the skinless hush bossfight in abortionbirth",
            "-this is accentuated by the fact a placeholder version of his theme was the same as skinless hushs theme",
            "-the attacks shown in his fight are not the true extent to his power, though reap prime was much too weak to mimic him properly",
            "-he scares me",
        },
    },
    {
        Type="creature",
        Name="reap prime",
        Info = {
            "-\"powerful\" boss monster, his only strength is being so frantic that it throws his opponents off",
        },
        Trivia = {
            "-a weaker iteration of reap, seeking revenge on me for abandoning him",
            "-his name references the prime bosses from ultrakill, though he is weaker than the normal version of reap. what a misleading title",
            "-what a joke",
        },
    },
}
local MAX_LENGTH = 24
local function getFormattedEntryString(str)
    local fStrings = {}
    local splitStrings = {}

    for s in str:gmatch("([^ ]+)") do
        splitStrings[#splitStrings+1] = s
    end

    local st = ""

    for _, s in ipairs(splitStrings) do
        if(#(st.." "..s)>MAX_LENGTH) then
            fStrings[#fStrings+1] = st
            st=s
        else
            st=st.." "..s
        end
    end

    fStrings[#fStrings+1] = st

    return fStrings
end

local function getFormattedFlorapediaEntry(index)
    local entry = {}
    local infoDat = greenIsaacFlorapediaEntries[index].Info
    local effectDat = greenIsaacFlorapediaEntries[index].Effect
    local triviaDat = greenIsaacFlorapediaEntries[index].Trivia

    if(infoDat) then
        entry[#entry+1] = {str="info",fsize=3,nosel=true}
        for _, str in ipairs(infoDat) do
            for i, formatStr in ipairs(getFormattedEntryString(str)) do
                local sel = true
                if(i==1) then sel = false end
                entry[#entry+1] = {str=formatStr,fsize=2,nosel=sel}
            end
        end
    end

    if(effectDat) then
        entry[#entry+1] = {str="effect",fsize=3,nosel=true}
        for _, str in ipairs(effectDat) do
            for i, formatStr in ipairs(getFormattedEntryString(str)) do
                local sel = true
                if(i==1) then sel = false end
                entry[#entry+1] = {str=formatStr,fsize=2,nosel=sel}
            end
        end
    end

    if(triviaDat) then
        entry[#entry+1] = {str="",fsize=2,nosel=true}

        entry[#entry+1] = {str="trivia",fsize=3,nosel=true}
        for _, str in ipairs(triviaDat) do
            for i, formatStr in ipairs(getFormattedEntryString(str)) do
                local sel = true
                if(i==1) then sel = false end
                entry[#entry+1] = {str=formatStr,fsize=2,nosel=sel}
            end
        end
    end

    return entry
end

for i, data in ipairs(greenIsaacFlorapediaEntries) do
    local prefix = "florapedia_"
    local tabletoAdd = "florapedia_items"
    if(data.Type=="creature") then tabletoAdd="florapedia_entities" end

    local name = tostring(data.Name)

    greenIsaacDSSMenus[tabletoAdd]["buttons"][#greenIsaacDSSMenus[tabletoAdd]["buttons"]+1] = { str=name, dest=prefix..name }

    local buttons = getFormattedFlorapediaEntry(i)

    greenIsaacDSSMenus[prefix..name]={
        title=name,
        buttons = buttons
    }
end

DeadSeaScrollsMenu.AddPalettes({
	{
		Name = "green isaac",
		{ 138, 171, 136 },
		{ 44, 50, 44 },
		{ 74, 89, 72 },
	},
})

local greenIsaacDSSKey = {
    Item = greenIsaacDSSMenus.main,
    Main = "main",
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Green Isaac", {
    Run = dssmod.runMenu,

    Open = dssmod.openMenu,

    Close = dssmod.closeMenu,

    --UseSubMenu = false,
    Directory = greenIsaacDSSMenus,
    DirectoryKey = greenIsaacDSSKey,
})
