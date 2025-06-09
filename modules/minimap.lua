---@diagnostic disable: deprecated
DFRL:SetDefaults("minimap", {
    enabled = {true},
    hidden = {false},

    darkMode       = {false,  1, "checkbox",                      "appearance",        "Enable dark mode for the minimap"},

    mapSquare      = {false,  4, "checkbox",                      "map basic",    "Show the Minimap Square design"},
    mapSize        = {180,    5, "slider",   {140, 350},          "map basic",    "Adjusts the overall size of the minimap"},
    mapAlpha   = {1,      6, "slider",   {0.1, 1},            "map basic",    "Adjusts transparency of the entire minimap"},

    showShadow     = {true,   2, "checkbox",                      "map shadow",    "Show or hide the shadow inside the minimap"},
    alphaShadow    = {0.3,    7, "slider",   {0.1, 1},            "map shadow",    "Adjusts transparency of the minimap shadow"},

    showZoom       = {true,   3, "checkbox",                      "map zoom",          "Show or hide zoom buttons on the minimap"},
    scaleZoom      = {0.8,    8, "slider",   {0.2, 2},            "map zoom",          "Adjusts size of zoom buttons"},
    alphaZoom      = {1,      9, "slider",   {0.1, 1},            "map zoom",          "Adjusts transparency of zoom buttons"},
    zoomX          = {-5,    10, "slider",   {-100, 100},         "map zoom",          "Adjusts horizontal position of zoom buttons"},
    zoomY          = {40,    11, "slider",   {-100, 100},         "map zoom",          "Adjusts vertical position of zoom buttons"},

    showTopPanel   = {true,  12, "checkbox",                       "top panel",         "Show or hide the top information panel"},
    topPanelWidth  = {180,   13, "slider",   {100, 600},          "top panel",         "Adjusts the width of the top panel"},
    topPanelHeight = {12,    14, "slider",   {5, 50},             "top panel",         "Adjusts the height of the top panel"},

    zoneTextSize   = {10,    17, "slider",   {6, 30},             "top panel zone",    "Adjusts font size of the zone text"},
    zoneTextY      = {-3,    18, "slider",   {-50, 50},           "top panel zone",    "Adjusts vertical position of the zone text"},
    zoneTextX      = {4,     19, "slider",   {-50, 50},           "top panel zone",    "Adjusts horizontal position of the zone text"},

    showTime   = {true,  20, "checkbox",                      "top panel time",    "Show or hide the time display on the minimap"},
    timeSize   = {10,    21, "slider",   {6, 30},             "top panel time",    "Adjusts font size of the time display"},
    timeY      = {-3,    22, "slider",   {-50, 50},           "top panel time",    "Adjusts vertical position of the time display"},
    timeX      = {-4,    23, "slider",   {-50, 50},           "top panel time",    "Adjusts horizontal position of the time display"},

})

DFRL:RegisterModule("minimap", 2, function()
    d:DebugPrint("BOOTING")

    local texpath = "Interface\\AddOns\\DragonflightReloaded\\media\\tex\\minimap\\"

    -- hide stuff
    do
        Minimap:ClearAllPoints()
        Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -35, -60)

        MinimapCluster:EnableMouse(false)
        MinimapBorder:Hide()
        MinimapBorderTop:Hide()
        MinimapToggleButton:Hide()
        GameTimeFrame:Hide()

        KillFrame(MinimapShopFrame)
    end

    -- minimap
    local minimapBorder = Minimap:CreateTexture("MinimapBorder", "OVERLAY")
    minimapBorder:SetTexture(texpath.. "uiminimapborder.tga")

    local minimapShadow = Minimap:CreateTexture("MinimapShadow", "BORDER")
    minimapShadow:SetTexture(texpath.. "uiminimapshadow.tga")

    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function()
        if arg1 > 0 then
            MinimapZoomIn:Click()
        elseif arg1 < 0 then
            MinimapZoomOut:Click()
        end
    end)

    -- top panel
    local topPanel
    local timeText
    do
        topPanel = CreateFrame("Frame", "MinimapTopPanel", Minimap)
        topPanel:SetWidth(200)
        topPanel:SetHeight(13)
        topPanel:SetPoint("BOTTOM", Minimap, "TOP", 0, 30)

        local bgTexture = topPanel:CreateTexture(nil, "BACKGROUND")
        bgTexture:SetTexture(texpath.. "uiminimap_toppanel.tga")
        bgTexture:SetPoint("TOPLEFT", topPanel, "TOPLEFT", -0, 0)
        bgTexture:SetPoint("BOTTOMRIGHT", topPanel, "BOTTOMRIGHT", 5, -20)

        MinimapZoneTextButton:ClearAllPoints()
        MinimapZoneTextButton:SetParent(topPanel)
        MinimapZoneTextButton:SetPoint("LEFT", topPanel, "LEFT", 4, -2)
        MinimapZoneText:SetJustifyH("LEFT")
        MinimapZoneText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")

        local timeFrame = CreateFrame("Frame", "MinimapTimeFrame", UIParent)
        timeFrame:SetWidth(40)
        timeFrame:SetHeight(20)
        timeFrame:SetPoint("RIGHT", topPanel, "RIGHT", -4, -2)
        timeFrame:EnableMouse(true)

        timeText = timeFrame:CreateFontString("MinimapTimeText", "OVERLAY", "GameFontNormal")
        timeText:SetPoint("CENTER", timeFrame, "CENTER", 0, 0)
        timeText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        timeText:SetTextColor(1, 1, 1, 1)

        local updateTimer = CreateFrame("Frame")
        updateTimer:SetScript("OnUpdate", function()
            if (this.tick or 0) > GetTime() then return end
            this.tick = GetTime() + 5

            local localTime = date("%H:%M")
            timeText:SetText(localTime)
        end)

        timeFrame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")
            local hour, minute = GetGameTime()
            local serverTime = format("%d:%02d", hour, minute)
            GameTooltip:AddLine("Time")
            GameTooltip:AddLine("Local: " .. date("%H:%M"), 1, 1, 1)
            GameTooltip:AddLine("Server: " .. serverTime, 1, 1, 1)
            GameTooltip:Show()
        end)

        timeFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        -- expose
        DFRL.topPanel = topPanel
    end

    -- zoom buttons
    do
        MinimapZoomIn:ClearAllPoints()
        MinimapZoomIn:SetParent(Minimap)
        MinimapZoomIn:SetPoint("TOPLEFT", Minimap, "BOTTOMRIGHT", -5, 40)
        MinimapZoomIn:SetScale(0.9)

        MinimapZoomIn:SetNormalTexture(texpath.. "ZoomIn32.tga")
        MinimapZoomIn:SetDisabledTexture(texpath.. "ZoomIn32-disabled.tga")
        MinimapZoomIn:SetHighlightTexture(texpath.. "ZoomIn32-over.tga")
        MinimapZoomIn:SetPushedTexture(texpath.. "ZoomIn32-push.tga")

        MinimapZoomOut:ClearAllPoints()
        MinimapZoomOut:SetParent(Minimap)
        MinimapZoomOut:SetPoint("TOPRIGHT", MinimapZoomIn, "BOTTOMLEFT", 0, 0)
        MinimapZoomOut:SetScale(0.9)

        MinimapZoomOut:SetNormalTexture(texpath.. "ZoomOut32.tga")
        MinimapZoomOut:SetDisabledTexture(texpath.. "ZoomOut32-disabled.tga")
        MinimapZoomOut:SetHighlightTexture(texpath.. "ZoomOut32-over.tga")
        MinimapZoomOut:SetPushedTexture(texpath.. "ZoomOut32-push.tga")
    end

    -- mail
    do
        MiniMapMailFrame:ClearAllPoints()
        MiniMapMailFrame:SetPoint("TOPLEFT", topPanel, "BOTTOMLEFT", -2, -1)
        MiniMapMailIcon:SetTexture(texpath.. "mail.tga")
        MiniMapMailIcon:SetWidth(32)
        MiniMapMailIcon:SetHeight(32)
        MiniMapMailBorder:Hide()
    end

    -- buffs
    do
        BuffButton0:ClearAllPoints()
        BuffButton0:SetPoint("TOPRIGHT", topPanel, "TOPLEFT", -50, 0)

        BuffButton8:ClearAllPoints()
        BuffButton8:SetPoint("TOPRIGHT", topPanel, "TOPLEFT", -50, -15)

        TempEnchant1:ClearAllPoints()
        TempEnchant1:SetPoint("TOPRIGHT", topPanel, "TOPLEFT", -50, -75)

        BuffButton16:ClearAllPoints()
        BuffButton16:SetPoint("TOPRIGHT", topPanel, "TOPLEFT", -50, -120)
    end

    -- tracker
    do
        MiniMapTrackingFrame:ClearAllPoints()
        MiniMapTrackingFrame:SetPoint("TOPRIGHT", topPanel, "TOPLEFT", -15, 0)
        MiniMapTrackingFrame:SetScale(0.6)
        MiniMapTrackingBorder:Hide()
    end

    -- durability
    do
        DurabilityFrame:ClearAllPoints()
        ---@diagnostic disable-next-line: redundant-parameter
        DurabilityFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", 15, 15)
        DurabilityFrame.SetPoint = function() return end
        DurabilityFrame:SetScale(0.7)


    end

    -- EBC
    do
        ---@diagnostic disable-next-line: undefined-field
        _G.EBC_Minimap:Hide()
        ---@diagnostic disable-next-line: undefined-field
        _G.EBC_Minimap.Show = function() end

        -- EBC_Minimap:SetParent(UIParent)
        -- EBC_Minimap:ClearAllPoints()
        -- EBC_Minimap:Hide()
        -- EBC_Minimap:SetPoint("TOPRIGHT", topPanel, "BOTTOMRIGHT", 0, -15)
        -- EBC_Minimap:SetScale(0.8)

        -- local regions = {EBC_Minimap:GetRegions()}
        -- for _, region in ipairs(regions) do
        --     if region and region:GetObjectType() == "Texture" then
        --         local width, height = region:GetWidth(), region:GetHeight()
        --         if width > 20 or height > 20 then
        --             region:Hide()
        --         end
        --     end
        -- end
    end

    -- collector
    DFRL.MinimapButtonsPerRow = 3
    do
        ---@diagnostic disable-next-line: undefined-field
        KillFrame(_G.MBB_MinimapButtonFrame)
        ---@diagnostic disable-next-line: undefined-field
        KillFrame(_G.MinimapButtonFrame)
        ---@diagnostic disable-next-line: undefined-field
        KillFrame(_G.MBFMiniButtonFrame)

        local collector = CreateFrame("Frame", "MinimapButtonCollector", UIParent)
        collector:SetFrameStrata("MEDIUM")
        collector:SetPoint("RIGHT", Minimap, "LEFT", -35, 0)
        collector:SetWidth(40)
        collector:SetHeight(150)

        -- create background with gradient
        collector.bg = collector:CreateTexture(nil, "BACKGROUND")
        collector.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        collector.bg:SetAllPoints()
        ---@diagnostic disable-next-line: undefined-field
        collector.bg:SetGradientAlpha("HORIZONTAL", 0.1, 0.1, 0.1, 0, 0.1, 0.1, 0.1, 1)

        local function CollectMinimapButtons()
            d:DebugPrint("Starting minimap button collection...")

            local buttons = {}
            local children = { Minimap:GetChildren() }
            local numChildren = table.getn(children)

            d:DebugPrint("Found " .. numChildren .. " children on Minimap")

            -- get children
            for i = 1, numChildren do
                local child = children[i]
                if child and child:IsVisible() then
                    local childName = child:GetName() or "unnamed"
                    local childType = child:GetObjectType()

                    d:DebugPrint("Child " .. i .. ": " .. childName .. " (Type: " .. childType .. ", Visible: true)")

                    local isMinimapButton = false

                    -- check if its a direct Button or Frame with Button
                    if child:IsObjectType("Button") then
                        isMinimapButton = true
                        d:DebugPrint("Found direct Button: " .. childName)
                    elseif child:IsObjectType("Frame") then
                        local frameChildren = { child:GetChildren() }
                        for j = 1, table.getn(frameChildren) do
                            if frameChildren[j] and frameChildren[j]:IsObjectType("Button") then
                                isMinimapButton = true
                                d:DebugPrint("Found Frame with Button inside: " .. childName)
                                break
                            end
                        end
                        if not isMinimapButton then
                            d:DebugPrint("Frame has no Button children: " .. childName)
                        end
                    else
                        d:DebugPrint("Skipped non-Button/Frame: " .. childName .. " (Type: " .. childType .. ")")
                    end

                    if isMinimapButton then
                        -- skip known UI elements
                        local skipNames = {
                            "MinimapBorder", "MinimapBackdrop", "MiniMapWorldMapButton",
                            "MinimapZoomIn", "MinimapZoomOut", "MiniMapMailFrame",
                            "MiniMapBattlefieldFrame", "MiniMapTrackingFrame",
                            "MiniMapZoneTextButton", "MiniMapMeetingStoneFrame",
                            "TWMiniMapBattlefieldFrame", "EBC_Minimap", "LFTMinimapButton"
                        }

                        local shouldSkip = false
                        for k = 1, table.getn(skipNames) do
                            if childName == skipNames[k] then
                                shouldSkip = true
                                break
                            end
                        end

                        if not shouldSkip then
                            local parentName = ""
                            if child:GetParent() and child:GetParent():GetName() then
                                parentName = child:GetParent():GetName()
                            end

                            local lowerName = string.lower(childName)
                            local lowerParent = string.lower(parentName)

                            -- skip UI panels, arrows, and player buttons
                            if not (string.find(lowerName, "panel") or
                                    string.find(lowerParent, "panel") or
                                    string.find(lowerName, "arrow") or
                                    string.find(lowerName, "player")) then

                                table.insert(buttons, child)
                                d:DebugPrint("Added minimap button: " .. childName)
                            else
                                d:DebugPrint("Skipped UI panel/arrow button: " .. childName .. " (parent: " .. parentName .. ")")
                            end
                        else
                            d:DebugPrint("Skipped known UI element: " .. childName)
                        end
                    end
                end
            end

            -- gatherer fix since they decided to call it "GathererUI_IconFrame" -,-
            if _G["GathererUI_IconFrame"] then
                table.insert(buttons, _G["GathererUI_IconFrame"])
                d:DebugPrint("Added Gatherer button manually")
            end

            d:DebugPrint("Total buttons found: " .. table.getn(buttons))

            -- arrange buttons
            local buttonSize = 24
            local padding = 4
            local buttonsPerRow = DFRL.MinimapButtonsPerRow
            local count = 0

            for i = 1, table.getn(buttons) do
                local button = buttons[i]
                button:SetParent(collector)
                button:ClearAllPoints()

                local row = math.floor(count / buttonsPerRow)
                local col = count - (row * buttonsPerRow)

                button:SetPoint("TOPRIGHT", collector, "TOPRIGHT",
                    -3 - (row * (buttonSize + padding)),
                    -6 - (col * (buttonSize + padding)))

                -- disable setpoint so buttons dont escape (like atlas for ex.)
                if not button.originalSetPoint then
                    button.originalSetPoint = button.SetPoint
                    button.SetPoint = function(self, point, relativeTo, relativePoint, xOfs, yOfs)
                        return
                    end
                end

                d:DebugPrint("Positioned button " .. (button:GetName() or "unnamed") .. " at position " .. count)
                count = count + 1
            end

            -- resize collector
            local rows = math.ceil(count / buttonsPerRow)
            local newWidth = 42 + (rows * (buttonSize + padding))
            local newHeight = math.max(30, 12 + (math.min(count, buttonsPerRow) * (buttonSize + padding)))
            collector:SetWidth(newWidth)
            collector:SetHeight(newHeight)

            d:DebugPrint("Collector resized to height: " .. newHeight .. " for " .. count .. " buttons")
        end

        local function DelayedCollect()
            d:DebugPrint("Starting delayed collection timer...")
            local timer = 0
            collector:SetScript("OnUpdate", function()
                timer = timer + arg1
                if timer > 0.1 then
                    d:DebugPrint("Timer expired, collecting buttons now...")
                    CollectMinimapButtons()
                    collector:SetScript("OnUpdate", nil)
                    collector:Hide()
                end
            end)
        end

        local function AddGoldenBorder()
            local positions = {
                {point1="BOTTOMLEFT", point2="TOPLEFT", point3="BOTTOMRIGHT", point4="TOPRIGHT", width=nil, height=1, gradient=true},
                {point1="TOPLEFT", point2="TOPRIGHT", point3="BOTTOMLEFT", point4="BOTTOMRIGHT", width=1, height=nil, gradient=false},
                {point1="TOPLEFT", point2="BOTTOMLEFT", point3="TOPRIGHT", point4="BOTTOMRIGHT", width=nil, height=1, gradient=true}
            }

            local names = {"topBorder", "bottomBorder", "rightBorder"}

            for i = 1, 3 do
                local border = collector:CreateTexture(nil, "OVERLAY")
                collector[names[i]] = border
                border:SetTexture("Interface\\Buttons\\WHITE8X8")
                border:SetPoint(positions[i].point1, collector, positions[i].point2, 0, 0)
                border:SetPoint(positions[i].point3, collector, positions[i].point4, 0, 0)
                if positions[i].width then border:SetWidth(positions[i].width) end
                if positions[i].height then border:SetHeight(positions[i].height) end
                border:SetVertexColor(1, 0.82, 0, 1)
                if positions[i].gradient then
                    ---@diagnostic disable-next-line: undefined-field
                    border:SetGradientAlpha("HORIZONTAL", 1, 0.82, 0, 0, 1, 0.82, 0, 1)
                end
            end
        end

        -- on load
        DelayedCollect()
        AddGoldenBorder()

        -- toggle button
        local toggleButton = CreateFrame("Button", "MinimapButtonCollectorToggle", UIParent)
        toggleButton:SetWidth(16)
        toggleButton:SetHeight(16)
        toggleButton:SetPoint("RIGHT", Minimap, "LEFT", -12, 0)
        toggleButton:SetNormalTexture(texpath.. "dfrl_collector_toggle.tga")
        toggleButton:SetPushedTexture(texpath.. "dfrl_collector_toggle.tga")
        toggleButton:SetHighlightTexture(texpath.. "dfrl_collector_toggle.tga")

        -- show/hide
        toggleButton:SetScript("OnClick", function()
            if collector:IsVisible() then
                UIFrameFadeOut(collector, 0.3, 1, 0)
                collector.fadeInfo.finishedFunc = collector.Hide
                collector.fadeInfo.finishedArg1 = collector
            else
                collector:SetAlpha(0)
                collector:Show()
                UIFrameFadeIn(collector, 0.3, 0, 1)
            end
        end)

        -- expose
        DFRL.toggleButton = toggleButton
    end

    -- callbacks
    local callbacks = {}

    local function CalculateTexOffset(size)
        local minSize, maxSize = 140, 350
        local minOffset, maxOffset = 10, 26

        local offset = minOffset + (size - minSize) * (maxOffset - minOffset) / (maxSize - minSize)
        return offset
    end

    callbacks.mapSize = function(value)
        Minimap:SetHeight(value)
        Minimap:SetWidth(value)

        ThrottledMessage("Move your character a bit after setting 'Map Size'.")

        local offset = CalculateTexOffset(value)

        minimapBorder:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -offset, offset)
        minimapBorder:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", offset, -offset)

        minimapShadow:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -offset, offset)
        minimapShadow:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", offset, -offset)
    end

    callbacks.showShadow = function(value)
        if value then
            minimapShadow:Show()
        else
            minimapShadow:Hide()
        end
    end

    callbacks.darkMode = function(value)
        local darkColor = {0.2, 0.2, 0.2}
        local lightColor = {1, 1, 1}
        local color = value and darkColor or lightColor

        minimapBorder:SetVertexColor(color[1], color[2], color[3])
        local normalTex = DFRL.toggleButton:GetNormalTexture()
        local pushedTex = DFRL.toggleButton:GetPushedTexture()

        if normalTex then normalTex:SetVertexColor(color[1], color[2], color[3]) end
        if pushedTex then pushedTex:SetVertexColor(color[1], color[2], color[3]) end

        local zoomInNormal = MinimapZoomIn:GetNormalTexture()
        local zoomOutNormal = MinimapZoomOut:GetNormalTexture()
        zoomInNormal:SetVertexColor(color[1], color[2], color[3])
        zoomOutNormal:SetVertexColor(color[1], color[2], color[3])

        local zoomInDisabled = MinimapZoomIn:GetDisabledTexture()
        local zoomOutDisabled = MinimapZoomOut:GetDisabledTexture()
        zoomInDisabled:SetVertexColor(color[1], color[2], color[3])
        zoomOutDisabled:SetVertexColor(color[1], color[2], color[3])
    end

    callbacks.alphaShadow = function(value)
        minimapShadow:SetAlpha(value)
    end

    callbacks.showZoom = function(value)
        if value then
            MinimapZoomIn:Show()
            MinimapZoomOut:Show()
        else
            MinimapZoomIn:Hide()
            MinimapZoomOut:Hide()
        end
    end

    callbacks.scaleZoom = function(value)
        MinimapZoomIn:SetScale(value)
        MinimapZoomOut:SetScale(value)
    end

    callbacks.alphaZoom = function(value)
        MinimapZoomIn:SetAlpha(value)
        MinimapZoomOut:SetAlpha(value)
    end

    callbacks.mapAlpha = function(value)
        Minimap:SetAlpha(value)
    end

    callbacks.showTopPanel = function(value)
        if value then
            topPanel:Show()
        else
            topPanel:Hide()
        end
    end

    callbacks.topPanelWidth = function(value)
        topPanel:SetWidth(value)
    end

    callbacks.topPanelHeight = function(value)
        topPanel:SetHeight(value)
    end

    callbacks.zoneTextSize = function(value)
        MinimapZoneText:SetFont("Fonts\\FRIZQT__.TTF", value, "")
    end

    callbacks.zoneTextY = function(value)
        MinimapZoneTextButton:ClearAllPoints()
        MinimapZoneTextButton:SetPoint("LEFT", topPanel, "LEFT", DFRL:GetConfig("minimap", "zoneTextX"), value)
    end

    callbacks.zoneTextX = function(value)
        MinimapZoneTextButton:ClearAllPoints()
        MinimapZoneTextButton:SetPoint("LEFT", topPanel, "LEFT", value, DFRL:GetConfig("minimap", "zoneTextY"))
    end

    callbacks.timeSize = function(value)
        timeText:SetFont("Fonts\\FRIZQT__.TTF", value, "")
    end

    callbacks.timeY = function(value)
        timeText:ClearAllPoints()
        timeText:SetPoint("RIGHT", topPanel, "RIGHT", DFRL:GetConfig("minimap", "timeX"), value)
    end

    callbacks.timeX = function(value)
        timeText:ClearAllPoints()
        timeText:SetPoint("RIGHT", topPanel, "RIGHT", value, DFRL:GetConfig("minimap", "timeY"))
    end

    callbacks.showTime = function(value)
        if value then
            timeText:Show()
        else
            timeText:Hide()
        end
    end

    callbacks.showPfQuest = function (value)
        if pfBrowserIcon then
            if value then
                pfBrowserIcon:Show()
            else
                pfBrowserIcon:Hide()
            end
        end
    end

    callbacks.mapSquare = function(value)
        if value then
            minimapBorder:SetTexture(texpath.. "map_dragonflight_square2.tga")
            minimapShadow:SetTexture(texpath.. "map_dragonflight_square_shadow.tga")
            Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
        else
            minimapBorder:SetTexture(texpath.. "uiminimapborder.tga")
            minimapShadow:SetTexture(texpath.. "uiminimapshadow.tga")
            Minimap:SetMaskTexture("Textures\\MinimapMask")
        end
    end

    callbacks.zoomX = function(value)
        MinimapZoomIn:ClearAllPoints()
        MinimapZoomIn:SetPoint("TOPLEFT", Minimap, "BOTTOMRIGHT", value, DFRL:GetConfig("minimap", "zoomY"))
    end

    callbacks.zoomY = function(value)
        MinimapZoomIn:ClearAllPoints()
        MinimapZoomIn:SetPoint("TOPLEFT", Minimap, "BOTTOMRIGHT", DFRL:GetConfig("minimap", "zoomX"), value)
    end

    -- execute callbacks
    DFRL:RegisterCallback("minimap", callbacks)
end)
