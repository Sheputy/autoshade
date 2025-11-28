# AutoShade Pro - Changelog

All notable changes to AutoShade Pro are documented in this file.

---

## [1.0.0] - November 28, 2025

### 🎉 Initial Release

This is the official production release of **AutoShade Pro**, a complete architectural redesign and enhancement of the legacy AutoShade project by Gr0x.

### ✨ Major Features

#### Core Functionality
- **Intelligent Object Attachment System**: Automatic attachment of complementary objects to parent elements with precision positioning
- **Live Preview System**: Real-time visual feedback with shader-based highlighting and ghost object previews
- **Dynamic Configuration**: Centralized external configuration system (`config.lua`) for easy customization
- **Web-Based User Interface**: Modern, responsive HTML5/CSS3/JavaScript interface replacing legacy MTA GUI

#### Attachment Types (10+)
- Standard Shades (front, back, left, right, bottom)
- JetDoors (front & back variants with positional adjustments)
- NBBals (Dark and Orange directional variants)
- Towers (double-sided configurations)
- Crates (front & back mounting with collision geometry)
- Jetty (wooden architectural systems with optional shading)
- Mesh (A51 Panel attachment systems)

#### Material Variants
- **Light** (Model ID: 3458) - Bright, contemporary environments
- **Dark** (Model ID: 8558) - Professional, sophisticated aesthetics
- **Orange** (Model ID: 8838) - Industrial, warm-tone environments

#### Advanced Features
- **Theme Selection**: Real-time switching between material themes (Light/Dark/Orange)
- **Multi-Axis Configuration**: Simultaneous left, right, and bottom attachment positioning
- **Automatic Update System**: Integrated update checker with version management
- **Flexible Model Override**: Support for custom model IDs per attachment
- **Per-Attachment Scaling**: Individual scale parameters from 0.1 to 10.0
- **Collision Configuration**: Per-attachment collision geometry control
- **Custom Parent Offsets**: Special offset definitions for specific parent objects (IDs 6959, 8417)

### 🏗️ Architecture Improvements

#### Object-Oriented Design
- Complete rewrite from procedural to object-oriented architecture
- Proper encapsulation and state management
- Modular codebase with clear separation of concerns

#### Code Quality
- Professional development standards and best practices
- Comprehensive error handling and validation
- Optimized performance with offset lookup caching
- Clean client/server separation

#### Developer Experience
- Configuration-driven extensibility (no code modifications needed for new attachments)
- Comprehensive documentation and code comments
- Easy-to-modify configuration files
- Intuitive attachment definition syntax

#### Codebase
- **Client Module** (`cshade_client.lua`): UI rendering, selection management, live preview
- **Server Module** (`cshade_server.lua`): Request processing, object creation, positioning
- **Shared Configuration** (`config.lua`): Centralized material, offset, and attachment definitions
- **Auto-Update System** (`autoupdater.lua`): Version checking and resource management
- **Web Interface** (`ui/`): Modern HTML/CSS/JavaScript UI

### 📋 Supported Attachments (Detailed)

#### Standard Configurations
- **Basic** (sides: left, right, bottom)
- **Basic + Crates** (sides: left, right, bottom + front/back crates)
- **Every Side** (sides: left, right, bottom, front, back)
- **Bottom Only** (sides: bottom only)

#### Specialized Attachments
- **JetDoor (Front)**: Front-facing jet door attachments
- **JetDoor (Back)**: Back-facing jet door attachments
- **NBbal (Dark)**: Dark directional spherical elements
- **NBbal (Orange)**: Orange directional spherical elements
- **Tower**: Double-sided architectural panels
- **Crate**: Robust container-style elements
- **Jetty**: Wooden architectural systems
- **Jetty + Shade**: Combined wooden and shade configurations
- **Mesh**: Advanced A51 Panel systems

### 🎨 User Interface

#### Visual Components
- **Header Section**: Branding with settings access
- **Control Bar**: Preset selector and theme button group
- **Sides Section**: Interactive side cards (Left, Right, Bottom) with visual feedback
- **Preview System**: Live ghost object visualization
- **Settings Panel**: Advanced configuration options
- **Status Indicators**: Real-time attachment status display

#### Theme System
- Light theme for bright, high-visibility environments
- Dark theme for sophisticated, professional aesthetics
- Orange theme for industrial, warm-tone applications
- Real-time theme switching with visual updates

### 🔧 Configuration System

#### Material Definitions
- Three material variants with unique aesthetic properties
- Easy model ID mapping for custom replacements
- Support for future material variants

#### Offset Management
- Centralized offset lookup tables
- Per-attachment positioning precision
- Configurable rotation offsets (X, Y, Z degrees)
- Customizable scale factors

#### Dynamic Profiles
- Automatic profile generation based on parent type
- Support for standard and short parent objects
- Orange mode detection for appropriate material selection
- Extensible profile system for future enhancements

### 🔐 Security & Stability

#### Input Validation
- Comprehensive element type checking
- Model ID validation
- Attachment parameter verification
- Client/server authorization

#### Error Handling
- Graceful failure recovery
- Informative error logging
- Invalid state detection and recovery
- Resource cleanup on errors

#### Performance
- Optimized offset lookups with caching
- Efficient batch attachment operations
- Memory-optimized preview ghost management
- Minimal server resource usage

### 📚 Documentation

#### Included Documentation
- **README.MD**: Comprehensive user and developer guide
- **CHANGELOG.MD**: Version history and release notes
- **config.lua**: Inline configuration documentation
- **Source Code**: Detailed comments and function documentation

#### Developer Resources
- Clear architecture documentation
- Configuration syntax examples
- Extension guidelines
- Code commenting best practices

### 🛠️ Installation & Setup

#### Requirements
- MTA:SA Server (Multi Theft Auto: San Andreas)
- Administrative server access
- ACL permissions for resource operations

#### ACL Permissions Required
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

#### Setup Process
1. Place resource in `resources/` directory
2. Configure ACL permissions
3. Register in `mtaserver.conf`
4. Restart server

### 📞 Support & Community

#### Getting Help
- Contact `Corrupt` on Discord for issues and questions
- Detailed documentation available in README.MD

#### Feature Requests
- Request additional object support via Discord DM
- Include object ID, attachment points, and use case
- Future updates will include expanded object library

#### Contributing
- Contributions welcome via pull requests
- Follow existing code standards
- Include documentation for new features

### 📄 License

**Open Source License with Mandatory Attribution**

- ✅ Free to use, modify, and redistribute
- ✅ Commercial and personal use permitted
- 🔴 **Attribution required**: Must credit "Corrupt" and "AutoShade Pro"
- 🔴 Attribution mandatory even for single code snippet usage
- ⚠️ Violations subject to cease-and-desist and legal action

### 🙏 Credits

**AutoShade Pro**: Complete redesign and modernization  
**Author**: Corrupt  
**Original Concept**: Gr0x (Legacy AutoShade)  
**Platform**: MTA:SA (Multi Theft Auto: San Andreas)

---

### Known Limitations (v1.0.0)

1. **Object Support**: Currently supports 10+ core attachment types; additional objects planned for future releases
2. **Preset Customization**: Presets are defined in configuration; custom preset UI planned for future version
3. **Bulk Operations**: Single-element operations; batch processing planned for v1.1.0
4. **Multi-Element Selection**: Currently single-parent selection only

### Roadmap (Planned Features)

- **v1.1.0**: Batch attachment operations, custom preset UI, additional object support
- **v1.2.0**: Advanced animation system, attachment preview animations
- **v1.3.0**: Extended object library (20+ attachment types)
- **v2.0.0**: Performance optimization, database persistence, advanced analytics

---

## Version Information

| Property | Value |
|----------|-------|
| Version | 1.0.0 |
| Release Date | November 28, 2025 |
| Author | Corrupt |
| Status | Production Ready ✅ |
| Platform | MTA:SA |
| License | Open Source (Attribution Required) |

---

**End of Changelog**

For support, feature requests, or to report bugs, contact: **Corrupt** (Discord)
