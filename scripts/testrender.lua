local mod = jezreelMod

local funcs = {}

local sprite = Sprite()
sprite:Load("gfx/entities/effects/redkeys/counter.anm2", true)

function funcs:postRender(name)
    local hud = Game():GetHUD()
    hud:Render()
    local keys = Isaac.GetPlayer():GetNumKeys()

    local uiOffset = Vector(Options.HUDOffset * 20, Options.HUDOffset * 12)
    local renderPos = Vector(17,66)

    sprite:Play("Counter", true)
    sprite:Render(renderPos+uiOffset)

    sprite:Play("Numbers", true)
    sprite:SetFrame(math.floor(keys/10))
    sprite:Render(renderPos+uiOffset)

    renderPos = renderPos+Vector(6,0)
    sprite:SetFrame(keys%10)
    sprite:Render(renderPos+uiOffset)
end
--mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, funcs.postRender)