local mod = jezreelMod

local orbEffect = Isaac.GetEntityVariantByName("Orb Glow")

local funcs = {}

---@param color table
---@param shift number
local function hueShift(color, shift)
    local sCos = math.cos(shift*math.pi/180)
    local sSin = math.sin(shift*math.pi/180)

    local shiftedColor = {}
    shiftedColor.R = color.R*(sCos+(1-sCos)/3)
                    +color.G*((1-sCos)/3-sSin*(0.577))
                    +color.B*((1-sCos)/3+sSin*(0.577))
    shiftedColor.G = color.R*((1-sCos)/3+sSin*(0.577))
                    +color.G*(sCos+(1-sCos)/3)
                    +color.B*((1-sCos)/3-sSin*(0.577))
    shiftedColor.B = color.R*((1-sCos)/3-sSin*(0.577))
                    +color.G*((1-sCos)/3+sSin*(0.577))
                    +color.B*(sCos+(1-sCos)/3)
    return shiftedColor
end

function funcs:postEffectRender(effect, offset)
    local color = effect.Color
    local shiftedCol = hueShift({R=86,G=227,B=178}, math.floor(math.sin(effect.FrameCount/20)*50))
    --local shiftedCol = hueShift({R=255,G=0,B=248}, math.floor(effect.FrameCount/15)*60)
    color.R = shiftedCol.R/255
    color.G = shiftedCol.G/255
    color.B = shiftedCol.B/255

    effect.Color = color
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, funcs.postEffectRender, orbEffect)

mod.ENTITIES.ORBGLOW = funcs