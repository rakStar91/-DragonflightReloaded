---@diagnostic disable: deprecated
DFRL:SetDefaults("micromenu", {
    enabled = {true},
    hidden = {false},

    darkMode = {false, 1, "checkbox", "appearance", "Activate darkmode"},
    microScale = {0.85, 2, "slider", {0.5, 1.5}, "appearance", "Adjusts the scale of the micro menu"},
    microAlpha = {1, 3, "slider", {0.1, 1}, "appearance", "Adjusts the transparency of the micro menu"},
    microSpacing = {3, 4, "slider", {0.5, 15}, "appearance", "Adjusts spacing between micro menu buttons"},

})

DFRL:RegisterModule("micromenu", 1, function()
    d.DebugPrint("BOOTING")

    local path = "Interface\\AddOns\\DragonflightReloaded\\media\\tex\\micromenu\\uimicromenu2x.tga"
    local buttonWidth = 20
    local buttonHeight = 30
    local buttonSpacing = 2

    local microMenuContainer = CreateFrame("Frame", "DFRLMicroMenuContainer", UIParent)
    microMenuContainer:SetWidth((buttonWidth + 2) * 10)
    microMenuContainer:SetHeight(buttonHeight)
    microMenuContainer:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -15, 15)
    microMenuContainer:SetClampedToScreen(true)

    local buttons = {
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        QuestLogMicroButton,
        SocialsMicroButton,
        WorldMapMicroButton,
        MainMenuMicroButton,
        HelpMicroButton
    }

    for _, button in ipairs(buttons) do
        if button then
            button:Show()
            button:Enable()
            button:SetAlpha(1)
        end
    end

    -- PVP button
    local pvpButton = CreateFrame("Button", "DFRLPvPMicroButton", microMenuContainer)
    pvpButton:SetWidth(buttonWidth)
    pvpButton:SetHeight(buttonHeight)
    pvpButton:SetHitRectInsets(0, 0, 0, 0)
    pvpButton:Show()
    pvpButton:Enable()
    pvpButton:SetScript("OnClick", function()
        if BattlefieldFrame:IsVisible() then
            ToggleGameMenu()
        else
            ShowTWBGQueueMenu()
        end
    end)

    pvpButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(pvpButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Player vs Player", 1, 1, 1)
        GameTooltip:AddLine("Queue for battlegrounds and view PvP statistics.")
        GameTooltip:AddLine("Right-click to toggle honor system.")
        GameTooltip:Show()
    end)

    pvpButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- LFT button
    local lftButton = CreateFrame("Button", "DFRLLFTMicroButton", microMenuContainer)
    lftButton:SetWidth(buttonWidth)
    lftButton:SetHeight(buttonHeight)
    lftButton:SetHitRectInsets(0, 0, 0, 0)
    lftButton:Show()
    lftButton:Enable()
    lftButton:SetScript("OnClick", LFT_Toggle)

    lftButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(lftButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Looking For Team", 1, 1, 1)
        GameTooltip:AddLine("Open the Group Finder interface to find a team,")
        GameTooltip:AddLine("be aware that you must travel to the dungeon manually.")
        GameTooltip:Show()
    end)

    lftButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- custom buttons position
    local newButtons = {}
    for i, button in ipairs(buttons) do
        table.insert(newButtons, button)
        if i == 5 then -- after SocialsMicroButton
            table.insert(newButtons, pvpButton)
            table.insert(newButtons, lftButton)
        end
    end
    buttons = newButtons

    for i, button in ipairs(buttons) do
        button:Show()
        button:Enable()
        button:SetParent(microMenuContainer)
        button:ClearAllPoints()

        local xOffset = (i-1) * (buttonWidth + buttonSpacing)
        button:SetPoint("TOPLEFT", microMenuContainer, "TOPLEFT", xOffset, 0)

        button:SetWidth(buttonWidth)
        button:SetHeight(buttonHeight)
        button:SetHitRectInsets(0, 0, 0, 0)

        if button == pvpButton or button == lftButton then
            local regions = {button:GetRegions()}
            for _, region in ipairs(regions) do
                if region:GetObjectType() == "Texture" then
                    region:Hide()
                end
            end
        else
            -- blizzar handles this
        end
    end

    -- character button (position 1)
    if buttons[1] then
        buttons[1]:SetNormalTexture(path)
        if buttons[1]:GetNormalTexture() then
            buttons[1]:GetNormalTexture():SetTexCoord(2/256, 37/256, 324/512, 372/512)
            buttons[1]:GetNormalTexture():Show()
        end
        buttons[1]:SetPushedTexture(path)
        if buttons[1]:GetPushedTexture() then
            buttons[1]:GetPushedTexture():SetTexCoord(82/256, 116/256, 216/512, 264/512)
        end
        buttons[1]:SetHighlightTexture(path)
        if buttons[1]:GetHighlightTexture() then
            buttons[1]:GetHighlightTexture():SetTexCoord(82/256, 116/256, 216/512, 264/512)
        end
    end

    -- spellbook button (position 2)
    if buttons[2] then
        buttons[2]:SetNormalTexture(path)
        if buttons[2]:GetNormalTexture() then
            buttons[2]:GetNormalTexture():SetTexCoord(122/256, 157/256, 54/512, 102/512)
            buttons[2]:GetNormalTexture():Show()
        end
        buttons[2]:SetPushedTexture(path)
        if buttons[2]:GetPushedTexture() then
            buttons[2]:GetPushedTexture():SetTexCoord(190/256, 225/256, 432/512, 480/512)
        end
        buttons[2]:SetHighlightTexture(path)
        if buttons[2]:GetHighlightTexture() then
            buttons[2]:GetHighlightTexture():SetTexCoord(190/256, 225/256, 432/512, 480/512)
        end
    end

    -- -- talents button (position 3)
    if buttons[3] then
        buttons[3]:SetNormalTexture(path)
        if buttons[3]:GetNormalTexture() then
            buttons[3]:GetNormalTexture():SetTexCoord(162/256, 197/256, 0/512, 48/512)
            buttons[3]:GetNormalTexture():Show()
        end
        buttons[3]:SetPushedTexture(path)
        if buttons[3]:GetPushedTexture() then
            buttons[3]:GetPushedTexture():SetTexCoord(82/256, 117/256, 0/512, 48/512)
        end
        buttons[3]:SetHighlightTexture(path)
        if buttons[3]:GetHighlightTexture() then
            buttons[3]:GetHighlightTexture():SetTexCoord(82/256, 117/256, 0/512, 48/512)
        end
    end

    -- quest button (position 4)
    if buttons[4] then
        buttons[4]:SetNormalTexture(path)
        if buttons[4]:GetNormalTexture() then
            buttons[4]:GetNormalTexture():SetTexCoord(202/256, 237/256, 270/512, 318/512)
            buttons[4]:GetNormalTexture():Show()
        end
        buttons[4]:SetPushedTexture(path)
        if buttons[4]:GetPushedTexture() then
            buttons[4]:GetPushedTexture():SetTexCoord(42/256, 77/256, 432/512, 480/512)
        end
        buttons[4]:SetHighlightTexture(path)
        if buttons[4]:GetHighlightTexture() then
            buttons[4]:GetHighlightTexture():SetTexCoord(42/256, 77/256, 432/512, 480/512)
        end
    end

    -- socials button (position 5)
    if buttons[5] then
        buttons[5]:SetNormalTexture(path)
        if buttons[5]:GetNormalTexture() then
            buttons[5]:GetNormalTexture():SetTexCoord(42/256, 76/256, 54/512, 102/512)
            buttons[5]:GetNormalTexture():Show()
        end
        buttons[5]:SetPushedTexture(path)
        if buttons[5]:GetPushedTexture() then
            buttons[5]:GetPushedTexture():SetTexCoord(42/256, 77/256, 0/512, 48/512)
        end
        buttons[5]:SetHighlightTexture(path)
        if buttons[5]:GetHighlightTexture() then
            buttons[5]:GetHighlightTexture():SetTexCoord(42/256, 77/256, 0/512, 48/512)
        end
    end

    -- PVP button (position 6 - custom)
    buttons[6]:SetNormalTexture(path)
    buttons[6]:GetNormalTexture():SetTexCoord(0/256, 37/256, 269/512, 319/512)
    buttons[6]:SetPushedTexture(path)
    buttons[6]:GetPushedTexture():SetTexCoord(161/256, 197/256, 161/512, 211/512)
    buttons[6]:SetHighlightTexture(path)
    buttons[6]:GetHighlightTexture():SetTexCoord(161/256, 197/256, 161/512, 211/512)

    -- LFT button (position 7 - custom)
    buttons[7]:SetNormalTexture(path)
    buttons[7]:GetNormalTexture():SetTexCoord(0/256, 38/256, 161/512, 211/512)
    buttons[7]:SetPushedTexture(path)
    buttons[7]:GetPushedTexture():SetTexCoord(41/256, 78/256, 107/512, 157/512)
    buttons[7]:SetHighlightTexture(path)
    buttons[7]:GetHighlightTexture():SetTexCoord(41/256, 78/256, 107/512, 157/512)

    -- world map button (position 8)
    if buttons[8] then
        buttons[8]:SetNormalTexture(path)
        if buttons[8]:GetNormalTexture() then
            buttons[8]:GetNormalTexture():SetTexCoord(162/256, 196/256, 107/512, 157/512)
            buttons[8]:GetNormalTexture():Show()
        end
        buttons[8]:SetPushedTexture(path)
        if buttons[8]:GetPushedTexture() then
            buttons[8]:GetPushedTexture():SetTexCoord(202/256, 237/256, 54/512, 102/512)
        end
        buttons[8]:SetHighlightTexture(path)
        if buttons[8]:GetHighlightTexture() then
            buttons[8]:GetHighlightTexture():SetTexCoord(202/256, 237/256, 54/512, 102/512)
        end
    end

    -- main menu button (position 9)
    if buttons[9] then
        buttons[9]:SetNormalTexture(path)
        if buttons[9]:GetNormalTexture() then
            buttons[9]:GetNormalTexture():SetTexCoord(2/256, 37/256, 107/512, 157/512)
            buttons[9]:GetNormalTexture():Show()
        end
        buttons[9]:SetPushedTexture(path)
        if buttons[9]:GetPushedTexture() then
            buttons[9]:GetPushedTexture():SetTexCoord(122/256, 157/256, 323/512, 372/512)
        end
        buttons[9]:SetHighlightTexture(path)
        if buttons[9]:GetHighlightTexture() then
            buttons[9]:GetHighlightTexture():SetTexCoord(122/256, 157/256, 323/512, 372/512)
        end
    end

    -- help button (position 10)
    if buttons[10] then
        buttons[10]:SetNormalTexture(path)
        if buttons[10]:GetNormalTexture() then
            buttons[10]:GetNormalTexture():SetTexCoord(202/256, 237/256, 215/512, 265/512)
            buttons[10]:GetNormalTexture():Show()
        end
        buttons[10]:SetPushedTexture(path)
        if buttons[10]:GetPushedTexture() then
            buttons[10]:GetPushedTexture():SetTexCoord(162/256, 198/256, 215/512, 265/512)
        end
        buttons[10]:SetHighlightTexture(path)
        if buttons[10]:GetHighlightTexture() then
            buttons[10]:GetHighlightTexture():SetTexCoord(162/256, 198/256, 215/512, 265/512)
        end
    end

    -- hide other UI elements
    if LFTMinimapButton then LFTMinimapButton:Hide() end
    if MicroButtonPortrait then MicroButtonPortrait:Hide() end
    if ShopMicroButton then ShopMicroButton:Hide() end
    if PVPMicroButton then PVPMicroButton:Hide() end

    if LFT then
        LFT:Hide()
    end

    if MinimapShopFrame then
        MinimapShopFrame:Hide()
    end

    if TWMiniMapBattlefieldFrame then
        TWMiniMapBattlefieldFrame:Hide()
    end

    -- fps and network stats
    local netStatsFrame
    do
        UIPARENT_MANAGED_FRAME_POSITIONS["FramerateLabel"] = nil

        netStatsFrame = CreateFrame("Frame", "DFRL_NetStatsFrame", UIParent)
        netStatsFrame:SetPoint("BOTTOMRIGHT", CharacterMicroButton, "BOTTOMLEFT", -10, -1)
        netStatsFrame:SetWidth(98)
        netStatsFrame:SetHeight(26)
        netStatsFrame:SetClampedToScreen(true)

        netStatsFrameBG = netStatsFrame:CreateTexture(nil, "BACKGROUND")
        netStatsFrameBG:SetAllPoints(netStatsFrame)
        netStatsFrameBG:SetTexture(0, 0, 0, 0.3)

        local size = 9

        local msText = netStatsFrame:CreateFontString(nil, "OVERLAY")
        msText:SetPoint("TOPRIGHT", netStatsFrame, "TOPRIGHT", -8, -2)
        msText:SetFont("Fonts\\FRIZQT__.TTF", size, "")
        msText:SetTextColor(1, 1, 1, 1)

        local bwText = netStatsFrame:CreateFontString(nil, "OVERLAY")
        bwText:SetPoint("TOPRIGHT", msText, "BOTTOMRIGHT", 0, -3)
        bwText:SetFont("Fonts\\FRIZQT__.TTF", size, "")
        bwText:SetTextColor(1, 1, 1, 1)

        local fpsText = netStatsFrame:CreateFontString(nil, "OVERLAY")
        fpsText:SetPoint("RIGHT", msText, "LEFT", -10, 0)
        fpsText:SetFont("Fonts\\FRIZQT__.TTF", size, "")
        fpsText:SetTextColor(1, 1, 1, 1)

        -- hide blizzard
        FramerateLabel:ClearAllPoints()
        FramerateLabel:SetPoint("RIGHT", msText, "LEFT", -30, 0)
        FramerateLabel:SetFont("Fonts\\FRIZQT__.TTF", size, "")
        FramerateLabel:SetTextColor(1, 1, 1, 0)

        FramerateText:SetFont("Fonts\\FRIZQT__.TTF", size, "")
        FramerateText:SetTextColor(1, 1, 1, 0)

        local latencyIndicator = CreateFrame("Frame", "DFRL_LatencyIndicator", UIParent)
        latencyIndicator:SetPoint("TOP", HelpMicroButton, "BOTTOM", 0, 7)
        latencyIndicator:SetWidth(20)
        latencyIndicator:SetHeight(15)

        local latencyTexture = latencyIndicator:CreateTexture(nil, "ARTWORK")
        latencyTexture:SetAllPoints(latencyIndicator)

        netStatsFrame:SetScript("OnUpdate", function()
            if (this.tick or 0) > GetTime() then return end
            this.tick = GetTime() + 0.5

            local bandwidthIn, bandwidthOut, latencyHome = GetNetStats()

            msText:SetText(string.format("MS: %d", latencyHome))
            bwText:SetText(string.format("UL/DL: %.1f / %.1f", bandwidthIn, bandwidthOut))
            fpsText:SetText(string.format("FPS: %d", GetFramerate()))
        end)

        latencyIndicator:SetScript("OnUpdate", function()
            if (this.tick or 0) > GetTime() then return end
            this.tick = GetTime() + 2

            local _, _, latencyHome = GetNetStats()

            if latencyHome < 100 then
                latencyTexture:SetTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\micromenu\\LatencyGreen.tga")
            elseif latencyHome < 200 then
                latencyTexture:SetTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\micromenu\\LatencyYellow.tga")
            else
                latencyTexture:SetTexture("Interface\\AddOns\\DragonflightReloaded\\media\\tex\\micromenu\\LatencyRed.tga")
            end
        end)

        netStatsFrame:Hide()

        hooksecurefunc("ToggleFramerate", function()
            local checkTimer = CreateFrame("Frame")
            checkTimer:SetScript("OnUpdate", function()
                if FramerateLabel:IsVisible() then
                    netStatsFrame:Show()
                else
                    netStatsFrame:Hide()
                end
                checkTimer:SetScript("OnUpdate", nil)
            end)
        end)
    end

    -- expose
    DFRL.microMenuContainer = microMenuContainer
    DFRL.netStatsFrame = netStatsFrame

    -- callbacks
    local callbacks = {}

    callbacks.darkMode = function(value)
        local darkColor = {0.2, 0.2, 0.2}
        local lightColor = {1, 1, 1}
        local color = value and darkColor or lightColor

        for _, button in ipairs(buttons) do

            local normalTexture = button:GetNormalTexture()
            if normalTexture then
                normalTexture:SetVertexColor(color[1], color[2], color[3])
            end
        end
    end

    callbacks.microScale = function(value)
        if DFRL.microMenuContainer then
            DFRL.microMenuContainer:SetScale(value)
        end
    end

    callbacks.microAlpha = function(value)
        if DFRL.microMenuContainer then
            DFRL.microMenuContainer:SetAlpha(value)
        end
    end

    callbacks.microSpacing = function(value)
        if DFRL.microMenuContainer and buttons then
            for i, button in ipairs(buttons) do
                button:ClearAllPoints()
                local xOffset = (i-1) * (buttonWidth + value)
                button:SetPoint("TOPLEFT", DFRL.microMenuContainer, "TOPLEFT", xOffset, 0)
            end

            -- update container width
            DFRL.microMenuContainer:SetWidth((buttonWidth + value) * table.getn(buttons))
        end
    end

    -- execute callbacks
    DFRL:RegisterCallback("micromenu", callbacks)
end)
