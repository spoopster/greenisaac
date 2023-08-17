local mod = jezreelMod

local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)

local funcs = {}

local function isAnyPlayerGreenCain()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:GetPlayerType()==greenCain) then return true end
    end
    return false
end

function funcs:rerenderOnCollect(pickup, offset, subtype)
    if(pickup.SubType==subtype and pickup:GetSprite():GetAnimation()=="Collect") then
        pickup.SpriteScale = Vector(1,1)
        pickup:GetSprite():Render(Isaac.WorldToRenderPosition(pickup.Position)+offset)
        pickup.SpriteScale = Vector.Zero
    end
end

function funcs:rerollLocked(pickup, subtype, mark)
    if(isAnyPlayerGreenCain()) then return end
    if(pickup.SubType==subtype and mark==0) then
        local sub = subtype
        while(sub==subtype) do
            pickup:Morph(5,300,0,true)
            sub=pickup.SubType
        end
    end
end

function funcs:genericInit(pickup, subtype)
    if(pickup.SubType==subtype) then
        local sprite = pickup:GetSprite()
        sprite:Play("Appear", true)
    end
end

function funcs:genericUpdate(pickup, subtype)
    if(pickup.SubType==subtype) then
        local sprite = pickup:GetSprite()
        if(sprite:IsFinished("Appear")) then
            sprite:Play("Idle", true)
        end
        if(sprite:IsFinished("Collect")) then
            pickup:Remove()
        end
    end
end

function funcs:genericCollision(pickup, collider, subtype)
    local sprite = pickup:GetSprite()
    local anim = sprite:GetAnimation()

    if(pickup.SubType~=subtype) then goto invalid end
    if(collider.Type==5) then return false end
    if(collider.Type~=1) then return true end
    if(anim=="Appear" or (anim=="Collect" and sprite:GetFrame()>4)) then return true end
    if(anim~="Idle") then return true end
    if(not collider:ToPlayer():IsExtraAnimationFinished()) then return nil end

    if(collider:GetData().usingSack==true) then
        sprite:Play("Collect", true)
        pickup.SpriteScale = Vector.Zero
    end

    ::invalid::

    return 0
end

function funcs:replaceLocked(player, subtype, mark)
    if(isAnyPlayerGreenCain()) then return end
    if(mark==1) then return end
    for i=0,3 do
        local card = player:GetCard(i)
        if(card==subtype) then
            local pickup = Isaac.Spawn(5,300,subtype,Vector.Zero,Vector.Zero,nil)
            card = pickup.SubType
            pickup:Remove()

            player:SetCard(i, card)
        end
    end
end

return funcs