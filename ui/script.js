/**
 * ============================================================================
 * AutoShade Pro - Logic Controller
 * Version: 1.0.0
 * Changelog: Initial Release
 * ============================================================================
 */

// Data
const OBJECT_DATA = [
    { name: "Shade (Standard)", id: 3458 },
    { name: "JetDoor (Front)",  id: 3095 },
    { name: "JetDoor (Back)",   id: 3095 },
    { name: "Nbbal (Dark)",     id: 6959 },
    { name: "Nbbal (Orange)",   id: 8417 },
    { name: "Tower",            id: 16327 },
    { name: "Crate",            id: 3798 },
    { name: "Jetty",            id: 3406 },
    { name: "Jetty + Shade",    id: 3406 },
    { name: "Mesh",             id: 3280 }
];

// Presets (Combinations only)
const DEFAULT_PRESETS = [
    { name: "Full Coverage (Standard)", l: true, r: true, b: true, m: "Shade (Standard)" },
    { name: "Full Coverage (Tower)",    l: true, r: true, b: true, m: "Tower" },
    { name: "Full Coverage (Crate)",    l: true, r: true, b: true, m: "Crate" },
    { name: "Full Coverage (Jetty)",    l: true, r: true, b: true, m: "Jetty" },
    { name: "Full Coverage (Mesh)",     l: true, r: true, b: true, m: "Mesh" },
    
    { name: "Sides Only (Left + Right)", l: true, r: true, b: false, m: "None" },
    { name: "Tunnel Mode (U-Shape)",    l: true, r: true, b: true, m: "None" },
    { name: "Bottom Only",              l: false, r: false, b: true, m: "None" },
    
    { name: "Ends Only (Front + Back)", l: false, r: false, b: false, m: "Shade (Standard)" },
    { name: "Reset All",                l: false, r: false, b: false, m: "None" }
];

// State
const State = {
    material: "Light",
    sides: { left: false, right: false, bottom: true },
    ends: { front: "None", back: "None" },
    cachedModels: { front: "Shade (Standard)", back: "Shade (Standard)" },
    currentContext: null 
};

// Navigation
const Nav = {
    openSelector: (context) => {
        if(context !== 'presets' && !document.getElementById('chk-' + context).checked) return;
        
        State.currentContext = context;
        document.getElementById('view-selector').classList.remove('hidden');
        
        const saveBtn = document.getElementById('save-preset-btn');
        if(context === 'presets') saveBtn.classList.remove('hidden');
        else saveBtn.classList.add('hidden');

        Selector.build(context);
    },
    closeSelector: () => {
        document.getElementById('view-selector').classList.add('hidden');
    },
    toggleSettings: () => {
        const settings = document.getElementById('view-settings');
        const dash = document.getElementById('view-dashboard');
        
        if (settings.classList.contains('hidden')) {
            settings.classList.remove('hidden');
            dash.classList.add('hidden');
        } else {
            settings.classList.add('hidden');
            dash.classList.remove('hidden');
        }
    }
};

// Selector
const Selector = {
    build: (context) => {
        const grid = document.getElementById('selector-grid');
        const title = document.getElementById('selector-title');
        grid.innerHTML = '';

        if (context === 'presets') {
            title.innerText = "Configuration Presets";
            grid.classList.add('presets-mode'); 
            
            // Default Presets
            DEFAULT_PRESETS.forEach(p => {
                const card = document.createElement('div');
                card.className = 'sel-item preset-card';
                card.innerHTML = `<span class="preset-name">${p.name}</span>`;
                card.onclick = () => { 
                    Editor.applyPreset(p.l, p.r, p.b, p.m); 
                    Nav.closeSelector(); 
                };
                grid.appendChild(card);
            });

            // Custom Presets
            const custom = Selector.getCustomPresets();
            custom.forEach((p, index) => {
                const card = document.createElement('div');
                card.className = 'sel-item preset-card';
                card.style.borderColor = "var(--accent)";
                card.innerHTML = `
                    <span class="preset-name" style="color:var(--accent);">${p.name}</span>
                    <div class="del-preset" onclick="Selector.deletePreset(${index}, event)">✕</div>
                `;
                card.onclick = () => { 
                    Editor.applyState(p.state); 
                    Nav.closeSelector(); 
                };
                grid.appendChild(card);
            });

        } else {
            title.innerText = `Select ${context.charAt(0).toUpperCase() + context.slice(1)} Model`;
            grid.classList.remove('presets-mode'); 
            const current = State.ends[context];

            OBJECT_DATA.forEach(obj => {
                const card = document.createElement('div');
                card.className = `sel-item object-card ${current === obj.name ? 'selected' : ''}`;
                
                // Text Only Card
                card.innerHTML = `
                    <div class="obj-name">${obj.name}</div>
                    <div class="obj-id">${obj.id}</div>
                `;
                
                card.onclick = () => {
                    Editor.setCap(context, obj.name, true);
                    Nav.closeSelector();
                };
                grid.appendChild(card);
            });
        }
    },

    getCustomPresets: () => {
        try { return JSON.parse(localStorage.getItem('ashade_presets') || '[]'); } catch(e) { return []; }
    },

    saveCurrentAsPreset: () => {
        const name = prompt("Enter a name for this preset:");
        if(!name) return;

        const presets = Selector.getCustomPresets();
        presets.push({
            name: name,
            state: JSON.parse(JSON.stringify(State))
        });
        localStorage.setItem('ashade_presets', JSON.stringify(presets));
        Selector.build('presets');
    },

    deletePreset: (index, e) => {
        if(e) e.stopPropagation();
        if(!confirm("Delete this preset?")) return;
        
        const presets = Selector.getCustomPresets();
        presets.splice(index, 1);
        localStorage.setItem('ashade_presets', JSON.stringify(presets));
        Selector.build('presets');
    }
};

// Editor
const Editor = {
    init: () => {
        // Drag handled by MTA window mostly, but we keep listeners just in case for header
        Editor.refreshUI();
    },

    setTheme: (theme, el) => {
        State.material = theme;
        document.querySelectorAll('.theme-btn').forEach(e => e.classList.remove('active'));
        el.classList.add('active');
        Editor.sync();
    },

    toggleSide: (side) => {
        const chk = document.getElementById('chk-' + side);
        chk.checked = !chk.checked;
        State.sides[side] = chk.checked;
        Editor.refreshUI();
        Editor.sync();
    },

    toggleCap: (side) => {
        const chk = document.getElementById('chk-' + side);
        const isActive = chk.checked;
        const model = State.cachedModels[side];
        Editor.setCap(side, model, isActive);
    },

    setCap: (side, model, isActive) => {
        const chk = document.getElementById('chk-' + side);
        chk.checked = isActive;
        
        if (isActive) {
            State.ends[side] = model;
            State.cachedModels[side] = model;
        } else {
            State.ends[side] = "None";
        }
        Editor.refreshUI();
        Editor.sync();
    },

    refreshUI: () => {
        ['left', 'right', 'bottom'].forEach(s => {
            const card = document.getElementById('card-' + s);
            const chk = document.getElementById('chk-' + s);
            chk.checked = State.sides[s];
            if(State.sides[s]) card.classList.add('active');
            else card.classList.remove('active');
        });

        ['front', 'back'].forEach(s => {
            const wrap = document.getElementById('wrap-' + s);
            const lbl = document.getElementById('lbl-' + s);
            const chk = document.getElementById('chk-' + s);
            
            const isActive = (State.ends[s] !== "None");
            chk.checked = isActive;
            
            const model = isActive ? State.ends[s] : State.cachedModels[s];
            lbl.innerText = model;

            if(isActive) wrap.classList.remove('disabled');
            else wrap.classList.add('disabled');
        });
    },

    applyPreset: (l, r, b, model) => {
        State.sides = { left: l, right: r, bottom: b };
        ['front', 'back'].forEach(side => {
            if (model !== "None") {
                State.ends[side] = model;
                State.cachedModels[side] = model;
            } else {
                State.ends[side] = "None";
            }
        });
        document.getElementById('label-preset').innerText = "Custom Config"; 
        Editor.refreshUI();
        Editor.sync();
    },

    applyState: (newState) => {
        State.material = newState.material;
        State.sides = newState.sides;
        State.ends = newState.ends;
        State.cachedModels = newState.cachedModels;
        
        document.querySelectorAll('.theme-btn').forEach(b => {
            if(b.innerText === State.material) b.classList.add('active');
            else b.classList.remove('active');
        });

        document.getElementById('label-preset').innerText = "Custom Preset";
        Editor.refreshUI();
        Editor.sync();
    },

    sync: () => { if(window.mta) mta.triggerEvent("ui:updateConfig", JSON.stringify(State)); },
    generate: () => { if(window.mta) mta.triggerEvent("ui:generate"); },
    undo: () => { if(window.mta) mta.triggerEvent("ui:undo"); },
    
    updateSetting: (k, v) => { if(window.mta) mta.triggerEvent("ui:updateSettings", k, v); },
    updateKey: (el, k) => {
        const v = el.value.toLowerCase();
        if(v.length > 0 && window.mta) mta.triggerEvent("ui:updateSettings", k, v);
    }
};

document.addEventListener('DOMContentLoaded', Editor.init);