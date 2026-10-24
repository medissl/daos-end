# Gameplay and art review — October 23, 2026

## Scope and evidence

The user asked whether the current game is all the intended experience, requested research into idle cultivation games, and asked how to reduce the generated appearance of the artwork. This note records a design assessment, not implementation authorization or acceptance of the current art.

Inspected `scripts/progression.gd`, `scripts/cultivation_state.gd`, `tests/simulate_pacing.gd`, the preserved pacing log, the visual delivery note, art provenance, landscape composition code, and the saved 430 x 932 after screenshot. No live browser session or new test run was performed for this review. The delivery's 73 gameplay/save and 48 UI checks remain reported results, not independently rerun evidence. Android is unverified.

Companion primary-source research is saved in `docs/design/IDLE_CULTIVATION_RESEARCH.md`. Its descriptions and code inspection are not playtests or proof of commercial games' pacing or enjoyment.

## Current gameplay assessment

- The implementation contains one spendable resource, two production improvements, one breakthrough-cost improvement, two realms, and one breakthrough.
- Four Deep Breathing purchases, two Meridian Circulation purchases and one Settle the Mind purchase produce seven upgrade purchases total. There is no active tapping mechanic.
- Base production begins at 1 Qi/s. Maximum Mortal production is 7.5 Qi/s; Qi Refining doubles it to 15 Qi/s. Upgrades are retained.
- The saved simulation reaches the first purchase at 25 seconds and breakthrough at approximately 12 minutes with its documented purchase sequence. This is not claimed to be globally optimal or human playtest evidence. No-purchase advancement takes 4,000 seconds.
- Settle the Mind costs 200 and reduces the requirement by 1,000, producing an 800-Qi net advantage when used for this one advancement. Timing remains a decision, but there is no alternative specialization or opportunity that makes foregoing it an enduring strategy.
- After all purchases and the one breakthrough, more Qi has no implemented use. Offline progress works toward the same capped objectives; it does not create new objectives.

The milestone was deliberately constrained. It can establish resource accounting, persistence and basic input behavior. It does not establish a satisfying long-term incremental loop. A longer list of realms with the same purchases would extend the waiting without resolving the lack of changing decisions.

## Proposed next gameplay question

Can the player choose between improving immediate cultivation and pursuing a different route that improves later progress, with both approaches useful under understandable conditions?

Proposed bounded experiment, not approved balance or implementation requirements:

1. Keep the current cultivation and persistence foundation.
2. Add one repeatable Bamboo Forest expedition with a clear guaranteed base reward, a visible duration, and a resource that has two competing useful uses.
3. Add two genuinely different selectable techniques: one favors Qi production and one favors expedition performance. Define what performance actually affects before implementation; a new percentage with no practical consequence is insufficient.
4. Let materials improve a technique or support the next advancement. Show requirements and outcomes before commitment. Essential progress must not depend on a rare roll.
5. Make the next realm unlock a choice or capability. Do not fill five realms by copying the same cost curve.

Decide whether cultivation and expeditions run concurrently, what the expedition tradeoff is, whether technique switching is exploitable, resource yields, costs, and offline resolution before issuing an implementation prompt. Avoid a stance system that rewards continual switching or watching short timers.

Acceptance should include two useful player strategies, a clear explanation for each choice, a rewarding short return session, and a concrete next goal after advancement. Simulate spending and resource bottlenecks, then play at normal speed. Do not add prestige, full inventories, alchemy, pets or many expedition locations until this small interaction is enjoyable. Reincarnation reset rules remain undefined and must be specified separately.

## Art assessment

The inspected screenshot is materially more illustrated than the original polygon version. It still reads as generated fantasy artwork to this reviewer. That is a subjective visual judgment, not a reliable authorship detector or a claim that an anatomical error has been demonstrated.

Contributors to that impression in this image include dense short marks and mottled shading on robe and platform, a conventional centered novice design, and a strongly outlined dark character/platform against pale scenery. The independent asset does not yet feel fully grounded in one painting. Native UI is readable, but the lower half remains a large practice form; visual changes have not created additional gameplay.

Recommended production approach after proving the next loop:

- Establish one original character model sheet and a small visual vocabulary for outlines, brush marks, garment construction, value groups and accents.
- Simplify robe shading into a few intentional masses; use texture to explain a fold or material instead of spreading speckling over every surface.
- Match character, platform and environment in perspective, ink density and contact treatment. Keep most distant scenery quiet.
- Use generation as a source of candidate compositions or individual assets. Inspect and selectively repaint the focal asset rather than regenerating the whole screen repeatedly. Neither a longer prompt nor an approval from an automated critic guarantees a convincing result.
- If human illustration work becomes practical, prioritize the one continuously visible cultivator. A coherent simpler illustration can be a better fit than a more elaborate generated one.

Ink painting offers many styles; sparse treatment is a project choice, not a universal rule of authenticity. The [Nelson-Atkins discussion of brush and ink](https://www.nelson-atkins.org/art/exhibitions/expressions-of-brush-and-ink/) distinguishes outlines, texture marks, dots and washes and discusses expressive restraint. The [Asian Art Museum landscape overview](https://education.asianart.org/resources/the-development-of-landscape-painting-in-china-the-song-through-the-ming-dynasties/) discusses both expressive strokes and sparse pale-ink approaches. These support deliberate mark selection; they do not certify the current artwork or establish a test for AI generation.

## Recommended boundary

Freeze presentation temporarily at its current functional quality. Use the next design discussion to specify the small expedition/technique interaction, then prepare one focused implementation prompt. Revisit the central character artwork after the interaction has shown that players have worthwhile decisions and a reason to return.
