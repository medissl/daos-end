# Jade Road artwork and interface review

Reviewed in the running Godot game and exported Edge browser at 320×640,
390×844, 430×932 and 1280×800, in that order. Phones use a complete four-sided
reading surface below the cultivator, compact side-by-side selection/training
and bottom navigation. Desktop places the paper beside the scene. Methods
share the main paper without a second frame. The full-scroll HUD
comparison crowded navigation and was rejected. See
[full-scroll sample](screenshots/style-a-full-scroll.png) and
[quiet instrument sample](screenshots/style-b-quiet-instrument.png).

## Production and provenance

[ART_MANIFEST.json](ART_MANIFEST.json) records 30 individually generated assets:
four combat symbols, nine items, three resource/realm symbols, four guardian
families, two regions, six interface skins and two state symbols. Sources are
archived outside runtime imports. Seven targeted edits simplified the scroll,
action plaque, reward tray, sentinel, tortoise, pine sword and main panel. These are
separate images; none is a screenshot used as a functional interface.

Generation used OpenAI's built-in image tool with the existing Azure emblem
as the common ink/mineral-wash reference. Exact retained generation/edit
prompts, reference paths, generation filenames, crop bounds and SHA-256 hashes
are in the manifest. Initial prompt strings for the first four skin masters
and the new main-panel master were not retained; that gap is not filled with
invented verbatim prompts.
The subsequent scroll/plaque/tray edit prompts are retained. Original and
refined source files remain available.

`tests/prepare_jade_art.py` performs alpha-preserving crop, padding and resize.
It does not repaint anatomy or brushwork. Icons are 256×256 with a 216px
occupied-area target. Region layers are bounded to 1200×900. Linear filtering,
no mipmaps and transparent edges suit the Compatibility renderer and current
logical sizes. The existing cultivator and sanctuary layers are reused.

## Runtime construction

All text, prices, timers, quantities, selection behavior and hit targets are
native Godot controls. Artwork ignores input. Equipment and art selection are
free; Train and Refine are separate buttons. Mastery uses generated sockets
with a resource fill. Selection uses a seal plus a label; color is supplemental.

| Material | Texture slice L/T/R/B | Live content inset | Actual use |
|---|---|---|---|
| Main panel, 512×511 | 24/24/24/24 | 20px sides/top, 16px bottom | Complete gameplay surface; all four contours inside viewport |
| Methods group | No additional texture | 4px | Two methods on the main paper; no nested border |
| Menu/detail scroll | 24/28/24/28 | 40px | Optional details and all settings |
| Action plaque, 512×90 | 24/16/24/16 | 8px minimum horizontal; centered labels leave more space | All purchases/commitments, 48px minimum height |
| Reward tray | 112/72/112/72 | 28px horizontal, 30px vertical | Short result and wrapping reward icons |
| Progress track/fill | Center regions exclude 48px track ends / 24px fill tips; independent caps | No embedded text | HP, focus and tutorial progress |

Independent 10px meter cap layers are derived from the generated track ends;
the center stretches independently. No border curls stretch across labels.
The completed tutorial meter is hidden after Foundation; Core has an explicit
requirements view. All options, including reduced animation, sound, Help and
Credits, live in Menu. Return is pinned outside its settings scroll.

## Inspection and refinement

- Simplified the original scroll's large knobs, wavy edges and busy wash into
  thin rods, tiny jade caps, straight contours and quiet paper. Removed the
  horizontal expansion that clipped end caps at the viewport edge.
- Replaced the visibly cut main panel with a generated complete paper frame.
  The source cleanup left cyan only at alpha 1/255; no blue pixels exceeded
  alpha 16/255. Ivory/dark composites and rendered border samples were checked.
  The landscape fades into paper before the separately drawn character,
  removing the hard landscape/panel seam. See [frame/alpha review](screenshots/main-frame-alpha-review.png).
- Fixed narrow Azure labels extending into Train. All phone method titles are
  21px, labels 14–15px, emblems 32px; selection/training targets are 70px tall
  with an 8px gap. Train is 80px wide. The main paper reserves 20px side insets.
- Placed phone navigation below the action scroll. Equipment uses a short
  instruction, three filters and separate refinement prices/actions; longer
  rules moved to optional details. Combat art cells show actual icons,
  order and Ready/cooldown/focus/condition states rather than a prose list.
  Camp sits beside the encounter title above the fold, with a Queued state.
- The first DPR 3 mobile-browser check reproduced a separate scaling defect:
  the layout used the 960px backing canvas for a 320px phone, so the controls
  shrank to one-third their intended logical size. The root Window now uses
  canvas-item scaling with a logical size derived from physical size / screen
  density, refreshed on resize. This also configures native mobile density;
  native Android execution remains unverified. See Godot's
  [virtual content size](https://docs.godotengine.org/en/stable/classes/class_window.html#class-window-property-content-scale-size)
  and [screen density API](https://docs.godotengine.org/en/stable/classes/class_displayserver.html#class-displayserver-method-screen-get-scale).
  [DPR 3 before](screenshots/retina-before-320x640.png) and
  [after](screenshots/retina-320x640-methods.png) are actual matched-size browser captures.
  Dedicated DPR 2 and 2.625 contexts verify actual density, touch selection
  and live viewport changes; the DPR 3 ordinary route/Core run checks gameplay.
- Native content swipes and drags beginning on Refine are verified in the
  browser. The latter must cancel the purchase without spending stones.
  Longer chapter lists scroll deliberately within the complete outer frame.
- Added actual font-width and nested-label bounds checks, beyond checking
  only button rectangles. Help, menu Return and HUD bounds are checked too.
- Reward icons wrap instead of forcing three discoveries into one narrow row.
  Art cards reserve enough height for labels and mastery sockets.
- Inspected the existing face, hands, crossed legs, robe overlap and platform
  contact. No obvious additional limb/digit was identified. This is stylized
  generated illustration, not a claim of human-painted anatomy perfection.
- Reviewed crane legs/neck, tortoise four-leg silhouette, sentinel joints and
  serpent contour. Removed tortoise cloud curls and sentinel excess plates.
  The serpent remains intentionally coiled; family reuse across encounters is
  explicit. Guardian art is not 24 unique character paintings.
- [32/48/64px contact sheet](screenshots/icon-size-review.png): Flame, equipment
  and resource silhouettes remain distinct on ivory and dark jade. Pale Sword
  and Ward details soften at 32px, so names remain visible. No conspicuous
  colored alpha halo was identified. Not all fine brush marks survive 32px.
- [Region layer review](screenshots/scene-layer-review.png): broad washes and
  limited detail support the reused cultivator. Native shield, poison and burst
  cues sit separately from the illustrated encounter family.

The scene uses modest sprite/pulse feedback, not skeletal combat animation.
Golden Core adds a localized core light, the same jade pendant ornament and a
new badge, preserving character identity. Reduced animation retains readable
static state. A future human repaint and device review could improve individual
character and brushwork; no universal “AI-free” quality claim is made.
