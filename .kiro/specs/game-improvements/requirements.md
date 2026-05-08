# Requirements: Game Improvements

## Feature 1 — Broom Trash Cleanup (Hold Interaction)

### Overview
The player can pick up the broom from the shed. When holding the broom and aiming at any of the 6 trash nodes in `World_Day1A.tscn`, a "Hold E" prompt appears. Holding E for 6 seconds removes the trash node from the world. This mirrors the watering-can hold interaction pattern exactly.

### Requirements

**R1.1** — The `garbageheap.tscn` scene must have a script (`trash.gd`) attached to the root `Trash` node. The script must:
- Expose a `slot` variable set to `"Trash Area"` so the broom can key-match it.
- Expose a `CLEAN_DURATION` constant of `6.0` seconds.
- Expose a `current_clean_time` float (starts at `0.0`).
- Expose a `_fully_cleaned` bool (starts at `false`).
- Provide a `clean(delta: float)` method that accumulates `current_clean_time`, calls `queue_free()` on itself when `current_clean_time >= CLEAN_DURATION`, and marks the task done via `DaySystem.set_task_done(1, 1, true)` only when all 6 are cleaned (tracked via a static counter or a world-level signal — simplest: just `queue_free()` and let the world script count remaining trash).
- Be in the `"interactable"` group so the player's raycast shows "Press E to interact" when not holding the broom, and in a custom group `"cleanable"` for the broom to detect.

**R1.2** — The `garbageheap.tscn` scene must have a `StaticBody3D` child with a `CollisionShape3D` (box or sphere shape) so the raycast can hit it. The collision layer/mask must match the player's raycast (layers 1 & 2).

**R1.3** — The `walis_1.gd` (broom) script must be rewritten to mirror `watering_can.gd`:
- `key` variable set to `"Trash Area"`.
- `is_equipped` bool.
- `onPickup()` — disables collision, sets position/rotation for hand, sets `is_equipped = true`.
- `onDrop()` — re-enables collision, sets `is_equipped = false`, calls `_stop_cleaning(player)`.
- `_process(delta)` — when equipped, reads the player's ray; if ray hits a node with `slot == "Trash Area"` and `interact` is held, calls `target.clean(delta)`, shows/hides `HUD/HoldLabel`, and drives `HUD/TextureProgressBar` with `current_clean_time / CLEAN_DURATION`. When not holding or not aiming, calls `_stop_cleaning(player)`.
- `_stop_cleaning(player_node)` — hides progress bar and resets its value.

**R1.4** — The 6 `Trash` nodes already placed in `World_Day1A.tscn` must each have a `CollisionShape3D` child (added inside `garbageheap.tscn`) so they are hittable by the raycast. No new nodes need to be added to the world scene — only the scene file `garbageheap.tscn` needs the collision and script.

**R1.5** — When a trash node is fully cleaned it calls `queue_free()` on itself, removing it from the world. No animation is required.

**R1.6** — If the player releases E before 6 seconds, `current_clean_time` resets to `0.0` (same as watering can — progress does not persist between hold attempts).

---

## Feature 2 — Remove "Press LMB to interact" Prompt

### Overview
The `ActionLabel` in `UI.tscn` currently shows "Press [LMB] to interact". This label and its signal connection must be removed entirely. Only "Press E to interact" (`InteractLabel`) and "Hold E" (`HUD/HoldLabel` on the player) remain.

### Requirements

**R2.1** — The `ActionLabel` node in `UI.tscn` must be deleted.

**R2.2** — The `show_action_prompt` signal in `globals.gd` and its emit calls in `player.gd` must be removed to avoid errors from the missing node.

**R2.3** — The `_show_action` method and `actionLabel` reference in `ui.gd` must be removed.

**R2.4** — The `Globals.show_action_prompt.connect(...)` call in `ui.gd._ready()` must be removed.

**R2.5** — All `Globals.show_action_prompt.emit(...)` calls in `player.gd` must be removed.

---

## Feature 3 — Apply Palatino Linotype Font

### Overview
Apply the Palatino Linotype font family from `res://Fonts/` across the game. The rule is:
- **Monologue text** (Dialogic VN textbox used for monologues) → `palatinolinotype_italic.ttf`
- **Dialogue text and UI labels** → `palatinolinotype_roman.ttf`

### Requirements

**R3.1** — Create a Godot `FontFile` resource (or reference the TTF directly) for:
- `res://Fonts/palatinolinotype_roman.ttf` — used for UI and dialogue.
- `res://Fonts/palatinolinotype_italic.ttf` — used for monologue.

**R3.2** — In `UI.tscn`, apply `palatinolinotype_roman.ttf` as the default font on the root `UI` Control node's theme (replacing the existing anonymous `Theme` sub-resources). All child labels (`InteractLabel`, `JournalHintLabel`, `Crosshair`, `TaskBar` labels) inherit from this theme.

**R3.3** — In `custom_visual_novel_textbox.tscn` (used by the `style.tres` monologue style), set `theme_override_fonts/normal_font` on `DialogicNode_DialogText` to `palatinolinotype_italic.ttf`.

**R3.4** — In the `Dialog.tres` style's textbox layer (which uses the default `vn_textbox_layer.tscn`), the dialogue text font should be `palatinolinotype_roman.ttf`. Since `Dialog.tres` uses the stock `vn_textbox_layer.tscn`, apply the font override via the `overrides` dictionary in the layer resource, or by creating a second custom textbox scene for dialogue.

**R3.5** — The `HoldLabel` in `player.tscn` must use `palatinolinotype_roman.ttf` via a `theme_override_fonts/font` property.

**R3.6** — Do not change font sizes — only the font face changes. Do not break any existing layout or theme structure.
