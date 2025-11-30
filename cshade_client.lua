-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       cshade_client.lua (Client)
--  AUTHOR:     Corrupt
--  VERSION:    1.0.3 (EDF/Production Rotation De-sync Fix + Matrix Math)
--  DESC:       Client handles UI and Preview. Math is now consistent with Server. Includes de-sync fixes between editor preview and production.
-- ============================================================================

local screenW, screenH = guiGetScreenSize()

-- UI Mapping Constants
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

-- Shader Code
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

-- Class Definition
ShadeClient = {
    selectedElements = {},
    previewGhosts = {},
    shaders = {},
    state = {
        isSelectionMode = false,
        isLivePreview = false,
        lastToggleTime = 0,
        lastEditorElement = nil,
        config = {
            material = "Light",
            sides = { left = false, right = false, bottom = true },
            ends = { front = "None", back = "None" }
        },
        settings = {
            autoClose = true,
            bindSelect = "h",
            bindGen = "g",
            bindMenu = "g",
            bindPreview = "k"
        }
    }
}
ShadeClient.__index = ShadeClient
GlobalClient = setmetatable({}, ShadeClient)

-- ////////////////////////////////////////////////////////////////////////////
-- // GUI SYSTEM
-- ////////////////////////////////////////////////////////////////////////////

function ShadeClient:initGUI()
    local w, h = 860, 560
    local x, y = (screenW - w) / 2, (screenH - h) / 2
    self.window = guiCreateWindow(x, y, w, h, "AutoShade Pro", false)
    guiSetAlpha(self.window, 0)
    guiSetVisible(self.window, false)
    
    self.browser = guiCreateBrowser(0, 25, w, h - 25, true, true, false, self.window)
    addEventHandler("onClientBrowserCreated", self.browser, function()
        loadBrowserURL(source, "http://mta/local/ui/index.html")
    end)
    
    self:refreshBinds()
end

function ShadeClient:toggleMenu()
    if (getTickCount() - self.state.lastToggleTime) < 200 then return end
    self.state.lastToggleTime = getTickCount()
    
    local isVis = not guiGetVisible(self.window)
    guiSetVisible(self.window, isVis)
    
    if isVis then
        guiSetInputMode("no_binds_when_editing")
        -- Cursor removed as requested
    else
        guiSetInputMode("allow_binds")
    end
end

-- ////////////////////////////////////////////////////////////////////////////
-- // CORE: PREVIEW & MATRIX LOGIC
-- ////////////////////////////////////////////////////////////////////////////

function ShadeClient:syncGhostPositions()
    for _, item in ipairs(self.previewGhosts) do
        if isElement(item.parent) and isElement(item.element) then
            local data = item.data
            local pScale = item.parent.scale
            
            -- Matrix Composition (Identical to Server)
            local parentMatrix = item.parent.matrix
            local offsetMatrix = Matrix(data.offset * pScale, data.rotOffset)
            local finalMatrix = offsetMatrix * parentMatrix
            
            local newPos = finalMatrix:getPosition()
            local newRot = finalMatrix:getRotation()
            
            -- Direct OOP Application
            item.element.position = newPos
            item.element.rotation = newRot
            setObjectScale(item.element, (data.scale or 1) * pScale)
        end
    end
end

function ShadeClient:updatePreview()
    -- Clear old ghosts
    for _, item in ipairs(self.previewGhosts) do
        if isElement(item.element) then destroyElement(item.element) end
    end
    self.previewGhosts = {}
    
    if not self.state.isLivePreview then return end
    if not ShadeConfig then return end
    
    local matID = ShadeConfig.Materials[self.state.config.material] or 3458
    
    for parent, _ in pairs(self.selectedElements) do
        if isElement(parent) then
            local model = parent.model
            local configKey = "Basic"
            if model == 8838 then
                configKey = (self.state.config.material == "Orange") and "Orange" or "Dark"
            else
                configKey = (self.state.config.material == "Orange") and "Orange" or "Basic"
            end
            
            if ShadeConfig.Offsets[model] and ShadeConfig.Offsets[model][configKey] then
                local sideConfig = ShadeConfig.Offsets[model][configKey]
                
                -- Helper to spawn ghost
                local function spawn(data)
                    if not data then return end
                    local finalModel = data.modelOverride or matID
                    if finalModel == "parent" then finalModel = model end
                    
                    local ghost = createObject(finalModel, 0, 0, 0)
                    setElementCollisionsEnabled(ghost, false)
                    setElementAlpha(ghost, 150)
                    setElementInterior(ghost, parent.interior)
                    setElementDimension(ghost, parent.dimension)
                    
                    table.insert(self.previewGhosts, { element = ghost, parent = parent, data = data })
                end
                
                -- Helper to check groups
                local function checkGroup(key)
                    if not key then return end
                    if sideConfig[key] then spawn(sideConfig[key]) end
                    local i = 1
                    while sideConfig[key.."_"..i] do
                        spawn(sideConfig[key.."_"..i])
                        i = i + 1
                    end
                end
                
                if self.state.config.sides.left then checkGroup("left") end
                if self.state.config.sides.right then checkGroup("right") end
                if self.state.config.sides.bottom then checkGroup("bottom") end
                
                if self.state.config.ends.front ~= "None" then
                    local fk = SUPPORTED_CAP_MAPPINGS[self.state.config.ends.front]
                    if fk then checkGroup(fk.f) end
                end
                
                if self.state.config.ends.back ~= "None" then
                    local bk = SUPPORTED_CAP_MAPPINGS[self.state.config.ends.back]
                    if bk then checkGroup(bk.b) end
                end
            end
        end
    end
    self:syncGhostPositions()
end

-- ////////////////////////////////////////////////////////////////////////////
-- // LOGIC: GENERATION
-- ////////////////////////////////////////////////////////////////////////////

function ShadeClient:triggerGeneration()
    local list = {}
    for obj, _ in pairs(self.selectedElements) do table.insert(list, obj) end
    if #list == 0 then return outputChatBox("No objects selected!", 255, 0, 0) end
    
    local req = {}
    if self.state.config.sides.left then req["left"] = true end
    if self.state.config.sides.right then req["right"] = true end
    if self.state.config.sides.bottom then req["bottom"] = true end
    
    local f = SUPPORTED_CAP_MAPPINGS[self.state.config.ends.front]
    if self.state.config.ends.front ~= "None" and f then req[f.f] = true end
    
    local b = SUPPORTED_CAP_MAPPINGS[self.state.config.ends.back]
    if self.state.config.ends.back ~= "None" and b then req[b.b] = true end
    
    triggerServerEvent("onBatchShadeRequest", resourceRoot, list, req, self.state.config.material)
    
    if self.state.settings.autoClose then
        guiSetVisible(self.window, false)
        guiSetInputMode("allow_binds")
    end
    self:clearSelection()
end

-- ////////////////////////////////////////////////////////////////////////////
-- // INPUT & HIGHLIGHTS
-- ////////////////////////////////////////////////////////////////////////////

function ShadeClient:applyHighlight(el)
    if not self.state.isSelectionMode then return end
    if not isElement(el) then return end
    if self.shaders[el] then return end
    
    local shader = dxCreateShader(SHADER_CODE)
    if shader then
        dxSetShaderValue(shader, "color", 0, 1, 0.61, 0.4)
        engineApplyShaderToWorldTexture(shader, "*", el)
        self.shaders[el] = shader
    end
end

function ShadeClient:removeHighlight(el)
    if self.shaders[el] then
        if isElement(self.shaders[el]) then destroyElement(self.shaders[el]) end
        self.shaders[el] = nil
    end
end

function ShadeClient:clearSelection()
    for el, _ in pairs(self.selectedElements) do self:removeHighlight(el) end
    self.selectedElements = {}
    self:updatePreview()
end

function ShadeClient:refreshBinds()
    unbindAll()
    local s = self.state.settings
    if s.bindSelect ~= "" then bindKey(s.bindSelect, "down", function() self:toggleSelectionMode() end) end
    if s.bindPreview ~= "" then bindKey(s.bindPreview, "down", function() self:togglePreviewMode() end) end
    
    if s.bindGen ~= "" then
        bindKey(s.bindGen, "down", function()
            if isChatBoxInputActive() or isConsoleActive() then return end
            -- FIX: Don't trigger if Shift is held
            if getKeyState("lshift") or getKeyState("rshift") then return end
            
            if not guiGetVisible(self.window) then self:triggerGeneration() end
        end)
    end
    
    if s.bindMenu ~= "" then
        bindKey(s.bindMenu, "down", function()
            if isChatBoxInputActive() or isConsoleActive() then return end
            if getKeyState("lshift") or getKeyState("rshift") then self:toggleMenu() end
        end)
    end
end

function ShadeClient:toggleSelectionMode()
    if isChatBoxInputActive() or isConsoleActive() then return end
    self.state.isSelectionMode = not self.state.isSelectionMode
    if self.state.isSelectionMode then
        outputChatBox("#00ff9d[AutoShade] #FFFFFFMulti-Select ON.", 255, 255, 255, true)
        for el, _ in pairs(self.selectedElements) do self:applyHighlight(el) end
    else
        outputChatBox("#00ff9d[AutoShade] #FFFFFFMulti-Select OFF.", 255, 255, 255, true)
        self.state.lastEditorElement = nil
        for el, _ in pairs(self.selectedElements) do self:removeHighlight(el) end
    end
end

function ShadeClient:togglePreviewMode()
    if isChatBoxInputActive() or isConsoleActive() then return end
    self.state.isLivePreview = not self.state.isLivePreview
    if self.state.isLivePreview then
        outputChatBox("#00ff9d[AutoShade] #FFFFFFLive Preview: ON", 255, 255, 255, true)
        self:updatePreview()
    else
        outputChatBox("#00ff9d[AutoShade] #FFFFFFLive Preview: OFF", 255, 255, 255, true)
        for _, item in ipairs(self.previewGhosts) do if isElement(item.element) then destroyElement(item.element) end end
        self.previewGhosts = {}
    end
end

function unbindAll()
    unbindKey(GlobalClient.state.settings.bindSelect, "down")
    unbindKey(GlobalClient.state.settings.bindPreview, "down")
    unbindKey(GlobalClient.state.settings.bindGen, "down")
    unbindKey(GlobalClient.state.settings.bindMenu, "down")
end

-- ////////////////////////////////////////////////////////////////////////////
-- // EVENTS
-- ////////////////////////////////////////////////////////////////////////////

addEventHandler("onClientResourceStart", resourceRoot, function() GlobalClient:initGUI() end)

addEventHandler("onClientRender", root, function()
    -- Editor Integration
    if getResourceState(getResourceFromName("editor_main")) == "running" then
        local currentSel = exports.editor_main:getSelectedElement()
        if currentSel ~= GlobalClient.state.lastEditorElement then
            GlobalClient.state.lastEditorElement = currentSel
            
            if currentSel and isElement(currentSel) and currentSel.type == "object" then
                if ShadeConfig.Offsets[currentSel.model] then
                    if GlobalClient.state.isSelectionMode then
                        if not GlobalClient.selectedElements[currentSel] then
                            GlobalClient.selectedElements[currentSel] = true
                            GlobalClient:applyHighlight(currentSel)
                        end
                    else
                        GlobalClient:clearSelection()
                        GlobalClient.selectedElements[currentSel] = true
                    end
                    GlobalClient:updatePreview()
                end
            elseif not currentSel and not GlobalClient.state.isSelectionMode then
                GlobalClient:clearSelection()
            end
        end
    end
    
    if GlobalClient.state.isLivePreview then GlobalClient:syncGhostPositions() end
end)

addEvent("ui:updateConfig", true)
addEventHandler("ui:updateConfig", root, function(json)
    GlobalClient.state.config = fromJSON(json)
    GlobalClient:updatePreview()
end)

addEvent("ui:generate", true)
addEventHandler("ui:generate", root, function() GlobalClient:triggerGeneration() end)

addEvent("ui:undo", true)
addEventHandler("ui:undo", root, function() triggerServerEvent("onAutoShadeUndo", resourceRoot) end)

addEvent("ui:updateSettings", true)
addEventHandler("ui:updateSettings", root, function(k, v)
    if v == "true" then v = true elseif v == "false" then v = false end
    GlobalClient.state.settings[k] = v
    GlobalClient:refreshBinds()
end)