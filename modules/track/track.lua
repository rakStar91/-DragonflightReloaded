DFRL:NewDefaults("UpdateNotifier", {
    enabled = {true},
    updateDays = {"7"},
})

DFRL:NewMod("UpdateNotifier", 1, function()
    debugprint(">> BOOTING")

    --=================
    -- SETUP
    --=================

    local Setup = {
        font = DFRL:GetInfoOrCons("font"),
        version = DFRL:GetInfoOrCons("version"),
        updateDays = 7,
        frame = nil,
        txt1 = nil,
        txt2 = nil,
        dd = nil,
        btn = nil,
    }

    function Setup:ParseDate(dateStr)
        debugprint("ParseDate - Input: " .. tostring(dateStr))
        local slash1 = string.find(dateStr, "/")
        local slash2 = string.find(dateStr, "/", slash1 + 1)
        if slash1 and slash2 then
            local day = tonumber(string.sub(dateStr, 1, slash1 - 1))
            local month = tonumber(string.sub(dateStr, slash1 + 1, slash2 - 1))
            local year = tonumber(string.sub(dateStr, slash2 + 1))
            debugprint("ParseDate - Parsed: day=" .. tostring(day) .. ", month=" .. tostring(month) .. ", year=" .. tostring(year))
            if day and month and year then
                local timestamp = time({year = year, month = month, day = day})
                debugprint("ParseDate - Timestamp: " .. tostring(timestamp))
                return timestamp
            end
        end
        debugprint("ParseDate - Failed to parse")
        return nil
    end

    function Setup:CheckVersionUpdate()
        debugprint(">> CheckVersionUpdate START")
        local stored = DFRL_DB_SETUP.lastVersionCheck
        debugprint("Stored data: " .. tostring(stored and "exists" or "nil"))
        debugprint("Current version: " .. tostring(self.version))
        debugprint("Stored version: " .. tostring(stored and stored.version or "nil"))

        if not stored or stored.version ~= self.version then
            debugprint("Version differs - updating record")
            DFRL_DB_SETUP.lastVersionCheck = {
                version = self.version,
                date = date("%d/%m/%Y")
            }
            debugprint("Version updated: " .. self.version)
        else
            debugprint("Version unchanged: " .. self.version)
        end
        debugprint("<< CheckVersionUpdate END")
    end

    function Setup:IsUpdateOverdue()
        debugprint(">> IsUpdateOverdue START")
        local stored = DFRL_DB_SETUP.lastVersionCheck
        debugprint("Stored data exists: " .. tostring(stored and "yes" or "no"))

        if stored and stored.date then
            debugprint("Valid date found: " .. tostring(stored.date))
            local setting = DFRL:GetTempDB("UpdateNotifier", "updateDays")
            debugprint("Update setting: " .. tostring(setting))

            if setting == "never" then
                debugprint("Update set to never - returning false")
                return false
            end

            local days = tonumber(setting) or self.updateDays
            debugprint("Days threshold: " .. tostring(days))

            local storedTime = self:ParseDate(stored.date)
            local todayTime = time()

            if storedTime then
                local daysDiff = math.floor((todayTime - storedTime) / 86400)
                debugprint("Days elapsed: " .. tostring(daysDiff))
                local overdue = daysDiff >= days
                debugprint("Is overdue: " .. tostring(overdue))
                debugprint("<< IsUpdateOverdue END")
                return overdue
            end
        end
        debugprint("Invalid/missing date - returning false")
        debugprint("<< IsUpdateOverdue END")
        return false
    end

    function Setup:ShowNotification()
        debugprint(">> ShowNotification START")

        if not self.frame then
            self.frame = DFRL.tools.CreateDFRLFrame(nil, 400, 120, "BOTTOM")
            debugprint("Frame created")
            self.frame:SetPoint("TOP", UIParent, "TOP", 0, 120)
            self.frame:SetFrameStrata("HIGH")
        end
        debugprint("Frame positioned and strata set")
        DFRL.tools.MoveFrame(self.frame, 0, -1, .3, 120)
        debugprint("Frame move animation started")

        local stored = DFRL_DB_SETUP.lastVersionCheck
        local lastDate = "UNKNOWN"
        if stored and stored.date then
            lastDate = tostring(stored.date)
        end
        debugprint("Last update date: " .. tostring(lastDate))

        if not self.txt1 then
            self.txt1 = DFRL.tools.CreateFont(self.frame, 13, "LAST UPDATE WAS ON |CFFFF0000" .. lastDate .. "|r.")
            self.txt1:SetPoint("TOP", self.frame, "TOP", 0, -15)
        end

        if not self.txt2 then
            self.txt2 = DFRL.tools.CreateFont(self.frame, 13, "Remember to update |cFFFFD100Dragonflight:|r Reloaded.")
            self.txt2:SetPoint("TOP", self.txt1, "BOTTOM", 0, -5)
        end

        if not self.dd then
            self.dd = DFRL.tools.CreateDropDown(self.frame, "Days to remind again:", "UpdateNotifier", "updateDays", {"7", "14", "30", "never"}, true, 20, 60)
            self.dd:SetPoint("CENTER", self.frame, "CENTER", 0, -15)
            debugprint("Dropdown created")
        end

        if not self.btn then
            self.btn = DFRL.tools.CreateButton(self.frame, "OK", 60, 20)
            self.btn:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, 10)
            self.btn:SetScript("OnClick", function()
                debugprint("OK button clicked - updating date and closing notification")
                DFRL_DB_SETUP.lastVersionCheck.date = date("%d/%m/%Y")
                debugprint("Date updated to: " .. DFRL_DB_SETUP.lastVersionCheck.date)
                DFRL.tools.MoveFrame(self.frame, 0, 1, .3, 120)
            end)
            debugprint("Button created and click handler set")
        end
        debugprint("<< ShowNotification END")
    end

    --=================
    -- INIT
    --=================
    function Setup:Run()
        debugprint(">> Setup:Run START")
        self:CheckVersionUpdate()
        debugprint("<< Setup:Run END")
    end

    local f = CreateFrame("Frame")
    debugprint("Event frame created")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    debugprint("PLAYER_ENTERING_WORLD event registered")
    f:SetScript("OnEvent", function()
        debugprint(">> PLAYER_ENTERING_WORLD fired")
        Setup:Run()
        local start = time()
        debugprint("Starting 3-second delay timer")
        f:SetScript("OnUpdate", function()
            if time() - start >= 3 then
                debugprint("3-second delay complete")
                f:SetScript("OnUpdate", nil)
                debugprint("Force showing notification for testing")
                debugprint("Checking if update is overdue")
                if Setup:IsUpdateOverdue() then
                    debugprint("Update is overdue - showing notification")
                    Setup:ShowNotification()
                else
                    debugprint("Update not overdue - no notification needed")
                end
                f:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end
        end)
    end)
end)
