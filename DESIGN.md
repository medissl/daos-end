# Dao's End — product and art direction

Design draft: 2026-10-23, Asia/Jakarta. Read this together with the global `~/.codex/DESIGN.md`. This file supplies this game's direction; the global file supplies the design process.

## Status and authority

User-established requirements: Godot 4/GDScript; Android and browser; portrait-first; illustrated 2D Chinese ink-wash cultivation fantasy; satisfying incremental growth; useful offline cultivation with reduced growth; illustrated gameplay rather than a text RPG; generated artwork, icons and usable interface art are allowed; a long-term target of **300 hours of active play**.

The active-hour interpretation was explicitly confirmed by the user. It does not mean account age, a 300-hour timer, or leaving a tab open. The duration is an ambition requiring content production and human playtests, not a verified property of this prototype.

Current implementation (2026-10-24): Living Dao extends the tutorial and Jade Road through Nascent Soul. Five regions contain twelve routes (48 encounters); seven combat arts, fifteen equipment pieces, three reversible laws, three optional departure preparations, six new inheritances and the three-stage Soul tribulation are implemented. Nascent Soul earns a fourth ordered art slot, distinct persistent garment/pose and a chapter ending. Save schema four retains frozen version-one/two/three migration. Continuous discoveries, whole-build presets and finite exclusive 30% supply assignments remove repeated administration. Presentation uses aligned character cels/cloth pieces, separate place layers, event-driven effects and interruptible 180 ms navigation. Evidence and remaining gates are in `docs/living-dao/DELIVERY.md`; older delivery records remain historical. There is no local Git metadata. Physical Android, human novice testing and subjective audio listening remain unverified.

Systems beyond Nascent Soul in `docs/design/CONTENT_300H_BLUEPRINT.md`, including reincarnation, remain proposed design. The implemented boundary is the user's `CODEX_MAJOR_UPDATE_PROMPT.md` (Living Dao). The fixed Foundation-to-Golden policy now takes 17.6 minutes of combat watching with no funding-only wait, compared with the historical 45.15-minute result. These automated seconds do not establish active enjoyment or session length; see `docs/living-dao/PACING.md`. All options belong in Menu; keep settings controls out of gameplay.

## Experience

The player grows from an inexperienced mortal into an immortal whose chosen methods visibly change what they can accomplish. They prepare a build, undertake a finite illustrated journey, discover a useful relationship or treasure, improve cultivation, and face a new kind of barrier. Reincarnation later preserves understanding and changes the next life's approach.

Progression must offer both anticipation and agency: useful purchases, recognizable build strengths, rare but nonessential discoveries, qualitative realm unlocks, and visible transformations. A larger number without a new decision is insufficient as the only long-term reward.

The first session explains itself through play and concise labels. Later sessions support exploration and experiments with techniques, artifacts and route hazards. Solved work becomes easier to automate. The game must not require repeated tapping, a mandatory daily checklist, lore quizzes, pop-up conversations, or reading a scrolling log to understand its state.

## Art-direction hypothesis

**An illustrated mountain retreat with cultivation objects the player can operate:** a methods scroll, a journey painting, jade-and-ink instruments and a meditating cultivator who changes across major achievements.

Use Chinese line-and-wash fantasy with deliberate contours and broad mineral washes. Foreground marks explain materials and form; distant mountains and mist simplify. The character has a recognizable original face, silhouette and practical outfit. The direction can be richer than historical monochrome literati painting while retaining controlled ink density and quiet space. It is not a requirement to imitate one historical school.

Palette: warm paper, charcoal, mineral jade, blue-grey and sparse cinnabar. Use deeper jade/ink for important actions and cinnabar for occasional achievement or selected-state accents. No endless gold filigree, glossy airbrushed skin, rainbow rarity blocks, synthetic speckling, ornamental clutter or generic fantasy lighting.

Our supplied reference screenshots inform character prominence and scenic composition. Research informs brushwork and interaction. No reference's proprietary art, exact composition, fictional characters or text is a production asset.

## Generate usable art, not screenshots of interfaces

Generated artwork is an authorized production tool. Use it for appropriate isolated assets: scenery, cultivator, guardians, item and technique icons, decorative UI skins, scroll edges, plaques, sockets, meter caps, seal overlays and effects. Follow applicable image-generation skills and inspect the output. Generation is not an exemption from art direction or quality review.

The user also authorizes downloading suitable artwork and audio from the internet. Verify each asset's license, record source/provenance and include required credits. Prefer free compatible sources; paid purchases are not implicit. Downloading a suitable asset is normal production work and does not require repeated permission.

Produce a reusable small kit before scaling the catalog:

| Material/object | Usage | Construction |
|---|---|---|
| Scholar's scroll | Grouped technique comparison or focused reading | Quiet interior; separately preserved edge/corner art; no frame around every sentence |
| Ink/jade plaque | Important action or purchase | Blank center for live label/cost; aligned normal/pressed/focus/unavailable states |
| Cultivation instrument | Resource/advancement progress | Separate track, clipped fill and endpoint ornaments; actual state drives fill |
| Cinnabar/jade seals | Selected, queued, mastered or prepared state | Small overlays with shape and concise text where necessary |
| Travel painting | A region, route or encounter | Vignette plus native route markers, reward counters and actions |
| Reward tray | Compact return/discovery summary | Real item icons, names and quantities; no baked text |

Use texture-based nine-slice controls only with defined slice margins, minimum size, content padding and permitted scaling. Keep spindles, knots and distinctive corners out of stretched centers. Decorative hit regions may be conventional rectangles; visual irregularity must not make controls hard to touch. Godot controls own text, quantities, prices, interaction and accessibility metadata.

Do not add a texture to every old rectangle and call the interface finished. Some readouts need no enclosure; some grouped reading needs a protected paper surface. Give readouts, choices and actions visibly different roles. Keep native dialogs in the same material/typography language.

The detailed manifest, generation workflow and runtime checks live in `docs/design/ART_ASSET_PRODUCTION_GUIDE.md`. Keep editable/full-resolution sources separate from runtime imports and record provenance/import dimensions. Do not leave required assets only in a temporary or generator directory.

## Icon, words and numbers

No universal text/icon percentage is specified. The reviewed research does not establish one. Use illustration for atmosphere, icons for recognition, words for intent, and numbers for decisions.

- Resource: stable symbol + quantity + short resource name where useful.
- Technique: distinctive emblem, name, current effect, mastery and clear selected/queued state.
- Purchase: exact cost and concise outcome before commitment; distinct from Equip and Details.
- Journey: place image, route/hazard identity, expected reward, progress and explicit action.
- Breakthrough: target, requirements, preparation and the capability gained.
- Navigation: short visible labels; no mystery icon strip.

Long formulas and optional flavor belong in tap/focus detail views. Keep decision-critical facts available without opening several dialogs. Familiar technical symbols may be icon-only if their purpose is unambiguous and accessible names remain present. A separate screen-reader name does not make an unfamiliar visible symbol understandable.

At 32–64 logical pixels, icons need recognizable silhouettes and selective detail. Several pale Qi-like curls currently resemble each other; keep good assets and simplify ambiguous ones in context. Do not use unrelated emoji or generic web icons alongside illustrated game assets.

## Composition and interaction

The UX reset supersedes the earlier fixed four-destination shell. Cultivate
keeps the scenic seated character; Explore uses a region/route composition;
battle keeps the actual encounter scene; Build uses a compact header and a
desktop comparison column. Depart and Continue live outside optional detail
scrolling. Known arts equip into an empty slot directly, or name the replacement
target. Improvement and refinement show exact costs in separate contexts.
Owned/equipped equipment is the default; acquisition sources live in Discover.
Camp navigation preserves the journey. Ending a journey is an explicit action.

Phone: protect the cultivator and landscape as the emotional focal point, while keeping the current objective and useful actions discoverable. Scene prominence is not an inflexible height percentage. Compact layouts and a deliberate drawer are preferable to clipping important method controls below oversized illustrations.

Desktop: compose the scene and an intentional methods/travel instrument together. Avoid an immense empty illustration beside an unrelated white spreadsheet panel. Narrow and wide layouts must share materials and interaction hierarchy without simply stretching one another.

Every control has pressed, focused, unavailable and selected states as relevant. Decorative art ignores input. Whole controls remain comfortably touchable; target at least 48 logical pixels and verify scaling on real devices when available. Do not make color the only state cue. Essential explanations work on touch and keyboard, not only hover.

Motion explains results: deliberate purchase response, readable encounter action, resource collection, a short breakthrough sequence and persistent realm effects. Keep timing responsive, effects cheap, and reduced motion usable. **Music, ambience and SFX are explicitly requested for the next content slice.** Follow `docs/design/AUDIO_PRODUCTION_GUIDE.md`: a coherent small mix, separate persisted controls, browser interaction unlock and actual listening checks. Quiet wind/water/cloth/wood and restrained instrumental colors fit the direction. Never signal every idle resource tick.

## Visible realm identity

| Realm | Persistent visual intention |
|---|---|
| Mortal | Modest robe, grounded body, still platform; minimal supernatural effects |
| Qi Refining | Small inward-flowing Qi strokes and a changed badge |
| Foundation | A stable thin aura and grounded platform seal |
| Golden Core | A localized core light and a deliberate robe/ornament upgrade |
| Nascent Soul | One restrained spirit-double motif or spirit silhouette |
| Soul Formation | A deeper sanctuary atmosphere and formation structure |
| Void Refinement | Carefully limited space/mist distortion with a static reduced-motion equivalent |
| Mahayana | A transformed sanctuary composition and major character illustration variant |
| Ascension | A new environment/pose and memorable sequence earned by the final trial |

These are proposed visual requirements for future implemented realms. Generate a new full character only at meaningful transformations; reuse identity and separate effects elsewhere. Show no future realm treatment as if already unlocked.

## Quality and implementation practice

Preserve the existing state/session/persistence separation. Build connected vertical slices, not all menus first. Keep configurable definitions and stable save IDs, introduce explicit migrations, and use isolated test saves. Do not erase progress to tune balance or stage screenshots.

Run existing appropriate tests, deterministic balance simulations, ordinary-speed samples and actual browser input/render checks. Design and inspect phones first: 320×640, the default 390×844, then 430×932; check 1280×800 afterward. Verify actual finger swipes and purchase cancellation as well as taps. Keep phone navigation below the bounded action scroll, independently sized selection/purchase targets and a complete main frame with text safely inset. Include initial load, long values, selected/queued methods, unaffordable purchases, journeys, rewards and advancement. Keep performance-conscious texture sizes and modest concurrent effects.

Before accepting a visual pass, compare the rendered game with its approved internal style sample and supplied direction. Inspect art construction, silhouettes, UI material fit, typography, readable effects, touch behavior and whether the main action is apparent. A test count, an asset count or a successful export is not visual acceptance.

Phone verification must include a mobile browser at DPR 3, other density contexts and live viewport resizing. Assert actual reported density; requested CDP overrides can be restored by screenshot capture. A narrow desktop viewport alone previously hid a physical-versus-logical-pixel scaling defect. Use logical dimensions for layout and retain high-density rendering; verify actual touch coordinates after scaling.

Before claiming content length, observe players and distinguish engaged activity, foreground waiting, offline elapsed time and repeated solved content. Do not manufacture 300 hours with long gates, low drop rates or compulsory micromanagement. Report the measured result and extend with new decisions when the game is too short.

## Research index

- `docs/design/CULTIVATION_FICTION_PATTERNS.md`: licensed fiction observations and original adaptations.
- `docs/design/LONGFORM_INCREMENTAL_RESEARCH.md`: connected systems, automation, prestige and active/offline evidence limits.
- `docs/design/ICON_TEXT_BALANCE_RESEARCH.md`: icon/label guidance and comprehension checks.
- `docs/design/ART_ASSET_PRODUCTION_GUIDE.md`: actual asset families, generation and Godot skin construction.
- `docs/design/AUDIO_PRODUCTION_GUIDE.md`: authorized downloads, licensing, music/ambience/SFX, mixing and browser verification.

Research is inspiration and evidence, not proof that the proposed game is balanced or that the authors' stories are game specifications.

## Next requested update: The Living Dao

The user has rejected the remaining static presentation and administrative clicking after the UX reset. The proposed next implementation boundary is `docs/design/major-update/CODEX_MAJOR_UPDATE_PROMPT.md`, supported by the interaction review and primary-source progression/motion research in that directory. It combines routine-action removal, explicit mastered supply assignment, real character/environment animation and realm treatments, and a Golden Core–Nascent Soul chapter with three regions, six routes, six inheritance challenges and connected build tools. These are **not implemented or verified** by writing the brief. Existing ordinary-node auto-advance and automatic reward credit must be preserved. The new supply policy intentionally revises the earlier no-repeat rule only after explicit player assignment and requires economy/save verification. Long-term reincarnation and the 300-active-hour goal remain outside this bounded update. Release readiness requires the brief's separate functional, visual, motion, audio, performance and usability evidence.
