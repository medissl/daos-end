# Dao’s End: icon and text balance

Research date: 2026-10-23 (Asia/Jakarta). Scope: mobile/web cultivation incremental UI. This is source research and proposed design guidance, not a usability-test result or implementation verification.

## Finding

**Do not prescribe a universal text-to-icon percentage.** None of the reviewed primary sources establishes one, nor a ratio that makes a game feel “premium.” Counts and screen-area percentages ignore whether players understand a symbol, can compare purchases, or can operate a control. Premium appearance remains a design judgment involving hierarchy, consistency, spacing, illustration, typography, and restraint.

## What the sources support

- Most icons have ambiguous meanings. NN/g recommends visible text alongside icons, especially navigation; hover-only labels increase interaction cost and do not work well on touchscreens. A familiar object is not necessarily a familiar action. [NN/g: Icon Usability](https://www.nngroup.com/articles/icon-usability/)
- Test recognition (“what object is this?”) separately from interpretation (“what will this do here?”). Evaluate icons in context for findability and successful tapping, as well as appearance. [NN/g: evaluating digital icons](https://www.nngroup.com/articles/how-to-test-digital-icons/)
- Progressive disclosure places frequently needed choices up front and advanced or rarely needed information behind an obvious secondary control. It does not justify hiding the information needed for the present task. [NN/g: Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
- Game UI text must remain readable; graphics and controls also need contrast against their backgrounds. These requirements still apply to decorative fantasy interfaces. [Xbox XAG 101: Text display](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101), [XAG 102: Contrast](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102)
- Color should reinforce another cue such as text, shape, pattern, or a symbol, rather than carry essential information alone. [Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/)
- Android recommends touch areas of at least 48 × 48 dp, which can surround smaller artwork. Descriptions should identify purpose rather than merely describe appearance. [Android: Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps)
- Functional images and controls need meaningful text alternatives. Narration needs the name, role, value/state, and relevant interaction information; purely decorative imagery should not add noise. Visible labels and assistive-technology names solve related but different problems. [Xbox XAG 106: Screen narration](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/106)

## Proposed rules for this project

Use **illustration for atmosphere, icons for recognition, words for intent, numbers for decisions.** These are project recommendations derived from the principles above, not validated quantitative standards.

| UI element | Keep visible | Put in optional details |
|---|---|---|
| Qi / herbs | Matching icon, short resource name, quantity; Qi production with `/s` | Source breakdown and full calculation |
| Purchase | Icon/name, current level, exact cost, concise effect or before → after value | Formula, extended explanation, lore |
| Technique | Distinct illustration, name, mastery pips, selected state, concise mechanical tradeoff | Full interactions and flavor text |
| Expedition | Location illustration/name, remaining time, expected reward, short action label | Complete rules and outcome breakdown |
| Breakthrough | Realm target, requirements, preparation state, clear action | Detailed unlock explanation; repeat key consequence before spending |
| Navigation | Icon plus short label | Secondary help |
| Reward summary | Item icon, short name, quantity | Optional flavor text/history |

Practical constraints:

- Keep `Equip`, `Train`, `Prepare`, and `Explore` distinguishable. A scroll picture alone cannot reliably communicate which action spends resources.
- Retain names for unfamiliar cultivation concepts. Do not replace Qi, resonance, or preparation explanations with cryptic seals.
- Display compared effects using consistent units and precision. An arrow or pips can reinforce numeric change; neither substitutes for a decision-critical amount.
- Give each resource a stable silhouette wherever it appears. Avoid a new icon for every sentence, label, or repeated stat.
- Show states with shape/border/checkmark and short text where helpful. Jade/red tint alone is insufficient for selected, affordable, or unavailable states.
- Move lore and long formulas into clearly labeled tap/click details. Keep ordinary costs, outcomes, and tradeoffs available without opening several panels. No hover-only essential content.
- Make the full card or button a comfortable target. Android dp is not a Godot pixel guarantee: validate physical size after viewport scaling, and test touch separately from mouse input.
- Preserve functional accessibility metadata and verify platform behavior. Setting a tooltip or adding a visible label does not establish screen-reader compatibility.
- Keep ink texture away from small numerical readouts; reuse restrained frames and deliberate empty space. This is art direction, not a scientific ratio rule.

## Lightweight human comprehension check

With several first-time players, show the real narrow-screen build without coaching. Ask them to identify resources and production, select a technique, compare two purchases, start an expedition, and explain what a breakthrough costs. Observe hesitation, wrong predictions, accidental purchases, and missed controls. Ask what unfamiliar icons depict and what they do. Then check whether players find detailed explanations when needed. Repeat troublesome tasks after revision. This is formative feedback, not statistical proof or a claim that testing has already occurred. The recognition/interpretation distinction follows [NN/g’s icon-evaluation method](https://www.nngroup.com/articles/how-to-test-digital-icons/).

## Limits

These sources provide general interaction and accessibility guidance, not cultivation-game balance research or a premium-style formula. No universal-ratio study was identified in the reviewed material. Apple HIG content was not used because its direct Markdown retrieval failed. No proxy copies, player tests, artwork audit, or code changes were part of this research.
