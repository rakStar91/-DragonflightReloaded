-- setfenv(1, DFRL:GetEnvironment())

-- -- shut down blizz
-- do
--     CastingBarFrame:Hide()
--     CastingBarFrame:SetScript("OnEvent", nil)
--     CastingBarFrame:SetScript("OnUpdate", nil)
-- end

-- local MyCastBar = {
--   frame       = nil,
--   barTexture  = nil,
--   spark       = nil,
--   flashTex    = nil,
--   backdrop    = nil,
--   text        = nil,
--   timeText    = nil,

--   config = {
--     width            = 200,
--     height           = 20,
--     bgTexture        = "Interface\\ChatFrame\\ChatFrameBackground",
--     barTexture       = "Interface\\TargetingFrame\\UI-StatusBar",
--     spark            = "Interface\\CastingBar\\UI-CastingBar-Spark",
--     barColor         = { r = 1, g = 0.7, b = 0 },         -- gold
--     alphaSpeed       = 3.0,        -- alpha units per second
--     flashSpeed       = 5.0,        -- flash units per second
--     holdTimeDuration = 1,          -- seconds to hold after fail/interrupt
--     font             = "Fonts\\FRIZQT__.TTF",
--     fontSizeName     = 12,
--     fontSizeTime     = 12,
--     textColorName    = { r = 1, g = 1, b = 1 },
--     textColorTime    = { r = 1, g = 1, b = 1 },
--     animations = {
--       useSpark = true,
--       useFlash = true,
--     },
--   },

--   state = {
--     casting    = false,
--     channeling = false,
--     fadeOut    = false,
--     flash      = false,
--     holdTime   = 0,
--     startTime  = 0,
--     maxValue   = 0,
--     endTime    = 0,
--     duration   = 0,
--     mode       = nil,
--     -- Smooth animation state
--     flashAlpha = 0,
--     currentProgress = 0, -- 0 to 1
--   },
-- }

-- -- initialize and create frames
-- function MyCastBar:Create(parent)
--   local f = CreateFrame("Frame", "MyCastBarFrame", parent or UIParent)
--   f:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
--   f:SetHeight(self.config.height)
--   f:SetWidth(self.config.width)
--   f:Hide()

--   -- Backdrop
--   local bd = f:CreateTexture(nil, "BACKGROUND")
--   bd:SetAllPoints(f)
--   bd:SetTexture(self.config.bgTexture)
--   bd:SetVertexColor(0, 0, 0, 0.8)
--   self.backdrop = bd

--   -- Custom bar texture instead of StatusBar
--   local bar = f:CreateTexture(nil, "ARTWORK")
--   bar:SetPoint("LEFT", f, "LEFT", 0, 0)
--   bar:SetHeight(self.config.height)
--   bar:SetWidth(1) -- Start with 1 pixel width
--   bar:SetTexture(self.config.barTexture)
--   bar:SetVertexColor(self.config.barColor.r, self.config.barColor.g, self.config.barColor.b)
--   self.barTexture = bar

--   -- Spark
--   if self.config.animations.useSpark then
--     local spark = f:CreateTexture(nil, "OVERLAY")
--     spark:SetHeight(self.config.height + 10)
--     spark:SetWidth(16)
--     spark:SetTexture(self.config.spark)
--     spark:Hide()
--     self.spark = spark
--   end

--   -- Flash overlay
--   if self.config.animations.useFlash then
--     local flash = f:CreateTexture(nil, "OVERLAY")
--     flash:SetAllPoints(f)
--     flash:SetTexture(1, 1, 1, 0)
--     self.flashTex = flash
--   end

--   -- Spell name text
--   local ts = f:CreateFontString(nil, "OVERLAY")
--   ts:SetFont(self.config.font, self.config.fontSizeName, "OUTLINE")
--   ts:SetPoint("LEFT", f, "LEFT", 5, 0)
--   ts:SetTextColor(self.config.textColorName.r, self.config.textColorName.g, self.config.textColorName.b)
--   self.text = ts

--   -- Time text
--   local tt = f:CreateFontString(nil, "OVERLAY")
--   tt:SetFont(self.config.font, self.config.fontSizeTime, "OUTLINE")
--   tt:SetPoint("RIGHT", f, "RIGHT", -5, 0)
--   tt:SetTextColor(self.config.textColorTime.r, self.config.textColorTime.g, self.config.textColorTime.b)
--   self.timeText = tt

--   -- Register events
--   f:RegisterEvent("SPELLCAST_START")
--   f:RegisterEvent("SPELLCAST_STOP")
--   f:RegisterEvent("SPELLCAST_FAILED")
--   f:RegisterEvent("SPELLCAST_INTERRUPTED")
--   f:RegisterEvent("SPELLCAST_DELAYED")
--   f:RegisterEvent("SPELLCAST_CHANNEL_START")
--   f:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
--   f:RegisterEvent("SPELLCAST_CHANNEL_STOP")

--   f:SetScript("OnEvent", function()
--     MyCastBar:HandleEvent(event, arg1, arg2)
--   end)
--   f:SetScript("OnUpdate", function()
--     MyCastBar:OnUpdate(arg1)
--   end)

--   self.frame = f
-- end

-- -- update the visual bar
-- function MyCastBar:UpdateBarVisual(progress)
--   if progress < 0 then progress = 0 end
--   if progress > 1 then progress = 1 end

--   local newWidth = progress * self.config.width
--   if newWidth < 1 then newWidth = 1 end -- minimum 1 pixel

--   self.barTexture:SetWidth(newWidth)

--   -- update spark position
--   if self.spark and progress > 0 and progress < 1 then
--     self.spark:SetPoint("CENTER", self.frame, "LEFT", newWidth, 0)
--     if not self.spark:IsShown() then self.spark:Show() end
--   elseif self.spark then
--     self.spark:Hide()
--   end
-- end

-- -- event handler
-- function MyCastBar:HandleEvent(event, arg1, arg2)
--   local s = self.state
--   local c = self.config

--   if event == "SPELLCAST_START" then
--     s.startTime = GetTime()
--     s.maxValue = s.startTime + (arg2 / 1000)
--     s.currentProgress = 0

--     self.barTexture:SetVertexColor(c.barColor.r, c.barColor.g, c.barColor.b)
--     self:UpdateBarVisual(0)

--     self.text:SetText(arg1)
--     s.holdTime = 0
--     s.casting = true
--     s.channeling = false
--     s.fadeOut = false
--     s.flash = false
--     s.flashAlpha = 0
--     s.mode = "casting"
--     self.frame:SetAlpha(1)
--     self.frame:Show()

--   elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" then
--     if self.frame:IsShown() then
--       -- Complete the bar instantly
--       s.currentProgress = 1
--       self:UpdateBarVisual(1)
--       self.barTexture:SetVertexColor(0, 1, 0) -- green

--       if event == "SPELLCAST_STOP" then
--         s.casting = false
--       else
--         s.channeling = false
--       end

--       s.flash = true
--       s.flashAlpha = 0
--       s.fadeOut = true
--       s.mode = "flash"
--     end

--   elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
--     if self.frame:IsShown() and not s.channeling then
--       s.currentProgress = 1
--       self:UpdateBarVisual(1)
--       self.barTexture:SetVertexColor(1, 0, 0) -- red

--       if event == "SPELLCAST_FAILED" then
--         self.text:SetText(FAILED)
--       else
--         self.text:SetText(INTERRUPTED)
--       end
--       s.casting = false
--       s.fadeOut = true
--       s.holdTime = GetTime() + c.holdTimeDuration
--       s.mode = "hold"
--     end

--   elseif event == "SPELLCAST_DELAYED" then
--     if self.frame:IsShown() then
--       s.startTime = s.startTime + (arg1 / 1000)
--       s.maxValue = s.maxValue + (arg1 / 1000)
--       s.mode = "delayed"
--     end

--   elseif event == "SPELLCAST_CHANNEL_START" then
--     s.startTime = GetTime()
--     s.duration = arg1 / 1000
--     s.endTime = s.startTime + s.duration
--     s.currentProgress = 1 -- Channeling starts full

--     self.barTexture:SetVertexColor(c.barColor.r, c.barColor.g, c.barColor.b)
--     self:UpdateBarVisual(1)

--     self.text:SetText(arg2)
--     s.holdTime = 0
--     s.casting = false
--     s.channeling = true
--     s.fadeOut = false
--     s.flash = false
--     s.flashAlpha = 0
--     s.mode = "channeling"
--     self.frame:SetAlpha(1)
--     self.frame:Show()

--   elseif event == "SPELLCAST_CHANNEL_UPDATE" then
--     if self.frame:IsShown() then
--       local origDur = s.endTime - s.startTime
--       s.endTime = GetTime() + (arg1 / 1000)
--       s.startTime = s.endTime - origDur
--       s.mode = "channel_update"
--     end
--   end
-- end

-- -- onupdate
-- function MyCastBar:OnUpdate(elapsed)
--   local s = self.state
--   local c = self.config
--   local now = GetTime()

--   if s.casting then
--     -- Calculate target progress (0 to 1)
--     local targetProgress = (now - s.startTime) / (s.maxValue - s.startTime)
--     if targetProgress > 1 then targetProgress = 1 end
--     if targetProgress < 0 then targetProgress = 0 end

--     -- Smooth progress interpolation
--     local progressDiff = targetProgress - s.currentProgress
--     local step = elapsed * 2 -- Adjust speed multiplier as needed

--     if progressDiff > 0 then
--       s.currentProgress = s.currentProgress + step
--       if s.currentProgress > targetProgress then
--         s.currentProgress = targetProgress
--       end
--     end

--     self:UpdateBarVisual(s.currentProgress)
--     if self.flashTex then self.flashTex:Hide() end

--   elseif s.channeling then
--     -- Calculate channeling progress (1 to 0)
--     local timeLeft = s.endTime - now
--     if timeLeft <= 0 then
--       s.channeling = false
--       s.fadeOut = true
--       s.currentProgress = 0
--       self:UpdateBarVisual(0)
--       return
--     end

--     local targetProgress = timeLeft / (s.endTime - s.startTime)
--     if targetProgress < 0 then targetProgress = 0 end
--     if targetProgress > 1 then targetProgress = 1 end

--     -- Smooth channeling progress
--     local progressDiff = targetProgress - s.currentProgress
--     local step = elapsed * 2

--     if progressDiff < 0 then
--       s.currentProgress = s.currentProgress + step * progressDiff
--       if s.currentProgress < targetProgress then
--         s.currentProgress = targetProgress
--       end
--     end

--     self:UpdateBarVisual(s.currentProgress)
--     if self.flashTex then self.flashTex:Hide() end

--   elseif now < s.holdTime then
--     -- Hold state - don't fade yet
--     return

--   elseif s.flash and self.flashTex then
--     -- Smooth flash animation
--     s.flashAlpha = s.flashAlpha + (c.flashSpeed * elapsed)
--     if s.flashAlpha > 1 then s.flashAlpha = 1 end

--     self.flashTex:SetAlpha(s.flashAlpha)
--     if s.flashAlpha >= 1 then
--       s.flash = false
--     end

--   elseif s.fadeOut then
--     -- Smooth fade out
--     local currentAlpha = self.frame:GetAlpha()
--     local newAlpha = currentAlpha - (c.alphaSpeed * elapsed)

--     if newAlpha <= 0 then
--       s.fadeOut = false
--       self.frame:Hide()
--       self.frame:SetAlpha(1)
--       if self.flashTex then
--         self.flashTex:SetAlpha(0)
--         self.flashTex:Hide()
--       end
--     else
--       self.frame:SetAlpha(newAlpha)
--     end
--   end

--   -- Update time text during cast/channel
--   if s.casting or s.channeling then
--     local remaining
--     if s.casting then
--       remaining = s.maxValue - now
--     else
--       remaining = s.endTime - now
--     end

--     if remaining < 0 then remaining = 0 end

--     -- Dynamic time formatting
--     local timeStr
--     if remaining >= 10 then
--       timeStr = string.format("%.0f", remaining)
--     elseif remaining >= 1 then
--       timeStr = string.format("%.1f", remaining)
--     else
--       timeStr = string.format("%.2f", remaining)
--     end

--     self.timeText:SetText(timeStr)
--   end
-- end

-- -- init
-- MyCastBar:Create()

-- local callbacks = {}

-- callbacks.darkMode = function(value)
--     local darkColor = {0.2, 0.2, 0.2}
--     local specialDark = {0.5, 0.5, 0.5}
--     local lightColor = {1, 1, 1}

--     -- Apply to backdrop (equivalent to old border/dropshadow)
--     local color = value and darkColor or lightColor
--     if MyCastBar.backdrop then
--         MyCastBar.backdrop:SetVertexColor(color[1], color[2], color[3], 0.8)
--     end

--     -- Apply to background (equivalent to old bg)
--     local bgColor = value and specialDark or lightColor
--     if MyCastBar.backdrop then
--         -- We can create a secondary backdrop effect or modify existing one
--         -- Since we only have one backdrop, we'll use a blend of both effects
--         local finalColor = value and {0.35, 0.35, 0.35} or lightColor
--         MyCastBar.backdrop:SetVertexColor(finalColor[1], finalColor[2], finalColor[3], 0.8)
--     end
-- end

-- -- Make callbacks accessible globally
-- _G.MyCastBarCallbacks = callbacks