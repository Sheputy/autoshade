# AutoShade Pro
![GitHub last commit](https://img.shields.io/github/last-commit/Sheputy/autoshade?color=brightgreen\&style=for-the-badge)
![GitHub repo size](https://img.shields.io/github/repo-size/Sheputy/autoshade?color=orange\&style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)
## Overview

**AutoShade Pro** is an enterprise-grade MTA:SA server resource designed for automatic object covering (Shading). It provides a professional, intuitive interface for dynamically attaching complementary architectural objects (shades, panels, doors, and more) to parent objects with millimeter-precision positioning, real-time visual previews, and comprehensive configuration management.

Originally inspired by the community-driven AutoShade project by Gr0x, AutoShade Pro has been completely rewritten from the ground up with a modern architecture, professional codebase standards, and significantly expanded functionality. This is not a simple modification—it's a next-generation tool built for production environments.

---

## Key Features

- **Intelligent Object Attachment System**: Attach pre-configured complementary objects to parent elements with precise, validated positioning
- **Live Preview & Real-Time Feedback**: Visualize attachments before application using shader-based highlighting and ghost object previews
- **Extensive Material Library**: Support for 10+ attachment types across three professional material variants
  - Standard Shades (Light, Dark, Orange)
  - JetDoors (Front & Back variants)
  - NBBals (Dark & Orange directional variants)
  - Towers (double-sided configurations)
  - Crates (front & back mounting)
  - Jetty & Jetty + Shade combinations
  - Mesh (A51 Panel systems)
- **Dynamic Theme System**: Seamlessly switch between Light, Dark, and Orange material themes
- **Flexible Multi-Axis Configuration**: Simultaneous attachment configuration for left, right, and bottom positions
- **Automated Update Management**: Integrated update checker ensures your resource stays current
- **Modern Web-Based Interface**: Responsive, professional UI built with HTML5/CSS3/JavaScript
- **Production-Ready Architecture**: Object-oriented design with OOP principles, proper encapsulation, and maintainability
- **Developer-Friendly Extensibility**: Configuration-driven system makes adding new attachment types straightforward

## Installation

### Prerequisites

- MTA:SA Server (Multi Theft Auto: San Andreas)
- Administrative access to server resources
- ACL (Access Control List) permissions

### Setup Instructions

1. **Deploy Resource**
   - Place the `autoshade` folder into your MTA:SA server's `resources` directory

2. **Configure ACL Rights**
   - Ensure your server grants the following permissions by typing `/aclrequest allow autoshade all` in your Console or Chat:
     ```
     function.fetchRemote
     function.restartResource
     function.fileCreate
     function.fileWrite
     function.fileClose
     function.xmlLoadFile
     function.xmlSaveFile
     function.xmlCreateChild
     general.ModifyOtherObjects
     ```

3. **Register Resource**
   - Add to `mtaserver.conf`:
     ```xml
     <resource src="autoshade" startup="1" protected="0" />
     ```

4. **Start Service**
   - Restart your MTA:SA server
   - Resource will auto-initialize on startup

---

## Comparison: AutoShade Pro vs Legacy AutoShade

AutoShade Pro represents a complete architectural reimagining of the original AutoShade project by Gr0x. While maintaining the core concept, every aspect has been rebuilt with professional standards, performance optimization, and enterprise-level functionality.

### Architecture Evolution

| Dimension | Legacy AutoShade (Gr0x) | AutoShade Pro |
|-----------|------------------------|---------------|
| **Design Pattern** | Procedural, event-callback driven | Object-Oriented with encapsulation |
| **Code Structure** | Monolithic (~450 lines) | Modular architecture (500+ LOC optimized) |
| **Configuration System** | Hard-coded within scripts | Centralized external `config.lua` |
| **User Interface** | Basic MTA GUI elements | Modern responsive web interface |
| **Extensibility Model** | Direct code modification required | Configuration-driven, zero-code extension |

### Capability Comparison

| Capability | Legacy AutoShade | AutoShade Pro |
|-----------|------------------|---------------|
| **Supported Attachment Types** | 7 (basic shades + crates) | 10+ (with directional variants) |
| **Material Variants** | 2 (Light/Dark) | 3 (Light/Dark/Orange) with full theme integration |
| **Live Preview** | ❌ None | ✅ Full preview with shader highlighting |
| **Preset Configurations** | 4 hardcoded presets | Unlimited dynamic presets |
| **Update System** | Manual only | ✅ Automated with version checking |
| **Offset Management** | Hard-coded vectors | Centralized dynamic lookup tables |
| **UI Interface** | Static, limited responsiveness | Dynamic, responsive web application |
| **Selection Feedback** | Basic highlighting | Advanced shader + preview ghost system |

### Technical Architecture

| Component | Legacy AutoShade | AutoShade Pro |
|-----------|------------------|---------------|
| **State Management** | Global variables scattered throughout | Unified state object with proper encapsulation |
| **Error Handling** | Basic `isElement()` checks | Comprehensive validation & error recovery |
| **Performance** | Inline matrix calculations per request | Optimized offset lookups with caching strategy |
| **Code Separation** | Mixed client/server logic | Clean separation of concerns (client/server/shared) |
| **Attachment Offsets** | Fixed hard-coded values | Dynamic offset tables with model overrides |
| **Model Support** | Limited to 3 base models | Flexible model override system supporting unlimited models |
| **Scaling System** | No per-attachment scaling | Per-attachment configurable scale parameters |
| **Collision Configuration** | Hard-coded collision rules | Per-attachment collision customization |

### Developer Experience

**Legacy Approach (Gr0x AutoShade):**
```lua
-- To add a new attachment type, direct code modification required:
if sides["new_attachment"] then
    autoShade.shades[element][8] = edf:edfCloneElement(element)
    local viktorVektor = Vector3(x, y, z)  -- Manual calculation required
    local positionVector = elementMatrix.transformPosition(elementMatrix, viktorVektor)
    local shadeX, shadeY, shadeZ = positionVector.x, positionVector.y, positionVector.z
    -- ... repeat entire process with hard-coded values throughout
    edf:edfSetElementProperty(autoShade.shades[element][8], "model", elemid)
    edf:edfSetElementPosition(autoShade.shades[element][8], shadeX, shadeY, shadeZ)
    -- ... 10+ more lines of repeated code
end
```

**Modern Approach (AutoShade Pro):**
```lua
-- To add a new attachment, simply update config.lua:
["new_attachment_front"] = { 
    offset = Vector3(18.67, 0.005, -18.67), 
    rotOffset = Vector3(90, 90, 0), 
    scale = 1.0, 
    collision = false, 
    modelOverride = 3798,
    doublesided = false
}
-- That's it! The system handles everything else automatically.
```

### User Experience Enhancements

| Aspect | Legacy AutoShade | AutoShade Pro |
|--------|------------------|---------------|
| **Interaction Model** | Keyboard-driven (Shift+G) | Click-based UI with visual feedback |
| **Configuration Selection** | 4 fixed presets only | Unlimited customizable presets |
| **Theme Management** | Single material at a time | Real-time theme switching |
| **Preview System** | None - apply and guess | Real-time visual preview before commit |
| **Feedback | Basic on-screen text | Shader highlighting + ghost previews + UI labels |

---



## Project Architecture

```
autoshade/
├── meta.xml                    # Resource manifest, ACL declarations, file registry
├── config.lua                  # [SHARED] Central configuration hub
│   ├── Material definitions    # Light (3458), Dark (8558), Orange (8838)
│   ├── Attachment specifications with offsets, rotations, scales
│   ├── Parent object overrides # IDs 6959, 8417
│   └── Dynamic profile generation engine
│
├── cshade_client.lua           # [CLIENT] User interface & interaction layer
│   ├── GUI state management
│   ├── Object selection system
│   ├── Live preview rendering
│   ├── Shader highlighting effects
│   └── Server event triggering
│
├── cshade_server.lua           # [SERVER] Attachment processing engine
│   ├── Request validation & processing
│   ├── Object instantiation & attachment
│   ├── Offset calculation & positioning
│   └── Resource persistence
│
├── autoupdater.lua             # [SERVER] Version management & auto-update system
│
├── CHANGELOG.MD                # Version history and release notes
│
├── ui/                         # Modern web-based user interface
│   ├── index.html              # Application markup (responsive design)
│   ├── style.css               # Professional styling & theme system
│   └── script.js               # Interactive client-side logic
│
└── README.MD                   # This documentation
```

---

## Configuration System

### Supported Material Variants

AutoShade Pro includes three professionally calibrated material variants, each optimized for different aesthetic requirements:

| Material | Model ID | Use Case |
|----------|----------|----------|
| **Light** | 3458 | White Shade |
| **Dark** | 8558 | Brown shade |
| **Orange** | 8838 | Orange Shade |

### Attachment Type Catalog

#### Front and Back Covers
- **Crates**: temp_crate1
- **Towers**: des_bycontowr
- **JetDoors**: a51_jetdoor on both sides (front/back)
- **NBBals**: vegasNbball1 & bballcourt01_lvs
- **Jetty**: cxref_woodjetty
- **Mesh**: a51_panel
- **More**: Many more objects will be added in the future

#### Advanced Configuration Options

Each attachment type supports:
- **Position Offset**: Vector3 coordinate relative to parent element
- **Rotation Offset**: Vector3 rotation (X, Y, Z) in degrees
- **Scale Factor**: Proportional scaling from 0.1 to 10.0
- **Collision Geometry**: Per-attachment toggle
- **Model Override**: Custom model ID substitution
- **Double-Sided Rendering**: Bidirectional visibility option

### Custom Parent Offsets

Manual override definitions for specific parent objects (Model IDs 6959 & 8417):
- Independent positioning for left, right, front, back, and bottom
- Individual scale and rotation parameters per side
- Bottom attachment with customizable collision

---

## Operational Guide

### Workflow: Creating Attachments

1. **Select Target Parent Object**
   - Click on the base object in the game world
   - Receive visual feedback and shader highlighting

2. **Choose Attachment Preset**
   - Open preset dropdown menu
   - Select configuration matching your requirements

3. **Select Material Theme**
   - Click theme button: Light, Dark, or Orange
   - Preview updates in real-time

4. **Configure Attachment Sides**
   - Toggle left, right, and bottom positions as needed
   - Each toggle updates live preview instantly

5. **Review Live Preview**
   - Visual representation of final attachment positions
   - Ghost objects show placement accuracy

6. **Apply Configuration**
   - Click "Apply" or execute command
   - Attachments created and positioned atomically

### User Interface Controls

| Control | Function |
|---------|----------|
| **Theme Buttons** | Switch active material (Light/Dark/Orange) |
| **Side Cards** | Toggle individual side attachments (Left/Right/Bottom) |
| **Preset Selector** | Choose pre-configured attachment templates |
| **Settings Panel** | Access advanced options and system configuration |
| **Live Preview** | Real-time visualization with shader effects |

---

## Technical Implementation

### Client-Side Module (`cshade_client.lua`)

**Responsibilities:**
- Complete UI event handling and state synchronization
- Object selection tracking and visual feedback
- Live preview rendering with ghost object system
- Shader-based highlighting for selected objects
- Server communication via triggerServerEvent

**Key Features:**
- Real-time DOM manipulation for responsive feedback
- Efficient event delegation and debouncing
- Memory-optimized preview ghost management

### Server-Side Module (`cshade_server.lua`)

**Responsibilities:**
- Request validation and authorization
- Atomic attachment creation and positioning
- Offset calculation from centralized configuration
- Resource state persistence
- Multi-client request handling

**Key Features:**
- Transaction-like attachment operations
- Comprehensive error logging and recovery
- Batch operation support for efficiency

### Shared Configuration (`config.lua`)

**Structure:**
- Material definitions and model mappings
- Centralized offset lookup tables
- End cap specifications (7 attachment types)
- Parent object override definitions
- Dynamic profile generation algorithms

**Accessibility:**
- Accessible from both client and server contexts
- Enables code reuse and consistency
- Single source of truth for positioning data

### Auto-Update System (`autoupdater.lua`)

**Functionality:**
- Periodic version checking
- Automated resource reloading on updates
- Version management and changelog tracking

---

## Extension & Development

### Adding New Attachment Types

AutoShade Pro's configuration-driven architecture makes extending the system straightforward:

**Step 1:** Define attachment in `SupportedEndCaps` table (config.lua)
```lua
["custom_panel_front"] = { 
    offset = Vector3(20.5, 0, -1.2), 
    rotOffset = Vector3(0, 90, 0), 
    scale = 1.5, 
    collision = false, 
    doublesided = true,
    modelOverride = 3280
}
```

**Step 2:** Add UI mapping to `SUPPORTED_CAP_MAPPINGS` (cshade_client.lua)
```lua
["Custom Panel"] = { f = "custom_panel_front", b = "custom_panel_back" }
```

**Step 3:** Test using live preview system

**That's it!** The attachment is now available system-wide.

### Modifying Offset Parameters

All positioning parameters are configurable in `config.lua`:

| Parameter | Type | Description |
|-----------|------|-------------|
| `offset` | Vector3 | Position relative to parent (X, Y, Z) |
| `rotOffset` | Vector3 | Rotation in degrees (X, Y, Z) |
| `scale` | Float | Scale factor (0.1 - 10.0) |
| `collision` | Boolean | Enable collision geometry |
| `modelOverride` | Integer | Custom model ID (optional) |
| `doublesided` | Boolean | Bidirectional rendering (optional) |

### Custom Parent Offset Configuration

For special parent objects, manual offsets can be defined:

```lua
ShadeConfig.Offsets[PARENT_MODEL_ID] = {
    ["Basic"] = {
        ["left"]    = { offset = Vector3(...), rotOffset = Vector3(...), ... },
        ["right"]   = { offset = Vector3(...), rotOffset = Vector3(...), ... },
        ["front_1"] = { offset = Vector3(...), rotOffset = Vector3(...), ... },
        ["bottom"]  = { offset = Vector3(...), rotOffset = Vector3(...), ... }
    }
}
```

### Support for Additional Objects

**Requesting New Object Support:**

AutoShade Pro is actively maintained with support for additional object types. If you need specific objects supported:

📧 **Contact on Discord:** `Corrupt`

When requesting new objects, please include:
- Object/Model ID
- Desired attachment points (front, back, left, right, bottom)
- Any special scaling or rotation requirements
- Use case description

**Future Updates:**
Additional object support will be released in regular updates. Join our community to stay informed of new features!

---

## Version Information

| Field | Value |
|-------|-------|
| **Current Version** | 1.0.2 |
| **Release Date** | November 30, 2025 |
| **Author** | Corrupt |
| **Original Concept** | Gr0x (Legacy AutoShade) |
| **Status** | Production Ready |

---

## Licensing

### Open Source License

AutoShade Pro is released under an **Open Source license** with specific attribution requirements.

### Rights Granted

You are **unrestricted in:**
- ✅ **Using** AutoShade Pro in any context (personal, commercial, educational, etc.)
- ✅ **Modifying** source code to suit your specific requirements
- ✅ **Redistributing** the resource (modified or unmodified)
- ✅ **Integrating** code snippets and components into your own projects
- ✅ **Forking** and creating derivative works

### Mandatory Attribution Requirements

**Critical:** Attribution is **legally required** regardless of modification extent. This includes:

**You MUST provide attribution if:**
- ✋ Using 100% unmodified code
- ✋ Using even a single line of code
- ✋ Integrating specific functions or algorithms
- ✋ Adapting any configuration concepts

**Attribution must include:**
1. **Creator Name**: "Corrupt"
2. **Project Name**: "AutoShade Pro"
3. **Link or Reference**: To original project (when possible)
4. **Visibility**: In documentation, README, comments, or credits

### Attribution Placement Examples

**In meta.xml:**
```xml
<!-- 
    Based on AutoShade Pro by Corrupt
    Original project repository/link
    Modifications: [describe changes]
-->
```

**In Resource README:**
```markdown
## Credits

This resource is based on **AutoShade Pro** by **Corrupt**
Original project: [link]
```

**In Lua Source Comments:**
```lua
-- Adapted from AutoShade Pro by Corrupt
-- Original implementation concepts used with attribution
```

**In-Game or Web Interface:**
```
Powered by AutoShade Pro (Corrupt)
```

### Violation Policy

Failure to provide proper attribution violates this license agreement. While the software is free, intellectual property recognition is mandatory:

- ⚠️ **First Violation**: Formal notice requesting attribution
- ⚠️ **Continued Violation**: Legal action and cease-and-desist
- ⚠️ **Commercial Use Without Attribution**: Subject to damages

**The original creator deserves recognition for intellectual contributions.**

---

## Documentation & Support

### Resource Documentation

Refer to the following resources for detailed information:

| Document | Content |
|----------|---------|
| `config.lua` | Comprehensive offset definitions and material specifications |
| `CHANGELOG.MD` | Version history, features, and breaking changes |
| UI Tooltips | In-game contextual help and guidance |

### Community & Support

**Questions or Issues?**
- 📧 Contact: `Corrupt` (Discord)
- 🐛 Bug Reports: Include version, reproduction steps, and error logs
- 💡 Feature Requests: Describe use case and desired functionality

**Contributing:**
- Contributions welcome via pull requests
- Follow existing code standards and conventions
- Include documentation for new features

---

## Credits & Attribution

### AutoShade Pro

**Author**: Corrupt  
**Created**: November 2025  
**Platform**: MTA:SA (Multi Theft Auto: San Andreas)

### Original Concept

**Based on**: AutoShade (Legacy)  
**Original Author**: Gr0x  
**Inspiration**: Community-driven development

AutoShade Pro is a complete architectural redesign and functional enhancement of the original AutoShade project. While maintaining conceptual compatibility, the codebase has been entirely rewritten to modern standards.

---

## Legal & Disclaimer

### Warranty Disclaimer

AutoShade Pro is provided **"AS IS"** without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement.

### Limitation of Liability

The author assumes no liability for damages, data loss, server issues, or other consequences arising from the use of this resource.

### User Responsibility

Users are responsible for:
- Backing up configurations before updates
- Testing in non-production environments first
- Maintaining proper server permissions and backups
- Complying with MTA:SA terms of service

---

**© 2025 Corrupt. All Rights Reserved.**  
**Built with ❤️ for the MTA:SA Community**

