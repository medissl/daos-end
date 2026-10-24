# Dao's End: The First Breath visual correction

Status: proposed visual direction responding to the user's rejection of the current placeholder interface. The user supplied cultivation-game screenshots as references. This pass changes presentation, not progression design. Generated with the built-in imagegen tool on October 23, 2026.

## Reference

Open `first-breath-visual-target-v1.png` beside this brief. It is a generated composition reference, not a running build or a production asset. Its character, scenery and HUD express the intended relationship. Do not use its baked text or controls in the playable game.

The user wants an appealing illustrated cultivation game that retains its Chinese ink-wash identity. Their examples emphasize a prominent meditating character within the world. Do not copy their proprietary characters, interface layouts or assets. Do not import their unrelated shops, currencies or navigation systems.

## Implement this bounded visual pass

Read applicable AGENTS.md instructions and the global DESIGN.md. Inspect current files and preserve existing work. Implement and verify this visual redesign; do not stop after writing a plan. Do not push or deploy.

The current `scripts/landscape.gd` draws placeholder polygon scenery. `scripts/main.gd` constructs the UI and coordinates lifecycle events. Its `_layout()` allocates about one-fifth of portrait height to the scenery. The current main screen therefore feels like a form with a thumbnail. Correct this composition.

Preserve the rules in `scripts/progression.gd`, state calculations, persistence, offline awards, lifecycle deduplication and existing player saves. Keep all three upgrades and the one breakthrough. Do not add new game systems, change costs or rates, or reset saves.

## Art and composition

- Make the sanctuary fill the composition behind the HUD, with layered distant mountains, mist, restrained waterfall detail and foreground stonework. Avoid a hard rectangular illustration thumbnail.
- Give the meditating cultivator a recognizable face, coherent anatomy, readable ivory robes with ink-blue details, and a clear seated silhouette. Keep the face and body visible above the controls. The character is a mortal novice, so ornament and supernatural effects stay modest.
- Prioritize the world and cultivator through roughly the upper half of the normal portrait screen. Use the generated target as a composition guide, not an inflexible pixel specification.
- Use translucent mineral washes, deliberate ink contours, dry-brush accents and localized paper texture. Retain separation between dark foreground ink and lighter distant washes. Keep the screen from becoming uniformly grey or brown.
- Use warm ivory, charcoal ink, mineral jade, muted blue-grey and a small cinnabar accent. Avoid neon, glossy skin, cinematic bloom, elaborate gold, excessive particles and generic fantasy filigree.
- Simplify the target's lower-panel ornament and corner vegetation. Give action labels priority over texture. Decorative seal marks must not masquerade as meaningful Chinese text.

## Live interface

Use a small title and readable realm label above the scene. Under the visible cultivator, show stored Qi, production, and breakthrough progress in a compact protected strip. Use dark text over quiet ivory surfaces, rather than text over detailed mountains.

Present Cultivation Practice as three compact scroll rows with clear labels, levels, costs and broad action targets. Use ink separators and restrained frames instead of stacked modern cards. Keep exact effects accessible through a tap or focus detail affordance; do not rely on hover. Describe the production effect accurately, including additive versus multiplicative changes.

Keep the breakthrough action easy to reach with an unmistakable unavailable state and readable requirement. Make affordability, learned upgrades, purchase feedback, offline rewards, save errors and Qi Refining advancement clear. The target image contains illustrative sample values; bind every actual value and enabled state to current gameplay state.

At ordinary portrait sizes, aim to show the face, Qi, all three upgrade actions and the breakthrough without scrolling. At 320 x 640 or with larger text, preserve legibility with an accessible practice drawer or scrolling practice region. Do not shrink everything to force a fit. Feedback must not permanently displace the main controls. Keep touch targets at least 48 logical pixels, visible focus states and no clipped costs.

For desktop, preserve the sanctuary as the dominant composition with a deliberately placed practice panel. Avoid stretching the portrait interface across the entire window.

## Asset production

Use actual illustrated assets for this pass; merely recoloring the polygons does not satisfy the request. Prefer available suitable original assets or built-in image generation when available. Do not assume generation produces production-ready output.

Create a small coherent asset set: sanctuary background, transparent cultivator, and only the foreground/mist/UI textures genuinely needed. Reuse one approved character design; do not generate unrelated characters independently. Bake static environmental detail into textures and keep useful scene layers separate. Do not simulate layer separation by moving identical full images over each other.

Generate clean artwork without text or buttons. Never use the complete reference screenshot as the game background or put invisible buttons over its pictured UI. Render text, progress bars, prices and controls with real Godot nodes. Use licensed, project-bundled fonts for consistent browser rendering; retain readable body text and use decorative lettering sparingly.

Inspect faces, hands, crossed legs, clothing seams, silhouettes, alpha edges and perspective. Reject obvious anatomical errors, inconsistent styles, accidental symbols and repeating synthetic texture. Inspect assets at the size players will actually see. Improve weak assets rather than hiding them with blur or glow. If suitable asset-generation tools are unavailable, report that limitation instead of claiming the placeholder artwork meets this brief.

Keep full-resolution sources organized outside runtime imports when appropriate. Import textures at sensible mobile sizes, avoid one huge transparent texture per small decoration, and measure actual runtime performance before adding optional effects. Use subtle breathing, slow mist and a restrained breakthrough accent. Respect reduced-motion preferences through a small setting if motion is introduced. Do not add audio or unrelated settings during this pass.

## Validation and delivery

Run the existing rule/save/session tests to detect accidental behavior changes. Update presentation checks to match the new layout while preserving their behavioral assertions. Never make old assertions pass by hiding duplicate controls.

Inspect actual running output at 320 x 640, 430 x 932 and 1280 x 800. Exercise each purchase, insufficient Qi, capped upgrades, breakthrough, offline return and save warnings. Test real pointer/touch-style interaction, not only button signals. Export and inspect the browser build when tooling permits. Report actual Android verification separately from desktop portrait emulation.

Review for recognizable ink painting, visible character, clean contrast, readable costs, useful action hierarchy, clipping, safe margins and responsive layout. Capture before/after screenshots and compare them to the target. A successful export alone does not establish visual success.

Deliver the working result, screenshots, asset/source provenance, tests actually run, measured performance where available, and remaining limitations. Record that this is a visual revision of milestone one, not authorization for milestone two.

## Generation prompt for the visual reference

One high-fidelity full-bleed portrait game screen for Dao's End, approximately 430:932. An original Chinese ink-wash cultivation idle RPG with a prominent hand-drawn novice meditating on a weathered stone platform. Delicate narrative figure painting, expressive controlled ink outlines, irregular robe folds, translucent mineral jade and blue-grey landscape washes, distant mountains and waterfall, small distant pavilion, framing pine branch, localized mist, warm ivory and a little cinnabar. Young adult male cultivator with closed eyes, black topknot, modest ivory hanfu with ink-blue lapels and belt, coherent seated lotus pose and two anatomically plausible hands resting on knees. No crown, ornate armor, weapon or jewelry. A restrained Qi arc, not a huge glowing magic circle. Avoid photorealism, glossy AI fantasy, synthetic noise, cinematic lighting, flat polygon mountains, decorative clutter and copied game assets. Compact readable live-HUD-style composition: small Dao's End title, Mortal / The First Breath realm label, 1,240 Qi, +3.75 Qi/sec, 1,240 / 4,000 progress. Warm parchment practice scroll with Deep Breathing Lv 2/4, 144 Qi; Meridian Circulation Lv 1/2, 480 Qi; Settle the Mind, Prepare your breakthrough, 200 Qi; unavailable Breakthrough, 4,000 Qi. Thin ink separators, broad jade price buttons, no modern nested cards, no fake tabs or shops. Painting continues behind quiet readable HUD surfaces. Full screen without phone frame. This paragraph records the generation direction; actual game values must come from state.
