DFRL:NewDefaults("Gui-shag", {
    enabled = {true},

})

DFRL:NewMod("Gui-shag", 3, function()
    debugprint(">> BOOTING")

    local Base = DFRL.gui.Base
    local panel = Base.scrollChildren[5]
    local Setup = {
        font = DFRL:GetInfoOrCons("font"),

        metadata = {},
        checkboxes = {},
        descriptionLabels = {},
        headers = {},

        DESCRIPTION_FONT_SIZE = 15,
        HEADER_TOP_SPACING = 40,
        HEADER_BOTTOM_SPACING = 25,
        CHECKBOX_ROW_SPACING = 45,
        MODULE_SPACING = 25,
    }

    local f = CreateFrame("Frame")
    f:RegisterEvent("VARIABLES_LOADED")
    f:SetScript("OnEvent", function()
        debugprint("VARIABLES LOADED FROM ELEM.LUA")
        if DFRL.gui.shaguCore == true or DFRL.gui.shaguExtras == true then
            debugprint("SHAGU FLAGS RECEIVED")
            Setup:MetaData()
            Setup:Elements()
        else
            debugprint("SHAGU FLAGS NOT READY, WAITING...")
            local waitFrame = CreateFrame("Frame")
            waitFrame.elapsed = 0
            waitFrame:SetScript("OnUpdate", function()
                this.elapsed = this.elapsed + arg1
                if (DFRL.gui.shaguCore == true or DFRL.gui.shaguExtras == true) or this.elapsed > 3 then
                    debugprint("SHAGU FLAGS READY OR TIMEOUT - Core: " .. tostring(DFRL.gui.shaguCore) .. " Extras: " .. tostring(DFRL.gui.shaguExtras))
                    this:SetScript("OnUpdate", nil)
                    if DFRL.gui.shaguCore == true or DFRL.gui.shaguExtras == true then
                        debugprint("FLAGS FOUND - CREATING UI")
                        Setup:MetaData()
                        Setup:Elements()
                    else
                        debugprint("TIMEOUT - NO FLAGS FOUND")
                    end
                end
            end)
        end
    end)

    function Setup:MetaData()
        if DFRL.gui.shaguCoreData then
            for elementName, valueTable in pairs(DFRL.gui.shaguCoreData) do

                self.metadata[elementName] = {
                    elementType = valueTable[2],
                    elementTypeMeta = valueTable[3],
                    category = valueTable[5],
                    categoryIndex = valueTable[6],
                    description = valueTable[7],
                    extraDescription = valueTable[8],
                    module = "core"
                }
            end
        end

        if DFRL.gui.shaguExtrasData then
            for elementName, valueTable in pairs(DFRL.gui.shaguExtrasData) do

                self.metadata[elementName] = {
                    elementType = valueTable[2],
                    elementTypeMeta = valueTable[3],
                    category = valueTable[5],
                    categoryIndex = valueTable[6],
                    description = valueTable[7],
                    extraDescription = valueTable[8],
                    module = "extras"
                }
            end
        end

        local count = 0
        for _ in pairs(self.metadata) do
            count = count + 1
        end

        debugprint("MetaData - Prepared metadata for " .. count .. " elements")
    end

    function Setup:Elements()


        debugprint("Elements - Starting UI creation")
        local groups = {}

        for key, data in pairs(self.metadata) do
            local module = data.module or "other"
            local cat = data.category or "Other"
            debugprint("Elements - Grouping " .. key .. " into " .. module .. "." .. cat .. " (index: " .. tostring(data.categoryIndex or 999) .. ")")

            if not groups[module] then groups[module] = {} end
            if not groups[module][cat] then groups[module][cat] = {} end

            table.insert(groups[module][cat], {key = key, data = data})
        end

        debugprint("Elements - Grouping complete, showing final groups:")
        for module, categories in pairs(groups) do
            for category, elements in pairs(categories) do
                debugprint("Elements - Group " .. module .. "." .. category .. " has " .. table.getn(elements) .. " elements")
            end
        end

        local yPos = 65
        debugprint("Elements - Starting placement at yPos: " .. yPos)

        local moduleOrder = {"core", "extras"}

        for _, module in pairs(moduleOrder) do
            if groups[module] then
                debugprint("Elements - Processing module: " .. module)

                local moduleTitle = module == "core" and "ShaguTweaks" or "ShaguTweaks Extras"
                local moduleHeader = DFRL.tools.CreateCategoryHeader(panel, moduleTitle, nil, 300, 50, 30)
                moduleHeader:SetPoint("TOP", panel, "TOP", -200, -yPos)
                yPos = yPos + self.HEADER_TOP_SPACING + self.HEADER_BOTTOM_SPACING
                debugprint("Elements - Created module header: " .. moduleTitle .. " at yPos: " .. yPos)

                local categoryNames = {}
                for categoryName in pairs(groups[module]) do
                    table.insert(categoryNames, categoryName)
                end
                table.sort(categoryNames)

                for _, category in pairs(categoryNames) do
                    local elements = groups[module][category]
                debugprint("Elements - Creating category: " .. category .. " with " .. table.getn(elements) .. " elements")

                debugprint("Elements - Sorting elements in " .. category .. " before sort:")
                for _, element in pairs(elements) do
                    debugprint("Elements - Pre-sort: " .. element.key .. " (index: " .. tostring(element.data.categoryIndex or 999) .. ")")
                end

                table.sort(elements, function(a, b)
                    return (a.data.categoryIndex or 999) < (b.data.categoryIndex or 999)
                end)

                debugprint("Elements - After sort in " .. category .. ":")
                for i, element in pairs(elements) do
                    debugprint("Elements - Post-sort " .. i .. ": " .. element.key .. " (index: " .. tostring(element.data.categoryIndex or 999) .. ")")
                end

                debugprint("Elements - Creating header for " .. category .. " at yPos: " .. yPos)
                local header = DFRL.tools.CreateCategoryHeader(panel, category)
                header:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -yPos)
                self.headers[category] = header
                yPos = yPos + self.HEADER_TOP_SPACING + self.HEADER_BOTTOM_SPACING
                debugprint("Elements - Header placed, new yPos: " .. yPos)

                for i, element in pairs(elements) do
                    debugprint("Elements - Placing element " .. i .. ": " .. element.key .. " at yPos: " .. yPos)

                    -- create description label on left
                    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    desc:SetFont(self.font .. "BigNoodleTitling.ttf", self.DESCRIPTION_FONT_SIZE, "OUTLINE")
                    desc:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -yPos)
                    desc:SetText(element.data.description or element.key)
                    desc:SetTextColor(.9, .9, .9)
                    self.descriptionLabels[element.key] = desc

                    -- create checkbox on right
                    local cb = DFRL.tools.CreateShaguCheckbox(panel, "DFRL_Shagu_" .. element.key, element.key)
                    cb:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -150, -yPos)
                    self.checkboxes[element.key] = cb
                    yPos = yPos + self.CHECKBOX_ROW_SPACING
                    debugprint("Elements - Element placed: " .. element.key .. " | Desc: '" .. tostring(element.data.description or element.key) .. "' | New yPos: " .. yPos)
                end

                    yPos = yPos + self.MODULE_SPACING
                    debugprint("Elements - Category " .. category .. " complete, added module spacing, new yPos: " .. yPos)
                end
            elseif module == "extras" and not DFRL.gui.shaguExtrasData then
                local txt = panel:CreateFontString(nil, "OVERLAY")
                txt:SetFont(self.font .. "BigNoodleTitling.ttf", 30, "OUTLINE")
                txt:SetPoint("TOP", panel, "TOP", 10, -yPos-50)
                txt:SetText("SHAGU TWEAKS EXTRAS MISSING\nINSTALL FOR MORE OPTIONS")
                txt:SetTextColor(1, 0.5, 0.5)
                local f3 = CreateFrame("Frame")
                f3.t = 0
                f3:SetScript("OnUpdate", function()
                    this.t = this.t + arg1
                    if this.t >= 0.5 then
                        txt:SetAlpha(txt:GetAlpha() > 0.5 and 0.3 or 1)
                        this.t = 0
                    end
                end)
            end
        end
    end
end)