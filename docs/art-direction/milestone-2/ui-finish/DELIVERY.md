# Milestone two interface finish

October 23, 2026. This pass changes native Godot presentation and interactions.
The gameplay, economy, save schema, migration and offline accounting remain
unchanged. No content, push or deployment was added.

## Composition

- One shared reading surface protects small type from the sanctuary painting.
  Its open edge and top rule replace the old enclosing frame. Readouts have
  typographic hierarchy; Cultivate and Forest use labeled, focusable tabs
  with selected-state semantics and an underline.
- Methods are coherent emblem units: name, effect, choice state, two mastery
  pips and an independently operable training action. Selected/queued units
  carry a side mark, with a top rule for the queue, and explicit state text.
  Ordinary choices have no enclosing box. Equip never spends herbs.
- At 320×640, equip and training sit side by side in short rows. Both method
  identities, effects, states and exact training prices remain visible,
  including the current/next bonus strip during a queued trip. Details and
  starter practice review are reachable below, in the bounded scrolling area.
  Wider screens use larger emblems and individual detail links.
- A small Effects link replaces the duplicate full-width primary summary.
  It explains current/next calculations and both mastery progressions.
  Starter practices have one review control, retaining the actual purchases.
- The forest illustration, route marker and remaining-time/reward readout
  carry the activity. The second progress bar is gone. Travelling is passive
  text; departure is an action. Repeat explicitly names its state and offers
  Stop after trip while repeating.
- Preparation sits beside advancement in both views. Its **12 extra herbs**
  and resulting **7,000 Qi** requirement are separate from the advancement
  requirement of **12 herbs**. A persistent prepared readout replaces the
  preparation action after purchase.
- Foundation uses a small attained/resonance readout, replacing the permanent
  disabled advancement button. Rewards have icon, resource name and amount.
  Readable modal surfaces and an obvious Return action remain.

The existing illustration layers and ink icons were retained. At runtime size,
the small Qi/breath/advancement wisps overlapped in meaning. Advancement now
uses the destination realm's lotus silhouette, with explicit Qi/herb cost
labels; the extra tiny Qi wisp on the action was removed. No new art cycle,
parchment noise, corner branding or flattened interface image was introduced.

## Comparable browser captures

Each side is an actual exported WASM game in an isolated Edge profile at the
named viewport. The same fixture recipe supplies both builds: Mortal with
124 Qi and one breathing level; Qi Refining with 9,000 Qi, 24 herbs and capped
starter practices; an Iron trip at 42 seconds with Azure queued and repeat
off; prepared Azure mastery one with 12 herbs; Foundation Azure mastery one
with 2,400 Qi and eight herbs. Rewards use a real wall-clock timestamp 120
seconds earlier. Counters continue normally during loading and capture, so
Qi and remaining seconds vary slightly between images. No clock acceleration
or production test API is present.

| Viewport | Methods | Running forest | Queued | Prepared | Foundation | Mortal | Details | Rewards |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 320×640 | [Before](before/320x640-methods.png) / [After](after/320x640-methods.png) | [Before](before/320x640-forest.png) / [After](after/320x640-forest.png) | [Before](before/320x640-queued.png) / [After](after/320x640-queued.png) | [Before](before/320x640-prepared.png) / [After](after/320x640-prepared.png) | [Before](before/320x640-foundation.png) / [After](after/320x640-foundation.png) | [Before](before/320x640-mortal.png) / [After](after/320x640-mortal.png) | [Before](before/320x640-details.png) / [After](after/320x640-details.png) | [Before](before/320x640-rewards.png) / [After](after/320x640-rewards.png) |
| 430×932 | [Before](before/430x932-methods.png) / [After](after/430x932-methods.png) | [Before](before/430x932-forest.png) / [After](after/430x932-forest.png) | [Before](before/430x932-queued.png) / [After](after/430x932-queued.png) | [Before](before/430x932-prepared.png) / [After](after/430x932-prepared.png) | [Before](before/430x932-foundation.png) / [After](after/430x932-foundation.png) | [Before](before/430x932-mortal.png) / [After](after/430x932-mortal.png) | [Before](before/430x932-details.png) / [After](after/430x932-details.png) | [Before](before/430x932-rewards.png) / [After](after/430x932-rewards.png) |
| 1280×800 | [Before](before/1280x800-methods.png) / [After](after/1280x800-methods.png) | [Before](before/1280x800-forest.png) / [After](after/1280x800-forest.png) | [Before](before/1280x800-queued.png) / [After](after/1280x800-queued.png) | [Before](before/1280x800-prepared.png) / [After](after/1280x800-prepared.png) | [Before](before/1280x800-foundation.png) / [After](after/1280x800-foundation.png) | [Before](before/1280x800-mortal.png) / [After](after/1280x800-mortal.png) | [Before](before/1280x800-details.png) / [After](after/1280x800-details.png) | [Before](before/1280x800-rewards.png) / [After](after/1280x800-rewards.png) |

Quick comparisons: [320 methods](comparison-320x640-methods.png),
[430 methods](comparison-430x932-methods.png),
[desktop Foundation](comparison-1280x800-foundation.png),
[430 forest](comparison-430x932-forest.png),
[320 queue](comparison-320x640-queued.png).

The rendered review led to short method rows, a second narrower layout,
more compact queue spacing, a tighter desktop reading surface and a touch
propagation fix for the new native containers. Captures were repeated after
these refinements. The comparisons contain only screenshot assembly and
captions; they are not altered mockups.

## Verification

| Check | Result |
| --- | --- |
| Opening, save and session suite | 73 passed |
| Milestone-two rules, migration and offline suite | 96 passed |
| Native presentation/state suite | 221 passed |
| Browser fixture/input journey | [Final report](../screenshots/browser-results.json) |
| Matched before/after captures | [Before report](before/browser-results.json), [After report](after/browser-results.json) |
| Gameplay/save source preservation | [SHA-256 comparison](core-preservation.json) |
| Local release | [Current build checksums](../BUILD.json) |

Checks cover initial fixed-size load, resizing, minimum 48-logical-pixel
targets, reachable controls, full 10,000/7,000 Qi and herb costs, unaffordable
purchases, visible focus, bounded details/rewards, queue/primary distinction,
preparation in both views, passive travel, repeat and Foundation completion.
Browser input exercises actual pointer/touch selection, training, preparation,
advancement, real 12-second absence/reload and keyboard Return activation.
The compact Foundation view now fits; practice review is expanded before
testing actual overflow. Real touch dragging must move that content without
changing the method, mastery or herbs. Effects panels are opened at all three
sizes and must not equip or spend.

Only presentation code, presentation tests, local export and documentation
changed. Core hashes cover `progression.gd`, `cultivation_state.gd`,
`cultivation_session.gd` and `save_store.gd`. The original presentation and
geometry were checkpointed under `.verification/ui-finish-before/`; the
project has no Git repository. Player saves were not used or reset by tests.

Run locally with the README's Godot 4.7.2 instructions, or serve `builds/web/`
and open [the local game](http://127.0.0.1:8765/). The native UI test refreshes
geometry before the browser tests. `tests/browser_ui_finish.cjs --capture`
captures the current build; the sealed Before folder records the old export.

## Limits and boundary

This is desktop browser emulation, not a physical Android test, a screen-reader
audit or a first-time-player comprehension study. Small-screen practices,
secondary explanations and some forest actions still require bounded scrolling.
No 22-minute ordinary-speed replay was necessary for this interface-only pass;
the prior complete run remains separately documented and the unchanged rules
were retested. Artwork remains generated and stylized, without new repainting.

The existing Azure-mastery herb bottleneck and surplus-Qi concern remain in
[the pacing report](../../../design/MILESTONE_2_PACING.md). No balance changes
were made. Stop here for UI review before adding content or gameplay systems.
