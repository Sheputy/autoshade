# AutoShade Pro - Changelog

All notable changes to AutoShade Pro are documented in this file.

---

## [1.0.3] - December 01, 2025

### 🔧 Hotfix — EDF / Production Rotation Final Fix (Regression Repair)

This hotfix corrects a regression where the prior fixes (1.0.1 / 1.0.2) did not fully resolve an EDF ↔ production rotation de-synchronization in certain gamemodes (notably Race). The issue caused objects to display correctly in the editor but be mis-rotated in live gameplay.

### What Went Wrong

- The 1.0.1/1.0.2 changes adjusted matrix composition and direct rotation application, but a subtle ordering difference and an EDF sync race caused remaining cases to diverge in production.

### Fixes (v1.0.3)

- Finalized Matrix Composition Parity: Reworked the exact matrix multiplication and rotation order to match the client preview deterministically (same transform order, same basis).
- Forced Post-Commit Rotation Enforcement: After EDF property updates and element creation, the server now assigns final rotation values and triggers a short validation tick to ensure EDF and engine state align before returning success.
- Added Defensive Sanity Checks: The server validates computed rotation vectors for NaN/Inf and logs any anomalies for immediate developer triage.
- Regression Tests & Logging: Added lightweight runtime verification steps when generating from preview mode that compare preview rotation and generated rotation and emit concise logs when mismatches were detected.

### Impact & Notes

- This hotfix is backward compatible with existing `config.lua` settings and preset files.
- The changes eliminate the last class of editor-to-production desyncs observed in fast-paced gamemodes.
- If you still encounter a rotation mismatch after v1.0.3, please include the parent model ID, the attachment type, and a small reproduction case when reporting.

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
| Version | 1.0.3 |
| Release Date | December 01, 2025 |
| Author | Corrupt |
| Status | Production Ready ✅ |
| Platform | MTA:SA |
| License | Open Source (Attribution Required) |

---

**End of Changelog**

For support, feature requests, or to report bugs, contact: **Corrupt** (Discord)
