DFRL:NewDefaults("Collector", {
    enabled = { true },

    collectDarkMode = {0, "slider", {0, 1}, nil, "appearance", 1, "Adjust dark mode intensity", nil, nil},

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
        dragStartIndex = nil,
        buttonOrder = {},

    }

    DFRL.MinimapButtonsPerRow = 3

    function Setup:CleanupFrames()
        debugprint("Cleaning up existing minimap button frames...")
        KillFrame(_G.MBB_MinimapButtonFrame)
        KillFrame(_G.MinimapButtonFrame)
        KillFrame(_G.MBFMiniButtonFrame)
        debugprint("Cleanup complete")
    end

    function Setup:CollectorFrame()
        debugprint("Creating collector frame...")
        self.collector = CreateFrame("Frame", "MinimapButtonCollector", UIParent)
        self.collector:SetFrameStrata("MEDIUM")
        self.collector:SetPoint("RIGHT", Minimap, "LEFT", -35, 0)
        self.collector:SetWidth(40)
        self.collector:SetHeight(150)

        self.collector.bg = self.collector:CreateTexture(nil, "BACKGROUND")
        self.collector.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        self.collector.bg:SetAllPoints()
        self.collector.bg:SetGradientAlpha("HORIZONTAL", 0.1, 0.1, 0.1, 0, 0.1, 0.1, 0.1, 0.7)
        debugprint("Collector frame created with background")
    end

    function Setup:IsValidButton(frame)
        debugprint("Validating button: " .. (frame:GetName() or "unnamed"))
        if not frame:GetName() then return false end
        if not frame:IsVisible() then return false end
        if frame:GetHeight() > 40 then return false end
        if frame:GetWidth() > 40 then return false end
        if not frame:IsObjectType("Button") and not frame:IsObjectType("Frame") then return false end

        local ignored = {
            "Note", "GatherNote", "MinimapIcon", "GatherMatePin", "QuestieNote",
            "MiniNotePOI", "CartographerNotesPOI", "RecipeRadarMinimapIcon",
            "MinimapZoomIn", "MinimapZoomOut"
        }

        local name = frame:GetName()
        for i = 1, table.getn(ignored) do
            if string.find(string.lower(name), string.lower(ignored[i])) then
                debugprint("Button ignored by pattern: " .. name)
                return false
            end
        end

        if frame:IsObjectType("Button") then
            if frame:GetScript("OnClick") or frame:GetScript("OnMouseDown") or frame:GetScript("OnMouseUp") then
                debugprint("Valid button found: " .. name)
                return true
            end
        elseif frame:IsObjectType("Frame") then
            if string.find(string.lower(name), "icon") or string.find(string.lower(name), "button") then
                if frame:GetScript("OnMouseDown") or frame:GetScript("OnMouseUp") then
                    debugprint("Valid frame button found: " .. name)
                    return true
                end
            end

            local children = {frame:GetChildren()}
            for j = 1, table.getn(children) do
                if children[j] and children[j]:IsObjectType("Button") then
                    debugprint("Valid frame with button child found: " .. name)
                    return true
                end
            end
        end

        debugprint("Button validation failed: " .. name)
        return false
    end

    function Setup:FindButtons()
        debugprint("Starting minimap button collection...")
        local buttons = {}
        local children = { Minimap:GetChildren() }
        local numChildren = table.getn(children)

        debugprint("Found " .. numChildren .. " children on Minimap")

        for i = 1, numChildren do
            local child = children[i]
            if child and self:IsValidButton(child) then
                table.insert(buttons, child)
                debugprint("Added valid button: " .. child:GetName())
            elseif child and child:GetName() then
                debugprint("Skipped invalid button: " .. child:GetName())
            end
        end
        return buttons
    end

    function Setup:ArrangeButtons(buttons)
        debugprint("Arranging " .. table.getn(buttons) .. " buttons...")
        buttons = self:LoadSavedOrder(buttons)
        self.buttonOrder = buttons

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

            if not button.originalSetPoint then
                button.originalSetPoint = button.SetPoint
                button.SetPoint = function() end
            end

            self:EnableDrag(button, i)

            debugprint("Positioned button " .. (button:GetName() or "unnamed") .. " at position " .. count)
            count = count + 1
        end

        local rows = math.ceil(count / buttonsPerRow)
        local newWidth = 42 + (rows * (buttonSize + padding))
        local newHeight = math.max(30, 12 + (math.min(count, buttonsPerRow) * (buttonSize + padding)))
        self.collector:SetWidth(newWidth)
        self.collector:SetHeight(newHeight)

        debugprint("Collector resized to height: " .. newHeight .. " for " .. count .. " buttons")
    end

    function Setup:AddBorders()
        debugprint("Adding golden borders to collector...")
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
                border:SetGradientAlpha("HORIZONTAL", 1, 0.82, 0, 0, 1, 0.82, 0, 1)
            end
            debugprint("Created " .. names[i] .. " border")
        end
        debugprint("All borders added")
    end

    function Setup:CreateToggleButton()
        debugprint("Creating toggle button...")
        local toggleButton = CreateFrame("Button", "MinimapButtonCollectorToggle", UIParent)
        toggleButton:SetWidth(16)
        toggleButton:SetHeight(16)
        toggleButton:SetPoint("RIGHT", Minimap, "LEFT", -12, 0)
        toggleButton:SetNormalTexture(self.texpath.. "dfrl_collector_toggle.tga")
        toggleButton:SetHighlightTexture(self.texpath.. "dfrl_collector_toggle.tga")

        toggleButton:SetScript("OnClick", function()
            if self.collector:IsVisible() then
                debugprint("Hiding collector")
                UIFrameFadeOut(self.collector, 0.3, 1, 0)
                self.collector.fadeInfo.finishedFunc = self.collector.Hide
                self.collector.fadeInfo.finishedArg1 = self.collector
            else
                debugprint("Showing collector")
                self.collector:SetAlpha(0)
                self.collector:Show()
                UIFrameFadeIn(self.collector, 0.3, 0, 1)
            end
        end)

        DFRL.toggleButton = toggleButton
        debugprint("Toggle button created and exposed")
    end

    function Setup:StartDelayedCollection()
        debugprint("Starting delayed collection timer...")
        local timer = 0
        self.collector:SetScript("OnUpdate", function()
            timer = timer + arg1
            if timer > 0.1 then
                debugprint("Timer expired, collecting buttons now...")
                self:CleanupFrames()
                local buttons = self:FindButtons()
                if table.getn(buttons) == 0 then
                    debugprint("No buttons found, hiding collector and toggle")
                    self.collector:Hide()
                    DFRL.toggleButton:Hide()
                    self.collector:SetScript("OnUpdate", nil)
                    return
                end
                self:ArrangeButtons(buttons)
                self.collector:SetScript("OnUpdate", nil)
                self.collector:Hide()
            end
        end)
    end

    function Setup:LoadSavedOrder(buttons)
        debugprint("Loading saved button order...")
        local saved = DFRL:GetTempDB("Collector", "buttonOrder")
        if not saved then
            debugprint("No saved order found, using default")
            return buttons
        end
        debugprint("Found saved order with " .. table.getn(saved) .. " entries")

        local ordered = {}
        for i = 1, table.getn(saved) do
            for j = 1, table.getn(buttons) do
                if buttons[j]:GetName() == saved[i] then
                    table.insert(ordered, buttons[j])
                    debugprint("Matched saved button: " .. saved[i])
                    break
                end
            end
        end

        for i = 1, table.getn(buttons) do
            local found = false
            for j = 1, table.getn(ordered) do
                if buttons[i] == ordered[j] then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(ordered, buttons[i])
                debugprint("Added new button: " .. buttons[i]:GetName())
            end
        end

        debugprint("Loaded order complete with " .. table.getn(ordered) .. " buttons")
        return ordered
    end

    function Setup:SaveButtonOrder(buttons)
        debugprint("Saving button order...")
        local order = {}
        for i = 1, table.getn(buttons) do
            table.insert(order, buttons[i]:GetName())
        end
        DFRL:SetTempDBNoCallback("Collector", "buttonOrder", order)
        debugprint("Saved order with " .. table.getn(order) .. " buttons")
    end

    function Setup:RepositionAllButtons()
        debugprint("Repositioning all buttons after reorder")
        local buttonSize = 24
        local padding = 4
        local buttonsPerRow = DFRL.MinimapButtonsPerRow

        for i = 1, table.getn(self.buttonOrder) do
            local button = self.buttonOrder[i]
            button:ClearAllPoints()

            local row = math.floor((i - 1) / buttonsPerRow)
            local col = (i - 1) - (row * buttonsPerRow)
            local newX = -3 - (row * (buttonSize + padding))
            local newY = -6 - (col * (buttonSize + padding))

            button.originalSetPoint(button, "TOPRIGHT", self.collector, "TOPRIGHT", newX, newY)
            debugprint("Repositioned " .. button:GetName() .. " to position " .. i .. " (" .. newX .. ", " .. newY .. ")")
        end
    end

    function Setup:FindDropPosition(button)
        debugprint("Finding drop position for " .. button:GetName())
        local bx = button:GetLeft() + 12
        local by = button:GetTop() - 12
        local cx = self.collector:GetLeft()
        local cy = self.collector:GetTop()
        local buttonSize = 24
        local padding = 4
        local buttonsPerRow = DFRL.MinimapButtonsPerRow

        local relX = cx - bx
        local relY = cy - by

        local row = math.floor((relX + 3) / (buttonSize + padding))
        local col = math.floor((relY + 6) / (buttonSize + padding))

        if row < 0 then row = 0 end
        if col < 0 then col = 0 end

        local pos = (row * buttonsPerRow) + col + 1
        if pos > table.getn(self.buttonOrder) then
            pos = table.getn(self.buttonOrder)
        end

        debugprint("Drop position: " .. pos .. " (row:" .. row .. ", col:" .. col .. ")")
        return pos
    end

    function Setup:SnapBack(button)
        debugprint("Checking snap back for " .. button:GetName())
        local left = self.collector:GetLeft()
        local right = self.collector:GetRight()
        local top = self.collector:GetTop()
        local bottom = self.collector:GetBottom()
        local bx = button:GetLeft()
        local by = button:GetBottom()

        if bx < left or bx > right or by < bottom or by > top then
            debugprint("Button outside bounds, snapping back")
            return true
        end
        debugprint("Button within bounds")
        return false
    end

    function Setup:ReorderButtons(fromIndex, toIndex)
        debugprint("Reordering from " .. fromIndex .. " to " .. toIndex)

        if fromIndex == toIndex then
            debugprint("Same position, repositioning to grid")
            self:RepositionAllButtons()
            return
        end

        local temp = self.buttonOrder[fromIndex]
        table.remove(self.buttonOrder, fromIndex)
        table.insert(self.buttonOrder, toIndex, temp)

        self:SaveButtonOrder(self.buttonOrder)
        self:RepositionAllButtons()
        debugprint("Reorder complete - saved to DB")
    end

    function Setup:EnableDrag(button, index)
        debugprint("Enabling drag for " .. button:GetName() .. " at index " .. index)

        local dragTarget = button
        if button:IsObjectType("Frame") then
            local children = {button:GetChildren()}
            for i = 1, table.getn(children) do
                if children[i]:IsObjectType("Button") then
                    dragTarget = children[i]
                    debugprint("Found button child: " .. (dragTarget:GetName() or "unnamed"))
                    break
                end
            end
        end

        dragTarget:RegisterForDrag("LeftButton")
        button:SetMovable(true)
        dragTarget:EnableMouse(true)

        dragTarget:SetScript("OnDragStart", function()
            debugprint("Drag started for " .. button:GetName())
            self.dragStartIndex = index
            button.origRow = math.floor((index - 1) / DFRL.MinimapButtonsPerRow)
            button.origCol = (index - 1) - (button.origRow * DFRL.MinimapButtonsPerRow)
            button:StartMoving()
        end)

        dragTarget:SetScript("OnDragStop", function()
            debugprint("=== DRAG STOP START for " .. button:GetName() .. " ===")
            button:StopMovingOrSizing()

            if self:SnapBack(button) then
                debugprint("SNAP BACK: Button outside bounds")
                local currentIndex = nil
                for i = 1, table.getn(self.buttonOrder) do
                    if self.buttonOrder[i] == button then
                        currentIndex = i
                        break
                    end
                end

                button:ClearAllPoints()
                local buttonSize = 24
                local padding = 4
                local row = math.floor((currentIndex - 1) / DFRL.MinimapButtonsPerRow)
                local col = (currentIndex - 1) - (row * DFRL.MinimapButtonsPerRow)
                local newX = -3 - (row * (buttonSize + padding))
                local newY = -6 - (col * (buttonSize + padding))

                button.originalSetPoint(button, "TOPRIGHT", self.collector, "TOPRIGHT", newX, newY)
                debugprint("Snapped back to position " .. currentIndex)
                return
            end

            local dropIndex = self:FindDropPosition(button)
            debugprint("Drop index: " .. dropIndex)

            if self.dragStartIndex ~= dropIndex then
                self:ReorderButtons(self.dragStartIndex, dropIndex)
            else
                self:RepositionAllButtons()
            end
            debugprint("=== DRAG STOP END ===")
        end)
    end

    --=================
    -- INIT
    --=================
    function Setup:Run()
        debugprint("Running collector setup...")
        self:CleanupFrames()
        self:CollectorFrame()
        self:StartDelayedCollection()
        self:AddBorders()
        self:CreateToggleButton()
        debugprint("Collector setup complete")
    end

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
