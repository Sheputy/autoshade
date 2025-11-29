-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       cshade_server.lua (Server)
--  AUTHOR:     Corrupt
--  VERSION:    1.0.1 (Active Server Matrix Math + Direct Set + OOP)
--  DESC:       Server-side spawner using client-parity math.
-- ============================================================================

local edf = exports.edf

-- Class Definition
ShadeServer = {
    undoHistory = {}, -- Stores stacks of created elements per player
    cachedShades = {} -- Tracks shades attached to parent elements
}
ShadeServer.__index = ShadeServer

-- Global Singleton
GlobalShadeServer = setmetatable({}, ShadeServer)

-- ////////////////////////////////////////////////////////////////////////////
-- // CORE LOGIC: SPAWNING
-- ////////////////////////////////////////////////////////////////////////////

function ShadeServer:spawnShade(parentObject, data, parentScale, shadeModelID, parentModel)
    local shade = edf:edfCloneElement(parentObject)
    local finalModel = data.modelOverride or shadeModelID
    if finalModel == "parent" then finalModel = parentModel end
    
    edf:edfSetElementProperty(shade, "model", finalModel)

    -- A. Matrix Calculation (MATCHING CLIENT PREVIEW)
    -- This calculates the ABSOLUTE world position/rotation
    local offsetMatrix = Matrix(data.offset * parentScale, data.rotOffset)
    local finalMatrix = offsetMatrix * parentObject.matrix
    
    local newPos = finalMatrix:getPosition()
    local newRot = finalMatrix:getRotation()
    
    -- B. Apply Position & Rotation (DUAL METHOD)
    -- 1. Update EDF Properties (For Editor Save/Metadata)
    edf:edfSetElementPosition(shade, newPos.x, newPos.y, newPos.z)
    edf:edfSetElementRotation(shade, newRot.x, newRot.y, newRot.z)
    
    -- 2. Update Element Directly (For Visual Parity with Client)
    -- This bypasses potential EDF weirdness and forces the object to the Matrix result
    shade.position = newPos
    shade.rotation = newRot

    -- C. Scaling
    local configScale = data.scale or 1.0
    local finalChildScale = configScale * parentScale
    
    if math.abs(finalChildScale - 1.0) > 0.001 then
        edf:edfSetElementProperty(shade, "scale", finalChildScale)
        setObjectScale(shade, finalChildScale)
    end

    -- D. Properties
    local col = (data.collision ~= nil) and data.collision or true
    setElementCollisionsEnabled(shade, col)
    edf:edfSetElementProperty(shade, "collisions", tostring(col))
    
    if data.doublesided then 
        setElementDoubleSided(shade, true) 
    end

    -- E. Identity
    local idName = "CShade[" .. finalModel .. "]_" .. getTickCount() .. "_" .. math.random(1000)
    edf:edfSetElementProperty(shade, "id", idName)
    setElementID(shade, idName)

    return shade
end

-- ////////////////////////////////////////////////////////////////////////////
-- // EVENT HANDLERS
-- ////////////////////////////////////////////////////////////////////////////

function ShadeServer:handleBatchRequest(client, objectList, requestedSides, materialName)
    local processed = 0
    local newBatch = {} 
    local matID = ShadeConfig.Materials[materialName] or 3458

    for _, parent in ipairs(objectList) do
        if isElement(parent) then
            local pModel = parent.model
            local configKey = "Basic"
            
            -- Detect Orange Mode
            if pModel == 8838 then
                configKey = (materialName == "Orange") and "Orange" or "Dark"
            else
                configKey = (materialName == "Orange") and "Orange" or "Basic"
            end

            if ShadeConfig.Offsets[pModel] and ShadeConfig.Offsets[pModel][configKey] then
                local sideConfig = ShadeConfig.Offsets[pModel][configKey]
                local pScale = parent.scale
                local finalMatID = matID

                -- Special Dark/Dark Case
                if pModel == 8557 and matID == 8558 then finalMatID = 8557 end

                -- Cleanup Old
                if self.cachedShades[parent] then
                    for _, s in ipairs(self.cachedShades[parent]) do
                        if isElement(s) then destroyElement(s) end
                    end
                end
                self.cachedShades[parent] = {}

                -- Process Sides
                for reqSide, isActive in pairs(requestedSides) do
                    if isActive then
                        -- Single Entry
                        if sideConfig[reqSide] then
                            local s = self:spawnShade(parent, sideConfig[reqSide], pScale, finalMatID, pModel)
                            table.insert(self.cachedShades[parent], s)
                            table.insert(newBatch, s)
                        end
                        -- Multi Entry (side_1, side_2...)
                        local i = 1
                        while sideConfig[reqSide .. "_" .. i] do
                            local s = self:spawnShade(parent, sideConfig[reqSide .. "_" .. i], pScale, finalMatID, pModel)
                            table.insert(self.cachedShades[parent], s)
                            table.insert(newBatch, s)
                            i = i + 1
                        end
                    end
                end
                processed = processed + 1
            end
        end
    end

    -- Undo Stack
    if not self.undoHistory[client] then self.undoHistory[client] = {} end
    table.insert(self.undoHistory[client], newBatch)
    
    outputChatBox("#00ff9d[AutoShade] #FFFFFFGenerated shade for " .. processed .. " parent objects.", client, 255, 255, 255, true)
end

function ShadeServer:handleUndo(client)
    local stack = self.undoHistory[client]
    if stack and #stack > 0 then
        local lastBatch = table.remove(stack)
        local count = 0
        for _, obj in ipairs(lastBatch) do
            if isElement(obj) then 
                destroyElement(obj)
                count = count + 1 
            end
        end
        outputChatBox("#00ff9d[AutoShade] #FFFFFFUndid last generation (" .. count .. " objects removed).", client, 255, 255, 255, true)
    else
        outputChatBox("#ff004d[AutoShade] #FFFFFFNothing to undo!", client, 255, 255, 255, true)
    end
end

-- ////////////////////////////////////////////////////////////////////////////
-- // BINDINGS
-- ////////////////////////////////////////////////////////////////////////////

addEvent("onBatchShadeRequest", true)
addEventHandler("onBatchShadeRequest", resourceRoot, function(...)
    GlobalShadeServer:handleBatchRequest(client, ...)
end)

addEvent("onAutoShadeUndo", true)
addEventHandler("onAutoShadeUndo", resourceRoot, function()
    GlobalShadeServer:handleUndo(client)
end)

addEventHandler("onElementDestroy", root, function()
    if GlobalShadeServer.cachedShades[source] then 
        GlobalShadeServer.cachedShades[source] = nil 
    end
end)