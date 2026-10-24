# Dao's End — music, ambience and SFX

Draft: 2026-10-23. The user explicitly authorizes **downloading assets from the internet** for this project, including music and sound effects. This guide is production scope for the implementing chat; no audio has been downloaded, auditioned or integrated by the design chat.

## Sound direction

Serene cultivation and restrained danger. Use quiet instrumental phrasing, space, wind, water, cloth, wood, stone and occasional bells. Chinese instrumental colors such as plucked strings or a breathy flute may suit the setting; audition actual tracks rather than trusting names/tags. Avoid an endless busy melody, generic epic choir, sharp electronic UI beeps, slot-machine rewards and loud fanfare after every purchase.

Music supports thinking and repeated sessions. The ambient layer carries the sanctuary when music is muted. Combat is readable without becoming a constant impact loop. No voice acting, narrated novel text or required spoken exposition.

## Find, verify and download

Use primary creator/distributor pages. Prefer CC0 or straightforward commercial-use licenses; CC BY assets are acceptable when the required credit is implemented. Check the license for the exact asset, not an assumption about the entire website. Keep license text and attribution with the project. Do not extract commercial game soundtracks or download music from arbitrary videos.

The first-party [Kenney Interface Sounds](https://kenney.nl/assets/interface-sounds) page lists CC0 and supplies a free download. It is a source for candidate interface sounds, not a guarantee that each sound fits Chinese ink fantasy. OpenGameArt and Freesound can supply other candidates when each file's creator/license is verified; neither site's entire catalog shares one license. Search for field ambience and appropriate instrumental loops, and audition before selecting.

Downloading suitable free licensed assets is already authorized. Do not ask for repeated permission merely to fetch them. Paid purchases, paid subscriptions or accepting unfamiliar account terms are not implied by this authorization; complete the free available work and identify any genuine blocker.

Store selected originals/licenses under an organized source directory, normalized runtime files under `assets/audio/`, and a manifest with source URL, creator, title, license/version, downloaded filename, runtime mapping, edits and attribution. Include credits in the game where required. Keep only the selected usable subset in runtime imports.

## First chapter's actual kit

| Family | Deliverable | Use |
|---|---|---|
| Music | One calm retreat loop and one restrained journey loop, or a compatible pair of stems | Crossfade between retreat and travel; no frantic battle track requirement |
| Ambience | Soft mountain wind and river/water/bamboo texture | Layer according to current location; do not stack all regions together |
| UI | Soft selection, purchase/training, panel movement and unavailable-action response | Similar loudness/material family, short tails |
| Combat | Light attack, flame, ward, water/cleanse, enemy impact | Distinguishable events that match implemented skills |
| Progress | Herb/item collection, first-clear discovery and breakthrough bell/accent | Stronger reward only for meaningful events |

Reuse and edit a coherent small set rather than sourcing dozens of unrelated sounds. Do not play a sound on every Qi tick. Random variation is optional and cosmetic; it never changes game calculations. Do not add pretend combat sounds before actual combat is implemented.

## Technical behavior

Use clear Master, Music, Ambience and SFX controls, plus immediate mute. Save preferences separately from progression; migrating or reincarnating must not reset them. Default mix should be modest, with room for effects and no clipped peaks. Tune by listening, not a fixed volume number.

Trim silence and bad transients, normalize related effects consistently, and remove clicks at loop seams. Use compressed suitable music/ambience and short efficient SFX formats supported by the actual export. Keep long tracks out of unnecessary simultaneous memory loads. Fade scene changes and return/resume so multiple loops never start on top of one another.

Rate-limit rapid repeated effects and cap concurrent voices. Multiple hit results can share one concise sound event rather than produce a machine-gun burst. Preserve important breakthrough/discovery cues above routine feedback without startling the listener.

Godot's [official web export documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) notes browser autoplay restrictions and differences in sample/stream playback, including limitations on audio effects for samples. Verify the actual installed version and exported path. Do not assume a desktop mix or bus effect works in WASM.

Unlock browser audio through the first real player interaction, without an unnecessary full-screen start gate. The game remains fully playable if sound is blocked or muted. Pause/fade on backgrounding as appropriate; on return, resume a single correct loop. Test mute, per-channel controls and persistence in the actual browser build. Do not claim audibility merely because an audio node or automated event assertion exists.

## Acceptance

Audition through headphones and ordinary speakers when available. Inspect the full flow: first tap, purchase, equipment, combat, region transition, rewards, breakthrough, background/return, reload and mute. Listen for clipping, mismatched material, repeated cues, loop seams and fatigue. Check that volume controls affect their actual streams and that focus/reload does not duplicate music.

Record what was heard on native and browser builds, which source files were selected, and limitations. Screenshots cannot prove sound quality. If audible-output inspection is unavailable, still integrate and verify routing/events but report the listening test as unperformed. Physical Android playback remains a separate test.
