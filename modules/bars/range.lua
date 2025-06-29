
DFRL:NewDefaults("RangeIndicator", {
    enabled = { true },
    indicatorDark = {false, "checkbox", nil, nil, "appearance", 1, "Use dark color instead of red", nil, nil},
    indicatorFade = {true, "checkbox", nil, nil, "appearance", 2, "Enable fade in/out animation", nil, nil},
    indicatorAlpha = {1, "slider", {0, 1}, nil, "appearance", 3, "Adjust range indicator opacity", nil, nil},
})

DFRL:NewMod("RangeIndicator", 1, function()
    debugprint(">> BOOTING")

    -- =================
    -- SETUP
    -- =================
    local Setup = {
        texpath = "Interface\\AddOns\\-DragonflightReloaded\\media\\tex\\actionbars\\",
        rangeIndicatorFrame = nil,
        rangeIndicatorUpdateTimer = 0,
        buttonTypes = {
            "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
            "MultiBarRightButton", "MultiBarLeftButton", "BonusActionButton",
        }
    }

    function Setup:KillBlizz()
        function _G.ActionButton_UpdateHotkeys() end
        function _G.ActionButton_OnUpdate() end
    end

    function Setup:CreateIndicatorTexture(button)
        if button.rangeIndicator then
            return
        end

        local indicator = button:CreateTexture(nil, "OVERLAY")
        indicator:SetTexture(self.texpath .. "indicator_.tga")
        indicator:SetVertexColor(1, 0, 0)
        indicator:SetAllPoints(button)
        indicator:SetPoint("CENTER", button, "CENTER", -0, -0)
        indicator:Hide()
        indicator.showing = false
        indicator.useFade = true

        button.rangeIndicator = indicator
    end

    function Setup:CheckButtonRange(button)
        if not button or not button:IsVisible() then
            return true
        end

        local slot = ActionButton_GetPagedID(button)
        if not slot or slot == 0 then
            return true
        end

        if not UnitExists("target") then
            return true
        end

        if not UnitCanAttack("player", "target") then
            return true
        end

        local inRange = IsActionInRange(slot)
        if inRange == 0 then
            return false
        end

        return true
    end

    function Setup:UpdateIndicatorVisibility(button)
        if not button.rangeIndicator then
            return
        end

        local inRange = self:CheckButtonRange(button)
        local alpha = DFRL:GetTempDB("RangeIndicator", "indicatorAlpha")

        if inRange and button.rangeIndicator.showing then
            if button.rangeIndicator.useFade then
                UIFrameFadeOut(button.rangeIndicator, 0.2, alpha, 0)
            else
                button.rangeIndicator:Hide()
            end
            button.rangeIndicator.showing = false
        elseif not inRange and not button.rangeIndicator.showing then
            if button.rangeIndicator.useFade then
                UIFrameFadeIn(button.rangeIndicator, 0.2, 0, alpha)
            else
                button.rangeIndicator:SetAlpha(alpha)
                button.rangeIndicator:Show()
            end
            button.rangeIndicator.showing = true
        end
    end

    function Setup:ProcessAllButtons(func)
        for _, buttonType in ipairs(self.buttonTypes) do
            local i = 1
            while true do
                local button = getglobal(buttonType .. i)
                if not button then
                    break
                end
                func(self, button)
                i = i + 1
            end
        end
    end

    function Setup:RangeIndicator()
        self:ProcessAllButtons(self.CreateIndicatorTexture)
    end

    -- =================
    -- INIT
    -- =================
    function Setup:Run()
        self:KillBlizz()
        self:RangeIndicator()
    end

    Setup:Run()

    -- =================
    -- CALLBACKS
    -- =================
    local callbacks = {}

    callbacks.indicatorAlpha = function(value)
        for _, buttonType in ipairs(Setup.buttonTypes) do
            local i = 1
            while true do
                local button = getglobal(buttonType .. i)
                if not button then
                    break
                end
                if button.rangeIndicator then
                    button.rangeIndicator:SetAlpha(value)
                end
                i = i + 1
            end
        end
    end

    callbacks.indicatorDark = function(value)
        for _, buttonType in ipairs(Setup.buttonTypes) do
            local i = 1
            while true do
                local button = getglobal(buttonType .. i)
                if not button then
                    break
                end
                if button.rangeIndicator then
                    if value then
                        button.rangeIndicator:SetVertexColor(0, 0, 0)
                    else
                        button.rangeIndicator:SetVertexColor(1, 0, 0)
                    end
                end
                i = i + 1
            end
        end
    end

    callbacks.indicatorFade = function(value)
        for _, buttonType in ipairs(Setup.buttonTypes) do
            local i = 1
            while true do
                local button = getglobal(buttonType .. i)
                if not button then
                    break
                end
                if button.rangeIndicator then
                    button.rangeIndicator.useFade = value
                end
                i = i + 1
            end
        end
    end

    -- =================
    -- EVENT
    -- =================
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_TARGET_CHANGED")
    f:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    f:RegisterEvent("SPELLS_CHANGED")
    f:SetScript("OnEvent", function()
        Setup:ProcessAllButtons(Setup.CreateIndicatorTexture)
        Setup:ProcessAllButtons(Setup.UpdateIndicatorVisibility)
    end)

    local updateTimer = 0
    f:SetScript("OnUpdate", function()
        updateTimer = updateTimer + arg1
        if updateTimer >= 0.1 then
            Setup:ProcessAllButtons(Setup.UpdateIndicatorVisibility)
            updateTimer = 0
            DFRL.activeScripts["RangeIndicatorScript"] = true
        end
    end)

    DFRL:NewCallbacks("RangeIndicator", callbacks)
end)
