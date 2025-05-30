DFRL:SetDefaults("castbar", {
    enabled = {false},
    hidden = {false},

    darkMode = {false, 1, "checkbox", "appearance", "Use dark mode for castbar border"},
    timeShow = {true, 2, "checkbox", "appearance", "Show casting time"},
    castText = {true, 3, "checkbox", "appearance", "Show spell name text"},
    shadowShow = {true, 4, "checkbox", "appearance", "Show drop shadow"},
})

DFRL:RegisterModule("castbar", 1, function()
    d.DebugPrint("BOOTING")

    -- retexture blizzard castbar
    do
        UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil

        CastingBarFrame:SetStatusBarTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\castbar\\CastingBarStandard2.blp")
        CastingBarFrame:ClearAllPoints()
        CastingBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -180)

        CastingBarBorder:SetTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\castbar\\CastingBarFrame.blp")
        CastingBarBorder:SetAllPoints(CastingBarFrame)
        CastingBarFlash:SetTexture(nil)

        local bg = CastingBarFrame:GetRegions()
        bg:SetTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\castbar\\CastingBarBackground.blp")
        bg:SetAllPoints(CastingBarFrame)
        bg:SetDrawLayer("BACKGROUND", 0)

        CastingBarFrame.dropShadow = CastingBarFrame:CreateTexture("CastingBarDropShadow", "BACKGROUND")
        CastingBarFrame.dropShadow:SetTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\castbar\\CastingBarFrameDropShadow.blp")
        CastingBarFrame.dropShadow:SetPoint("TOP", CastingBarFrame, "CENTER", 0, 0)
        CastingBarFrame.dropShadow:SetWidth(CastingBarFrame:GetWidth())
        CastingBarFrame.dropShadow:SetHeight(CastingBarFrame:GetHeight() + 10)
        CastingBarFrame.dropShadow:SetDrawLayer("BACKGROUND", -1)

        CastingBarText:ClearAllPoints()
        CastingBarText:SetPoint("LEFT", CastingBarFrame.dropShadow, "LEFT", 5, -2)
    	CastingBarText:SetJustifyH("LEFT")

        -- expose
        CastingBarFrame.bg = bg
    end

    -- casting time
    do
        local castingTime = CastingBarFrame:CreateFontString(nil, "OVERLAY")
        castingTime:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        castingTime:SetPoint("RIGHT", CastingBarFrame.dropShadow, "RIGHT", -5, -2)
        castingTime:SetTextColor(1, 1, 1)
        CastingBarText.time = castingTime

        HookScript(CastingBarFrame, "OnUpdate", function()
            if CastingBarFrame:IsVisible() and CastingBarFrame.showTime then
                local minValue, maxValue = CastingBarFrame:GetMinMaxValues()
                local value = CastingBarFrame:GetValue()

                if CastingBarFrame.casting then
                    local timeLeft = maxValue - value
                    if timeLeft > 0 then
                        CastingBarText.time:SetText(format("%.1f", timeLeft))
                        CastingBarText.time:Show()
                    end
                elseif CastingBarFrame.channeling then
                    local timeLeft = value - minValue
                    if timeLeft > 0 then
                        CastingBarText.time:SetText(format("%.1f", timeLeft))
                        CastingBarText.time:Show()
                    end
                else
                    CastingBarText.time:Hide()
                end
            else
                CastingBarText.time:Hide()
            end
        end)
    end

    -- callbacks
    local callbacks = {}

    callbacks.darkMode = function(value)
        local darkColor = {0.2, 0.2, 0.2}
        local specialDark = {0.5, 0.5, 0.5}
        local lightColor = {1, 1, 1}

        local color = value and darkColor or lightColor
        CastingBarBorder:SetVertexColor(color[1], color[2], color[3])
        CastingBarFrame.dropShadow:SetVertexColor(color[1], color[2], color[3])

        local bgColor = value and specialDark or lightColor
        CastingBarFrame.bg:SetVertexColor(bgColor[1], bgColor[2], bgColor[3])
    end

    callbacks.timeShow = function(value)
        CastingBarFrame.showTime = value

        if value then
            CastingBarText.time:Show()
        else
            CastingBarText.time:Hide()
        end
    end


    callbacks.castText = function(value)
        if value then
            CastingBarText:Show()
        else
            CastingBarText:Hide()
        end
    end

    callbacks.shadowShow = function(value)
        if value then
            CastingBarFrame.dropShadow:Show()
        else
            CastingBarFrame.dropShadow:Hide()
        end
    end

    -- execute callbacks
    DFRL:RegisterCallback("castbar", callbacks)
end)
