# Exporting the demo for itch.io

## One-time setup
1. Open the project in Godot 4.7 or newer.
2. Editor menu, Manage Export Templates, Download and Install (needed once per Godot version).

## Export
1. Project menu, Export. The "Web" preset is already there (threads off, so it runs on itch.io
   without special headers).
2. Click Export Project and save to build/web/index.html.
3. Zip the CONTENTS of build/web (index.html must be at the top level of the zip, not inside a folder).

## Upload
1. On itch.io, create a new project. Kind of project: HTML.
2. Upload the zip and tick "This file will be played in the browser".
3. Embed options: viewport size 1280 x 720 (the game's 2x window), enable the fullscreen button.
   Leave "SharedArrayBuffer support" off. Do not enable mobile friendly (keyboard controls only).
4. Save, then check the page in the browser before publishing. Test: menu, content note,
   wake-up, inspect objects, pause/restart, door, teaser, demo-complete screen, return to title.

## Page text (draft: edit freely)
**Title:** Violet that Blooms in Winter (Demo)

**Short description:** A quiet story about a girl, a frozen lake, and the people trying to reach her.

**Genre / tags:** Role Playing, Interactive Fiction; pixel art, story rich, atmospheric,
psychological, 2D, singleplayer, Godot

**Description:**
Violet that Blooms in Winter is a narrative RPG about a withdrawn girl, a rainy school, and a dream
world where everything is perfect. This is an early prototype demo: it covers a rainy Monday
morning at home and a first look at Room 2-B. Art is placeholder.

**Content note:** Contains themes of bullying, abuse, grief, and withdrawal.

**Controls:** WASD or arrow keys to move. E, Z, Enter, or Space to interact and advance text.
Escape pauses the demo. Gamepad also works (stick or d-pad, A to interact, Start to pause).
Press F1 to show the current scene name.

## If something goes wrong
- Blank page or error on itch.io: confirm index.html is at the top level of the zip.
- No sound until you press a key: browsers block audio until the first input. This is normal.
- Quit is hidden in the web build on purpose (it does nothing in a browser).
