local function fiendFolioIncompatibility()
    if(jezreelMod:getMenuData().ff_incompatibility==2 and FiendFolio) then
        Isaac.GetPlayer().BabySkin = 0
    end
end
jezreelMod:AddCallback(ModCallbacks.MC_POST_UPDATE, fiendFolioIncompatibility)