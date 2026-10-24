# Dao’s End: usable art and interface asset production

Date: 2026-10-23, Asia/Jakarta. This is a proposed production guide, not completed artwork or runtime verification. Read alongside `ICON_TEXT_BALANCE_RESEARCH.md` and the global `~/.codex/DESIGN.md`.

## Evidence and direction

Reviewed saved images: milestone-two `browser-430x932-methods.png`, `browser-1280x800-methods.png`, `icon-set-runtime-sizes.png`, and the later `ui-finish/after/430x932-methods.png`. The later screenshot removes some row backgrounds but retains the large flat cream lower slab. The desktop image similarly places an illustrated cultivator beside a plain rectangular sheet. Existing art and thirteen icons are present; this review did not run the game or repeat reported tests.

The icons share delicate blue-green linework, but several spiritual symbols resemble small pale flourishes at 32 pixels. Consistency is useful; reliable recognition still needs stronger silhouettes. Keep good existing assets and revise weak ones in context.

Proposed direction: **an illustrated cultivation retreat with objects the player can operate**. A restrained scroll carries methods, a travel painting opens expeditions, and an ink-and-jade instrument presents cultivation progress. Artwork should give these objects personality without turning every label into an ornament.

The supplied references demonstrate character prominence, scenic depth, and recognizably game-like actions. Borrow those principles, not their proprietary characters, icon arrangements, saturated shop buttons, or notification clutter. Dao’s End remains original Chinese ink fantasy.

## Functional asset manifest

Produce only what the current playable systems use. This is a reusable kit, not a demand for dozens of unique frames.

| Asset family | Concrete deliverable | Runtime use |
|---|---|---|
| Retreat | Compatible distant mountains, mist, near rock/bamboo and grounded platform layers | One scene with controlled depth and modest atmospheric motion |
| Cultivator | Recognizable original silhouette and face; clean robe shapes; transparent cutout | Same identity across early realms, with separately authored spiritual overlays |
| Realm treatment | Qi flow, stable aura and one milestone ornament | Persistent visual change after advancement; effects stay behind readable controls |
| Methods scroll | Edge/corner skin, quiet paper interior, optional top spindle as separate ornament | One grouped technique region; not a scroll around every sentence |
| Action plaque | Ink/jade or dark lacquer skin with readable central area | Important training, exploration and advancement buttons |
| Small controls | Brush tab indicator, mastery sockets/fill, selection seal, lock mark | Navigation and states using a shared visual vocabulary |
| Cultivation meter | Thin ink track and separately clipped jade fill with end accents | Exact progress plus readable live value; no numeral baked into art |
| Destination | Distinct Bamboo Forest vignette; future locations only when implemented | Travel node or panorama with journey marker and timer |
| Rewards | Quiet tray/wash and item highlights | Item icons, live quantities and short names arranged together |
| Symbols | Audit existing Qi/herbs/method/realm symbols; add only new actual mechanics | Bold resource silhouettes, a consistent scale and line weight |

Suggested working sizes, to adjust after actual-size inspection: 256–512 px icon masters for 32–64 px display; a 512 × 256 action-skin master; a 512 × 512 nine-slice paper skin; approximately 1024 px character master. These are starting points, not export budgets. Match detail to final display size and document final dimensions/import settings.

## Build usable skins, not screenshot fragments

All names, costs, quantities, levels, percentages, timers, and labels remain live Godot text. No generated lettering, mock Chinese characters, or cost numbers inside textures. Separate functional controls from decorative artwork. A brush-shaped button can still have a conventional rectangular touch region with adequate clearance.

Godot provides texture-based nine-patch styling through `StyleBoxTexture`; its three-by-three layout preserves bordered designs at different sizes. `NinePatchRect` similarly keeps corners intact, with stretch/tile behavior for other regions. Tiling requires seamless art, while stretching can distort it. [Godot: StyleBoxTexture](https://docs.godotengine.org/en/stable/classes/class_styleboxtexture.html), [NinePatchRect](https://docs.godotengine.org/en/stable/classes/class_ninepatchrect.html)

For each stretchable skin, specify slice margins, minimum supported size, content padding and allowed scaling axes. Keep spindles, knots, stamps, jade ornaments and distinctive brush endings outside the stretching center. Reserve a low-detail, near-uniform interior for live text. Avoid baking one giant scenic stain into a region that must stretch. Decorative shadows and torn edges may extend outside the hitbox but must not obscure adjacent controls.

Test the smallest and widest real control sizes before accepting the skin. A handsome generated plaque that cannot resize or fit its label is a failed production asset.

## State system and readable composition

Author normal, pressed, focused, disabled/unaffordable, selected and locked appearances as needed. Shared artwork with deliberately authored overlays can provide states; separate generated paintings for every state are unnecessary. Keep geometry aligned. Use depth/edge changes, a selection seal or mastery pip alongside color, rather than tint alone. Show costs and concise effects while disabled. Hover is supplementary on desktop, never the only explanation.

Use a few materials consistently: quiet paper for reading, darker plaques for key actions, vermilion for rare achievement/selection accents, jade for cultivation. Keep ordinary readouts compact and comparatively unframed. Removing every surface would sacrifice readability; repeating the same surface everywhere would sacrifice hierarchy.

There is no universal premium icon/text ratio. Use illustration for place and identity, symbols for recognition, short words for intent, and numbers for choices. Keep unfamiliar action labels. Put lore and long formulas in tap-accessible details. One primary comparison must not require opening multiple explanations.

## Generation and consistency workflow

1. Build one **shared style sample** containing the existing character, a scenery crop, one herb icon, one method symbol, one live labeled button and one scroll edge at phone display size. Compare two real material directions, such as quiet scholar’s scroll versus jade-and-ink cultivation instrument; choose one internally.
2. Reuse the accepted sample as visual reference for subsequent generation/editing. Generate a specific isolated asset with transparency where appropriate. Do not ask for a whole mobile game screenshot and crop it into controls.
3. State the asset’s use, shape, material, silhouette, transparent boundary and reserved content area. Example: “Original Chinese ink-wash fantasy action plaque, muted deep jade, dry charcoal edge, sparse vermilion seal at left, quiet blank center for separately rendered text, no letters or symbols, straight-on flat UI asset, transparent background; match attached approved style sample.”
4. Inspect transparency, hands/anatomy, stray marks, cutout halos, fake detail, duplicated ornaments, inconsistent perspective and illegible miniature silhouettes. Edit/repaint selectively; do not accept defects because generation succeeded.
5. Store editable masters separately from exported runtime files. Record source/provenance, references, use, dimensions, slice margins and generation/edit notes. Do not copy proprietary game artwork or claim generated candidates are manually illustrated.

Brush marks should have purpose. Museum guidance distinguishes outlines, texture strokes, foliage dots and mist washes; project inference: reducing arbitrary texture can strengthen ink identity more effectively than adding grain everywhere. [Nelson-Atkins: Expressions of Brush and Ink](https://www.nelson-atkins.org/art/exhibitions/expressions-of-brush-and-ink/)

## Runtime acceptance

Integrate the sample controls first, then capture the actual game at 320 × 640, 430 × 932 and 1280 × 800. Review Mortal, selected method, unavailable purchase, active journey, rewards and breakthrough states. Check label contrast, numbers, cropping, scrolling, touch response and focus; decorative layers must not intercept input. Inspect icons at 32/48/64 px, not just enlarged atlases. Verify scene assets and small UI share brush density, palette and lighting. Check that new realms visibly change the scene without obscuring it.

Report screenshots and remaining defects separately from automated tests. A new asset count, passing tests, or “premium” wording does not establish visual quality. Finish when the assembled game has deliberate composition and clear actions, not merely when every old rectangle has a texture.
