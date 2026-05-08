# Tasks: Game Improvements

## Task 1: Create trash.gd script and update garbageheap.tscn
- [x] 1.1 Create `Scripts/trash.gd` with `slot`, `CLEAN_DURATION`, `current_clean_time`, `_fully_cleaned`, `clean(delta)`, and `reset_progress()` methods
- [x] 1.2 Update `Scenes/garbageheap.tscn` to attach `trash.gd` to the root `Trash` node, add a `StaticBody3D` with `CollisionShape3D` child (SphereShape3D radius 0.5), and add root to group `"interactable"`

## Task 2: Rewrite walis_1.gd (broom) to support hold-to-clean interaction
- [x] 2.1 Rewrite `Scripts/walis_1.gd` to mirror `watering_can.gd`: add `key = "Trash Area"`, `is_equipped`, `onPickup()`, `onDrop()`, `_process(delta)` with hold detection, `_get_trash_target()` parent-walk helper, and `_stop_cleaning()` — including resetting `current_clean_time` on the target when the player releases E

## Task 3: Remove ActionLabel and show_action_prompt signal
- [x] 3.1 Delete the `ActionLabel` node from `Scenes/UI.tscn`
- [x] 3.2 Remove `signal show_action_prompt` from `globals.gd`
- [x] 3.3 Remove `actionLabel` onready, `_show_action` method, and `show_action_prompt.connect` from `Scripts/ui.gd`
- [x] 3.4 Remove all `Globals.show_action_prompt.emit(...)` calls from `Scripts/player.gd`

## Task 4: Apply Palatino Linotype fonts
- [x] 4.1 Apply `palatinolinotype_roman.ttf` as the default font on the root `UI` Control node theme in `Scenes/UI.tscn`
- [x] 4.2 Apply `palatinolinotype_italic.ttf` font overrides on `DialogicNode_DialogText` in `Dialog/Styles/VisualNovelTextbox/custom_visual_novel_textbox.tscn` (monologue style)
- [x] 4.3 Create `Dialog/Styles/VisualNovelTextbox/dialogue_vn_textbox.tscn` as a copy of `custom_visual_novel_textbox.tscn` with `palatinolinotype_roman.ttf` applied to `DialogicNode_DialogText`, then update `Dialog/Styles/Dialog.tres` layer 13 to reference this new scene
- [x] 4.4 Apply `palatinolinotype_roman.ttf` font override on `HUD/HoldLabel` in `Scenes/player.tscn`
