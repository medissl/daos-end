# The Jade Road — implemented chapter and interface repair

2026-10-24. Playable Godot 4.7.2 / GDScript chapter through Golden Core.
No push, deployment or content beyond this boundary was performed.

## Play and build

Open `project.godot` in Godot 4.7.2 and press F5. For the actual browser export:

```powershell
python -m http.server 8765 --bind 127.0.0.1 --directory builds/web
```

Open [the local game](http://127.0.0.1:8765/). Keep one game tab per profile.
WebAssembly/WebGL 2 are required. Existing local progress is migrated in place;
do not replace a real save with a test fixture. Audio begins after a gesture.
**Menu** contains all options, including sound and reduced animation.

The installed engine used for verification was
`D:\Godot\Godot_v4.7.2-stable_win64_console.exe`. The Web preset is
single-threaded Compatibility. Rebuild with:

```powershell
godot --headless --path . --export-release Web builds/web/index.html
```

On another machine install matching Godot export templates and update/clear
the local custom-template paths in `export_presets.cfg`. Android needs its SDK,
Java and device checks; none is represented as completed here.

## What works

- Six finite four-node routes across Misty Mountain and Spirit River; eight
  enemy traits; route previews, safe camps, retained rewards and useful defeat
  reasons. First discoveries, gear and finale seals are tracked once.
- Deterministic 20Hz automatic combat; ordered arts, focus/cooldowns, barriers,
  poison, reflected hits, burst warnings, healing and bounded effects. Four
  combat arts, their mastery purchases, nine equipment items and three separate
  refinement levels are connected to earned rewards and real stats.
- Six optional objective trials and the separate Core Trial. Golden Core
  enforces 75,000 Qi, three distinct seals, two route clears per region and a
  Core Trial win. Optional preparation, third slot and free preset work.
- Equal 30% Foundation retreat when visible/closed, full-speed authorized
  foreground journeys, eight-hour absence cap and explicit v1/v2 migration.
  Azure's one-time 4/12-herb refund is retained. See
  [save/migration details](SAVE_MIGRATION.md).
- Thirty generated images, separately layered art and native controls.
  Two music loops, mountain/river ambience and twelve licensed effects have
  persisted Master/Music/Ambience/SFX and mute, gesture unlock, fades and bounded
  voices. Sources and edits are recorded, not inferred from a catalog license.

## Visual fixes from the user's review

Simplified the scroll's rods/end caps, contours and paper; removed clipped
horizontal expansion; gave text explicit interior margins. Replaced the cut
main gameplay panel with a complete four-sided paper frame and removed the
nested methods frame. Fixed Azure labels crossing into Train on phone screens.
All phones use compact method rows, independent 70px selection/training targets
and bottom navigation. The equipment header and instructions are shorter;
extended rules stay in optional details. Actual finger swipes scroll content,
and dragging from Refine cancels the purchase. Reward icons wrap, arts reserve room
for mastery, and meter caps remain inside their tracks. The completed tutorial
meter no longer appears as an unexplained strip under Foundation gameplay.

All settings moved into Menu. Its Return button stays outside the scrolling
options, with Help and Credits sharing a row. Detail text scrolls within the
paper; long explanations do not replace the game controls. The cultivator,
region/guardian, feedback and Golden Core ornament/badge are separate layers.

All purchases and commitments now use the same illustrated jade plaque,
including the original practices and method training. Combat art icons show
order, cooldowns, focus cost and readiness. Quiet navigation remains distinct.
Camp is beside the encounter title and reachable without scrolling at 320px;
its Queued state confirms the request. The Arts heading fits one line.

The high-density mobile-browser check exposed the main phone-specific defect:
layout used physical backing pixels, shrinking controls to one-third their
intended size at DPR 3. Window content now scales from logical dimensions
using the actual screen density and updates on resize. Native mobile uses the
same documented density path, but no Android build/device result is claimed.

The rejected retro-style UI cues, previous background music and bird ambience
were replaced. Effects use recorded wood, paper, air, impact, gong and water;
ambience uses quiet filtered water. Optional Chinese-instrument compositions
come from BiteMe Games. Music defaults off, with quieter ambience/SFX; this
audio-only preference revision preserves Master/mute and all progress saves.

[Visual review, skin specifications and source limitations](ART_REVIEW.md).

## Actual verification

| Command / evidence | Result |
|---|---|
| `tests/run_tests.gd` | 73 checks, 0 failures |
| `tests/milestone_two.gd` | 96 checks, 0 failures |
| `tests/jade_road.gd` | 190 checks, 0 failures; includes serialized active battles for every route/trial/Core |
| `tests/jade_audio.gd` | 15 checks, 0 failures; quieter defaults, preference migration/persistence, loops, debounce and focus cleanup |
| `tests/play_jade_chapter.gd` | All six routes, six trials, Core and Golden Core through public actions; 0 reachability failures |
| `tests/simulate_jade_road.gd` / `compare_jade_economy.gd` | Build/refinement/method/clock comparisons recorded |
| `tests/verify_jade_ui.gd` | 6,789 text/control/cap/frame/bounds checks, 0 failures, 164 rendered view states across four sizes; Camp above the fold |
| Web release export | Completed without reported errors |
| `node tests/browser_jade_road.cjs` | Phone-first four-size pointer/touch flow, finger swipes, separate purchases, camp/rewards, Core gate, third slot/preset, reload and audio routing; report below |
| `node tests/browser_jade_road.cjs --normal --retina` | Ordinary-speed first route and separately labeled Core Trial on the 390px DPR 3 phone; no accelerated clock; rewards/advancement survive reload |
| `node tests/browser_jade_road.cjs --comparison` | Matched Foundation captures, purchase-drag cancellation on phones, combat, Golden Core, Menu, Help and Credits at all four sizes; report below |
| `node tests/browser_jade_road.cjs --retina` | Actual mobile emulation at DPR 3: 320/390/430px, measured backing canvas, touch equip, finger scroll and Menu |
| `--retina --density=2` / `--density=2.625` | Dedicated contexts assert actual DPR; live 320/430/390px resizing, touch equip and rendered Arts verify scale/input without a reload |

Run the earned-path script before native UI verification: it produces the
earned Golden Core fixture. Run native UI before browser scripts to refresh
measured input coordinates. Tests use isolated profiles/save paths; no debug
state API or acceleration ships. Raw checks/build logs are in
[verification/](verification/), with hashes in [SOURCE_MANIFEST.json](SOURCE_MANIFEST.json)
and [TEST_RESULTS.json](TEST_RESULTS.json).

Real browser reports: [four-size flow](BROWSER_RESULTS.json),
[ordinary-speed play](NORMAL_BROWSER_RESULTS.json),
[final comparison](COMPARISON_BROWSER_RESULTS.json),
[high-density phones](RETINA_BROWSER_RESULTS.json),
[DPR 2](DENSITY_2_BROWSER_RESULTS.json) and
[DPR 2.625](DENSITY_2.625_BROWSER_RESULTS.json). Browser identity was Edge
with Intel Iris Xe WebGL through ANGLE. Exact short 120-frame timings are in
those reports. These are limited headless samples, not stable frame-rate or
mobile-device performance guarantees. The latest checks use the mobile-first
main frame, compact controls, bottom navigation and revision-two audio export.
The full four-size flow and audio run preceded the final Arts-heading,
Camp-placement and density refinements. Final browser comparisons cover
standard density, while high-density touch checks and ordinary-speed 390px
gameplay cover the final density correction. Native Windows bounds are
unchanged by the web/mobile-only density branch.
The eight balance, combat, progression and save implementation files also
[match the pre-finish chapter hashes](MOBILE_LOGIC_PRESERVATION.json).
Two exploratory CDP density overrides in the ordinary run stayed at DPR 3
after capture. Their raw metrics are retained and explicitly excluded as
evidence for other densities; dedicated contexts verify DPR 2 and 2.625.

## Rendered evidence

Matched input is a v2 Foundation save with practices 4/2/1, Azure M1, 2,400 Qi
and 8 herbs. After migration the legitimate one-time refund makes 12 herbs;
the displayed Retreat rate also changes to the specified 30%. Qi advances while
the real browser runs, so it is not pixel-identical numeric text.

| Viewport | Before | After |
|---|---|---|
| 320×640 | [before](screenshots/before/320x640-foundation.png) | [after](screenshots/after/320x640-foundation.png) |
| 390×844 (default) | No earlier baseline captured | [after](screenshots/after/390x844-foundation.png) |
| 430×932 | [before](screenshots/before/430x932-foundation.png) | [after](screenshots/after/430x932-foundation.png) |
| 1280×800 | [before](screenshots/before/1280x800-foundation.png) | [after](screenshots/after/1280x800-foundation.png) |

Representative final captures: [combat](screenshots/final-430x932-combat.png),
[small-screen menu](screenshots/final-320x640-menu.png),
[Help scroll](screenshots/final-320x640-help.png),
[Credits scroll](screenshots/final-320x640-credits.png),
[Golden Core](screenshots/final-1280x800-golden-core.png),
[ordinary first-clear rewards](screenshots/ordinary-route-first-clear.png),
[actual Core Trial victory](screenshots/ordinary-core-trial-victory.png).
The screenshot manifest distinguishes fixture and ordinary-speed evidence.
The [content catalog](CONTENT_MANIFEST.md), [art manifest](ART_MANIFEST.json) and
[derived cap records](DERIVED_ASSETS.json) identify the delivered definitions
and runtime layers.

Main-panel-specific native comparisons preserve the intermediate defect:
[320px before](screenshots/frame-before-320x640.png) /
[after](screenshots/frame-after-320x640.png),
[430px before](screenshots/frame-before-430x932.png) /
[after](screenshots/frame-after-430x932.png),
[desktop before](screenshots/frame-before-1280x800.png) /
[after](screenshots/frame-after-1280x800.png).

The actual high-density phone defect has its own same-size comparison:
[DPR 3 before](screenshots/retina-before-320x640.png) /
[after](screenshots/retina-320x640-methods.png).

## Audio evidence and its limit

[AUDIO_MANIFEST.json](AUDIO_MANIFEST.json) lists exact primary source, creator,
CC0 license, original filename, runtime mapping, edits and hashes. BiteMe's
creator page also restricts standalone asset resale; its explicit commercial
game-use permission and that qualification are retained. Source
recordings and license pages are archived in `sources/audio/`. Runtime files
were trimmed, DC-corrected, RMS matched, peak limited and loop-crossfaded.

Actual browser PCM was silent before a gesture, with all buses zero, with
Master zero and while muted. Music-only, ambience-only, SFX-only and mixed
streams produced nonzero signal below clipping. The default mix has music
off; music-only is an explicit slider test. Mute/display preferences
persisted separately; focus return did not add destination connections. WAV
captures are included for [music](browser-music-only.wav),
[ambience](browser-ambience-only.wav), [effects](browser-sfx-only.wav) and
[mixed output](browser-default-mix.wav).

**Listening remains unperformed.** The available audio preview reported that
audio input is unsupported. Signal/routing tests cannot establish musical fit,
fatigue, perceived loop seams or speaker/headphone quality. These need a human
listening review; Android audio is also unverified.

## Pacing and remaining limits

[PACING.md](PACING.md) reports the actual comparisons. The earned automated path
takes about 45 minutes, including about 28 minutes of retreat waiting and
17 minutes of combat waiting. It does not meet several engaged hours or prove
300 hours. Ordinary browser play completed the first four-node route, discovery
camp, free art equip, reload, then a separately labeled late Core Trial and
advancement in several minutes including loading/menu time (exact wall times
are in the browser reports). It is not a fresh-save
Mortal-to-Core human playthrough.

Guard Ward/Flame dominates ordinary routes. Cleanse and DOT matter in optional
trials, but limited-focus and mixed trials need stronger differentiation.
Replaying solved routes for stones is repetitive. Illustrations reuse four
guardian families; feedback is lightweight sprite/canvas work, not skeletal
animation. Pale icon details soften at 32px; short names remain. Screenshots
verify current layouts, not every possible device or assistive technology.

Next boundary: review the chapter's build dominance, challenge depth and human
engagement; perform audio listening and Android/device review. Do not add the
next realms or pad timers before that review. No account, cloud, prestige,
alchemy, law, party or gacha system was added.
