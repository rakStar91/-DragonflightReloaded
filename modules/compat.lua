---@diagnostic disable: undefined-global, deprecated
setfenv(1, DFRL:GetEnvironment())
d.DebugPrint("BOOTING")

-- ALL CODE HERE RUNS RIGHT AWAY, NOT ON MODULE LOAD ("PLAYER_ENTERING_WORLD")

--===========================
-- SHAGUTWEAKS FIXES
--===========================

function _G.ShaguFix()
    -- disable redundant or incompatible features -- config isnt loaded bug
    do
        -- i wont use config anymore since a) bugs out on first time (config nil)
        -- and b) disables it permanent and user has to delete WTF\shaguTweaks
        -- when DFRL gets disabled. Just disable the funcs instead.

        -- ShaguTweaks_config["Hide Errors"] = 0
        -- ShaguTweaks_config["Darkened UI"] = 0
        -- ShaguTweaks_config["Hide Gryphons"] = 0
        -- ShaguTweaks_config["MiniMap Clock"] = 0
        -- ShaguTweaks_config["MiniMap Tweaks"] = 0
        -- ShaguTweaks_config["MiniMap Square"] = 0
        -- ShaguTweaks_config["Movable Unit Frames"] = 0
        -- ShaguTweaks_config["Real Health Numbers"] = 0
        -- ShaguTweaks_config["Unit Frame Big Health"] = 0
        -- ShaguTweaks_config["Reduced Actionbar Size"] = 0
        -- ShaguTweaks_config["Unit Frame Class Colors"] = 0
        -- ShaguTweaks_config["Unit Frame Class Portraits"] = 0

        if not ShaguTweaks then return end
        ShaguTweaks.mods["Hide Errors"].enable = function() end
        ShaguTweaks.mods["Darkened UI"].enable = function() end
        ShaguTweaks.mods["Hide Gryphons"].enable = function() end
        ShaguTweaks.mods["MiniMap Clock"].enable = function() end
        ShaguTweaks.mods["MiniMap Tweaks"].enable = function() end
        ShaguTweaks.mods["MiniMap Square"].enable = function() end
        ShaguTweaks.mods["Movable Unit Frames"].enable = function() end
        ShaguTweaks.mods["Real Health Numbers"].enable = function() end
        ShaguTweaks.mods["Unit Frame Big Health"].enable = function() end
        ShaguTweaks.mods["Reduced Actionbar Size"].enable = function() end
        ShaguTweaks.mods["Unit Frame Class Colors"].enable = function() end
        ShaguTweaks.mods["Unit Frame Class Portraits"].enable = function() end
        -- d.DebugPrint("functions fix")
    end

    -- shagu bag fix (item rarity causes borders on CharacterBagXSlots)
    -- but we still want to keep the feature
    do
        if not ShaguTweaks then return end
        local mod = ShaguTweaks.mods["Item Rarity Borders"]
        if not mod then return end

        local orig = mod.enable
        mod.enable = function(self)
            orig(self)

            local skip = {
                "CharacterBag0Slot","CharacterBag1Slot",
                "CharacterBag2Slot","CharacterBag3Slot",
                "KeyRingButton"
            }

            for _, name in pairs(skip) do
                local btn = _G[name]
                if btn and btn.ShaguTweaks_border then
                btn.ShaguTweaks_border:Hide()
                end
            end
        end
    end

    -- disable GUI
    do
        if not ShaguTweaks then return end
        GameMenuButtonAdvancedOptions:Hide()
        GameMenuButtonAdvancedOptions:SetScript("OnClick", nil)
        AdvancedSettingsGUI:Hide()
        AdvancedSettingsGUI.Show = function() end
    end

    -- overwrite print
    do
        function print(msg)
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd100DFRL: |r".. tostring(msg))
        end
    end



    -- dynamic shagu disabler
    -- local f = CreateFrame("Frame")
    -- local timer = 0

    -- f:SetScript("OnUpdate", function()
    --     timer = timer + arg1
    --     if timer > 1 then
    --         local _G = getfenv(0)
    --         local ShaguTweaks = _G["ShaguTweaks"]
    --         if not ShaguTweaks or not ShaguTweaks.mods then
    --             print("ShaguTweaks or mods table not found!")
    --             f:SetScript("OnUpdate", nil)
    --             return
    --         end

    --         local mod = ShaguTweaks.mods["Auto Stance"]
    --         if not mod then
    --             print("Module 'Auto Stance' not found")
    --             f:SetScript("OnUpdate", nil)
    --             return
    --         end

    --         -- Save original disable if not saved yet
    --         if not mod._originalDisable then
    --             mod._originalDisable = mod.disable or function() end
    --         end

    --         -- Dynamic frame to cleanup in disable
    --         local dynamicFrame = mod.frame -- or assign mod's frame here if known

    --         -- Override disable method
    --         mod.disable = function(self)
    --             print("fired")
    --             if dynamicFrame then
    --                 dynamicFrame:UnregisterAllEvents()
    --                 dynamicFrame:SetScript("OnEvent", nil)
    --                 dynamicFrame = nil
    --             end
    --             self:_originalDisable()
    --         end

    --         print("Disable override applied.")
    --         f:SetScript("OnUpdate", nil)
    --     end
    -- end)



end

-- run instant in case it ws loaded already
ShaguFix()

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    if event=="ADDON_LOADED" then

        ShaguFix()

        d.DebugPrint("ShaguTweaks temp hotfix applied ADDON_LOADED")
    end
end)

--===========================
-- SHAGUTWEAKS-EXTRA FIXES
--===========================

--===========================
-- BAGSHUI FIXES
--===========================
