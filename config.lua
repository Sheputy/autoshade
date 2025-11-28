-- ============================================================================
--  PROJECT:    AutoShade Pro
--  FILE:       config.lua (Shared)
--  AUTHOR:     Corrupt
--  VERSION:    1.0.0
--  DESC:       Configuration for object offsets, materials, and generation logic.
-- ============================================================================

ShadeConfig = {}

-- Model ID mappings for internal logic
ShadeConfig.Materials = {
    ["Dark"]   = 8558,
    ["Light"]  = 3458,
    ["Orange"] = 8838
}

ShadeConfig.Offsets = {}

-- ////////////////////////////////////////////////////////////////////////////
-- // SECTION 1: SUPPORTED END CAPS
-- // Definitions for front/back attachments (Crates, Towers, Doors, etc.)
-- ////////////////////////////////////////////////////////////////////////////

local SupportedEndCaps = {
    -- [ CRATES ]
    ["crate_front"] = { offset = Vector3( 17.6453, 0, -3.5954), rotOffset = Vector3(0, 0, 0), scale = 2.55, collision = true,  modelOverride = 3798 },
    ["crate_back"]  = { offset = Vector3(-17.6561, 0, -3.5954), rotOffset = Vector3(0, 0, 0), scale = 2.55, collision = true,  modelOverride = 3798 },

    -- [ TOWERS ]
    ["tower_front"] = { offset = Vector3( 20.2148, 0, -1.0641), rotOffset = Vector3(0, -90, 0), scale = 1.0172, collision = false, doublesided = true, modelOverride = 16327 },
    ["tower_back"]  = { offset = Vector3(-20.2148, 0, -1.0641), rotOffset = Vector3(0,  90, 0), scale = 1.0172, collision = false, doublesided = true, modelOverride = 16327 },

    -- [ JET DOORS ]
    ["jetdoor_front_f"] = { offset = Vector3( 20.2046, 0, -1.0437), rotOffset = Vector3(0, 270, 0), scale = 0.568, collision = false, modelOverride = 3095 },
    ["jetdoor_front_b"] = { offset = Vector3(-20.2026, 0, -1.0437), rotOffset = Vector3(0,  90, 0), scale = 0.568, collision = false, modelOverride = 3095 },
    ["jetdoor_back_f"]  = { offset = Vector3( 19.8828, 0, -1.0357), rotOffset = Vector3(0,  90, 0), scale = 0.568, collision = false, modelOverride = 3095 },
    ["jetdoor_back_b"]  = { offset = Vector3(-19.8823, 0, -1.0357), rotOffset = Vector3(0, 270, 0), scale = 0.568, collision = false, modelOverride = 3095 },

    -- [ NBBALS (Dark & Orange) ]
    ["nbbal_front_dark"]   = { offset = Vector3( 20.2051, 0, -0.9672), rotOffset = Vector3(90,  90, 0), scale = 0.1246, collision = false, modelOverride = 6959 },
    ["nbbal_back_dark"]    = { offset = Vector3(-20.1970, 0, -0.9672), rotOffset = Vector3(90,  90, 0), scale = 0.1246, collision = false, modelOverride = 6959 },
    ["nbbal_front_orange"] = { offset = Vector3( 20.2051, 0, -0.9672), rotOffset = Vector3(90, -90, 0), scale = 0.1246, collision = false, modelOverride = 8417 },
    ["nbbal_back_orange"]  = { offset = Vector3(-20.1970, 0, -0.9672), rotOffset = Vector3(90,  90, 0), scale = 0.1246, collision = false, modelOverride = 8417 },

    -- [ JETTY (Wood) ]
    ["jetty_front"] = { offset = Vector3( 11.1104, 0.0292, -3.5242), rotOffset = Vector3(0, 0,    0), scale = 2.347, collision = false, modelOverride = 3406 },
    ["jetty_back"]  = { offset = Vector3(-11.1081, 0.0292, -3.5242), rotOffset = Vector3(0, 0, -180), scale = 2.347, collision = false, modelOverride = 3406 },

    -- [ MESH (A51 Panel) ]
    ["mesh_front"] = { offset = Vector3( 20.2018, -0.0627, -0.9919), rotOffset = Vector3(0,  90, 0), scale = 3.2, collision = false, doublesided = true, modelOverride = 3280 },
    ["mesh_back"]  = { offset = Vector3(-20.1998, -0.0627, -1.0829), rotOffset = Vector3(0, -90, 0), scale = 3.2, collision = false, doublesided = true, modelOverride = 3280 },
}

-- ////////////////////////////////////////////////////////////////////////////
-- // SECTION 2: MANUAL PARENT OFFSETS
-- // Custom defined offsets for specific parent objects
-- ////////////////////////////////////////////////////////////////////////////

-- [PARENT 6959] (Dark Nbbal)
ShadeConfig.Offsets[6959] = {
    ["Basic"] = {
        ["right"]   = { offset = Vector3( 19.1663,  0.0050, -2.5697), rotOffset = Vector3(90, 0,  90), scale = 0.99, collision = false },
        ["left"]    = { offset = Vector3(-19.1607, -0.0068, -2.5697), rotOffset = Vector3(90, 0, 270), scale = 0.99, collision = false },
        ["front_1"] = { offset = Vector3(  0.6728, 18.4947, -2.5697), rotOffset = Vector3(90, 0, 180), scale = 0.99, collision = false },
        ["front_2"] = { offset = Vector3( -0.6726, 18.4806, -2.5697), rotOffset = Vector3(90, 0, 180), scale = 0.99, collision = false },
        ["back_1"]  = { offset = Vector3( -0.6709, -18.5057, -2.5697), rotOffset = Vector3(90, 0,   0), scale = 0.99, collision = false },
        ["back_2"]  = { offset = Vector3(  0.6782, -18.4791, -2.5697), rotOffset = Vector3(90, 0,   0), scale = 0.99, collision = false },
        ["bottom"]  = { offset = Vector3(0, 0, -5.0721), rotOffset = Vector3(0, 0, 0), scale = 1, collision = true, modelOverride = 6959 },
    },
}

-- [PARENT 8417] (Orange Nbbal)
ShadeConfig.Offsets[8417] = {
    ["Basic"] = {
        ["right"]   = { offset = Vector3( 19.1663,  0.0050, 2.5127), rotOffset = Vector3( 90, 0, 270), scale = 0.99, collision = false },
        ["left"]    = { offset = Vector3(-19.1607, -0.0068, 2.5127), rotOffset = Vector3( 90, 0,  90), scale = 0.99, collision = false },
        ["front_1"] = { offset = Vector3(  0.6728, 18.4947, 2.5127), rotOffset = Vector3(-90, 0,   0), scale = 0.99, collision = false },
        ["front_2"] = { offset = Vector3( -0.6726, 18.4806, 2.5127), rotOffset = Vector3(-90, 0,   0), scale = 0.99, collision = false },
        ["back_1"]  = { offset = Vector3( -0.6709, -18.5057, 2.5127), rotOffset = Vector3( 90, 0,   0), scale = 0.99, collision = false },
        ["back_2"]  = { offset = Vector3(  0.6782, -18.4791, 2.5127), rotOffset = Vector3( 90, 0,   0), scale = 0.99, collision = false },
        ["bottom"]  = { offset = Vector3(0, 0, 5.0244), rotOffset = Vector3(0, 180, 0), scale = 1, collision = true, modelOverride = 8417 },
    },
}


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- // SECTION 3: CORE LOGIC & GENERATION
-- // DEVELOPER NOTE: PLEASE DO NOT ATTEMPT TO MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING
-- // Auto-generation of profiles based on parent type
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local MAGIC_X = 3.495

-- Dynamic Profiles for Standard/Short Parents
local DYNAMIC_PROFILES = {
    -- [PARENT 3458] (Standard / Long)
    ["3458_Basic"] = {
        isShort = false,
        isOrangeMode = false,
        wall    = { x = 18.6735, z = -18.6733, rotF = Vector3(0, 90, 0), rotB = Vector3(0, 270, 0) },
        side    = { y = 1.0427,  z = -1.0367,  scale = 1.0, rotL = Vector3(270, 0, 0), rotR = Vector3(90, 0, 0) },
        bottom  = { z = -2.0765, rot = Vector3(180, 0, 0) }
    },
    ["3458_Orange"] = {
        isShort = false,
        isOrangeMode = true,
        bottom  = { z = -2.06739, rot = Vector3(0, 180, -180), override = 3458 },

        -- Precise Map Data (Anti-Z-Fighting + Color Correction)
        precise_walls = {
            front = { offset = Vector3( 18.6699, 0.0063, -15.1763), rot = Vector3(0, -90, 180) },
            back  = { offset = Vector3(-18.6707, 0.0066, -15.1673), rot = Vector3(0,  90, -180) }
        },
        precise_sides = {
            left_1  = { offset = Vector3( 3.4945,  1.0470, -1.0290), rot = Vector3(-90, 180, -180) },
            left_2  = { offset = Vector3(-3.4950,  1.0335, -1.0290), rot = Vector3(-90, 180, -180) },
            right_1 = { offset = Vector3( 3.4950, -1.0505, -1.0390), rot = Vector3( 90,   0,    0) },
            right_2 = { offset = Vector3(-3.5030, -1.0326, -1.0380), rot = Vector3( 90,   0,    0) }
        }
    },

    -- [PARENT 8838] (Short / Orange Parent)
    ["8838_Dark"] = {
        isShort = true,
        isOrangeMode = false,
        wall    = { x = 15.1785, z = -18.6733, rotF = Vector3(0, 90, 0), rotB = Vector3(0, 270, 0) },
        side    = { y = 1.3047,  z = -0.5864,  scale = 0.8267, rotL = Vector3(270, 0, 0), rotR = Vector3(90, 0, 0) },
        bottom  = { z = -1.1765, rot = Vector3(180, 0, 0), override = 8838 }
    },
    ["8838_Orange"] = {
        isShort = true,
        isOrangeMode = true,

        -- Override Walls with Precise Data (Calculated from user map)
        precise_walls = {
            front = { offset = Vector3( 15.1742, 0.0115, -15.1786), rot = Vector3(0, -90, -180) },
            back  = { offset = Vector3(-15.1645, 0.0117, -15.1696), rot = Vector3(0,  90, -180) }
        },

        -- Override Sides Logic with explicit asymmetric values
        precise_sides = {
            left  = { offset = Vector3(0,  1.0384, -1.0307), rot = Vector3(-90, 180, 180) },
            right = { offset = Vector3(0, -1.0254, -1.0447), rot = Vector3( 90,   0,   0) },
        },

        -- Use Precise Vector for Bottom to fix Y offset
        bottom  = { offset = Vector3(-0.0018, 0.0108, -2.0730), rot = Vector3(0, 180, -180), override = 8838 }
    }
}

-------------------------------------------------------------------------------
-- Logic: ApplyDynamicLogic
-- Generates offset tables based on the profiles above.
-- @param parentId: The object ID of the parent
-- @param configKey: The variant type ("Basic", "Orange", "Dark")
-------------------------------------------------------------------------------
local function ApplyDynamicLogic(parentId, configKey)
    local profileKey = tostring(parentId) .. "_" .. configKey
    local profile = DYNAMIC_PROFILES[profileKey]
    if not profile then return end

    if not ShadeConfig.Offsets[parentId] then ShadeConfig.Offsets[parentId] = {} end
    ShadeConfig.Offsets[parentId][configKey] = {}
    local target = ShadeConfig.Offsets[parentId][configKey]

    -- A. WALL GENERATION
    if profile.precise_walls then
        target["front"] = { offset = profile.precise_walls.front.offset, rotOffset = profile.precise_walls.front.rot, scale = 1, collision = true }
        target["back"]  = { offset = profile.precise_walls.back.offset,  rotOffset = profile.precise_walls.back.rot,  scale = 1, collision = true }
    else
        target["front"] = { offset = Vector3( profile.wall.x, 0, profile.wall.z), rotOffset = profile.wall.rotF, scale = 1, collision = true }
        target["back"]  = { offset = Vector3(-profile.wall.x, 0, profile.wall.z), rotOffset = profile.wall.rotB, scale = 1, collision = true }
    end

    if profile.isOrangeMode then
        target["front"].modelOverride = 8838
        target["back"].modelOverride = 8838
    end

    -- B. SIDES GENERATION
    if profile.precise_sides then
        if profile.precise_sides.left_1 then
            -- Split Sides (3458 Style)
            target["left_1"]  = { offset = profile.precise_sides.left_1.offset,  rotOffset = profile.precise_sides.left_1.rot,  scale = 1, collision = true }
            target["left_2"]  = { offset = profile.precise_sides.left_2.offset,  rotOffset = profile.precise_sides.left_2.rot,  scale = 1, collision = true }
            target["right_1"] = { offset = profile.precise_sides.right_1.offset, rotOffset = profile.precise_sides.right_1.rot, scale = 1, collision = true }
            target["right_2"] = { offset = profile.precise_sides.right_2.offset, rotOffset = profile.precise_sides.right_2.rot, scale = 1, collision = true }
        else
            -- Single Sides (8838 Style)
            target["left"]  = { offset = profile.precise_sides.left.offset,  rotOffset = profile.precise_sides.left.rot,  scale = 1, collision = true }
            target["right"] = { offset = profile.precise_sides.right.offset, rotOffset = profile.precise_sides.right.rot, scale = 1, collision = true }
        end
    else
        -- Standard Calculation
        local s = profile.side
        local col = not profile.isOrangeMode
        if s.split then
            target["left_1"]  = { offset = Vector3( MAGIC_X,  s.y, s.z), rotOffset = s.rotL, scale = s.scale, collision = true }
            target["left_2"]  = { offset = Vector3(-MAGIC_X,  s.y, s.z), rotOffset = s.rotL, scale = s.scale, collision = true }
            target["right_1"] = { offset = Vector3( MAGIC_X, -s.y, s.z), rotOffset = s.rotR, scale = s.scale, collision = true }
            target["right_2"] = { offset = Vector3(-MAGIC_X, -s.y, s.z), rotOffset = s.rotR, scale = s.scale, collision = true }
        else
            target["left"]  = { offset = Vector3(0,  s.y, s.z), rotOffset = s.rotL, scale = s.scale, collision = col }
            target["right"] = { offset = Vector3(0, -s.y, s.z), rotOffset = s.rotR, scale = s.scale, collision = col }
        end
    end

    if profile.isOrangeMode then
        if (profile.precise_sides and profile.precise_sides.left_1) or (profile.side and profile.side.split) then
            target["left_1"].modelOverride = 8838; target["left_2"].modelOverride = 8838
            target["right_1"].modelOverride = 8838; target["right_2"].modelOverride = 8838
        else
            target["left"].modelOverride = 8838; target["right"].modelOverride = 8838
        end
    end

    -- C. BOTTOM GENERATION
    local bottomOffset = profile.bottom.offset or Vector3(0, 0, profile.bottom.z)
    target["bottom"] = { offset = bottomOffset, rotOffset = profile.bottom.rot, scale = 1, collision = true }

    if profile.bottom.override then
        target["bottom"].modelOverride = profile.bottom.override
    end

    -- D. EXTRAS (End Caps)
    for key, data in pairs(SupportedEndCaps) do
        local shiftX = profile.isShort and MAGIC_X or 0
        local finalX = (data.offset.x > 0) and (data.offset.x - shiftX) or (data.offset.x + shiftX)

        target[key] = {
            offset        = Vector3(finalX, data.offset.y, data.offset.z),
            rotOffset     = data.rotOffset,
            scale         = data.scale,
            collision     = data.collision,
            doublesided   = data.doublesided,
            modelOverride = data.modelOverride
        }
    end

    -- E. PIGGYBACK ALIASES (Jetty Special Cases)
    target["jetty_shade_front"]   = target["jetty_front"]
    target["jetty_shade_front_1"] = target["front"]
    target["jetty_shade_back"]    = target["jetty_back"]
    target["jetty_shade_back_1"]  = target["back"]
end

-- ////////////////////////////////////////////////////////////////////////////
-- // EXECUTION: INITIALIZATION
-- // ////////////////////////////////////////////////////////////////////////////

ApplyDynamicLogic(3458, "Basic")
ApplyDynamicLogic(3458, "Orange")
ApplyDynamicLogic(8838, "Dark")
ApplyDynamicLogic(8838, "Orange")

-- Aliasing IDs to share logic
ShadeConfig.Offsets[8558] = ShadeConfig.Offsets[3458]
ShadeConfig.Offsets[8557] = ShadeConfig.Offsets[3458]
ShadeConfig.Offsets[3095] = ShadeConfig.Offsets[3458]

-------------------------------------------------------------------------------
-- Helper: getRelativePos
-- Calculates world position based on element matrix and offsets.
-------------------------------------------------------------------------------
function ShadeConfig.getRelativePos(element, offX, offY, offZ)
    local m = getElementMatrix(element)
    return offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1],
           offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2],
           offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
end