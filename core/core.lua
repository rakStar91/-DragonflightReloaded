--=========================================================================
-- DRAGONFLIGHT: RELOADED DOCUMENTATION
--=========================================================================
----> Workflow:
-- 1. ADDON_LOADED: VersionCheckDB() checks/wipes DB versions → InitTempDB()
--    detects character → creates/gets profile mapping → loads profile data
--    into tempDB → applies missing defaults from NewDefaults() → RunMods()
-- 2. Runtime: RegisterCallback() sets up listeners, SetTempDB() triggers
--    TriggerCallback() for module reactions, modules execute in sandboxed
--    environment with shortcuts and track exec time, mem used, and scripts
-- 3. PLAYER_LOGOUT: SaveTempDB() writes tempDB back to character's profile,
--    preserving character-to-profile mapping
--=========================================================================

--=================
-- DFRL MAINFRAME
--=================
DFRL = CreateFrame("Frame", nil, UIParent)

--=================
-- TABLES
--=================
-- global
DFRL_PROFILES = {}
DFRL_DB_SETUP = {}

-- character
DFRL_CUR_PROFILE = {}
DFRL_FRAMEPOS = {}

-- internal
DFRL.env = {}
DFRL.tools = {}
DFRL.hooks = {}
DFRL.tempDB = {}
DFRL.modules = {}
DFRL.defaults = {}
DFRL.profiles = {}
DFRL.callbacks = {}
DFRL.performance = {}
DFRL.activeScripts = {}
DFRL.gui = {}

-- DB VERSION
DFRL.DBversion = "1.0"

--=================
-- LOCALS
--=================
local gcinfo = gcinfo
local GetTime = GetTime

-- boot flag
local boot = false

-- stub
local function debugprint() end
debugprint(">> BOOTING")

--=================
-- UTILITY
--=================
function DFRL:GetInfoOrCons(type)
    local name = "-DragonflightReloaded"
    if type == "name" then
        return name
    elseif type == "version" then
        return GetAddOnMetadata(name, "Version")
    elseif type == "author" then
        return GetAddOnMetadata(name, "Author")
    elseif type == "path" then
        return "Interface\\AddOns\\" .. name .. "\\"
    elseif type == "media" then
        return "Interface\\AddOns\\" .. name .. "\\media\\"
    elseif type == "tex" then
        return "Interface\\AddOns\\" .. name .. "\\media\\tex\\"
    elseif type == "font" then
        return "Interface\\AddOns\\" .. name .. "\\media\\fnt\\"
    end
end

function DFRL:CheckAddon(name)
    if name == "ShaguTweaks" then
        self.addon1 = true
        debugprint("CheckAddon - Detected: " .. name)
    elseif name == "ShaguTweaks-extras" then
        self.addon2 = true
        debugprint("CheckAddon - Detected: " .. name)
    elseif name == "Bagshui" then
        self.addon3 = true
        debugprint("CheckAddon - Detected: " .. name)
    end

    if IsAddOnLoaded("ShaguTweaks") then
        self.addon1 = true
        debugprint("CheckAddon - Already loaded: ShaguTweaks")
    elseif IsAddOnLoaded("ShaguTweaks-extras") then
        self.addon2 = true
        debugprint("CheckAddon - Already loaded: ShaguTweaks-extras")
    elseif IsAddOnLoaded("Bagshui") then
        self.addon3 = true
        debugprint("CheckAddon - Already loaded: Bagshui")
    end
end

function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd100DFRL: |r".. tostring(msg))
end

--=================
-- ENVIRONMENT
--=================
function DFRL:GetEnv()
    debugprint("GetEnv - Env requested")
    self.env._G = getfenv(0)
    self.env.T = self.tools
    self.env.debugprint = debugprint
    return self.env
end

setmetatable(DFRL.env, {__index = getfenv(0)})

--=================
-- MODULES
--=================
function DFRL:NewDefaults(moduleName, defaults)

    if not self.defaults[moduleName] then
        self.defaults[moduleName] = {}
    end

    local count = 0
    for key, value in pairs(defaults) do
        self.defaults[moduleName][key] = value
        count = count + 1
    end

    debugprint("Set " .. count .. " defaults for module: " .. moduleName)
end

function DFRL:NewMod(name, prio, func)
    if self.modules[name] then
        debugprint("NewMod - Module already registered: " .. name)
        return
    end
    debugprint("NewMod - Registrating new mod " .. name .. " with priority " .. prio)
    self.modules[name] = {func = func, priority = prio}
end

function DFRL:RunMods()
    local moduleList = {}
    for name, moduleData in pairs(self.modules) do
        tinsert(moduleList, {name = name, func = moduleData.func, priority = moduleData.priority})
    end

    table.sort(moduleList, function(a, b) return a.priority < b.priority end)

    debugprint("RunMods - Executing " .. table.getn(moduleList) .. " modules...")

    for i = 1, table.getn(moduleList) do
        local name = moduleList[i].name
        local func = moduleList[i].func
		local enabledValue = self.tempDB[name] and self.tempDB[name].enabled
		if enabledValue == true then
            collectgarbage()
			local startTime = GetTime()
			local startMem = gcinfo()
			setfenv(func, self:GetEnv())
			local success, err = pcall(func)
			if success then
				self.performance[name] = {
					time = GetTime() - startTime,
					memory = gcinfo() - startMem
				}
				debugprint("RunMods - " .. name .. " executed: " .. tostring(self.performance[name].time) .. "s, " .. tostring(self.performance[name].memory) .. "kb")
			else
				debugprint("RunMods - Error in module " .. name .. ": " .. tostring(err))
				geterrorhandler()(err)
			end
		else
			debugprint("RunMods - Skipping disabled module: " .. name)
		end
	end
end

--=================
-- DATABASE
--=================
function DFRL:InitTempDB()
    debugprint("InitTempDB - Config initializing...")
    self:VersionCheckDB()

    -- set default profile if none exists
    local charName = UnitName("player")
    debugprint("Character detected: " .. charName)

    if not DFRL_CUR_PROFILE[charName] then
        DFRL_CUR_PROFILE[charName] = "Default"
        debugprint("Created default profile for character: " .. charName)
    end

    local curProfile = DFRL_CUR_PROFILE[charName]
    debugprint("Using profile: " .. curProfile .. " for character: " .. charName)

    -- ensure profile exists
    if not DFRL_PROFILES[curProfile] then
        DFRL_PROFILES[curProfile] = {}
        debugprint("Created new profile: " .. curProfile)
    end

    local settings = 0
    local defaults = 0


    -- copy existing module settings from current profile
    for moduleName, moduleTable in pairs(DFRL_PROFILES[curProfile]) do
        if type(moduleTable) == "table" then
            self.tempDB[moduleName] = self.tempDB[moduleName] or {}
            for key, value in pairs(moduleTable) do
                self.tempDB[moduleName][key] = value
                settings = settings + 1
            end
        end
    end

    -- add missing defaults
    for moduleName, defaultsTable in pairs(self.defaults) do
        self.tempDB[moduleName] = self.tempDB[moduleName] or {}
        for key, defaultValue in pairs(defaultsTable) do
            if self.tempDB[moduleName][key] == nil then
                self.tempDB[moduleName][key] = defaultValue[1]
                defaults = defaults + 1
            end
        end
    end

    debugprint("Config initialized: " .. tostring(settings) .. " settings loaded, " .. tostring(defaults) .. " defaults applied")
end

function DFRL:VersionCheckDB()
    if not DFRL_DB_SETUP.version or DFRL_DB_SETUP.version ~= self.DBversion then
        debugprint("Version mismatch - wiping all DB's")
        DFRL_PROFILES = {}
        DFRL_DB_SETUP = {}
        DFRL_CUR_PROFILE = {}
        DFRL_DB_SETUP.version = self.DBversion
        print("Version mismatch - wiping all DFRL DB's")
    end
    debugprint("DB version check complete: " .. DFRL_DB_SETUP.version)
end

function DFRL:SetTempDB(moduleName, key, value)
    local oldValue = self.tempDB[moduleName][key]
    self.tempDB[moduleName][key] = value
    debugprint("Config changed for " .. moduleName .. "." .. key .. ": " .. tostring(oldValue) .. " -> " .. tostring(value))
    local callbackName = moduleName .. "_" .. key .. "_changed"
    self:TriggerCallback(callbackName, value)
end

function DFRL:SetTempDBNoCallback(moduleName, key, value)
    if not self.tempDB[moduleName] then
        self.tempDB[moduleName] = {}
        debugprint("Module not found in config, creating: " .. moduleName)
    end
    self.tempDB[moduleName][key] = value
    debugprint("Config added for " .. moduleName .. "." .. key .. ": " .. tostring(value))
end

-- will be replaceed by new
-- gettempDB after test phase
function DFRL:GetTempValue(tableName, key)
    if not self.tempDB[tableName] then
        return nil
    end

    return self.tempDB[tableName][key]
end

function DFRL:GetTempDB(moduleName, key)
    local caller = debugstack(2, 2, 0)
    debugprint("Config requested for " .. moduleName .. "." .. key .. ": " .. tostring(self.tempDB[moduleName][key]) .. " by " .. caller)
    return self.tempDB[moduleName][key]
end

function DFRL:SaveTempDB()
    local count = 0
    for _, _ in pairs(self.tempDB) do
        count = count + 1
    end

    local charName = UnitName("player")
    local curProfile = DFRL_CUR_PROFILE[charName] or "Default"
    debugprint("Saving character: " .. charName .. " to profile: " .. curProfile)

    DFRL_PROFILES[curProfile] = self.tempDB
    DFRL_DB_SETUP.version = self.DBversion
    debugprint("SaveDB - Saved " .. count .. " modules to profile: " .. curProfile)
end

function DFRL:ResetDB()
    self.tempDB = {}
    DFRL_PROFILES = {}
    DFRL_DB_SETUP = {}
    DFRL_CUR_PROFILE = {}
    DFRL_DB_SETUP.version = self.DBversion
    debugprint("DFRL:ResetDB() - Database reset")
    ReloadUI()
end

--=================
-- PROFILES
--=================
function DFRL:CreateProfile(profileName)
    debugprint("CreateProfile - Creating profile: " .. profileName)
    DFRL_PROFILES[profileName] = {}
    for moduleName, defaultsTable in pairs(self.defaults) do
        DFRL_PROFILES[profileName][moduleName] = {}
        for key, value in pairs(defaultsTable) do
            DFRL_PROFILES[profileName][moduleName][key] = value[1]
        end
    end
    debugprint("CreateProfile - Profile created: " .. profileName)
end

function DFRL:SwitchProfile(profileName)
    local charName = UnitName("player")
    local oldProfile = DFRL_CUR_PROFILE[charName]
    debugprint("SwitchProfile - Switching from " .. oldProfile .. " to " .. profileName)
    DFRL_PROFILES[oldProfile] = self.tempDB
    DFRL_CUR_PROFILE[charName] = profileName
    self:LoadProfile(profileName)
    debugprint("SwitchProfile - Profile switched to: " .. profileName)
end

function DFRL:CopyProfile(fromProfile, table)
    local src
    local name
    if table then
        debugprint("CopyProfile - Using provided table")
        src = table
        name = "static table"
    else
        debugprint("CopyProfile - Using profile: " .. fromProfile)
        src = DFRL_PROFILES[fromProfile]
        name = fromProfile
    end
    debugprint("CopyProfile - Loading " .. name .. " into tempDB")
    self.tempDB = {}
    for moduleName, moduleTable in pairs(src) do
        self.tempDB[moduleName] = {}
        for key, value in pairs(moduleTable) do
            self.tempDB[moduleName][key] = value
        end
    end
    debugprint("CopyProfile - Profile loaded into tempDB: " .. name)
end

function DFRL:LoadProfile(profileName)
    debugprint("LoadProfile - Loading profile: " .. profileName)
    self.tempDB = {}
    for moduleName, moduleTable in pairs(DFRL_PROFILES[profileName]) do
        self.tempDB[moduleName] = {}
        for key, value in pairs(moduleTable) do
            self.tempDB[moduleName][key] = value
        end
    end
    debugprint("LoadProfile - Profile loaded into tempDB: " .. profileName)
end

function DFRL:DeleteProfile(profileName)
    debugprint("DeleteProfile - Deleting profile: " .. profileName)
    DFRL_PROFILES[profileName] = nil
    debugprint("DeleteProfile - Profile deleted: " .. profileName)
end

--=================
-- CALLBACKS
--=================
function DFRL:NewCallbacks(moduleName, callbacksTable)
    debugprint("NewCallbacks - Registering new callbacks for module: " .. moduleName)

    local count = 0
    for key, func in pairs(callbacksTable) do
        local callbackName = moduleName .. "_" .. key .. "_changed"

        self.callbacks[callbackName] = {}
        tinsert(self.callbacks[callbackName], func)

        self:TriggerCallback(callbackName, self.tempDB[moduleName][key])

        count = count + 1
    end

    debugprint("Registered and triggered " .. count .. " callbacks for module: " .. moduleName)
end

function DFRL:TriggerCallback(callbackName, value)

    for _, callbackFunc in ipairs(self.callbacks[callbackName]) do
        callbackFunc(value)
    end

    debugprint("Triggered callback for: " .. callbackName)
end

function DFRL:TriggerAllCallbacks()
    for callbackName, callbacks in pairs(self.callbacks) do
        local nameWithoutChanged = string.gsub(callbackName, "_changed$", "")
        local lastUnderscore = string.find(nameWithoutChanged, "_[^_]*$")
        local moduleName = string.sub(nameWithoutChanged, 1, lastUnderscore - 1)
        local key = string.sub(nameWithoutChanged, lastUnderscore + 1)
        local value = self.tempDB[moduleName] and self.tempDB[moduleName][key]

        for _, callbackFunc in ipairs(callbacks) do
            callbackFunc(value)
        end
    end
    debugprint("Triggered all callbacks")
end

--=================
-- EVENT HANDLER
--=================
DFRL:RegisterEvent("ADDON_LOADED")
DFRL:RegisterEvent("PLAYER_LOGOUT")
DFRL:SetScript("OnEvent", function()

    -- check on every addon load
    if event == "ADDON_LOADED" then
        DFRL:CheckAddon(arg1)
    end

    -- init DRAGONFLIGHT:RELOADED
    if event == "ADDON_LOADED" and arg1 == "-DragonflightReloaded" then
        debugprint("EVENT: ADDON_LOADED")

        if boot then
            debugprint("EVENT: Already booted, skipping")
            return
        end

        DFRL:InitTempDB()
        DFRL:RunMods()

        print("Welcome to |cffffd200Dragonflight:|r Reloaded.")
        print("Open menu via |cffddddddESC|r or |cffddddddSLASH DFRL|r.")
    end

    -- save tempDB to globalDB on logout
    if event == "PLAYER_LOGOUT" then
        debugprint("EVENT: PLAYER_LOGOUT")
        DFRL:SaveTempDB()
    end
end)
