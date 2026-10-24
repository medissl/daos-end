# Milestone two UI finish pass

## Task

Finish the interface of the existing Dao's End milestone-two build. The user explicitly finds its UI/UX unfinished, especially the white/cream box treatment applied to everything. Preserve the ink-wash identity and implemented gameplay. This is an interface composition, interaction and styling pass, not new content or an economy rebalance.

Read applicable AGENTS.md and the global DESIGN.md, inspect current source and rendered screens, then implement and verify the result. Do not stop after writing a plan. Preserve unrelated work and player saves. Do not push or deploy.

Read `docs/design/ICON_TEXT_BALANCE_RESEARCH.md` and `docs/art-direction/milestone-2/DELIVERY.md`. Open the final browser screenshots, especially methods at 430×932 and 320×640, forest-active at 430×932, and desktop at 1280×800. The planning review inspected these saved images and relevant `scripts/main.gd` source; it did not rerun the application or independently repeat the delivery's tests.

## Diagnosed problem

The interface gives almost every element a similar rectangular container. In `main.gd`, `_button()` uses a bordered StyleBox for flat buttons, which is reused for tabs, details, technique selection, effects, mastery, practice and secondary actions. A nearly opaque cream `hud_panel` contains the entire stack. This flattens visual hierarchy and makes the result resemble a form pasted over illustration.

Technique identity, selected state, mastery pips, numerical effect and training action are split across several stacked controls. A full-width current-method row repeats information already present on the method. The small-screen screenshot clips technique content before important actions are visible. Several small Qi/breath/advancement swirl motifs are also visually similar. Those observations are review hypotheses, not human usability-test results.

Do not solve this by changing the cream color, adding parchment noise, making every rectangle transparent, reducing text everywhere, replacing all labels with icons, or adding ornate frames. Restructure and assign distinct visual roles.

## Art direction and surface system

Aim for an illustrated cultivation interface integrated into a painted sanctuary. Keep the existing character, scenery and icon assets where useful; this pass must not become another full artwork regeneration cycle. Make targeted asset adjustments only when needed for icon recognition or the composition.

Establish these roles:

1. **Readouts:** realm, resource totals, production and ordinary status use typography, spacing and quiet local wash protection. Avoid enclosing every readout in a bordered rectangle. Maintain high contrast; never place small text directly over detailed scenery.
2. **Choices:** techniques use compact illustrated emblems or restrained talisman-like treatments. Group their own name, effect, mastery and action into a coherent unit. Reserve a deliberate ink frame/seal and concise state label for selected/queued states. Unselected items must still look operable. Their interaction area can be generous without being a large visible box.
3. **Actions:** reserve the strongest jade/ink treatment for a meaningful current action, such as departure or advancement. Secondary controls are quieter and clearly actionable. Passive information must not look like a large disabled button.

Use a restrained shared content wash where needed, with deliberate edges and spacing; do not make separate white panels for every subsection. Detail dialogs and reward summaries may use an opaque readable surface because they temporarily focus attention. A large enclosing surface should have a clear reason to exist.

Use consistent type scale, alignment, numerical units and spacing. Avoid enormous section headings, arbitrary ornaments, dense texture behind numbers, modern dashboard cards, and generic web form borders. Preserve purposeful negative space and the cultivator's visibility.

## Specific interface changes

- Replace the two boxed navigation buttons with clearly labeled Cultivate / Forest tabs, using a restrained underline, brush mark or seal for the active view. Preserve comfortable targets, focus and selected-state semantics.
- Make realm and resources a compact deliberate HUD. Keep resource icons, short names and numbers legible. Remove repeated framing, not essential information.
- Consolidate each technique's illustration, short name, current/queued state, pips, current effect and mastery action. Do not leave separate full-width rectangles for every fact. Keep Equip/Choose distinct from Train and Details so selecting a method cannot accidentally spend herbs.
- Remove the redundant full-width method-summary button where the same information is already visible. Expose the full current/next calculation through an obvious smaller detail affordance. Keep any pending-effect information needed for the current decision visible.
- Use a compact technique layout at 320×640 rather than blindly retaining two tall illustration cards and clipping their useful content. Show method identity, choice state and the immediate tradeoff before optional details. Keep exact prices and reachable controls; do not shrink fonts or touch targets to force a fit.
- Keep learned starter practices under one concise review control or a genuinely useful compact summary. Avoid a row of individually boxed icons plus another large button repeating the same completed count.
- Use the forest vignette as the activity's focus. Consolidate method, remaining time, expected reward and progress. Remove duplicate progress decoration where one clear indication serves the task. Clearly separate a passive Travelling status from actual Depart / Stop-after-trip actions. Use an understandable repeat toggle with both label and state.
- Make preparation a small persistent state near requirements. Keep its actual cost and the advancement cost distinguishable. Do not hide decision-critical information inside help.
- At Foundation, present completion/resonance as an attained state, rather than a permanently large grey disabled advancement button. Keep relevant information available and avoid inventing a future realm.
- Simplify offline rewards into readable resource rows with icon, short label and amount. Avoid unlabeled arbitrary symbols. Preserve an obvious dismissal action and bounded mobile layout.

## Icon/text rules

No universal percentage is a requirement. The reviewed sources establish no premium text-to-icon ratio. Use illustration for atmosphere, icons for recognition, words for intent, and numbers for decisions. These are project design rules, not a claim of scientific optimality.

Retain short labels for navigation, unfamiliar methods and actions. Keep costs and concise outcomes visible before spending. Put longer formulas, lore and rare explanations in accessible detail views. Do not force players to open several dialogs to compare two choices. Icon-only controls are suitable only when the meaning is reliably familiar in context and functional accessibility names are retained.

Do not add a new icon for every line of copy. Keep resource symbols consistent. Review ambiguous small swirl icons at actual runtime size and simplify silhouettes or distinguish them where necessary. A color change alone does not establish a different meaning. Preserve selected/queued/disabled states with additional shape/text cues.

## Verification and completion

Preserve all production, purchase, expedition, queue, commitment, preparation, resonance, save-schema and offline rules. Do not fix the documented balance concern by silently changing numbers during this pass.

Run relevant existing gameplay/save checks and update presentation checks for the intended new layout while preserving behavior assertions. Verify real pointer, touch-style scrolling and keyboard focus. Check that dragging does not select a method or spend resources.

Render and inspect actual browser output at 320×640, 430×932 and 1280×800, including Mortal, unlocked methods, queued choice, running forest, preparation, Foundation, details and rewards. Validate initial load, resizing, long costs, unavailable purchases and visible focus. Maintain at least 48-logical-pixel action targets, while recognizing that physical Android sizing is still unverified.

Review whether current action, resources and method tradeoffs are evident without reading a paragraph. Check that the main screen no longer gives readouts, tabs, choices and actions the same enclosing box treatment. Preserve contrast and meaningful boundaries; fewer rectangles alone is not the acceptance test.

Capture before/after screenshots with comparable states, refine the highest-impact problems, then deliver working build instructions, screenshots, checks actually run and limitations. Do not claim a human comprehension test or Android-device result unless performed. Keep the existing balance concern documented for a separate gameplay review. Stop after this interface finish pass.

## Sources for the guidance

The research note links original sources and distinguishes evidence from this project's art direction. Key references: [NN/g Icon Usability](https://www.nngroup.com/articles/icon-usability/), [Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/), and [Xbox contrast guidance](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/102). None certifies this visual design or supplies a premium ratio.
