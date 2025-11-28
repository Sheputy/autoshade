-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       cshade_server.lua (Server)
--  AUTHOR:     Corrupt
--  CREDITS:    Gr0x, Arezu, Chrs1384, nyep (lacia) - Math & Logic support
--  VERSION:    1.0.0
--  DESC:       Handles object cloning, placement, and undo history within
--              the MTA Map Editor environment.
-- ============================================================================

local edf = exports.edf

addEvent("onBatchShadeRequest", true)
addEvent("onAutoShadeUndo", true)

-- ////////////////////////////////////////////////////////////////////////////
-- // STATE MANAGEMENT
-- ////////////////////////////////////////////////////////////////////////////

local undoHistory = {}      -- Stores batches of created objects per player
local storedShades = {}     -- Tracks shades attached to specific parents
local globalShadeCounter = 0

-- ////////////////////////////////////////////////////////////////////////////
-- // MATH HELPERS
-- // Non-OOP matrix and rotation math (Required for Map Editor compatibility)
-- ////////////////////////////////////////////////////////////////////////////

-- Replicates matrix:transformPosition(vector) using standard tables
-- MTA Matrix tables are [row][col]: Row 1: Right, Row 2: Front, Row 3: Up, Row 4: Pos
function getMatrixTransformedPos(matrix, offX, offY, offZ)
    local x = offX * matrix[1][1] + offY * matrix[2][1] + offZ * matrix[3][1] + matrix[4][1]
    local y = offX * matrix[1][2] + offY * matrix[2][2] + offZ * matrix[3][2] + matrix[4][2]
    local z = offX * matrix[1][3] + offY * matrix[2][3] + offZ * matrix[3][3] + matrix[4][3]
    return x, y, z
end

-- Converts Euler angles to MTA format
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

-- Converts MTA format to standard Euler angles
function convertRotationFromMTA(rx, ry, rz)
    rx = math.rad(rx); ry = math.rad(ry); rz = math.rad(rz)
    local sinX = math.sin(rx); local cosX = math.cos(rx)
    local sinY = math.sin(ry); local cosY = math.cos(ry)
    local sinZ = math.sin(rz); local cosZ = math.cos(rz)
    
    return math.deg(math.atan2(sinX, cosX * cosY)), 
           math.deg(math.asin(cosX * sinY)), 
           math.deg(math.atan2(cosZ * sinX * sinY + cosY * sinZ, cosY * cosZ - sinX * sinY * sinZ))
end

-- Rotates an object on its relative axes (Credit: Arezu)
function rotateX(rx, ry, rz, add)
    rx, ry, rz = convertRotationFromMTA(rx, ry, rz)
    rx = rx + add
    rx, ry, rz = convertRotationToMTA(rx, ry, rz)
    return rx, ry, rz
end

function rotateY(rx, ry, rz, add)
    return rx, ry + add, rz
end

-- ////////////////////////////////////////////////////////////////////////////
-- // CORE LOGIC: CREATION
-- ////////////////////////////////////////////////////////////////////////////

function getNextID()
    globalShadeCounter = globalShadeCounter + 1
    return globalShadeCounter
end

function clearOldShades(parent)
    if storedShades[parent] then
        for _, shade in ipairs(storedShades[parent]) do
            if isElement(shade) then 
                destroyElement(shade) 
            end
        end
    end
    storedShades[parent] = {}
end

function spawnSingleShade(parentObject, data, parentScale, shadeModelID, parentModel)
    -- Clone the parent to keep internal editor properties
    local shade = edf:edfCloneElement(parentObject)
    
    -- Determine final model ID (Config override vs Default Shade)
    local finalModel = data.modelOverride or shadeModelID
    if finalModel == "parent" then 
        finalModel = parentModel 
    end
    
    edf:edfSetElementProperty(shade, "model", finalModel)

    -- 1. POSITIONING (Manual Matrix Math)
    local parentMatrix = getElementMatrix(parentObject)
    local scaledOffX = data.offset.x * parentScale
    local scaledOffY = data.offset.y * parentScale
    local scaledOffZ = data.offset.z * parentScale
    
    local newX, newY, newZ = getMatrixTransformedPos(parentMatrix, scaledOffX, scaledOffY, scaledOffZ)
    edf:edfSetElementPosition(shade, newX, newY, newZ)

    -- 2. ROTATION (Relative Calculation)
    local shadeRX, shadeRY, shadeRZ = getElementRotation(parentObject)
    
    if data.rotOffset.x ~= 0 then 
        shadeRX, shadeRY, shadeRZ = rotateX(shadeRX, shadeRY, shadeRZ, data.rotOffset.x)
    end
    
    if data.rotOffset.y ~= 0 then 
        shadeRX, shadeRY, shadeRZ = rotateY(shadeRX, shadeRY, shadeRZ, data.rotOffset.y)
    end
    
    if data.rotOffset.z ~= 0 then 
        shadeRZ = shadeRZ + data.rotOffset.z
    end

    edf:edfSetElementRotation(shade, shadeRX, shadeRY, shadeRZ)

    -- 3. SCALING
    local configScale = data.scale or 1.0
    local finalChildScale = configScale * parentScale
    
    -- Only set scale if it differs from 1.0 to save performance/data
    if math.abs(finalChildScale - 1.0) > 0.001 then
        edf:edfSetElementProperty(shade, "scale", finalChildScale)
        setObjectScale(shade, finalChildScale)
    end

    -- 4. PROPERTIES (Collision/DoubleSided)
    local collisionEnabled = (data.collision ~= nil) and data.collision or true
    setElementCollisionsEnabled(shade, collisionEnabled)
    edf:edfSetElementProperty(shade, "collisions", tostring(collisionEnabled))
    
    if data.doublesided then 
        setElementDoubleSided(shade, true) 
    end

    -- 5. IDENTIFICATION
    local idName = "CShade[" .. finalModel .. "]_" .. getNextID()
    edf:edfSetElementProperty(shade, "id", idName)
    setElementID(shade, idName)

    return shade
end

-- ////////////////////////////////////////////////////////////////////////////
-- // EVENT HANDLERS
-- ////////////////////////////////////////////////////////////////////////////

function handleBatchShades(objectList, requestedSides, materialName)
    if not client then return end
    
    local processed = 0
    local newBatch = {} 
    
    -- Fast lookup for supported parents
    local SupportedParents = {}
    for id, _ in pairs(ShadeConfig.Offsets) do 
        SupportedParents[id] = true 
    end
    
    for _, parentObject in ipairs(objectList) do
        if isElement(parentObject) then
            local parentModel = getElementModel(parentObject)
            
            if SupportedParents[parentModel] then
                -- Determine Variant (Basic vs Orange vs Dark)
                local configKey = "Basic"
                if parentModel == 8838 then
                    configKey = (materialName == "Orange") and "Orange" or "Dark"
                else
                    configKey = (materialName == "Orange") and "Orange" or "Basic"
                end

                if ShadeConfig.Offsets[parentModel] and ShadeConfig.Offsets[parentModel][configKey] then
                    local sideConfig = ShadeConfig.Offsets[parentModel][configKey]
                    
                    -- Determine Shade Model
                    local shadeModelID = ShadeConfig.Materials[materialName] or 3458
                    -- Special Case: Dark Material on Dark Parent
                    if parentModel == 8557 and shadeModelID == 8558 then 
                        shadeModelID = 8557 
                    end
                    
                    local parentScale = getObjectScale(parentObject) or 1.0
                    
                    -- Clear previous generations for this specific parent
                    clearOldShades(parentObject) 

                    -- Process Requested Sides
                    for reqSide, isRequested in pairs(requestedSides) do
                        if isRequested then
                            -- A. Single Definition
                            if sideConfig[reqSide] then
                                local shade = spawnSingleShade(parentObject, sideConfig[reqSide], parentScale, shadeModelID, parentModel)
                                
                                if not storedShades[parentObject] then storedShades[parentObject] = {} end
                                table.insert(storedShades[parentObject], shade)
                                table.insert(newBatch, shade)
                            end
                            
                            -- B. Multipart Definitions (side_1, side_2...)
                            local i = 1
                            while sideConfig[reqSide .. "_" .. i] do
                                local shade = spawnSingleShade(parentObject, sideConfig[reqSide .. "_" .. i], parentScale, shadeModelID, parentModel)
                                table.insert(storedShades[parentObject], shade)
                                table.insert(newBatch, shade)
                                i = i + 1
                            end
                        end
                    end
                    processed = processed + 1
                end
            end
        end
    end
    
    -- Commit to Undo Stack
    if not undoHistory[client] then 
        undoHistory[client] = {} 
    end
    table.insert(undoHistory[client], newBatch)
    
    outputChatBox("#00ff9d[AutoShade] #FFFFFFGenerated shade for " .. processed .. " parent objects.", client, 255, 255, 255, true)
end
addEventHandler("onBatchShadeRequest", resourceRoot, handleBatchShades)

function handleUndo()
    if not client then return end
    
    local stack = undoHistory[client]
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
addEventHandler("onAutoShadeUndo", resourceRoot, handleUndo)

-- Cleanup Handler
addEventHandler("onElementDestroy", root, function()
    if storedShades[source] then 
        storedShades[source] = nil 
    end
end)