--=================
-- SETUP
--=================
local Setup = {
    error_counts = {},
    max_errors = 2
}

function Setup:GetAddonName(msg)
    if string.find(msg, "AddOns\\") then
        local start = string.find(msg, "AddOns\\")
        local path = string.sub(msg, start + 7)
        local end_pos = string.find(path, "\\")
        if end_pos then
            return string.sub(path, 1, end_pos - 1)
        end
    end
    return "UNKNOWN"
end

function Setup:FormatErrorMessage(addon, msg, throttled)
    if throttled then
        return "|cffff0000DFRL: |cffffffff[|cffffffffERROR - ADDON: |cffff0000" .. addon .. "|cffffffff] : [|cffff0000ERROR SPAM THROTTLED|cffffffff]"
    else
        return "|cffff0000DFRL: |cffffffff[|cffffffffERROR - ADDON: |cffff0000" .. addon .. "|cffffffff] : |cffffffff" .. (msg or "nil")
    end
end

function Setup:ErrorHandler(msg)
    local addon = self:GetAddonName(msg)

    if not self.error_counts[msg] then
        self.error_counts[msg] = 1
        DEFAULT_CHAT_FRAME:AddMessage(self:FormatErrorMessage(addon, msg, false))
    else
        self.error_counts[msg] = self.error_counts[msg] + 1
        if self.error_counts[msg] <= self.max_errors then
            DEFAULT_CHAT_FRAME:AddMessage(self:FormatErrorMessage(addon, msg, false))
        elseif self.error_counts[msg] == self.max_errors + 1 then
            DEFAULT_CHAT_FRAME:AddMessage(self:FormatErrorMessage(addon, msg, true))
        end
    end
end

--=================
-- INIT
--=================
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    seterrorhandler(function(err) Setup:ErrorHandler(err) end)
    if event == "PLAYER_ENTERING_WORLD" then
        f:UnregisterAllEvents()
    end
end)

seterrorhandler(function(err) Setup:ErrorHandler(err) end)