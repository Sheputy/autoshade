-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       cshade_updater.lua (Server)
--  AUTHOR:     Corrupt
--  DESC:       Safe Auto-Updater with Anti-Corruption & Loop Protection.
--              Adapted from VisionX repository.
-- ============================================================================

------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------
local autoUpdate = true
local STARTUP_DELAY = 1 * 60 * 1000        -- 1 Minute (Faster check for testing)
local AUTO_UPDATE_INTERVAL = 24 * 60 * 60 * 1000 -- 24 Hours
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/Sheputy/autoshade/master/"

-- Branding Colors 
local BRAND_COLOR = "#00ff9d"   -- AutoShade Green
local TEXT_COLOR  = "#FFFFFF"   -- White
local INFO_COLOR  = "#FFA64C"   -- Orange (Warnings)
local ERROR_COLOR = "#FF4C4C"   -- Red (Critical)

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local currentVersion = "0.0.0"
local resourceName = getResourceName(getThisResource())
local resource = getThisResource()

------------------------------------------------------------
-- UTILS
------------------------------------------------------------
local function getLocalVersion()
    local meta = xmlLoadFile("meta.xml")
    if meta then
        local info = xmlFindChild(meta, "info", 0)
        if info then
            currentVersion = xmlNodeGetAttribute(info, "version") or "0.0.0"
        end
        xmlUnloadFile(meta)
    else
        currentVersion = "0.0.0" -- version on first install or corrupt meta
    end
    return currentVersion
end

local function isNewer(v1, v2)
    if v1 == v2 then return false end
    local v1parts, v2parts = {}, {}
    for p in v1:gmatch("%d+") do table.insert(v1parts, tonumber(p)) end
    for p in v2:gmatch("%d+") do table.insert(v2parts, tonumber(p)) end
    for i = 1, math.max(#v1parts, #v2parts) do
        local p1, p2 = v1parts[i] or 0, v2parts[i] or 0
        if p1 > p2 then return true end
        if p1 < p2 then return false end
    end
    return false
end

------------------------------------------------------------
-- STARTUP LOGIC
------------------------------------------------------------
addEventHandler("onResourceStart", resourceRoot, function()
    getLocalVersion()
    
    -- === 1. LOOP PROTECTION (FRESH INSTALL) ===
    if currentVersion == "0.0.0" then
        outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] #FFA64CFirst Install Detected.#FFFFFF Run: #FFFF00/aclrequest allow %s all", BRAND_COLOR, resourceName), root, 255, 255, 255, true)
        return
    end

    -- === 2. PERMISSIONS CHECK ===
    if not hasObjectPermissionTo(resource, "function.fetchRemote") then
        outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] %sError:#FFFFFF Missing ACL. Run: #FFFF00/aclrequest allow %s all", BRAND_COLOR, ERROR_COLOR, resourceName), root, 255, 255, 255, true)
        return
    end

    if autoUpdate then
        outputServerLog("[AutoShade] Updater armed. Checking in "..(STARTUP_DELAY/1000).." seconds.")
        setTimer(checkForUpdates, STARTUP_DELAY, 1, false) -- Auto check
        setTimer(checkForUpdates, AUTO_UPDATE_INTERVAL, 0, false)
    end
end)

------------------------------------------------------------
-- UPDATE CHECKER
------------------------------------------------------------
function checkForUpdates(isManual, player)
    -- Safety: Don't update if version is 0.0.0 (prevents death loops on corrupt meta)
    if currentVersion == "0.0.0" then return end

    if isManual then
        outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] #FFA64CChecking for updates...", BRAND_COLOR), player, 255, 255, 255, true)
    end

    local metaURL = GITHUB_RAW_URL .. "meta.xml?cb=" .. getTickCount()

    fetchRemote(metaURL, function(data, err)
        if err ~= 0 or not data then
            if isManual then
                outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] %sUpdate check failed (GitHub unreachable).", BRAND_COLOR, ERROR_COLOR), player, 255, 255, 255, true)
            end
            return
        end

        local remoteVer = data:match('version="([^"]+)"')
        if remoteVer and isNewer(remoteVer, currentVersion) then
            outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] #FFA64CUpdate found:#FFFFFF v%s. Downloading...", BRAND_COLOR, remoteVer), root, 255, 255, 255, true)
            processUpdate(data)
        elseif isManual then
            outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] #00FF00You are on the latest version (v%s).", BRAND_COLOR, currentVersion), player, 255, 255, 255, true)
        end
    end)
end

------------------------------------------------------------
-- SAFE DOWNLOAD LOGIC (Temp Files)
------------------------------------------------------------
function processUpdate(metaContent)
    local filesToDownload = {}
    
    -- Extract all src="" files from new meta
    for path in metaContent:gmatch('src="([^"]+)"') do 
        table.insert(filesToDownload, path) 
    end
    
    -- Extract UI files (file src="")
    for path in metaContent:gmatch('<file%s+src="([^"]+)"') do
        table.insert(filesToDownload, path)
    end

    table.insert(filesToDownload, "meta.xml")

    if #filesToDownload == 0 then return end

    local downloadedCount = 0
    local total = #filesToDownload
    local tempPrefix = "temp_update_"

    for _, fileName in ipairs(filesToDownload) do
        local url = GITHUB_RAW_URL .. fileName .. "?cb=" .. getTickCount()
        
        fetchRemote(url, function(data, err)
            if err == 0 and data then
                -- Flatten path for temp file (ui/style.css -> temp_update_ui_style.css)
                local safeName = fileName:gsub("/", "_")
                local tempName = tempPrefix .. safeName
                
                if fileExists(tempName) then fileDelete(tempName) end
                
                local file = fileCreate(tempName)
                if file then
                    fileWrite(file, data)
                    fileClose(file)
                    downloadedCount = downloadedCount + 1
                end
            else
                outputServerLog("[AutoShade] Failed to download: " .. fileName)
            end

            -- Only apply if ALL files downloaded successfully
            if downloadedCount >= total then
                applyUpdate(filesToDownload, tempPrefix)
            end
        end)
    end
end

------------------------------------------------------------
-- APPLY UPDATE (Backup & Rename)
------------------------------------------------------------
function applyUpdate(fileList, tempPrefix)
    outputServerLog("[AutoShade] Download complete. Applying update...")
    
    -- Ensure backup directory exists
    if not fileExists("backups/.keep") then
        local dummy = fileCreate("backups/.keep")
        if dummy then fileClose(dummy) end
    end

    for _, fileName in ipairs(fileList) do
        local safeName = fileName:gsub("/", "_")
        local tempName = tempPrefix .. safeName
        
        if fileExists(tempName) then
            -- 1. Backup existing file
            if fileExists(fileName) then
                local backupName = "backups/" .. safeName .. ".bak"
                if fileExists(backupName) then fileDelete(backupName) end
                fileRename(fileName, backupName)
            end
            

            if fileName:find("/") then
                if not fileExists("ui/index.html") and fileName:match("^ui/") then
                end
            end

            if fileExists(fileName) then fileDelete(fileName) end -- Double check
            fileRename(tempName, fileName)
        end
    end

    outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] #FFA64CUpdate applied.#FFFFFF Restarting...", BRAND_COLOR), root, 255, 255, 255, true)
    
    if hasObjectPermissionTo(resource, "function.restartResource") then
        setTimer(function() restartResource(resource) end, 1000, 1)
    else
        outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] %sCannot restart automatically (No ACL). Please restart manually.", BRAND_COLOR, ERROR_COLOR), root, 255, 255, 255, true)
    end
end

------------------------------------------------------------
-- COMMANDS
------------------------------------------------------------
addCommandHandler("autoshade", function(player, cmd, arg)
    if arg and arg:lower() == "update" then
        -- Check Admin permissions
        local accName = getAccountName(getPlayerAccount(player))
        if isObjectInACLGroup("user."..accName, aclGetGroup("Admin")) then
            checkForUpdates(true, player)
        else
            outputChatBox(string.format("#FFFFFF[%sAutoShade#FFFFFF] %sAccess Denied.", BRAND_COLOR, ERROR_COLOR), player, 255, 255, 255, true)
        end
    end
end)