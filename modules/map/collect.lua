DFRL:NewDefaults("Collector", {
    enabled = { true },

    collectDarkMode = {0, "slider", {0, 1}, nil, "appearancse", 1, "Adjusst dark mode intensity", nil, nil},

})

DFRL:NewMod("Collector", 1, function()
    debugprint(">> BOOTING")

    --=================
    -- SETUP
    --=================
    local Setup = {
        texpath = "Interface\\AddOns\\-DragonflightReloaded\\media\\tex\\minimap\\",

        collector = nil,
        toggleButton = nil,

    }


    DFRL.MinimapButtonsPerRow = 3

    function Setup:Collector()
        -- collector
        ---@diagnostic disable-next-line: undefined-field
        KillFrame(_G.MBB_MinimapButtonFrame)
        ---@diagnostic disable-next-line: undefined-field
        KillFrame(_G.MinimapButtonFrame)
        ---@diagnostic disable-next-line: undefined-field
        KillFrame(_G.MBFMiniButtonFrame)

        self.collector = CreateFrame("Frame", "MinimapButtonCollector", UIParent)
        self.collector:SetFrameStrata("MEDIUM")
        self.collector:SetPoint("RIGHT", Minimap, "LEFT", -35, 0)
        self.collector:SetWidth(40)
        self.collector:SetHeight(150)

        self.collector.bg = self.collector:CreateTexture(nil, "BACKGROUND")
        self.collector.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        self.collector.bg:SetAllPoints()
        ---@diagnostic disable-next-line: undefined-field
        self.collector.bg:SetGradientAlpha("HORIZONTAL", 0.1, 0.1, 0.1, 0, 0.1, 0.1, 0.1, 0.7)

        local function CollectMinimapButtons()
            debugprint("Starting minimap button collection...")

            local buttons = {}
            local children = { Minimap:GetChildren() }
            local numChildren = table.getn(children)

            debugprint("Found " .. numChildren .. " children on Minimap")

            -- get children
            for i = 1, numChildren do
                local child = children[i]
                if child and child:IsVisible() then
                    local childName = child:GetName() or "unnamed"
                    local childType = child:GetObjectType()

                    debugprint("Child " .. i .. ": " .. childName .. " (Type: " .. childType .. ", Visible: true)")

                    local isMinimapButton = false

                    -- check if its a direct Button or Frame with Button
                    if child:IsObjectType("Button") then
                        isMinimapButton = true
                        debugprint("Found direct Button: " .. childName)
                    elseif child:IsObjectType("Frame") then
                        local frameChildren = { child:GetChildren() }
                        for j = 1, table.getn(frameChildren) do
                            if frameChildren[j] and frameChildren[j]:IsObjectType("Button") then
                                isMinimapButton = true
                                debugprint("Found Frame with Button inside: " .. childName)
                                break
                            end
                        end
                        if not isMinimapButton then
                            debugprint("Frame has no Button children: " .. childName)
                        end
                    else
                        debugprint("Skipped non-Button/Frame: " .. childName .. " (Type: " .. childType .. ")")
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
                                debugprint("Added minimap button: " .. childName)
                            else
                                debugprint("Skipped UI panel/arrow button: " .. childName .. " (parent: " .. parentName .. ")")
                            end
                        else
                            debugprint("Skipped known UI element: " .. childName)
                        end
                    end
                end
            end

            -- gatherer fix since they decided to call it "GathererUI_IconFrame" -,-
            if _G["GathererUI_IconFrame"] then
                table.insert(buttons, _G["GathererUI_IconFrame"])
                debugprint("Added Gatherer button manually")
            end

            debugprint("Total buttons found: " .. table.getn(buttons))

            -- arrange buttons
            local buttonSize = 24
            local padding = 4
            local buttonsPerRow = DFRL.MinimapButtonsPerRow
            local count = 0

            for i = 1, table.getn(buttons) do
                local button = buttons[i]
                button:SetParent(self.collector)
                button:ClearAllPoints()

                local row = math.floor(count / buttonsPerRow)
                local col = count - (row * buttonsPerRow)

                button:SetPoint("TOPRIGHT", self.collector, "TOPRIGHT",
                    -3 - (row * (buttonSize + padding)),
                    -6 - (col * (buttonSize + padding)))

                -- disable setpoint so buttons dont escape (like atlas for ex.)
                if not button.originalSetPoint then
                    button.originalSetPoint = button.SetPoint
                    button.SetPoint = function(self, point, relativeTo, relativePoint, xOfs, yOfs)
                        return
                    end
                end

                debugprint("Positioned button " .. (button:GetName() or "unnamed") .. " at position " .. count)
                count = count + 1
            end

            -- resize self.collector
            local rows = math.ceil(count / buttonsPerRow)
            local newWidth = 42 + (rows * (buttonSize + padding))
            local newHeight = math.max(30, 12 + (math.min(count, buttonsPerRow) * (buttonSize + padding)))
            self.collector:SetWidth(newWidth)
            self.collector:SetHeight(newHeight)

            debugprint("Collector resized to height: " .. newHeight .. " for " .. count .. " buttons")
        end

        local function DelayedCollect()
            debugprint("Starting delayed collection timer...")
            local timer = 0
            self.collector:SetScript("OnUpdate", function()
                timer = timer + arg1
                if timer > 0.1 then
                    debugprint("Timer expired, collecting buttons now...")
                    CollectMinimapButtons()
                    self.collector:SetScript("OnUpdate", nil)
                    self.collector:Hide()
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
                local border = self.collector:CreateTexture(nil, "OVERLAY")
                self.collector[names[i]] = border
                border:SetTexture("Interface\\Buttons\\WHITE8X8")
                border:SetPoint(positions[i].point1, self.collector, positions[i].point2, 0, 0)
                border:SetPoint(positions[i].point3, self.collector, positions[i].point4, 0, 0)
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
        toggleButton:SetNormalTexture(self.texpath.. "dfrl_collector_toggle.tga")
        toggleButton:SetHighlightTexture(self.texpath.. "dfrl_collector_toggle.tga")

        -- show/hide
        toggleButton:SetScript("OnClick", function()
            if self.collector:IsVisible() then
                UIFrameFadeOut(self.collector, 0.3, 1, 0)
                self.collector.fadeInfo.finishedFunc = self.collector.Hide
                self.collector.fadeInfo.finishedArg1 = self.collector
            else
                self.collector:SetAlpha(0)
                self.collector:Show()
                UIFrameFadeIn(self.collector, 0.3, 0, 1)
            end
        end)

        -- expose
        DFRL.toggleButton = toggleButton
    end

    function Setup:Run()
        Setup:Collector()
    end

    --=================
    -- INIT
    --=================
    Setup:Run()

    --=================
    -- EXPOSE
    --=================

    --=================
    -- CALLBACKS
    --=================
    local callbacks = {}

    callbacks.collectDarkMode = function(value)
        local intensity = DFRL:GetTempDB("Collector", "collectDarkMode")
        local color = {1 - intensity, 1 - intensity, 1 - intensity}
        if not value then color = {1, 1, 1} end

        local normalTex = DFRL.toggleButton:GetNormalTexture()
        local highlightTex = DFRL.toggleButton:GetHighlightTexture()
        if normalTex then normalTex:SetVertexColor(color[1], color[2], color[3]) end
        if highlightTex then highlightTex:SetVertexColor(color[1], color[2], color[3]) end
    end

    --=================
    -- EVENT
    --=================

    DFRL:NewCallbacks("Collector", callbacks)
end)
