local FLASHBANG_FRAME = 0
local FLASHBANG_WHITE_DURATION = 30
local MAXFLASHBANG_FRAME = 90

local blackBg = Sprite()
blackBg:Load("gfx/black.anm2", true)
blackBg:Play("Main")
blackBg.Scale = Vector(3,3)
local function flashbangModeRender()
    if(not (jezreelMod.getMenuData().flashbangMode==2)) then return end
    if(FLASHBANG_FRAME>0) then
        local a = FLASHBANG_FRAME/(MAXFLASHBANG_FRAME-FLASHBANG_WHITE_DURATION)
        a=math.min(a,1)

        blackBg.Color = Color(1,1,1,a,1,1,1)
        blackBg:Render(Vector.Zero)

        FLASHBANG_FRAME=FLASHBANG_FRAME-1
    end
end
jezreelMod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, flashbangModeRender)

local function postEffectInit(_, effect)
    if(not (jezreelMod.getMenuData().flashbangMode==2)) then return end
    FLASHBANG_FRAME=MAXFLASHBANG_FRAME
end
jezreelMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, EffectVariant.BOMB_EXPLOSION)