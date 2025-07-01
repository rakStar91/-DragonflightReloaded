-- local f = CreateFrame("Frame", nil, UIParent)
-- f:SetWidth(200)
-- f:SetHeight(20)
-- f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

-- local bg = f:CreateTexture(nil, "BACKGROUND")
-- bg:SetAllPoints()
-- bg:SetTexture(0, 0, 0, 0.5)

-- local bar = f:CreateTexture(nil, "ARTWORK")
-- bar:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
-- bar:SetPoint("LEFT", 0,0)
-- bar:SetHeight(20)

-- f:RegisterEvent("UNIT_HEALTH")
-- f:RegisterEvent("UNIT_MAXHEALTH")

-- f:SetScript("OnEvent", function()
--     if arg1 == "player" then
--         local current = UnitHealth("player")
--         local max = UnitHealthMax("player")
--         bar:SetWidth(200 * (current / max))
--     end
-- end)

-- local current = UnitHealth("player")
-- local max = UnitHealthMax("player")
-- bar:SetWidth(200 * (current / max))

-- =================
-- MODULE TEMPLATE
-- =================

-- DFRL:NewDefaults("TEMPLATE", {
--     enabled = { true },
-- })

-- DFRL:NewMod("TEMPLATE", 1, function()
--     debugprint(">> BOOTING")

--     =================
--     SETUP
--     =================
--     local Setup = {
--     }

--     function Setup:Run()
--     end

--     =================
--     INIT
--     =================
--     Setup:Run()

--     =================
--     EXPOSE
--     =================

--     =================
--     CALLBACKS
--     =================
--     local callbacks = {}

--     =================
--     EVENT
--     =================

--     DFRL:NewCallbacks("TEMPLATE", callbacks)
-- end)
