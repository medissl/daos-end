# Living Dao — event and migration contract

2026-10-24. Implementation contract, not a passed release report.

The existing state/session clock remains the sole reward engine. Foreground
frontier journeys run at full speed. Retreat and an explicitly assigned supply
route run at 30% simulation speed, whether visible or closed. Session restore
credits at most eight hours. Rendering and animation never spend or award.

Supply reuses the journey's encounter state and ordinary node settlement. It
requires a fully cleared route, no active frontier/camp, no departure preparation,
and explicit selection of one, three or six circuits. While assigned, Bamboo
gathering is suspended in place; Qi accrues once through the same clock. Supply
cannot discover nodes, grant first-clear funding, unique items or seals. Each
completed circuit decrements its finite budget. Defeat terminates the assignment;
a requested stop camps at the next safe boundary. Starting a frontier requires
ending the assignment, never two concurrent combat/reward engines.

At a combat boundary: settle ordinary resources once; record eligible first-clear
history/discoveries once; advance the node; honor requested camp; otherwise start
the next ordinary/trial encounter immediately. Discovery display is nonblocking.
Route completion stops a frontier. Only the already authorized supply policy may
start another solved circuit. Unused wall time resumes reduced-rate retreat.

A departure preparation is a selection, not a purchase reservation. Its displayed
price is checked and consumed atomically once at Depart. Cancelling preview costs
nothing, so there is no stranded reservation. Supply never consumes preparations.
Build/law/preset changes affect the next encounter, never the committed current
one. Restores accept owned/learned selections and explain any omissions.

Save v4 preserves v1/v2/v3 via frozen legacy readers/rules. Legitimate prior absence
is credited under the old rules before conversion. A live v3 encounter retains
its frozen resolver/stats until its safe boundary; subsequent encounters use new
rules. New fields default safely, and no supply/preparation is opted into by
migration. Wealth, equipment refinements and first-clear history are retained.
Original files are preserved through the existing recovery mechanism. New saves
must pass bounded structural and computed-build validation before atomic writing.

The Core gate becomes 24,000 Qi. Existing routes gain 2,400 first-clear Qi each;
conversion remits that new funding once for already cleared routes, preserving
wealth and avoiding a penalty for having cleared them before this release.
Sword casts become two 95% hits. Against channelers, Ward conserves focus until
a charge is within two seconds; otherwise it triggers at or below 65% HP. Protection remains
automatic and useful without pre-empting offense at full health.

Core Guardian is 580 HP / 11 attack / 2 poison (formerly 650 / 13 / 3).
Ford Watcher's venom is 7, with its burst reduced from 2.5× to 1.8× so recovery
answers its disclosed pressure instead of a generic Ward/Flame build solving it.
Seeded comparisons demonstrate guard failure and recovery success there; these
are mechanical comparisons, not human enjoyment evidence.
