# Milestone two delivery

The subsequent **interface finish pass** is documented in
[ui-finish/DELIVERY.md](ui-finish/DELIVERY.md), with matched browser comparisons.
That note supersedes the original UI composition described below. Gameplay
and the pacing review remain unchanged. `BUILD.json` identifies the current export.

October 23, 2026. Connected gameplay and illustrated presentation are
implemented through Foundation Establishment. Nothing was pushed or deployed.
No local Git metadata exists; checkpoint copies are under
`.verification/m2-before/`, not a claimed commit history.

## What changed

The specified 1,200/800-Qi opening now leads to two freely known techniques and
concurrent two-minute Bamboo Forest trips. Herbs compete between mastery,
optional preparation and advancement. Foundation costs both resources, retains
upgrades and unlocks half-strength secondary technique effects.

Departures commit both technique bonuses. Choices queue, mastery and resonance
wait until departure, and realm base production changes immediately. Stop
finishes the current trip and survives reload. Qi, herbs and trips use the same
event-boundary timeline and eight-hour absence cap. A sub-nanosecond tolerance
absorbs floating-point summation dust at exact completion boundaries.

Version-one saves use their original validator/formula, are preserved and
explicitly migrate to version two without equipping methods or inventing trips.
The application name, paths, backup, interrupted-write and recovery behavior
remain intact. Validation covers resources, mastery caps, unlocks, queue/idle
consistency and commitments attainable from prior mastery/resonance.

The focal novice, scenery and stone were overhauled using a restrained
line-and-wash direction. Thirteen matching illustrated icons and a forest
vignette now communicate resources and actions. Techniques use real selectable
emblems, selected/queued frames and mastery pips. Forest shows the committed
method, a timer-linked marker, exact reward/time and repeat state. Preparation
has a persistent seal; advancement displays both matching resource icons and
counts. Return rewards use a compact illustrated panel. Long explanations are
optional. The play screen has no title in the corner or persistent text log.

## Working build and sources

The ready local release browser export is `builds/web/index.html`; serve its directory
over HTTP using the README command. Godot 4.7.2 can run the source with F5.
This is a local build, not a deployed site.
Exported file sizes and SHA-256 checksums are recorded in [BUILD.json](BUILD.json).

- [Artwork, inspection and font provenance](../../../assets/ART_SOURCES.md)
- [Individual icon manifest](../../../assets/icons/manifest.json)
- [Prompt and edit directions](PROMPTS.md)
- [Pacing comparison](../../design/MILESTONE_2_PACING.md)
- [Implementation handoff](../../MILESTONE_2_HANDOFF.md)

Generated sources remain separate from runtime-normalized textures, under
`sources/`. All labels, hit areas, states, costs and reward counters are native
controls. No generated complete interface is loaded. The route is a view of
the specified timer, without a second movement/gameplay system.

## Checks and evidence

| Verification | Result |
| --- | --- |
| Retained opening/save/session tests | 73 passed |
| New rules, trips, migration and persistence | 96 passed |
| Native presentation and visual-state checks | 165 passed |
| Fresh ordinary-speed complete browser journey | Passed, approximately 22 minutes |
| Final illustrated browser fixture flow | See passing `screenshots/browser-results.json` |
| Physical Android / APK | Unavailable; no claim |

Native checks include all three realms at **320×640, 430×932 and 1280×800**:
48-pixel actions, initial fixed-viewport load, reachable scroll endpoints,
character composition, bounded details/rewards, distinct queue/mastery states,
accessible control names, saved reduced motion and visible save failure.

Browser checks exercise the exported WASM game in an isolated Edge profile.
They use real pointer and touch input, verify that dragging changes the bounded
content without choosing a method, and use keyboard activation to dismiss
details. Migration, committed/queued effects, mastery, preparation, Foundation,
resonance and a real twelve-second page absence/reload are observed through
the real IndexedDB save. No production-only test API or speed controls exist.

The full fresh ordinary run was recorded while the icon presentation was still
being finalized. It used no seeded resources or accelerated time. Final icon
controls were then re-exercised using explicit fixtures; advancing a trip’s
fixture progress to 119 seconds is test evidence, not ordinary-speed play.
`normal-*.png` captures show that earlier run and are not final-art screenshots.

The final browser report records a short requestAnimationFrame sample and its
renderer. This measures presentation timing on desktop Intel Iris Xe/ANGLE,
not sustained Android performance or a GPU capture. Browser errors must be
empty in the passing report.

The final release passed with **zero browser errors**. Its 430×932 desktop
emulation sample contained **181 frame intervals**, median **16.7 ms** and
p95 **16.9 ms**, using Intel Iris Xe through ANGLE/Direct3D11. The packaged
game content is approximately **5.70 MB**; the uncompressed engine WASM is
approximately **39.51 MB**.

## Final rendered screenshots

- [430×932: techniques and mastery](screenshots/browser-430x932-methods.png)
- [430×932: active forest route](screenshots/browser-430x932-forest-active.png)
- [320×640: compact technique controls](screenshots/browser-320x640-methods.png)
- [320×640: active forest route](screenshots/browser-320x640-forest-active.png)
- [1280×800: desktop composition](screenshots/browser-1280x800-methods.png)
- [Current and queued method frames](screenshots/browser-queued-method.png)
- [Mastery pip and numerical effect](screenshots/browser-mastery.png)
- [Prepared Foundation seal and costs](screenshots/browser-foundation-prepared.png)
- [Illustrated offline rewards](screenshots/browser-offline-rewards.png)
- [Icons at real 32/48/64-pixel sizes](screenshots/icon-set-runtime-sizes.png)
- [Final browser results](screenshots/browser-results.json)
- [Ordinary-speed results](screenshots/normal-browser-results.json)

The pre-integration style sample is retained separately as process evidence.
It was followed by refinements to grounding, alpha/size normalization, icon
contrast, garment masses, compact headings and actual initial-layout behavior.
The small icon review led to stronger herb leaves and a simplified Meridian
symbol rather than another complete screen regeneration.

## Pacing and remaining limitations

All fresh simulated routes use the same opening: first purchase at 25 seconds,
Qi Refining at **7:06**. Cultivation-first reaches Foundation at **25:06**,
gathering/preparation-first at **17:06**, and mastery-first at **25:06**.
The simplest tested Iron/preparation route reaches it at **15:06**. In a
representative migrated Qi Refining state those times are 18:00, 10:00, 18:00
and 8:00 respectively. These are specified-policy comparisons, not global
optimization or proof of balance. See the pacing report for spending,
production, controls and proposals kept separate from implementation.

Azure mastery is practically unattractive for the immediate advancement goal
when herbs bind and surplus Qi has no later spending use in this milestone.
The implementation intentionally stops at Foundation for that review.

Artwork remains generated and stylized. The face is idealized; some source
alpha edges retain fine fringing and small wash marks. Runtime-size review
found no conspicuous colored halo on ivory, but it is not a guarantee of perfect
illustration. Human repainting could improve individual character and mark
quality. Small paired resource motifs do not replace readable labels/numbers.

At 320×640, mastery and preparation require bounded scrolling; targets and
fonts were not shrunk to force every action into one screenshot. Engine
accessibility names and focus states are present, but assistive-technology
and physical-device verification remain unperformed. Android Java/SDK paths
and a physical Android device are unavailable. The Game Development Studio
CLI is unavailable; no receipt from its validation workflow is claimed.

Use one active tab per save. Browser filesystem sync remains asynchronous,
and offline progress accounting does not add a new installable PWA cache.
Review gameplay and visuals before expanding the project.
