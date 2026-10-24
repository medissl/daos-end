# Interaction review: a living ink world with less administration

Reviewed 2026-10-24. This is a design review and implementation brief, not a runtime update. The user's latest correction is decisive: reduce routine clicking and reading, make actions visibly connected, and retain the ink theme without a dated or static presentation.

## Evidence from the current build

Reviewed the live localhost build at 390×844 using its existing Foundation save: dismissed the offline summary, observed the Stone Gate Guardian fight, requested camp, visited Build and Cultivate. Captured battle and Build in `evidence/`. This was a short expert walkthrough, not a fresh progression run, listening review, physical Android test, or human usability study. Existing progression was not reset or replaced. There is no local Git metadata.

- Battle has a recognizable illustrated setting, but the character remains seated opposite a guardian while HP bars, focus and short text carry most of the action. At this phone size a substantial blank area separates the readouts from the bottom controls.
- Build displays separate Improve controls, Equip, Discover techniques and Technique details, besides destination navigation. Their pale rectangular treatment gives actions similar prominence. Selected Build navigation is unusually pale against the landscape in the captured frame.
- The offline modal repeats implementation-like information: retreat percentage, wall-time cap and journey status. Those policies are useful details, but the return experience should lead with earned rewards and the current objective.
- Source corroborates the static feeling: `landscape.gd` draws one cultivator texture with a `sin(breath) * .6` translation. Realm changes add arcs, a chest light and a pendant rather than a changed character pose/outfit. `main.gd` redraws decorative motion on a 0.1-second cadence. `chapter_ui.gd::show_section` immediately changes visibility; there is no transition in that path.
- Important qualification: ordinary journey nodes already advance automatically. `cultivation_state.gd` pauses for discoveries, requested camp, and intermediate trial stages. The next update should remove unnecessary discovery/result administration without claiming that every existing node requires Continue.

The prior delivery's tap reduction and regression checks are useful evidence of a narrower task. They do not establish satisfying play or finished presentation. Its own chapter pacing report records 34 scripted decisions, about 16.8 minutes of combat waiting and another 28.3 minutes of retreat waiting. It also identifies a broadly dominant Ward/Flame build. A larger content catalog on this foundation would repeat the same weakness.

## What research supports

Research on game motivation treats perceived competence and autonomy as important contributors to engagement; mastering awkward controls is a prerequisite that can impede access to those experiences. This is a motivational framework, not proof that our proposed mechanics will retain players. Design implication: make the player understand and influence an outcome, then show the result clearly. [Przybylski, Rigby and Ryan, original paper](https://selfdeterminationtheory.org/SDT/documents/2010_PrzybylskiRigbyRyan_ROGP.pdf)

Progressive disclosure separates common tasks from less frequent specialized information. Applied here, one useful technique summary can lead to one consolidated detail sheet; hiding every cost or effect behind another tap would undermine the purpose. [NN/g: Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)

Interface motion is useful when it communicates feedback, navigation and state changes. Motion also draws attention, so constant animated controls can distract. Applied here, short contextual transitions should explain continuity, while environmental and character motion supply the game's atmosphere. They have different jobs. [NN/g: The Role of Animation and Motion in UX](https://www.nngroup.com/articles/animation-purpose-ux/)

The user's supplied illustrated cultivation references remain composition references: prominent character, atmospheric landscape, readable progression. Their crowded icon strips and monetization affordances are not requirements. The ink identity itself does not require primitive interaction or dated animation. [Onmyoji's official character presentation](https://en.onmyojigame.com/shikigami/) is a reference for character identity only; it is neither Chinese cultivation lore nor a source of reusable assets.

Additional comparable-game and production research lives alongside this review. Those notes distinguish publisher descriptions, source inspection and original design proposals from hands-on observations.

## Replacement interaction contract

1. **Choose a goal, then see it happen.** A route or illustrated trial tile shows its main reward and hazard directly. Select to inspect; one clear Depart action commits. Returning to an unchanged authorized task resumes it directly.
2. **Routine rewards settle automatically.** Currency, ordinary loot and learning a technique do not demand a Claim button or stop the journey. A concise discovery strip remains available in the collection. Stop only at an actual branch, requested camp, defeat or route end.
3. **Preserve intentional choices.** Never spend currency, consume preparation, overwrite a full loadout, choose a new frontier route or reincarnate automatically without an explicit policy/commitment. Optional convenience must not silently change a player's build.
4. **Manage an object in one place.** Selecting a technique/item opens one sheet containing its effect, current slot, replacement target, upgrade cost and relevant actions. Remove separate global Details/Discover/Improve destinations when they duplicate this sheet. Keep exact purchase effects visible before spending.
5. **Automate solved work.** Mastered-route supply assignment is finite and explicitly selected. It is background resource support, not an endless cycle of mandatory repeat/claim clicks or a source of autonomous first clears.
6. **Use motion as continuity.** Press response, panel movement, route departure, approach to a guardian, readable attacks, reward settlement and return should look related. Avoid a black screen or a full-screen ink wipe for every tap.
7. **Show the fantasy.** Character pose/garment motion, guardian anticipation and response, location ambience and persistent realm treatments must be visible in runtime. A moving effect icon across two stationary PNGs is not the finished combat presentation.

The suggested action and copy budgets in the implementation prompt are review targets, not published scientific ratios. Check comprehension and complete tasks on actual rendered screens. Do not shrink touch targets or truncate decision-critical text to meet a number.
