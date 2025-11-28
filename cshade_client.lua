-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       cshade_client.lua (Client)
--  AUTHOR:     Corrupt
--  VERSION:    1.0.0
--  DESC:       Handles UI integration, selection logic, live previews, 
--              and shader highlights.
-- ============================================================================

-- ////////////////////////////////////////////////////////////////////////////
-- // CONSTANTS & CONFIGURATION
-- ////////////////////////////////////////////////////////////////////////////

local screenW, screenH = guiGetScreenSize()
local UI = {}

-- Shader code for selection highlighting
local SHADER_CODE = [[
    float4 color = float4(0, 1, 0.61, 1);
    technique TexReplace {
        pass P0 {
            MaterialAmbient = color;
            MaterialDiffuse = color;
            MaterialEmissive = color;
            Lighting = true;
        }
    }
]]

-- Mapping UI dropdown names to internal config keys
local SUPPORTED_CAP_MAPPINGS = {
    ["Shade (Standard)"] = { f = "front",              b = "back" },
    ["JetDoor (Front)"]  = { f = "jetdoor_front_f",    b = "jetdoor_front_b" },
    ["JetDoor (Back)"]   = { f = "jetdoor_back_f",     b = "jetdoor_back_b" },
    ["Nbbal (Dark)"]     = { f = "nbbal_front_dark",   b = "nbbal_back_dark" },
    ["Nbbal (Orange)"]   = { f = "nbbal_front_orange", b = "nbbal_back_orange" },
    ["Tower"]            = { f = "tower_front",        b = "tower_back" },
    ["Crate"]            = { f = "crate_front",        b = "crate_back" },
    ["Jetty"]            = { f = "jetty_front",        b = "jetty_back" },
    ["Jetty + Shade"]    = { f = "jetty_shade_front",  b = "jetty_shade_back" },
    ["Mesh"]             = { f = "mesh_front",         b = "mesh_back" }
}

-- ////////////////////////////////////////////////////////////////////////////
-- // STATE MANAGEMENT
-- ////////////////////////////////////////////////////////////////////////////

local state = {
    selectedElements  = {},   -- Table of currently selected objects
    previewGhosts     = {},   -- Table of ghost elements for live preview
    shaders           = {},   -- Table of active highlight shaders
    isSelectionMode   = false,
    isLivePreview     = false,
    lastToggleTime    = 0,
    lastEditorElement = nil,  -- Tracks what the editor is currently hovering

    -- Default Config (synced with UI)
    config = {
        material = "Light",
        sides    = { left = false, right = false, bottom = true },
        ends     = { front = "None", back = "None" }
    },

    -- User Settings
    settings = {
        autoClose   = true,
        bindSelect  = "h",
        bindGen     = "g",
        bindMenu    = "g",
        bindPreview = "k"
    }
}

-- ////////////////////////////////////////////////////////////////////////////
-- // UI SYSTEM (CEF)
-- ////////////////////////////////////////////////////////////////////////////

function initGUI()
    -- EXACT REFERENCE SIZE: 820x520 (Expanded slightly for padding)
    local w, h = 860, 560
    local x, y = (screenW - w) / 2, (screenH - h) / 2

    UI.window = guiCreateWindow(x, y, w, h, "AutoShade Pro", false)
    guiSetAlpha(UI.window, 0) -- Invisible window container
    guiWindowSetSizable(UI.window, true)
    guiSetVisible(UI.window, false)

    -- Create Browser (Offset for title bar)
    UI.browser = guiCreateBrowser(0, 25, w, h - 25, true, true, false, UI.window)

    addEventHandler("onClientBrowserCreated", UI.browser, function()
        loadBrowserURL(source, "http://mta/local/ui/index.html")
    end)
end
addEventHandler("onClientResourceStart", resourceRoot, initGUI)

-- Handle Window Resizing (Responsive)
addEventHandler("onClientGUISize", resourceRoot, function()
    if source == UI.window then
        local newW, newH = guiGetSize(UI.window, false)
        guiSetSize(UI.browser, newW, newH - 25, false)
    end
end)

function toggleMenu()
    if (getTickCount() - state.lastToggleTime) < 200 then return end
    state.lastToggleTime = getTickCount()

    local isVis = not guiGetVisible(UI.window)
    guiSetVisible(UI.window, isVis)
    
    if isVis then 
        -- "no_binds_when_editing" allows WASD movement unless you are 
        -- actively typing in a text input field within the browser.
        guiSetInputMode("no_binds_when_editing") 
        -- Cursor logic removed to allow Editor 'F' key usage
    else 
        guiSetInputMode("allow_binds")
    end
end

-- ////////////////////////////////////////////////////////////////////////////
-- // CORE LOGIC: GENERATION
-- ////////////////////////////////////////////////////////////////////////////

function triggerGeneration()
    local list = {}
    for obj, _ in pairs(state.selectedElements) do 
        table.insert(list, obj) 
    end

    if #list == 0 then 
        outputChatBox("AutoShade: No objects selected!", 255, 0, 0) 
        return 
    end
    
    local req = {}
    
    -- Sides
    if state.config.sides.left   then req["left"]   = true end
    if state.config.sides.right  then req["right"]  = true end
    if state.config.sides.bottom then req["bottom"] = true end
    
    -- Ends
    local f = SUPPORTED_CAP_MAPPINGS[state.config.ends.front]
    if state.config.ends.front ~= "None" and f then req[f.f] = true end

    local b = SUPPORTED_CAP_MAPPINGS[state.config.ends.back]
    if state.config.ends.back ~= "None" and b then req[b.b] = true end

    -- Send to Server
    triggerServerEvent("onBatchShadeRequest", resourceRoot, list, req, state.config.material)

    -- Cleanup
    if state.settings.autoClose then 
        guiSetVisible(UI.window, false)
        guiSetInputMode("allow_binds") 
        -- Cursor logic removed
    end
    clearSelection()
end

-- ////////////////////////////////////////////////////////////////////////////
-- // CORE LOGIC: PREVIEW (GHOSTS)
-- ////////////////////////////////////////////////////////////////////////////

function updatePreview()
    clearPreviewGhosts()
    
    if not state.isLivePreview then return end
    if not ShadeConfig then return end -- Safety check
    
    -- Check if we have selections
    local count = 0
    for _ in pairs(state.selectedElements) do count = count + 1 end
    if count == 0 then return end

    local matID = ShadeConfig.Materials[state.config.material] or 3458

    for parent, _ in pairs(state.selectedElements) do
        if isElement(parent) then
            local model = getElementModel(parent)
            
            -- Determine Config Key (Basic vs Orange vs Dark)
            local configKey = "Basic"
            if model == 8838 then 
                configKey = (state.config.material == "Orange") and "Orange" or "Dark"
            else 
                configKey = (state.config.material == "Orange") and "Orange" or "Basic" 
            end

            -- If offset data exists for this model
            if ShadeConfig.Offsets[model] and ShadeConfig.Offsets[model][configKey] then
                local sideConfig = ShadeConfig.Offsets[model][configKey]
                
                -- Helper: Spawn single ghost
                local function spawnGhost(data)
                    if not data then return end
                    local finalModel = data.modelOverride or matID
                    if finalModel == "parent" then finalModel = model end
                    
                    local ghost = createObject(finalModel, 0, 0, 0)
                    setElementCollisionsEnabled(ghost, false)
                    setElementAlpha(ghost, 150) -- Semi-transparent
                    setElementInterior(ghost, getElementInterior(parent))
                    setElementDimension(ghost, getElementDimension(parent))
                    
                    table.insert(state.previewGhosts, { 
                        element = ghost, 
                        parent = parent, 
                        data = data 
                    })
                end

                -- Helper: Spawn group (handles split sides like left_1, left_2)
                local function spawnGhostGroup(key)
                    if not key then return end
                    -- Try exact key
                    if sideConfig[key] then spawnGhost(sideConfig[key]) end
                    -- Try numbered keys (key_1, key_2...)
                    local i = 1
                    while sideConfig[key .. "_" .. i] do 
                        spawnGhost(sideConfig[key .. "_" .. i])
                        i = i + 1 
                    end
                end

                -- Spawn requested components
                if state.config.sides.left   then spawnGhostGroup("left") end
                if state.config.sides.right  then spawnGhostGroup("right") end
                if state.config.sides.bottom then spawnGhostGroup("bottom") end

                if state.config.ends.front ~= "None" then
                    local fKey = SUPPORTED_CAP_MAPPINGS[state.config.ends.front]
                    if fKey then spawnGhostGroup(fKey.f) end
                end
                
                if state.config.ends.back ~= "None" then
                    local bKey = SUPPORTED_CAP_MAPPINGS[state.config.ends.back]
                    if bKey then spawnGhostGroup(bKey.b) end
                end
            end
        end
    end
    -- Immediately position ghosts
    syncGhostPositions()
end

-- ////////////////////////////////////////////////////////////////////////////
-- // INPUT & BINDS
-- ////////////////////////////////////////////////////////////////////////////

function refreshBinds()
    unbindAll()
    if state.settings.bindSelect ~= "" then 
        bindKey(state.settings.bindSelect, "down", handleSelectionToggle) 
    end
    if state.settings.bindPreview ~= "" then 
        bindKey(state.settings.bindPreview, "down", handlePreviewToggle) 
    end
    
    if state.settings.bindGen ~= "" then
        bindKey(state.settings.bindGen, "down", function() 
            if isChatBoxInputActive() or isConsoleActive() then return end
            if getKeyState("lshift") or getKeyState("rshift") then return end
            if not guiGetVisible(UI.window) then triggerGeneration() end
        end)
    end
    
    if state.settings.bindMenu ~= "" then
        bindKey(state.settings.bindMenu, "down", function()
            if isChatBoxInputActive() or isConsoleActive() then return end
            if (getKeyState("lshift") or getKeyState("rshift")) then toggleMenu() end
        end)
    end
end

function unbindAll()
    unbindKey(state.settings.bindSelect, "down", handleSelectionToggle)
    unbindKey(state.settings.bindPreview, "down", handlePreviewToggle)
    unbindKey(state.settings.bindGen, "down") 
    unbindKey(state.settings.bindMenu, "down")
end
addEventHandler("onClientResourceStart", resourceRoot, refreshBinds)

function handleSelectionToggle()
    if isChatBoxInputActive() or isConsoleActive() then return end
    state.isSelectionMode = not state.isSelectionMode
    
    if state.isSelectionMode then 
        outputChatBox("#00ff9d[AutoShade] #FFFFFFMulti-Select ON.", 255, 255, 255, true)
        for el, _ in pairs(state.selectedElements) do applyHighlight(el) end
    else 
        outputChatBox("#00ff9d[AutoShade] #FFFFFFMulti-Select OFF.", 255, 255, 255, true)
        state.lastEditorElement = nil 
        for el, _ in pairs(state.selectedElements) do removeHighlight(el) end
    end
end

function handlePreviewToggle()
    if isChatBoxInputActive() or isConsoleActive() then return end
    state.isLivePreview = not state.isLivePreview
    
    if state.isLivePreview then
        outputChatBox("#00ff9d[AutoShade] #FFFFFFLive Preview: ON", 255, 255, 255, true)
        updatePreview()
    else
        outputChatBox("#00ff9d[AutoShade] #FFFFFFLive Preview: OFF", 255, 255, 255, true)
        clearPreviewGhosts()
    end
end

-- ////////////////////////////////////////////////////////////////////////////
-- // VISUALS: SHADER HIGHLIGHTS
-- ////////////////////////////////////////////////////////////////////////////

function applyHighlight(element) 
    if not state.isSelectionMode then return end
    if not isElement(element) then return end
    if state.shaders[element] then return end -- Already highlighted

    local shader = dxCreateShader(SHADER_CODE)
    if shader then 
        dxSetShaderValue(shader, "color", 0, 1, 0.61, 0.4) 
        engineApplyShaderToWorldTexture(shader, "*", element)
        state.shaders[element] = shader 
    end 
end

function removeHighlight(element) 
    if state.shaders[element] then 
        if isElement(state.shaders[element]) then 
            destroyElement(state.shaders[element]) 
        end
        state.shaders[element] = nil 
    end 
end

function clearSelection() 
    for el, _ in pairs(state.selectedElements) do 
        removeHighlight(el) 
    end
    state.selectedElements = {}
    clearPreviewGhosts()
end

function clearPreviewGhosts() 
    for _, item in ipairs(state.previewGhosts) do 
        if isElement(item.element) then 
            destroyElement(item.element) 
        end 
    end
    state.previewGhosts = {} 
end

-- ////////////////////////////////////////////////////////////////////////////
-- // EVENT HANDLERS (UI BRIDGES)
-- ////////////////////////////////////////////////////////////////////////////

addEvent("ui:updateConfig", true)
addEventHandler("ui:updateConfig", root, function(json) 
    state.config = fromJSON(json)
    updatePreview() 
end)

addEvent("ui:updateSettings", true)
addEventHandler("ui:updateSettings", root, function(key, val) 
    if val == "true" then val = true 
    elseif val == "false" then val = false end
    
    state.settings[key] = val
    refreshBinds() 
end)

addEvent("ui:undo", true)
addEventHandler("ui:undo", root, function() 
    triggerServerEvent("onAutoShadeUndo", resourceRoot) 
end)

addEvent("ui:generate", true)
addEventHandler("ui:generate", root, function() 
    triggerGeneration() 
end)

-- ////////////////////////////////////////////////////////////////////////////
-- // GAME LOOP (RENDER)
-- ////////////////////////////////////////////////////////////////////////////

addEventHandler("onClientRender", root, function()
    -- Selection Logic (Editor Integration)
    if getResourceState(getResourceFromName("editor_main")) == "running" then
        local currentSel = nil
        pcall(function() currentSel = exports.editor_main:getSelectedElement() end)
        
        if currentSel ~= state.lastEditorElement then
            state.lastEditorElement = currentSel
            
            if currentSel and isElement(currentSel) and getElementType(currentSel) == "object" then
                -- Check if supported
                if ShadeConfig.Offsets[getElementModel(currentSel)] then
                    if state.isSelectionMode then 
                        -- Multi-select mode
                        if not state.selectedElements[currentSel] then 
                            state.selectedElements[currentSel] = true
                            applyHighlight(currentSel) 
                        end 
                    else 
                        -- Single-select mode
                        clearSelection()
                        state.selectedElements[currentSel] = true 
                    end
                    updatePreview()
                end
            elseif not currentSel and not state.isSelectionMode then 
                clearSelection() 
            end
        end
    end

    -- Ghost Position Sync (Smooth Movement)
    if state.isLivePreview then 
        syncGhostPositions() 
    end
end)

-- ////////////////////////////////////////////////////////////////////////////
-- // MATH & MATRIX UTILITIES
-- ////////////////////////////////////////////////////////////////////////////

function getMatrixTransformedPos(matrix, offX, offY, offZ)
    local x = offX * matrix[1][1] + offY * matrix[2][1] + offZ * matrix[3][1] + matrix[4][1]
    local y = offX * matrix[1][2] + offY * matrix[2][2] + offZ * matrix[3][2] + matrix[4][2]
    local z = offX * matrix[1][3] + offY * matrix[2][3] + offZ * matrix[3][3] + matrix[4][3]
    return x, y, z
end

-- Convert Euler Angles from MTA format to rotation matrix compatible radians
function convertRotationFromMTA(rx, ry, rz)
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local sinX = math.sin(rx); local cosX = math.cos(rx)
    local sinY = math.sin(ry); local cosY = math.cos(ry)
    local sinZ = math.sin(rz); local cosZ = math.cos(rz)
    return math.deg(math.atan2(sinX, cosX * cosY)), 
           math.deg(math.asin(cosX * sinY)), 
           math.deg(math.atan2(cosZ * sinX * sinY + cosY * sinZ, cosY * cosZ - sinX * sinY * sinZ))
end

-- Convert back to MTA format
function convertRotationToMTA(rx, ry, rz)
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local sinX = math.sin(rx); local cosX = math.cos(rx)
    local sinY = math.sin(ry); local cosY = math.cos(ry)
    local sinZ = math.sin(rz); local cosZ = math.cos(rz)
    
    local newRx = math.asin(cosY * sinX)
    local newRy = math.atan2(sinY, cosX * cosY)
    local newRz = math.atan2(cosX * sinZ - cosZ * sinX * sinY, cosX * cosZ + sinX * sinY * sinZ)
    
    return math.deg(newRx), math.deg(newRy), math.deg(newRz)
end

function rotateX(rx, ry, rz, add)
    rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
    rx = rx + add
    rx, ry, rz = convertRotationToMTA(rx, ry, rz)
    return rx, ry, rz
end

function rotateY(rx, ry, rz, add)
    return rx, ry + add, rz
end

function syncGhostPositions()
    for _, item in ipairs(state.previewGhosts) do
        if isElement(item.parent) and isElement(item.element) then
            local data = item.data
            local parentScale = getObjectScale(item.parent) or 1.0
            local parentMatrix = getElementMatrix(item.parent)
            
            -- Position
            local newX, newY, newZ = getMatrixTransformedPos(
                parentMatrix, 
                data.offset.x * parentScale, 
                data.offset.y * parentScale, 
                data.offset.z * parentScale
            )
            setElementPosition(item.element, newX, newY, newZ)
            setObjectScale(item.element, (data.scale or 1) * parentScale)
            
            -- Rotation
            local prx, pry, prz = getElementRotation(item.parent)
            local drx, dry, drz = data.rotOffset.x, data.rotOffset.y, data.rotOffset.z
            
            if drx ~= 0 then prx, pry, prz = rotateX(prx, pry, prz, drx) end
            if dry ~= 0 then prx, pry, prz = rotateY(prx, pry, prz, dry) end
            if drz ~= 0 then prz = prz + drz end
            
            setElementRotation(item.element, prx, pry, prz)
        end
    end
end