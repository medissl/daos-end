# Save policy and migration

The existing `user://cultivation.json` location and application identity remain.
Web uses Godot IDBFS; native Windows uses the existing Godot app_userdata folder.
Audio and display preferences are separate `.cfg` files.

Schema 3 records policy `jade-road-v1` and an `azure_refund: true` marker.
Frozen v1/v2 validators, formulas and trip advancement live in `scripts/legacy/`.
The v3 validator recomputes battle stats from bounded historical loadouts and
checks enemy definitions, IDs, slots, effect bounds, histories and realm gates.
JSON numbers are normalized on load; nanounit canonicalization of combat
accumulators prevents tiny binary/JSON round-trip drift changing later results.

## Migration order

1. Validate the old file against its frozen old policy.
2. Preserve the original as a timestamped recovery file. If preservation fails,
   saving pauses; an unreadable file is not silently overwritten.
3. Credit legitimate old absence once, capped at eight wall-clock hours, using
   the old formula, trip commitments and full-speed timeline.
4. Carry resources, realm, practices, methods, mastery, trip and repeat intent
   forward. New chapter systems start with no invented gear or clear history.
5. Credit Azure herbs already overpaid: M0 0, M1 4, M2 12. Persist the schema-3
   checkpoint at the current timestamp so refund/old absence cannot repeat.
6. Thereafter Foundation retreat/absence use 30% simulation. A player-started
   foreground finite journey uses full speed; closed time uses 30%, stops at a
   safe boundary, then follows the existing authorized retreat behavior.

Golden Core has multiplier 8, three combat slots and one free preset. Advancement
cannot bypass required distinct clears, seals, Core Trial or 75,000 Qi.

## Recovery and verification

Primary, `.bak` and interrupted `.tmp` candidates remain supported. Invalid and
unsupported candidates are preserved. No cleanup removes player recovery files.
Chapter reward history prevents first-clear gear/seals/arts from being awarded
again; ordinary replay resources are intentional. Defeat keeps permanent rewards.

The original 73-check and 96-check suites cover old progression, migration and
recovery. The 190-check chapter suite adds deterministic event/effect ordering,
partial clocks, 30% transitions/cap, one-time refunds at all mastery levels,
loadout snapshots, rewards/reload and all route/trial/Core active-combat JSON
round trips. Inflated attack and altered enemy definitions are rejected. The
earned-path simulation validates serialized checkpoints after every route and
trial. Browser tests use isolated profiles and actual IDBFS flushing/reload.

No real browser profile is seeded or reset by these tests. A local native launch
can perform the legitimate migration on the existing native save; original and
recovery files are retained. Browser filesystem sync is asynchronous: abrupt
termination or unavailable storage can still lose the latest unflushed writes.
This remains a local game, without accounts, cloud recovery or anti-cheat claims.
