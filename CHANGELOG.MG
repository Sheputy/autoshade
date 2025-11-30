# AutoShade Pro - Changelog

All notable changes to AutoShade Pro are documented in this file.

---

## [1.0.1] - November 30, 2025

### 🔧 Critical Fixes & Improvements (Official)

This patch is an authoritative maintenance release addressing parity and stability issues discovered after the initial launch. The changes below ensure the server-side generation matches the client preview exactly and improve UX and math stability across the codebase.

### Logic Parity (Preview vs. Generation)

- Fixed Rotation Mismatch: Addressed a critical issue where generated objects would rotate differently than their preview ghosts. The server now uses the exact same matrix composition logic as the client preview to guarantee visual parity.
- Direct Rotation Application: The server now applies rotation directly to the element (assigning element rotation at creation/commit time) in addition to updating EDF properties. This forces immediate visual parity with the client preview and bypasses potential EDF sync delays or conversion inconsistencies.

### Input & User Experience

- Cursor Logic Removed: Removed `showCursor(true)` calls from the UI. The interface now relies on the native EDF editor cursor, preventing "double cursor" issues and input freezing for editors.
- Keybind Conflict Fix: The Generate key (`G`) no longer triggers if the Shift key is held down. This prevents accidental generation when attempting to open the menu (Shift + G).

### Technical

- OOP Matrix Math: Standardized all rotation calculations to use MTA's Matrix class for improved stability, maintainability, and readability compared to legacy trigonometry-based functions. This reduces conversion rounding errors and simplifies future math changes.

### Backward Compatibility & Notes

- This patch remains backward compatible with v1.0.0 configuration files.
- These fixes are foundational for future features (batch operations, extended object library) and reduce a class of subtle visual/rotation bugs encountered by extension authors.

---
## [1.0.2] - November 30, 2025

### 🔧 Hotfix — EDF / Production Rotation De-sync Fix

This hotfix resolves a critical rotation de-synchronization observed between the in-editor EDF preview and live production gameplay (e.g., Race gamemode). The issue caused objects to appear correctly in the editor but mis-rotated in the actual game.

### Fixes

- Fixed EDF ↔ Production Rotation De-sync: Server now applies the same matrix composition and coordinate transforms as the client preview and sets element rotation directly at creation/commit time to avoid EDF synchronization delays.
- Ensured consistent rotation order and axis handling across client/server math to prevent rounding and conversion drift when moving assets from editor to live gamemodes.

### Notes

- This hotfix is backward compatible with existing `config.lua` settings. It addresses a real-world desync observed in Race and other fast-synced gamemodes.
- Consider updating any downstream tools that relied on the legacy rotation behavior; the new behavior is mathematically consistent and intended for correctness.

---

## [1.0.0] - November 28, 2025

### 🎉 Initial Release

This is the official production release of **AutoShade Pro**, a complete architectural redesign and enhancement of the legacy AutoShade project by Gr0x.

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
| Version | 1.0.1 |
| Release Date | November 30, 2025 |
| Author | Corrupt |
| Status | Production Ready ✅ |
| Platform | MTA:SA |
| License | Open Source (Attribution Required) |

---

**End of Changelog**

For support, feature requests, or to report bugs, contact: **Corrupt** (Discord)
