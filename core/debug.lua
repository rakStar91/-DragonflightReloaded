---@diagnostic disable: deprecated

-- debug toggle (and one in gui.lua, will be changed later)
local DEBUG_MODE = false

-- tables
DFRL_LOGS = {}
DFRL_DEBUGTOOLS = {}

local TEMPDB = {}
TEMPDB.ERROR = {}

-- tools
if DEBUG_MODE then
    -- local eventMonitor = CreateFrame("Frame")
    -- eventMonitor:RegisterAllEvents()
    -- eventMonitor:SetScript("OnEvent", function()
    --     local event = event
    --     if not string.find(event, "CHAT") then
    --         local time = date()
    --         DEFAULT_CHAT_FRAME:AddMessage(time .. " - Event fired: " .. event)
    --     end
    -- end)

    local debugText = CreateFrame("Frame", "DFRL_DebugIndicator", UIParent)
    debugText:SetPoint("TOP", UIParent, "TOP", 0, -5)
    debugText:SetWidth(200)
    debugText:SetHeight(30)

    local text = debugText:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
    text:SetText("DEBUG MODE")
    text:SetTextColor(1, 0, 0, 1)
    text:SetAllPoints()

    DEFAULT_CHAT_FRAME:SetMaxLines(1000)
end

function DFRL_DEBUGTOOLS.DebugPrint(msg)
    local stack = debugstack(2, 1, 0)
    local filename = "unknown"
    if stack then
        local s, e = string.find(stack, "\\([^\\]+)%.lua")
        if s and e then
            filename = string.sub(stack, s+1, e)
        end
    end

    local time = date()
    local formattedMsg = time .. " - " .. tostring(msg)

    if not TEMPDB[filename] then
        TEMPDB[filename] = {}
    end

    tinsert(TEMPDB[filename], formattedMsg)

    if DEBUG_MODE then
        DEFAULT_CHAT_FRAME:AddMessage(filename .. ": " .. formattedMsg)
    end
end

function DFRL_DEBUGTOOLS.DumpTable(tbl)
    if DEBUG_MODE ~= true then return end

    local function dump(t, depth)
        if type(t) ~= "table" then return tostring(t) end
        depth = depth or 0
        local indent = string.rep("  ", depth)
        local output = "{\n"

        for k, v in pairs(t) do
            output = output .. indent .. "  [" .. tostring(k) .. "] = "
            if type(v) == "table" then
                output = output .. dump(v, depth + 1)
            else
                output = output .. tostring(v)
            end
            output = output .. ",\n"
        end

        output = output .. indent .. "}"
        return output
    end

    local result = dump(tbl, 0)
    DEFAULT_CHAT_FRAME:AddMessage(result)
    return result
end

function DFRL_DEBUGTOOLS.redF(frame)
    if DEBUG_MODE ~= true then return end
    if not frame then return end

    local border = CreateFrame("Frame", nil, frame)
    border:SetFrameLevel(frame:GetFrameLevel() + 1)
    border:SetAllPoints()

    border.tex = border:CreateTexture(nil, "OVERLAY")
    border.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    border.tex:SetVertexColor(1, 0, 0, 1)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(1, 0, 0, 1)
end

local function GetFrameParents(frame)
    local result = frame:GetName() or "Unnamed"
    local parent = frame:GetParent()

    while parent do
        local parentName = parent:GetName() or "Unnamed"
        result = result .. " -> " .. parentName
        parent = parent:GetParent()
    end

    return result
end

local function CreateSlashHandler()
    -- print frame parents
    SLASH_FRAMEPARENTS1 = "/frameparents"
    SlashCmdList["FRAMEPARENTS"] = function()
        local frame = GetMouseFocus()
        local hierarchy = GetFrameParents(frame)
        DEFAULT_CHAT_FRAME:AddMessage("Frame hierarchy: " .. hierarchy)
    end

    -- print textures and regions
    SLASH_FRAMEREGIONS1 = "/frameregions"
    SlashCmdList["FRAMEREGIONS"] = function()
        local frame = GetMouseFocus()
        if not frame then
            DEFAULT_CHAT_FRAME:AddMessage("No frame under mouse cursor")
            return
        end

        DEFAULT_CHAT_FRAME:AddMessage("Frame: " .. (frame:GetName() or "Unnamed"))

        local regions = {frame:GetRegions()}
        if not regions or table.getn(regions) == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("No regions found")
            return
        end

        for i, region in ipairs(regions) do
            local regionType = region:GetObjectType()
            local width, height = region:GetWidth(), region:GetHeight()
            local texture = ""

            if regionType == "Texture" then
                texture = region:GetTexture() or "No texture"
            end

            DFRL_DEBUGTOOLS.DebugPrint(i .. ": " .. regionType .. " - Size: " .. width .. "x" .. height .. " - Texture: " .. texture)
        end
    end

    -- display texture in the center
    SLASH_CENTEREDTEXTURE1 = "/cT"
    SlashCmdList["CENTEREDTEXTURE"] = function(msg)
        msg = string.gsub(msg, "\"(.*)\"", "%1")
        msg = string.gsub(msg, "\\\\", "\\")

        if not DFRL_TEXTURE_FRAME then
            DFRL_TEXTURE_FRAME = CreateFrame("Frame", "DFRL_TEXTURE_FRAME", UIParent)
            DFRL_TEXTURE_FRAME:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            DFRL_TEXTURE_FRAME:SetWidth(256)
            DFRL_TEXTURE_FRAME:SetHeight(256)
            DFRL_TEXTURE_FRAME.texture = DFRL_TEXTURE_FRAME:CreateTexture(nil, "ARTWORK")
            DFRL_TEXTURE_FRAME.texture:SetAllPoints()

            local border = CreateFrame("Frame", nil, DFRL_TEXTURE_FRAME)
            border:SetFrameLevel(DFRL_TEXTURE_FRAME:GetFrameLevel() + 1)
            border:SetAllPoints()
            border:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            border:SetBackdropBorderColor(1, 0, 0, 1)
        end

        DFRL_TEXTURE_FRAME.texture:SetTexture(msg)
        DFRL_TEXTURE_FRAME:Show()

        DEFAULT_CHAT_FRAME:AddMessage("Displaying texture: " .. msg)
    end
end

-- run slash handler
if DEBUG_MODE then
    CreateSlashHandler()
end

-- error handler
function DFRL_DEBUGTOOLS.ErrorHandler(errorMsg)
    local time = date()
    local stack = debugstack(2, 10, 0)
    local formattedError = time .. " - " .. tostring(errorMsg)
    tinsert(TEMPDB.ERROR, formattedError .. " - " .. stack)

    DEFAULT_CHAT_FRAME:AddMessage("ERROR: " .. formattedError, 1, 0, 0)
end

seterrorhandler(DFRL_DEBUGTOOLS.ErrorHandler)

-- event handler
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function()

    -- make sure our errhandler sticks so we are
    -- a bit aggresive here :p
    if event == "ADDON_LOADED" then
        DFRL_DEBUGTOOLS.DebugPrint("EVENT: ADDON_LOADED [ErrorHandler]")
        seterrorhandler(DFRL_DEBUGTOOLS.ErrorHandler)
    end

    if event == "PLAYER_ENTERING_WORLD" then
        DFRL_DEBUGTOOLS.DebugPrint("EVENT: PLAYER_ENTERING_WORLD [ErrorHandler]")
        seterrorhandler(DFRL_DEBUGTOOLS.ErrorHandler)

        f:UnregisterEvent("PLAYER_ENTERING_WORLD") -- prevent blizz instance repeats
    end

    if event == "PLAYER_LOGOUT" then
        DFRL_DEBUGTOOLS.DebugPrint("EVENT: PLAYER_LOGOUT, TEMPDB COPIED OVER")
        DFRL_LOGS = TEMPDB
    end
end)
