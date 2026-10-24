# Dao's End — task-based UX reset

Implemented 2026-10-24 against `CODEX_UX_RESET_PROMPT.md` and the live audit.
The interface now uses **Cultivate / Explore / Build**, with Techniques and
Equipment inside Build. Scenery and the seated cultivator remain prominent at
home; route preparation, battle, camp and Build use their own compositions.
Desktop Build uses an inventory column and a persistent comparison column.

## What changed

- Depart and Continue remain above navigation, outside enemy/reward scrolling.
  Route preview leads with reward and a useful hazard/counter, with encounters
  available for optional inspection. Battle prioritizes HP, readiness, focus,
  one relevant threat and Camp; cues use real combat state.
- Camp presents exact rewards and the discovered art. Equip fills the empty
  slot for free; a full loadout names each replacement target. Improve is a
  separate context with mastery, exact price and before/after potency.
- Equipment starts with equipped names and owned items. Empty inventory has
  a direct Stone Steps path. Comparison, free Equip, refinement costs and the
  refinement purchase are distinct. Discover contains acquisition sources.
- One factual objective leads home. Core requirements remain secondary, with
  empty sockets versus completed seals. Build and Cultivate preserve camp;
  ending the journey is explicitly labeled. Queued changes say when they apply.
- Removed the universal ornate frame and nested reward tray from task screens.
  Quiet bounded reading surfaces, distinct secondary controls, native focus
  outlines and one cleaner generated jade plaque establish hierarchy. No text
  or interface is baked into artwork. Existing scene/icon/audio art is retained.
  Display-font oversampling is 2; functional labels remain Lato.
- A final desktop review caught navigation crossing dark rocks in the battle
  scene. Local paper protection fixes that contrast; the desktop task suite was
  rerun and its final captures replace the earlier desktop images in this gallery.
- Early realm locks are explained, and periodic refresh cannot restore
  cultivation advancement controls on Explore/Build. Settings stay in Menu.

## Actual tasks and measured comparison

Exported Godot Web ran in isolated Edge storage using real touch/keyboard input.
The core walkthrough starts from the same Foundation-entry save, with no gear
or chapter history, completes the actual first Stone Steps encounter, requests
camp, equips Flame for free, visits Build, returns to camp and continues into
the second real encounter. No accelerated clock or game-state API was used.
Additional camp/developed/early/Golden fixtures are labeled in the harness.
This is an implementing-agent walkthrough, **not a human novice study**.

Taps / explicit scroll gestures (the after run includes a two-tap Build detour):

| Viewport | Before | Direct after | After with Build detour | Observed run before / after |
|---|---:|---:|---:|---:|
| 320x640 | 9 / 4 | 5 / 0 | 7 / 0 | 48.2s / 35.8s |
| 390x844 | 9 / 4 | 5 / 0 | 7 / 0 | 30.7s / 29.5s |
| 430x932 | 9 / 4 | 5 / 0 | 7 / 0 | 31.5s / 29.1s |
| 1280x800 | 9 / 4 | 5 / 0 | 7 / 0 | 32.3s / 37.8s |

The five essential actions are goal → Depart → request Camp → Equip Flame →
Continue. The complete path needed no general Help or scrolling. The before
path required scrolling to reach Depart, the art controls and Continue.
Seconds include loading and harness waits; they are not a claim of faster
combat, human reading speed or changed game pacing.

The explicit replacement task retains the other slot and spends no herbs.
Owned comparison → free Equip → refinement context → purchase takes four taps.
The driver centers the lower item twice at 320/390/desktop and does not scroll
at 430; these are observed gestures, not a minimum-scroll usability measurement.
The desktop replacement is already visible in the unscrolled capture.
Refinement spends exactly 15 stones and the existing 2,500 Qi price. Prices,
mastery and effects remain visible in the decision context.

Ambiguities corrected: hidden slot mode, Clear versus remove, training versus
equip, an unowned catalog presented as inventory, below-fold route/camp actions,
ambiguous current/next readouts and a disabled Continue after completion.
Optional inventory/detail scrolling remains; it no longer gates route/camp tasks.

## Verification

- All four required viewports: **320×640, 390×844, 430×932, 1280×800**.
  Phones use mobile/touch DPR 3; additional actual task runs use DPR 2 and 2.625.
  Initial load, live viewport resizing, Menu keyboard Return and persisted mute
  settings were exercised. Fractional-density device-pixel captures are retained.
- Actual camp discovery equip keeps Sword, mastery and herbs unchanged.
  Camp → Build → camp and Cultivate → Explore preserve the paused journey
  and do not award rewards twice. Continue commits Sword/Flame to encounter two.
- A separate live 390px fight changes Ward/Flame to Ward/Sword while in combat:
  the active encounter keeps its frozen build; the next encounter commits the
  new one after the requested safe camp.
- A real touch drag beginning on Improve and ending off the button spends
  nothing. Explicit target replacement, separate free equipment equip and a
  separate refinement purchase were verified at each required size.
- Existing regressions: **73 core/save/offline + 96 milestone-two + 190 Jade Road
  + 15 audio assertions**, all passing. Audio verification covers signal/routing;
  no listening assessment is claimed. Export succeeds.
- Native UI bounds/text/48px-target and popup checks pass, including a focused
  post-refresh early-realm pass. Their logs supplement task evidence; a layout
  count is not a design acceptance statement.
- Nine protected rule/state/save/audio source files are byte-identical to the
  checkpoint; see [PRESERVATION.json](PRESERVATION.json). Existing art/audio files
  are unchanged. No save schema, reward, price, timer or combat rule changed.

Machine-readable evidence: [before](BEFORE_B| 320x640 | 9 / 4 | 5 / 0 | 7 / 0 | 48.2s / 35.8s |
| 390x844 | 9 / 4 | 5 / 0 | 7 / 0 | 30.7s / 29.5s |
| 430x932 | 9 / 4 | 5 / 0 | 7 / 0 | 31.5s / 29.1s |
| 1280x800 | 9 / 4 | 5 / 0 | 7 / 0 | 32.3s / 37.8s |ER_RESULTS.json),
[after](AFTER_B| 320x640 | 9 / 4 | 5 / 0 | 7 / 0 | 48.2s / 35.8s |
| 390x844 | 9 / 4 | 5 / 0 | 7 / 0 | 30.7s / 29.5s |
| 430x932 | 9 / 4 | 5 / 0 | 7 / 0 | 31.5s / 29.1s |
| 1280x800 | 9 / 4 | 5 / 0 | 7 / 0 | 32.3s / 37.8s |ER_RESULTS.json), [DPR 2](DENSITY-2_B| 320x640 | 9 / 4 | 5 / 0 | 7 / 0 | 48.2s / 35.8s |
| 390x844 | 9 / 4 | 5 / 0 | 7 / 0 | 30.7s / 29.5s |
| 430x932 | 9 / 4 | 5 / 0 | 7 / 0 | 31.5s / 29.1s |
| 1280x800 | 9 / 4 | 5 / 0 | 7 / 0 | 32.3s / 37.8s |ER_RESULTS.json),
[DPR 2.625](DENSITY-2.625_B| 320x640 | 9 / 4 | 5 / 0 | 7 / 0 | 48.2s / 35.8s |
| 390x844 | 9 / 4 | 5 / 0 | 7 / 0 | 30.7s / 29.5s |
| 430x932 | 9 / 4 | 5 / 0 | 7 / 0 | 31.5s / 29.1s |
| 1280x800 | 9 / 4 | 5 / 0 | 7 / 0 | 32.3s / 37.8s |ER_RESULTS.json), [logs](logs/ux-browser.log),
[final desktop pass](FINAL-DESKTOP_B| 320x640 | 9 / 4 | 5 / 0 | 7 / 0 | 48.2s / 35.8s |
| 390x844 | 9 / 4 | 5 / 0 | 7 / 0 | 30.7s / 29.5s |
| 430x932 | 9 / 4 | 5 / 0 | 7 / 0 | 31.5s / 29.1s |
| 1280x800 | 9 / 4 | 5 / 0 | 7 / 0 | 32.3s / 37.8s |ER_RESULTS.json),
[source diff against the checkpoint](SOURCE_DIFF.patch).

## Comparable rendered screenshots

[Open the comparison gallery](COMPARE.html). Each pair uses the same viewport
and scenario class; battle HP and accumulated Qi vary with capture timing.
Camp captures come from the real first encounter. Techniques comparisons use
the same isolated camp fixture; actual-flow captures also retain the subsequent
equipped state.

| View | 320×640 | 390×844 | 430×932 | 1280×800 |
|---|---|---|---|---|
| cultivate | [before](screenshots/before/320x640-cultivate.png) / [after](screenshots/after/320x640-cultivate.png) | [before](screenshots/before/390x844-cultivate.png) / [after](screenshots/after/390x844-cultivate.png) | [before](screenshots/before/430x932-cultivate.png) / [after](screenshots/after/430x932-cultivate.png) | [before](screenshots/before/1280x800-cultivate.png) / [after](screenshots/after/1280x800-cultivate.png) |
| preview | [before](screenshots/before/320x640-preview.png) / [after](screenshots/after/320x640-preview.png) | [before](screenshots/before/390x844-preview.png) / [after](screenshots/after/390x844-preview.png) | [before](screenshots/before/430x932-preview.png) / [after](screenshots/after/430x932-preview.png) | [before](screenshots/before/1280x800-preview.png) / [after](screenshots/after/1280x800-preview.png) |
| battle | [before](screenshots/before/320x640-battle.png) / [after](screenshots/after/320x640-battle.png) | [before](screenshots/before/390x844-battle.png) / [after](screenshots/after/390x844-battle.png) | [before](screenshots/before/430x932-battle.png) / [after](screenshots/after/430x932-battle.png) | [before](screenshots/before/1280x800-battle.png) / [after](screenshots/after/1280x800-battle.png) |
| camp | [before](screenshots/before/320x640-camp.png) / [after](screenshots/after/320x640-camp.png) | [before](screenshots/before/390x844-camp.png) / [after](screenshots/after/390x844-camp.png) | [before](screenshots/before/430x932-camp.png) / [after](screenshots/after/430x932-camp.png) | [before](screenshots/before/1280x800-camp.png) / [after](screenshots/after/1280x800-camp.png) |
| techniques | [before](screenshots/before/320x640-techniques.png) / [after](screenshots/after/320x640-techniques.png) | [before](screenshots/before/390x844-techniques.png) / [after](screenshots/after/390x844-techniques.png) | [before](screenshots/before/430x932-techniques.png) / [after](screenshots/after/430x932-techniques.png) | [before](screenshots/before/1280x800-techniques.png) / [after](screenshots/after/1280x800-techniques.png) |
| equipment empty | [before](screenshots/before/320x640-equipment-empty.png) / [after](screenshots/after/320x640-equipment-empty.png) | [before](screenshots/before/390x844-equipment-empty.png) / [after](screenshots/after/390x844-equipment-empty.png) | [before](screenshots/before/430x932-equipment-empty.png) / [after](screenshots/after/430x932-equipment-empty.png) | [before](screenshots/before/1280x800-equipment-empty.png) / [after](screenshots/after/1280x800-equipment-empty.png) |
| equipment owned | [before](screenshots/before/320x640-equipment-owned.png) / [after](screenshots/after/320x640-equipment-owned.png) | [before](screenshots/before/390x844-equipment-owned.png) / [after](screenshots/after/390x844-equipment-owned.png) | [before](screenshots/before/430x932-equipment-owned.png) / [after](screenshots/after/430x932-equipment-owned.png) | [before](screenshots/before/1280x800-equipment-owned.png) / [after](screenshots/after/1280x800-equipment-owned.png) |
| realm | [before](screenshots/before/320x640-realm.png) / [after](screenshots/after/320x640-realm.png) | [before](screenshots/before/390x844-realm.png) / [after](screenshots/after/390x844-realm.png) | [before](screenshots/before/430x932-realm.png) / [after](screenshots/after/430x932-realm.png) | [before](screenshots/before/1280x800-realm.png) / [after](screenshots/after/1280x800-realm.png) |

[Screenshot hashes and dimensions](| cultivate | [before](screenshots/before/320x640-cultivate.png) / [after](screenshots/after/320x640-cultivate.png) | [before](screenshots/before/390x844-cultivate.png) / [after](screenshots/after/390x844-cultivate.png) | [before](screenshots/before/430x932-cultivate.png) / [after](screenshots/after/430x932-cultivate.png) | [before](screenshots/before/1280x800-cultivate.png) / [after](screenshots/after/1280x800-cultivate.png) |
| preview | [before](screenshots/before/320x640-preview.png) / [after](screenshots/after/320x640-preview.png) | [before](screenshots/before/390x844-preview.png) / [after](screenshots/after/390x844-preview.png) | [before](screenshots/before/430x932-preview.png) / [after](screenshots/after/430x932-preview.png) | [before](screenshots/before/1280x800-preview.png) / [after](screenshots/after/1280x800-preview.png) |
| battle | [before](screenshots/before/320x640-battle.png) / [after](screenshots/after/320x640-battle.png) | [before](screenshots/before/390x844-battle.png) / [after](screenshots/after/390x844-battle.png) | [before](screenshots/before/430x932-battle.png) / [after](screenshots/after/430x932-battle.png) | [before](screenshots/before/1280x800-battle.png) / [after](screenshots/after/1280x800-battle.png) |
| camp | [before](screenshots/before/320x640-camp.png) / [after](screenshots/after/320x640-camp.png) | [before](screenshots/before/390x844-camp.png) / [after](screenshots/after/390x844-camp.png) | [before](screenshots/before/430x932-camp.png) / [after](screenshots/after/430x932-camp.png) | [before](screenshots/before/1280x800-camp.png) / [after](screenshots/after/1280x800-camp.png) |
| techniques | [before](screenshots/before/320x640-techniques.png) / [after](screenshots/after/320x640-techniques.png) | [before](screenshots/before/390x844-techniques.png) / [after](screenshots/after/390x844-techniques.png) | [before](screenshots/before/430x932-techniques.png) / [after](screenshots/after/430x932-techniques.png) | [before](screenshots/before/1280x800-techniques.png) / [after](screenshots/after/1280x800-techniques.png) |
| equipment empty | [before](screenshots/before/320x640-equipment-empty.png) / [after](screenshots/after/320x640-equipment-empty.png) | [before](screenshots/before/390x844-equipment-empty.png) / [after](screenshots/after/390x844-equipment-empty.png) | [before](screenshots/before/430x932-equipment-empty.png) / [after](screenshots/after/430x932-equipment-empty.png) | [before](screenshots/before/1280x800-equipment-empty.png) / [after](screenshots/after/1280x800-equipment-empty.png) |
| equipment owned | [before](screenshots/before/320x640-equipment-owned.png) / [after](screenshots/after/320x640-equipment-owned.png) | [before](screenshots/before/390x844-equipment-owned.png) / [after](screenshots/after/390x844-equipment-owned.png) | [before](screenshots/before/430x932-equipment-owned.png) / [after](screenshots/after/430x932-equipment-owned.png) | [before](screenshots/before/1280x800-equipment-owned.png) / [after](screenshots/after/1280x800-equipment-owned.png) |
| realm | [before](screenshots/before/320x640-realm.png) / [after](screenshots/after/320x640-realm.png) | [before](screenshots/before/390x844-realm.png) / [after](screenshots/after/390x844-realm.png) | [before](screenshots/before/430x932-realm.png) / [after](screenshots/after/430x932-realm.png) | [before](screenshots/before/1280x800-realm.png) / [after](screenshots/after/1280x800-realm.png) |HOT_MANIFEST.json) identify the raw
browser images. Side-by-side PNGs are evidence composites only; they are never
loaded by the game.

## Assets, preservation and limits

One targeted imagegen edit creates the new blank jade action plaque from the
existing plaque reference. Transparent runtime PNG: 512×96; nine-slice margins
24/16/24/16; native text padding 16/6/16/6. The full prompt, source and hashes
are in [ASSET_MANIFEST.json](ASSET_MANIFEST.json); the full-resolution source is
archived in `sources/`. It was inspected in isolation and in the actual browser
for complete edges, a quiet center and consistent brushwork. It contains no
anatomy, text, synthetic paper grain or extra ornament. Character/landscape and
system emblems are the existing separate layers, not a flattened screenshot.

The pre-edit source/build/asset checkpoint is `.verification/ux-reset-before`.
There is no local Git metadata, so no invented commit or Git rollback is claimed.
All verification used disposable stores/browser profiles. Existing player saves
were neither replaced nor cleared. Nothing was pushed or deployed.

Phone browser emulation is not a physical Android test; Android, screen-reader
behavior and human novice comprehension remain unverified. Listening was not
performed in this pass; audio files, routing and preferences are preserved.
Lower inventory entries still need scrolling on short screens. Some pale small
emblems remain less distinct than their short labels. The chapter still reuses
four guardian families and needs a human playtest for engagement.

Chapter pacing was not rerun or altered: the prior [earned-path report](../jade-road/PACING.md)
measures about **45.15 minutes including waiting**, with about 16.82 minutes of
combat waiting. This UX task does not establish several engaged hours or the
long-term 300-hour ambition. Next work is review and human/device testing of
this interface and the existing chapter, before any new content or timer changes.
