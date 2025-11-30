-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       cshade_server.lua (Server)
--  AUTHOR:     Corrupt
--  FIX:        Fix #2 Object Rotation Logic - Desync Editor vs Race
-- ============================================================================

local edf = exports.edf

ShadeServer = {
    undoHistory = {},
    cachedShades = {}
}
ShadeServer.__index = ShadeServer
GlobalShadeServer = setmetatable({}, ShadeServer)

-- ////////////////////////////////////////////////////////////////////////////
-- // 1. Arezu Math Conversion Helpers
-- ////////////////////////////////////////////////////////////////////////////

local function convertRotationFromMTA(rx, ry, rz)
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local sinX, cosX = math.sin(rx), math.cos(rx)
    local sinY, cosY = math.sin(ry), math.cos(ry)
    local sinZ, cosZ = math.sin(rz), math.cos(rz)
    
    return math.deg(math.atan2(sinX, cosX * cosY)), 
           math.deg(math.asin(cosX * sinY)), 
           math.deg(math.atan2(cosZ * sinX * sinY + cosY * sinZ, cosY * cosZ - sinX * sinY * sinZ))
end

local function convertRotationToMTA(rx, ry, rz)
    rx, ry, rz = math.rad(rx), math.rad(ry), math.rad(rz)
    local sinX, cosX = math.sin(rx), math.cos(rx)
    local sinY, cosY = math.sin(ry), math.cos(ry)
    local sinZ, cosZ = math.sin(rz), math.cos(rz)
    
    local newRx = math.asin(cosY * sinX)
    local newRy = math.atan2(sinY, cosX * cosY)
    local newRz = math.atan2(cosX * sinZ - cosZ * sinX * sinY, cosX * cosZ + sinX * sinY * sinZ)
    
    return math.deg(newRx), math.deg(newRy), math.deg(newRz)
end

-- Rotates around X axis 
local function rotateX(rx, ry, rz, add)
    rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
    rx = rx + add
    rx, ry, rz = convertRotationToMTA(rx, ry, rz)
    return rx, ry, rz
end

-- Rotates around Y axis 
local function rotateY(rx, ry, rz, add)
    return rx, ry + add, rz
end

-- Rotates around Z axis
local function rotateZ(rx, ry, rz, add)
    return rx, ry, rz + add
end

-- ////////////////////////////////////////////////////////////////////////////
-- // 2. CORE SPAWNING LOGIC 
-- ////////////////////////////////////////////////////////////////////////////

function ShadeServer:spawnShade(parentObject, data, parentScale, shadeModelID, parentModel)
    local finalModel = data.modelOverride or shadeModelID
    if finalModel == "parent" then finalModel = parentModel end
    local shade = edf:edfCloneElement(parentObject)
    
    -- B. CALCULATE POSITION
    local elementMatrix = parentObject.matrix
    local viktorVektor = Vector3(data.offset.x * parentScale, data.offset.y * parentScale, data.offset.z * parentScale)
    local positionVector = elementMatrix:transformPosition(viktorVektor)
    local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z

    -- C. CALCULATE ROTATION
    local shadeRX, shadeRY, shadeRZ = getElementRotation(parentObject)

    -- 1. Apply X Offset (Complex Math - handles Sides/Bottom flipping)
    if data.rotOffset.x ~= 0 then
        shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, data.rotOffset.x)
    end
    
    -- 2. Apply Y Offset (Simple Math - handles Front/Back facing)
    if data.rotOffset.y ~= 0 then
        shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, data.rotOffset.y)
    end
    
    -- 3. Apply Z Offset (Simple Math)
    if data.rotOffset.z ~= 0 then
        shadeRX, shadeRY, shadeRZ = rotateZ(shadeRX, shadeRY, shadeRZ, data.rotOffset.z)
    end

    -- D. APPLY TO EDF
    edf:edfSetElementProperty(shade, "model", finalModel)
    edf:edfSetElementPosition(shade, shadeX, shadeY, shadeZ)
    edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)

    -- E. SCALING
    local configScale = data.scale or 1.0
    local finalChildScale = configScale * parentScale
    if math.abs(finalChildScale - 1.0) > 0.001 then
        edf:edfSetElementProperty(shade, "scale", finalChildScale)
        setObjectScale(shade, finalChildScale)
    end

    -- F. PROPERTIES
    local col = (data.collision ~= nil) and data.collision or true
    setElementCollisionsEnabled(shade, col)
    edf:edfSetElementProperty(shade, "collisions", tostring(col))
    
    if data.doublesided then 
        setElementDoubleSided(shade, true) 
        edf:edfSetElementProperty(shade, "doublesided", "true")
    end

    -- G. SEQUENTIAL NAMING
    local highestIndex = 0
    local searchPattern = "^c_shade%[" .. finalModel .. "%] %((%d+)%)$"
    for _, obj in ipairs(getElementsByType("object")) do
        local elemID = getElementID(obj)
        if elemID then
            local numStr = string.match(elemID, searchPattern)
            if numStr then
                local num = tonumber(numStr)
                if num and num > highestIndex then highestIndex = num end
            end
        end
    end
    local nextIndex = highestIndex + 1
    local idName = "c_shade[" .. finalModel .. "] (" .. nextIndex .. ")"
    
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
            if pModel == 8838 then
                configKey = (materialName == "Orange") and "Orange" or "Dark"
            else
                configKey = (materialName == "Orange") and "Orange" or "Basic"
            end

            if ShadeConfig.Offsets[pModel] and ShadeConfig.Offsets[pModel][configKey] then
                local sideConfig = ShadeConfig.Offsets[pModel][configKey]
                local pScale = parent.scale or 1
                local finalMatID = matID
                if pModel == 8557 and matID == 8558 then finalMatID = 8557 end

                if self.cachedShades[parent] then
                    for _, s in ipairs(self.cachedShades[parent]) do
                        if isElement(s) then destroyElement(s) end
                    end
                end
                self.cachedShades[parent] = {}

                for reqSide, isActive in pairs(requestedSides) do
                    if isActive then
                        if sideConfig[reqSide] then
                            local s = self:spawnShade(parent, sideConfig[reqSide], pScale, finalMatID, pModel)
                            table.insert(self.cachedShades[parent], s)
                            table.insert(newBatch, s)
                        end
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