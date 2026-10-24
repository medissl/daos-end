# Motion, character progression and asset production research

Research and source inspection: 2026-10-24. This is a proposed production specification, not a claim of implemented animation or measured device performance. Scope: an achievable illustrated 2D Godot game, preserving the ink-and-mineral-wash direction.

## What the current source actually does

Inspection covered `scripts/landscape.gd`, the relevant portions of `scripts/main.gd` and `scripts/chapter_ui.gd`, `scripts/forest_route.gd`, `scripts/game_audio.gd`, `project.godot`, export presets and current asset provenance. This note does not substitute for a new rendered/browser review.

| Area | Current implementation | Consequence for the next update |
|---|---|---|
| Character | One transparent `assets/art/cultivator.png` is drawn whole. `landscape.gd` offsets the complete image by `sin(breath) * .6`. | The seated figure, robe, hair and seat move together. Increasing the amplitude cannot produce breathing or cloth movement. |
| Motion cadence | `main.gd` updates `breath`, calls `landscape.queue_redraw()` and refreshes UI when `paint_elapsed >= .1`. | Decorative custom drawing advances around 10 times per second, separately from the engine frame rate. Do not claim a 10 FPS game, but do remove this cadence from animated properties. |
| Realm identity | Foundation adds an arc; Golden Core adds chest circles and a pendant texture. The body illustration remains the same. | These communicate a minor effect change more strongly than a transformed cultivator. |
| Actions | Combat sends an effect icon along an interpolation path for .55 seconds; enemy telegraphs use arcs. | Actions lack authored anticipation, directional motion, impact and recovery. |
| Environments | A single background texture is selected per region. | Clouds, water, foreground plants and mist are not independently animated scenery layers in this renderer. |
| Navigation | `chapter_ui.gd::show_section()` immediately switches section/surface visibility, then refreshes and lays out. | There is no visible scene handoff in this path. Sound already crossfades separately. |
| Existing audio | `game_audio.gd` has a capped SFX pool, two-player loop crossfades, browser gesture unlock, persisted sliders/mute and pause handling. | Preserve and audition this work rather than replacing the audio architecture. All players currently request Stream playback. |
| Existing accessibility | Presentation preferences include reduced motion, initially consulting the browser preference. | Extend this setting across the new animation system; retain the existing persisted choice. |
| Rendering/export | Compatibility renderer; web export has thread support disabled. | The solution must run in this actual renderer and exported browser build. |

Source facts above are local observations, not independent evidence that the current game feels good. The existing files and `assets/ART_SOURCES.md` also show that isolated character/environment/icon assets already exist: another static art replacement alone would repeat the same limitation.

## Technical findings from primary sources

Godot's cutout workflow supports a hierarchy of separate sprite pieces with deliberate pivots, and can combine cutout animation with occasional cel animation. That fits a seated illustrated cultivator whose cloth and hair move subtly while hands and face remain carefully drawn. The cutout tutorial itself warns that its content has not yet been updated for Godot 4.7, so verify editor details against the installed engine rather than assuming every tutorial shortcut still matches. [Official cutout animation guide](https://docs.godotengine.org/en/stable/tutorials/animation/cutout_animation.html)

Use `AnimationPlayer` for authored timings and loops. It supports animation libraries and blend times; property updates occur on process frames. `AnimationTree` adds advanced transitions using an `AnimationPlayer`'s animations, but a small seated-character rig does not initially need its extra machinery. [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html), [Using AnimationTree](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html)

Use short, interruptible `Tween`s for changing UI values and navigation geometry. Godot explicitly recommends avoiding concurrent tweens on the same property; keep the active tween and cancel it on interruption. This matters when the player changes destinations rapidly. [Tween reference](https://docs.godotengine.org/en/stable/classes/class_tween.html)

Static `CanvasItem` custom drawing can remain cached without redrawing every frame. Separating animated sprite transforms from static scenery is preferable to reconstructing every visual and text control at animation cadence. [CanvasItem reference](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)

`Parallax2D` is the current recommended parallax node. Its repeating textures require deliberate sizing and positioning; nonseamless painted fog should not be tiled blindly. A fixed retreat can also use a few independently moving sprites without a camera or parallax subsystem. [Official 2D parallax guide](https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html)

Overlapping transparent surfaces increase fill cost. Prefer tightly bounded mist, aura and effect sprites to repeated full-screen transparent passes, particularly on mobile. Profile before adding screen-reading shaders. [GPU optimization](https://docs.godotengine.org/en/stable/tutorials/performance/gpu_optimization.html)

Godot web exports require WebAssembly/WebGL 2.0 and the Compatibility renderer. Single-threaded exports improve hosting compatibility but carry performance tradeoffs. Default web Sample audio has feature restrictions; Stream restores engine audio features at greater latency, particularly without threads. Do not change playback mode just to satisfy a theoretical guideline: compare timing and loop quality in this project's actual export. Browser audio still needs a user gesture. [Official web export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)

## Production deliverables: a character who belongs in the painting

Produce one approved character identity sheet first: face, hairstyle, hairpin, robe silhouette, jade cross-collar, cape and pouch construction, palette, seated proportions and line-weight reference. Preserve the current character's useful identifying details unless the approved redraw deliberately replaces them. A front portrait, a three-quarter bust and the seated gameplay pose must read as the same person. This is an art review deliverable, not additional mandatory gameplay UI.

Generate/edit from that same approved reference; do not independently prompt a new face for every realm or animation frame. Generated images require cleanup and inspection, especially fingers, garment joins, duplicated ornaments, hair edges and transparency. Fewer coherent assets are better than a large inconsistent catalog. If generation cannot deliver a clean moving joint, keep that anatomy fixed and animate the cloth around it; do not hide the defect behind glow.

Deliver a transparent aligned cutout kit, preferably 8–12 useful pieces rather than a full puppet skeleton:

| Piece | Production requirement | Intended use |
|---|---|---|
| Platform and grounded legs | Separate from the moving upper body; fixed contact shadow | Prevent floating and whole-image bobbing |
| Torso/inner robe | Complete underpainting behind overlapping cape and sleeves | Subtle chest expansion and posture change |
| Head with stable face | One approved face; optional clean eye overlay only if useful at actual size | Small head settle; optional rare blink |
| Hair mass / one loose lock | Hidden overlap under the head and pin | Delayed response to a local breeze |
| Left and right sleeve/cape tails | Enough hidden painted cloth at pivots | Independent cloth movement without detached wrists |
| Hands | Fixed or a few carefully authored cel variants | Intentional mudra/technique gesture; never rubber fingers |
| Belt or sash tail | Separate only where it visibly improves the result | Secondary motion |
| Realm ornament overlays | Aligned to the same body anchors | Persistent earned progression |

Record a common source canvas, anchor/pivot coordinates, z order, overlap margins, maximum allowed rotation and animation-safe crop for each part. Reassemble and inspect at the full motion extremes over dark, light and actual painted backgrounds. Reject exposed holes, doubled outlines, bright alpha halos and body parts that slide against one another. Do not cut existing flat art into missing geometry and assume the gaps will stay hidden.

Keep a reusable `CultivatorVisual` scene with a small explicit presentation interface such as `set_realm`, `play_action`, `set_reduced_motion` and `set_active`. It listens to already-committed gameplay events. Animation callbacks must never determine whether an item is awarded, whether damage occurs or whether a save advances.

Initial authored clips:

- **Meditation:** an 8–12 second seamless cycle with chest/cape response, delayed sleeve/hair movement and fixed seated contact. Amplitude judged at actual display size. No compulsory blinking for a tiny face.
- **Technique release:** brief anticipatory gesture, directional brush stroke, identifiable impact and recovery. Differentiate sword, flame, ward and river by shape, path and timing, not recolor alone. Reuse the rig.
- **Enemy anticipation and hit:** one readable windup/charge response and one restrained hit reaction for each existing enemy visual family. Do not require full locomotion for every encounter.
- **Discovery:** object silhouette resolves into the real item icon, quantity and one relevant action. Ordinary repeats update the tray without a blocking ceremony.
- **Breakthrough:** a skip-safe 1.2–2 second authored sequence, with a visible before/after transformation and calm persistent end state. Routine navigation never waits for this kind of ceremony.

These timings are proposed tuning ranges, not evidence of an industry optimum. Record a motion reel at native speed; a still screenshot cannot validate animation.

## Earned transformation schedule

Bind visual tiers to attained realm state, never the current spendable Qi amount. Spending resources must not make the character look weaker. On load, reconstruct the final appearance immediately; do not replay an old breakthrough. Crossfading compatible aligned poses is acceptable, but mismatched faces should be fixed in the assets rather than concealed in a dissolve.

| Attainment | Persistent readable change | Actual production scope |
|---|---|---|
| Mortal | Grounded novice, natural hair/cloth response | Base cutout kit |
| Qi Refining | A few inward ink/Qi strokes with clear quiet intervals | Reusable effect overlay; same identity and clothing |
| Foundation | Stable seal integrated into the seat/terrace; deliberate cape or trim improvement | Clean matching torso/cape variation plus seal layer |
| Golden Core | New robe/ornament silhouette and localized warm core breathing through cloth | Second approved character costume kit; retain same head and common anchors where possible |
| Nascent Soul, when gameplay exists | Brief spirit echo paired with an intentional costume/pose evolution | Third coherent milestone treatment only when the content ships |

All tiers must remain distinguishable with motion disabled. Their exact fiction is a design choice; no claim that this is a universal cultivation-lore rule. Do not regenerate a whole body at every minor stage or fill the screen with permanent neon rings. A robe/pose change, changed environment detail and meaningful new mechanic should reinforce the same milestone.

## A place with atmosphere, and journeys without needless confirmation

For each shipped region, supply an opaque distant painting, one middle layer, one foreground silhouette layer, and one or two isolated atmospheric details. Recover or repaint the artwork behind removed layers. Keep a still fallback composition. A fixed sanctuary needs only a few carefully chosen motions: slow drifting mist, a branch moving within a very small range, and occasional leaves. Spirit River needs water reflection/ripple motion consistent with its painted marks; it does not need every surface to ripple.

Animate attention locally. Stop nonvisible scene loops; keep foreground contrast and mist away from counters, enemy silhouettes and essential controls. Environmental effects cannot create apparent interactive objects that do nothing.

Maintain one journey presentation through travel, encounter, rewards and onward travel. Do not insert a modal or a compulsory Continue/Collect button at every automatic step merely to show animation. The content/state design should decide where a genuine choice is needed. When a safe routine node finishes, let the scene move on under the player's selected journey policy, and put its reward in a compact running tray. Pause and present choices only at a real branch, discovery replacement decision, danger warning or meaningful camp decision. Keep Pause/Return available. Animation supports this change; a flourish on the existing confirmation chain does not solve it.

Navigation motion contract:

| Event | Proposed treatment | Interaction contract |
|---|---|---|
| Cultivate / Explore / Build | 160–220 ms crossfade with a small consistent content shift; shared scene anchors remain stable | Input responds immediately; rapid changes cancel the previous transition and settle to the latest destination |
| Detail sheet | 180–240 ms reveal from a consistent edge plus readable scrim | Correct focus transfer and restoration; tap outside only where dismissal is safe |
| Purchase/equip | 100–180 ms pressed/selected response and local delta | No success dialog for routine purchases; no delayed duplicate mutation |
| Travel to encounter | 250–400 ms layered handoff; enemy/route identity resolves in scene | No extra click; simulation does not wait for the paint effect |
| Victory/reward | Short in-scene resolution; a significant new object gets a restrained reveal | Routine reward enters the tray automatically; no text log required to know what happened |
| Breakthrough | Short authored event and persistent transformed scene | State committed once; interruptions, reloads and repeated taps cannot duplicate progress |

Avoid rendering the whole previous UI to a full-screen snapshot for every change unless profiling justifies it. Native child modulation/position is sufficient for many transitions. Keep one owner for each animated property, cancel stale tweens and exclude outgoing controls from input while they fade.

## Acceptance gates and evidence

These are proposed checks for the implementation chat. None are asserted passed by this research note.

1. **Asset consistency:** a contact sheet shows Mortal/Foundation/Golden Core at actual phone and desktop render sizes. Same face and garment construction, clean alpha, readable silhouette, grounded feet/seat, no exposed cutout seams at extreme poses. Every shipped file has provenance, source edit history and license/credits as appropriate. No baked interactive text.
2. **Motion evidence:** capture a 20–30 second native-speed clip including meditation, a destination handoff, a battle action, a reward and an attained realm change. Inspect loop seams and separate body/cloth motion, not just a flashing aura. At least two region clips demonstrate different environmental motion.
3. **Responsiveness:** test rapid destination changes, back/dismiss during reveals, buying twice rapidly, rotating/resizing during a transition, opening settings, hiding/resuming the tab, and loading an attained realm. No stuck opacity, invisible active buttons, double rewards, lost focus or blocked essential actions.
4. **Reduced motion:** disable decorative drift, parallax, body deformation, shake and sweeping wipes. Prefer instant state changes or a brief opacity change; retain static realm distinctions, readable telegraphs and all interactions. No advantage/disadvantage from the preference.
5. **Performance:** record device/browser, renderer, logical size, DPR, build type and test duration. Measure frame-time distribution, worst transition spikes, load/download size and memory before/after the animated scene, battle and ten navigation cycles. Target smooth 60 Hz presentation on the agreed reference desktop and at least stable 30 Hz on an ordinary Android reference device; explicitly mark unavailable hardware unverified. These are product targets, not guarantees. Desktop emulation does not establish Android speed.
6. **No cadence coupling:** continuous visual transforms run on frame/process animation. Resource-label refresh and deterministic simulation can retain their own appropriate cadence; moving an entire UI refresh loop to 60 Hz is not the fix. Cache reusable textures outside `_draw` and preload the next bounded region/encounter set before its reveal.
7. **Fill and texture limits:** report imported texture dimensions and approximate decoded memory, not just PNG file sizes. Bound translucent layer coverage and particle counts. Repeated journeys and transitions do not continuously grow nodes, tweens or memory. If 30 Hz fails, reduce atmosphere resolution/count before shrinking text or disabling essential feedback.
8. **Audio audition:** actual listening confirms gesture unlock, dry UI response, readable action/impact timing, unbroken region crossfade, no click/pop at loops and no foreground/background duplicate playback. Confirm persisted music/mute behavior and Stream latency in the single-threaded web export. Exported files existing is insufficient evidence.

Use the standard Godot Profiler for script costs and the Visual Profiler, where available, for rendering costs; the latter excludes other CPU tasks. Browser measurements and device observation remain necessary for the export. [Official debugger/profiling reference](https://docs.godotengine.org/en/stable/tutorials/scripting/debug/debugger_panel.html)

The first production checkpoint should be one fully coherent moving sanctuary and one uninterrupted illustrated journey. Accept that representative slice before multiplying costume kits, regions and effects. The complete update can then extend the approved system across shipped content without turning each new asset into a different visual style.
