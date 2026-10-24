# Runtime artwork and fonts

Milestone two: **A Cultivator’s First Journey**, October 23, 2026.

All new raster artwork is original generated-and-edited material produced with
the built-in imagegen tool. It is not a human illustration commission. No
commercial game art, museum image, emoji set or generic web icon library was
incorporated. The first-breath visual target remains a composition reference,
not accepted final art and never a runtime interface texture.

## World and character

| Runtime layer | Preserved source | Production |
| --- | --- | --- |
| `art/cultivator.png` | `docs/art-direction/milestone-2/sources/cultivator.png` | New novice silhouette: asymmetric ivory shoulder cape, jade cross-collar robe, herb pouch, single wood hairpin. Targeted edit simplified robe masses, hair and stone, retaining identity and anatomy. Source `exec-a018a06b-a585-49e7-b5c6-7b61c33ed117.png`; draft `exec-1d7904c2-82eb-46ee-9cb3-bf813c9d297e.png`. |
| `art/sanctuary-portrait.png` | Same filename under the milestone source folder | Quiet cliff, pine, bamboo and low mountain washes. Source `exec-5734fb4c-39e5-4062-82b5-f725ced18683.png`. |
| `art/sanctuary-wide.png` | Same filename under the milestone source folder | Companion composition, using the portrait as style reference. Source `exec-e6eb392d-6d31-4636-bcb5-63c4ca10902b.png`. |
| `art/bamboo-route.png` | `sources/icons/route.png` under the milestone folder | Original horizontal destination vignette, same environment and icon references. Source `exec-c3d6080d-f721-4041-b1dc-e5314f7ebf82.png`. Runtime downscaled to 1248×416. |

The character/seat is one independent transparent layer. The environment is
separate; portrait aligns the terrace with the seat instead of floating it
over mist. A cheap native arc provides a restrained realm effect, with a second
arc at Foundation. No heavy shaders or copied complete game screenshot are used.

The small style sample was rendered with live Godot controls before adopting
the assets: `docs/art-direction/milestone-2/screenshots/style-sample-430x932.png`.
Its text-led control layout was subsequently replaced following the updated
brief; it is process evidence, not a final screen.

## Matching game icons

Thirteen independent transparent icons share the Azure Cloud style reference
`exec-494aaa0c-fcba-46e2-b415-049fb841d36a.png`. Each has its own reusable PNG.
No atlas or asset framework was needed.

| Icon | Actual purpose | Intended logical size |
| --- | --- | --- |
| Qi | Resource, advancement price, return reward | 22–42 px |
| Spirit Herbs | Resource, mastery/preparation costs, trip/return rewards | 22–42 px |
| Breathing | Starter practice and retained practice summary | 32–40 px |
| Meridian | Starter practice and retained practice summary | 32–40 px |
| Still Mind | Starter practice and retained practice summary | 32–40 px |
| Azure Cloud | Selectable primary emblem, route commitment and navigation | 26–80 px |
| Iron Body | Selectable primary emblem and route commitment | 32–80 px |
| Bamboo Forest | Destination/navigation emblem | 26–40 px |
| Preparation | Persistent prepared seal and preparation action | 30–32 px |
| Advancement | Actual realm advancement control | 38 px |
| Mortal / Qi Refining / Foundation | Current realm badge and attained state | 38 px |

`assets/icons/manifest.json` maps each icon to its preserved source, generation
identifier, purpose and intended size. Sources are under
`docs/art-direction/milestone-2/sources/icons/`. Runtime PNGs are 256×256,
normalized with consistent padding. `tests/normalize_icons.py` performs only
technical alpha-bounds cropping, centering and downscaling; it does not repaint
or invent illustration. Originals remain intact. All icon alpha channels were
checked for genuine transparency.

Actual rendered 32/48/64 px inspection:
`docs/art-direction/milestone-2/screenshots/icon-set-runtime-sizes.png`.
The herb icon was edited for darker, simpler leaf masses. Meridian’s first
ornate version and a subsequent pale glossy edit were rejected; the selected
version uses a simple torso, three nodes and firm ink channels. No claim of
perfect generated-art cleanup is made: some source edges retain fine color
fringing and some miniature wash marks disappear at small sizes. The final
runtime inspection found no conspicuous colored halo on ivory; 22 px motifs
serve paired numerical labels rather than carrying meaning alone.

Focal inspection covered the face, both hands/fingers, crossed legs and covered
feet, robe/cape seams, pouch attachment, hair silhouette, alpha edges and stone
contact. The illustration remains stylized with an idealized face; further
human repainting could improve its individuality. No unambiguous extra limb or
digit was identified in the selected asset.

## Milestone-two live game presentation (historical)

All text, prices, hit targets, pips, frames, selection/queue seals, counters,
progress markers, focus outlines and reward panels are native Godot controls
or small native canvas drawing. No interface words or state indicators are
baked into generated images.

The route marker visualizes the single expedition timer. It is not a movement,
combat or exploration simulation. Realm badges, mastery pips and preparation
seals reflect actual saved state. Resource changes briefly show signed counts.
Reduced motion removes decorative breathing/flash motion; meaningful progress
continues to update.

Built-in generation prompts and edit directions are recorded in
`docs/art-direction/milestone-2/PROMPTS.md`. Historical milestone-one sources
remain in `docs/art-direction/sources/`, outside runtime imports.

Fonts are bundled unchanged under SIL Open Font License 1.1, including license
texts in the exported pack:

- **Cormorant Garamond**, Cormorant Project Authors: [official font source](https://github.com/google/fonts/tree/main/ofl/cormorantgaramond), `fonts/CormorantGaramond-OFL.txt`. Variable font rendered at weight 650 for headings.
- **Lato Regular**, Łukasz Dziedzic / tyPoland: [official font source](https://github.com/google/fonts/tree/main/ofl/lato), `fonts/Lato-OFL.txt`. Used for prices and functional body text.

Files were obtained from Google's official `google/fonts` repository. Museum
research references informed the cleanup criteria; no museum images were
downloaded or incorporated into game assets.

## Jade Road chapter update — 2026-10-23

The current chapter adds actual generated interface materials, replacing the
historical native-only frame statement above: one methods scroll, action
plaque, progress track/fill/caps, mastery sockets, selection seal, reward
tray and complete four-sided main panel. Methods share the main paper rather
than nesting another framed scroll. Functional text and input remain native
Godot controls. Thirty
generated runtime images and archived originals/edits are described in
`docs/jade-road/ART_MANIFEST.json` and `ART_REVIEW.md` there. Region/guardian,
combat art, nine equipment and resource/realm images are integrated with
actual systems. The earlier character/sanctuary and font provenance remains.

Licensed downloaded audio has separate file-level provenance and archived
license evidence in `docs/jade-road/AUDIO_MANIFEST.json` and `sources/audio/`.
Browser PCM/routing checks do not substitute for an unperformed listening test.
