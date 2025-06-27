setfenv(1, DFRL:GetEnv())

--=================
-- SETUP
--=================
local Setup = {
    welcomeConfig = {
        width = 400,
        height = 300,
        timerDuration = 10,
        barWidth = 200,
        barHeight = 3,
    },

    patchConfig = {
        width = 400,
        height = 200,
        timerDuration = 10,
        barWidth = 200,
        barHeight = 3,
        title = "|cFFFF0000Important Patch Warning|r",
        text = "Patch 2.0.0 implemented config changes.\n\n\nYour config DB has been reset.",
        additionalText = "",
    },
}

function Setup:ShowWelcomePage()
    local welcomeFrame = CreateFrame("Frame", "DFRL_WelcomeFrame", UIParent)
    welcomeFrame:SetWidth(self.welcomeConfig.width)
    welcomeFrame:SetHeight(self.welcomeConfig.height)
    welcomeFrame:SetPoint("CENTER", 0, 0)
    welcomeFrame:SetFrameStrata("TOOLTIP")
    welcomeFrame:SetToplevel(true)
    welcomeFrame:SetBackdrop{
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    }
    welcomeFrame:EnableMouse(true)

    T.GradientLine(welcomeFrame, "TOP", 1)
    T.GradientLine(welcomeFrame, "BOTTOM", -1, 3)

    local title = DFRL.tools.CreateFont(welcomeFrame, 18, "|cFFFFFFFFWelcome to|r |cFFFFD700Dragonflight|r: |cFFFFFFFFReloaded 2.0|r!")
    title:SetPoint("TOP", 0, -20)

    local text = DFRL.tools.CreateFont(welcomeFrame, 13, "Tip:\nHold CTRL + SHIFT + ALT to move frames.\n\n\nBefore reporting bugs:\n|cffff6060Please disable all other addons|n except Dragonflight: Reloaded.|r\n\n90% of bug reports lead to conflicts with other addons.\nThank you for helping us keep bug reports accurate!")
    text:SetPoint("TOP", title, "BOTTOM", 0, -16)
    text:SetWidth(380)

    local okBtn = DFRL.tools.CreateButton(welcomeFrame, "Okay", 120, 24)
    okBtn:SetPoint("BOTTOM", 0, 20)
    okBtn:Disable()

    okBtn:SetScript("OnClick", function()
        welcomeFrame:Hide()
        DFRL:SetTempDBNoCallback("Generic", "firstRun", true)
    end)

    local barWidth = self.welcomeConfig.barWidth
    local barHeight = self.welcomeConfig.barHeight
    local timerBar = welcomeFrame:CreateTexture(nil, "OVERLAY")
    timerBar:SetTexture("Interface\\Buttons\\WHITE8x8")
    timerBar:SetVertexColor(1, 0.82, 0)
    timerBar:SetPoint("BOTTOM", okBtn, "TOP", 0, 10)
    timerBar:SetWidth(barWidth)
    timerBar:SetHeight(barHeight)

    local elapsed = 0
    welcomeFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed >= self.welcomeConfig.timerDuration then
            okBtn:Enable()
            timerBar:Hide()
            welcomeFrame:SetScript("OnUpdate", nil)
            DFRL.activeScripts["WelcomePageScript"] = false
        else
            timerBar:SetWidth(barWidth * (1 - elapsed / self.welcomeConfig.timerDuration))
            DFRL.activeScripts["WelcomePageScript"] = true
        end
    end)
end

-- function Setup:PatchWarning()
--     local patchFrame = CreateFrame("Frame", "DFRL_WelcomeFrame", UIParent)
--     patchFrame:SetWidth(self.patchConfig.width)
--     patchFrame:SetHeight(self.patchConfig.height)
--     patchFrame:SetPoint("CENTER", 0, 240)
--     patchFrame:SetBackdrop{ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
--     patchFrame:EnableMouse(true)

--     T.GradientLine(patchFrame, "TOP", -0)
--     T.GradientLine(patchFrame, "BOTTOM", 0)

--     local title = DFRL.tools.CreateFont(patchFrame, 16, self.patchConfig.title)
--     title:SetPoint("TOP", 0, -20)

--     local fullText = self.patchConfig.text
--     if self.patchConfig.additionalText ~= "" then
--         fullText = fullText .. "\n\n|cFFFF0000" .. self.patchConfig.additionalText .. "|r"
--     end

--     local text = DFRL.tools.CreateFont(patchFrame, 12, fullText)
--     text:SetPoint("TOP", title, "BOTTOM", 0, -16)
--     text:SetWidth(380)

--     local okBtn = DFRL.tools.CreateButton(patchFrame, "Okay", 120, 24)
--     okBtn:SetPoint("BOTTOM", 0, 20)
--     okBtn:Disable()

--     okBtn:SetScript("OnClick", function()
--         patchFrame:Hide()
--         DFRL:SetTempDBNoCallback("Generic", "patchWarn", true)
--     end)

--     local barWidth = self.patchConfig.barWidth
--     local barHeight = self.patchConfig.barHeight
--     local timerBar = patchFrame:CreateTexture(nil, "OVERLAY")
--     timerBar:SetTexture("Interface\\Buttons\\WHITE8x8")
--     timerBar:SetVertexColor(1, 0.82, 0)
--     timerBar:SetPoint("BOTTOM", okBtn, "TOP", 0, 10)
--     timerBar:SetWidth(barWidth)
--     timerBar:SetHeight(barHeight)

--     local elapsed = 0
--     patchFrame:SetScript("OnUpdate", function()
--         elapsed = elapsed + arg1
--         if elapsed >= self.patchConfig.timerDuration then
--             okBtn:Enable()
--             timerBar:Hide()
--             patchFrame:SetScript("OnUpdate", nil)
--             DFRL.activeScripts["PatchWarningScript"] = false
--         else
--             timerBar:SetWidth(barWidth * (1 - elapsed / self.patchConfig.timerDuration))
--             DFRL.activeScripts["PatchWarningScript"] = true
--         end
--     end)
-- end

DFRL.activeScripts["WelcomePageScript"] = false
DFRL.activeScripts["PatchWarningScript"] = false

--=================
-- INIT
--=================
local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function()
    if not DFRL:GetTempValue("Generic", "firstRun") then
        Setup:ShowWelcomePage()
    end

    -- if not DFRL:GetTempValue("Generic", "patchWarn") then
    --     Setup:PatchWarning()
    -- end
end)
