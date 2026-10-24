# Milestone 1 visual revision delivery

Completed October 23, 2026. This is a presentation revision of **The First
Breath**, not authorization for Milestone 2. No new gameplay systems, balance
changes, save migration or reset were added. Nothing was pushed or deployed.

## Result

- Full-screen illustrated sanctuary, with independently composited cultivator
  and stone dais. Portrait and desktop use matching environment compositions.
- Follow-up art edits reduced repeated scenery, noisy robe shading, hair loops
  and platform detail. The generated decorative scroll frame was rejected.
- Removed corner branding/milestone labels and development copy from play.
  Realm now belongs to the Qi readout. The illustrated cultivator remains the
  main focal point.
- Bundled Cormorant Garamond headings and Lato body/price text; thin ink
  separators and quiet ivory surfaces replace stacked modern cards.
- Native Godot controls provide real prices, enablement, progress and focus
  feedback. Exact effects open through the upgrade's title/level action.
- All three upgrade actions and breakthrough fit 390×844 and 430×932. At
  320×640 the practice rows scroll; breakthrough and feedback stay reachable.
- Help/effect/notice panels use the same typography and colors. Reduced motion
  is in practice help, with a separate `presentation.cfg` preference. Browser
  reduced-motion preferences are respected by default.

## Preservation and source review

SHA-256 comparisons confirmed these files are byte-for-byte unchanged:
`progression.gd`, `cultivation_state.gd`, `save_store.gd`, and
`cultivation_session.gd`. Save schema remains version 1, with the same paths,
costs, production, eight-hour offline cap and lifecycle deduplication.

Presentation/lifecycle coordination remains in `scripts/main.gd`; artwork
composition is in `scripts/landscape.gd`. Existing source copies and original
screenshots were checkpointed under `.verification/visual-before/` before edits.
This directory still has no Git metadata, so no Git commit/diff history is
claimed. Final source was reviewed against those copies.

Artwork, font licenses, source identifiers and inspection notes:
[assets/ART_SOURCES.md](../../assets/ART_SOURCES.md).
Research and reasons for the cleanup:
[VISUAL_QUALITY_RESEARCH.md](VISUAL_QUALITY_RESEARCH.md).
Full-resolution sources stay under `sources/`, excluded from runtime imports
by `docs/.gdignore`. Runtime textures are 1024×1536, 1536×1024, and an imported
1024×1024 character. No complete reference screenshot is loaded by the game.

## Checks actually performed

- **73 rule/save/session checks passed.**
- **48 native presentation checks passed**, including all three ordinary-size
  upgrade actions fitting, 48-pixel minimum action height, prominent character,
  reachable breakthrough, live rate/requirement refresh, persisted advancement,
  effect access, reduced motion, bounded help panel and visible save failure.
- Real native rendering reviewed at **320×640, 390×844, 430×932 and 1280×800**.
- Real exported WASM game checked in isolated headless **Microsoft Edge** at
  **320×640, 430×932 and 1280×800**. Pointer purchases, insufficient funds,
  learned caps, breakthrough, retained upgrades, reload, focus changes, offline
  cap, backward time, recovery preservation and notice detail all passed.
- Browser touch input swiped the short practice region and successfully bought
  Settle the Mind. The test exposed and fixed touch propagation through row
  buttons; it was not replaced with a button-signal assertion.
- Effect and help panels were inspected after fixing wrapped-text sizing and
  replacing desktop dialog chrome with a simple embedded game panel.
- Browser errors: **none** in the passing final flow.

Performance sample: 181 `requestAnimationFrame` intervals over approximately
three seconds at desktop size, median **16.7 ms**, p95 **16.8 ms**. Renderer:
ANGLE / Direct3D11 on Intel Iris Xe. This is a browser presentation-timing sample,
not a sustained gameplay benchmark, GPU capture or Android performance result.

The complete browser report is preserved in
[`screenshots/browser-results.json`](screenshots/browser-results.json).

## Screenshots

- [Before, 430×932](screenshots/before-430x932.png)
- [After, 430×932](screenshots/after-430x932.png)
- [After, 320×640](screenshots/after-320x640.png)
- [After, 1280×800](screenshots/after-1280x800.png)
- [Effect detail](screenshots/effect-detail.png)

Compared with the supplied target, the world and cultivator now dominate the
upper portrait composition, but the UI deliberately omits ornate corners,
decorative icons, scroll rollers, baked sample values and corner branding.

## Run and remaining limits

Import `project.godot` in Godot 4.7.2 and press F5. The ready browser build is
`builds/web/`; serve it over HTTP as described in the project README.

Android SDK/JDK configuration and physical Android testing remain unavailable;
desktop portrait and touch emulation are not Android-device evidence. No new
APK result is claimed. Artwork remains generated and edited, with provenance
disclosed; the user's visual review remains the acceptance decision.

The next step is reviewing this playable visual pass, then Android device
verification when its toolchain is available. Do not start additional gameplay
systems from this handoff.
