# Audio verification

The established licensed wood/paper/water/strike/ward material and saved Menu
controls are retained. No generated retro tones, idle tick or bird call were
added. New Returning/Thunder/Mirror events use the existing organic strike and
ward recordings. Music remains optional and off by default. Provenance,
licenses and edit details are in ../jade-road/AUDIO_MANIFEST.json; new bitmap
credits are in ART_MANIFEST.json and the in-game Menu.

The native audio suite passes 15 signal/routing checks, including gesture
unlock policy, saved choices, crossfades and bounded event playback. Browser
capture tees the actual AudioContext destination into a MediaStreamDestination;
the recorded WebM/Opus files contain rendered game output, not source samples.
48 kHz sample rate, running/audible sample count, sample peak and RMS peak are
reported per walkthrough in the browser JSON. Muting and reduced motion persist
through an actual browser reload. No idle sound is used as progress feedback.

These measurements prove output/routing and headroom, not aesthetic quality.
No implementing-agent subjective listening claim is made: an audio audition
surface is unavailable here. Actual headphone/speaker listening, loop seams,
location character, harshness and perceived attack timing remain a release
gate. The gallery exposes real captured mixes for that review. The visual-only
motion reel is labeled silent; independent audio files are clearly identified.
