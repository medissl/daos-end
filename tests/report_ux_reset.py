"""Package measured UX evidence; never manufacture a pass from partial output."""
import difflib
import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/ux-reset"
SIZES = ["320x640", "390x844", "430x932", "1280x800"]
VIEWS = ["cultivate", "preview", "battle", "camp", "techniques", "equipment-empty", "equipment-owned", "realm"]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


before = json.loads((OUT / "BEFORE_BROWSER_RESULTS.json").read_text(encoding="utf-8"))
after = json.loads((OUT / "AFTER_BROWSER_RESULTS.json").read_text(encoding="utf-8"))
assert before["completed"] and after["completed"]
assert not before["errors"] and not after["errors"]
baseline = {e["key"]: e for e in before["events"] if e["name"].startswith("BASELINE route")}
current = {e["key"]: e for e in after["events"] if e["name"].startswith("PASS route")}
assert set(baseline) == set(current) == set(SIZES)
desktop = json.loads((OUT / "FINAL-DESKTOP_BROWSER_RESULTS.json").read_text(encoding="utf-8"))
assert desktop["completed"] and not desktop["errors"]
current["1280x800"] = next(e for e in desktop["events"] if e["name"].startswith("PASS route"))
for file in (OUT / "screenshots/final-desktop").glob("*.png"):
    shutil.copyfile(file, OUT / "screenshots/after" / file.name)
for density in ["2", "2.625"]:
    report = json.loads((OUT / f"DENSITY-{density}_BROWSER_RESULTS.json").read_text(encoding="utf-8"))
    assert report["completed"] and not report["errors"]

logs = OUT / "logs"
logs.mkdir(exist_ok=True)
for filename in ["ux-export.log", "ux-full-native.log", "ux-early-native.log", "ux-browser.log", "ux-desktop-final.log", "ux-regression-core.log", "ux-regression-m2.log", "ux-regression-jade.log", "ux-regression-audio.log", "ux-density-2.log", "ux-density-2.625.log"]:
    shutil.copyfile(ROOT / ".verification" / filename, logs / filename)

checkpoint = ROOT / ".verification/ux-reset-before"
original = json.loads((checkpoint / "hashes.json").read_text(encoding="utf-8-sig"))
changed = [r["path"] for r in original if not (ROOT / r["path"]).exists() or digest(ROOT / r["path"]) != r["sha256"]]
protected = ["data/jade_road.json", "scripts/chapter_data.gd", "scripts/combat.gd", "scripts/progression.gd", "scripts/cultivation_state.gd", "scripts/cultivation_session.gd", "scripts/save_store.gd", "scripts/chapter_validation.gd", "scripts/game_audio.gd"]
receipt = []
for name in protected:
    expected = next(r["sha256"] for r in original if r["path"] == name)
    actual = digest(ROOT / name)
    assert expected == actual, name
    receipt.append(dict(path=name, checkpoint_sha256=expected, final_sha256=actual, identical=True))
(OUT / "PRESERVATION.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")
parts = []
for name in ["scripts/main.gd", "scripts/chapter_ui.gd", "scripts/landscape.gd", "scripts/ui_materials.gd"]:
    parts.extend(difflib.unified_diff((checkpoint / name).read_text(encoding="utf-8").splitlines(True), (ROOT / name).read_text(encoding="utf-8").splitlines(True), fromfile="checkpoint/" + name, tofile="current/" + name))
(OUT / "SOURCE_DIFF.patch").write_text("".join(parts), encoding="utf-8")

images = []
for size in SIZES:
    for view in VIEWS:
        for phase in ["before", "after"]:
            file = OUT / f"screenshots/{phase}/{size}-{view}.png"
            assert file.exists(), file
            with Image.open(file) as image:
                assert image.size == tuple(map(int, size.split("x"))), file
                images.append(dict(path=file.relative_to(OUT).as_posix(), size=list(image.size), sha256=digest(file), phase=phase, view=view))
(OUT / "SCREENSHOT_MANIFEST.json").write_text(json.dumps(images, indent=2) + "\n", encoding="utf-8")

# Evidence composites only. The running game still uses separate art and Controls.
font = ImageFont.truetype(str(ROOT / "assets/fonts/Lato-Regular.ttf"), 18)
for view in ["preview", "camp", "techniques", "equipment-owned"]:
    a = Image.open(OUT / f"screenshots/before/320x640-{view}.png").convert("RGB")
    b = Image.open(OUT / f"screenshots/after/320x640-{view}.png").convert("RGB")
    sheet = Image.new("RGB", (664, 684), "#e8e4da")
    sheet.paste(a, (8, 36))
    sheet.paste(b, (336, 36))
    draw = ImageDraw.Draw(sheet)
    draw.text((12, 8), "Before · 320 × 640", font=font, fill="#263e34")
    draw.text((340, 8), "After · 320 × 640", font=font, fill="#263e34")
    sheet.save(OUT / f"screenshots/compare-320-{view}.png")

html = '''<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Dao's End — UX comparison</title>
<style>body{margin:24px;background:#e8e4da;color:#253e34;font:16px system-ui}h1{font:28px Georgia}select{font:inherit;padding:10px;margin:0 16px 20px 0}main{display:flex;gap:20px;align-items:flex-start;overflow:auto}figure{margin:0}figcaption{padding:10px 0}img{display:block;max-width:none}p{max-width:850px;line-height:1.5}</style>
<h1>Dao's End — actual browser before / after</h1><p>Isolated Foundation-entry profiles, real first encounter, ordinary clock. Owned equipment uses the same developed fixture. Phone screenshots are CSS-sized captures from DPR 3; desktop DPR 1. These are gameplay captures, not interface mockups.</p>
<label>Viewport <select id="size"></select></label><label>View <select id="view"></select></label><main><figure><figcaption>Before</figcaption><img id="before"></figure><figure><figcaption>After</figcaption><img id="after"></figure></main>
<script>const sizes=SIZES,views=VIEWS;for(const k of sizes)size.add(new Option(k,k));for(const k of views)view.add(new Option(k.replaceAll('-',' '),k));function update(){for(const p of ['before','after'])document.getElementById(p).src='screenshots/'+p+'/'+size.value+'-'+view.value+'.png'}size.onchange=view.onchange=update;view.value='camp';update()</script>'''
html = html.replace("SIZES", json.dumps(SIZES)).replace("VIEWS", json.dumps(VIEWS))
(OUT / "COMPARE.html").write_text(html, encoding="utf-8")

rows = []
for size in SIZES:
    a, b = baseline[size], current[size]
    rows.append(f"| {size} | {a['taps']} / {a['scrolls']} | {b['directFlowTaps']} / 0 | {b['taps']} / {b['scrolls']} | {a['seconds']:.1f}s / {b['seconds']:.1f}s |")
screens = []
for view in VIEWS:
    cells = [view.replace("-", " ")]
    for size in SIZES:
        cells.append(f"[before](screenshots/before/{size}-{view}.png) / [after](screenshots/after/{size}-{view}.png)")
    screens.append("| " + " | ".join(cells) + " |")

delivery = """# Dao's End — task-based UX reset

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
ROWS

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

Machine-readable evidence: [before](BEFORE_BROWSER_RESULTS.json),
[after](AFTER_BROWSER_RESULTS.json), [DPR 2](DENSITY-2_BROWSER_RESULTS.json),
[DPR 2.625](DENSITY-2.625_BROWSER_RESULTS.json), [logs](logs/ux-browser.log),
[final desktop pass](FINAL-DESKTOP_BROWSER_RESULTS.json),
[source diff against the checkpoint](SOURCE_DIFF.patch).

## Comparable rendered screenshots

[Open the comparison gallery](COMPARE.html). Each pair uses the same viewport
and scenario class; battle HP and accumulated Qi vary with capture timing.
Camp captures come from the real first encounter. Techniques comparisons use
the same isolated camp fixture; actual-flow captures also retain the subsequent
equipped state.

| View | 320×640 | 390×844 | 430×932 | 1280×800 |
|---|---|---|---|---|
SCREENS

[Screenshot hashes and dimensions](SCREENSHOT_MANIFEST.json) identify the raw
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
"""
(OUT / "DELIVERY.md").write_text(delivery.replace("ROWS", "\n".join(rows)).replace("SCREENS", "\n".join(screens)), encoding="utf-8")
manifest = []
for folder in ["scripts", "data", "scenes", "assets/ui", "assets/fonts", "builds/web"]:
    for file in sorted((ROOT / folder).rglob("*")):
        if file.is_file(): manifest.append(dict(path=file.relative_to(ROOT).as_posix(), sha256=digest(file)))
(OUT / "FINAL_MANIFEST.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print("Packaged verified UX evidence; changed checkpoint files:", changed)
