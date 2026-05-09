# Design: Game Improvements

## Feature 1 — Broom Trash Cleanup

### New file: `Scripts/trash.gd`
Attached to the root `Node3D` of `garbageheap.tscn`. Mirrors `GardenPatchArea1.gd` in structure.

```
extends Node3D

const CLEAN_DURATION := 6.0
var slot := "Trash Area"
var current_clean_time := 0.0
var _fully_cleaned := false

func clean(delta: float) -> void:
    if _fully_cleaned:
        return
    current_clean_time += delta
    if current_clean_time >= CLEAN_DURATION:
        _fully_cleaned = true
        queue_free()

func reset_progress() -> void:
    current_clean_time = 0.0
```

### Modified: `garbageheap.tscn`
- Attach `trash.gd` to root `Trash` node.
- Add `StaticBody3D` child → `CollisionShape3D` with a `SphereShape3D` (radius ~0.5) or `BoxShape3D`. Collision layer 1, mask 1.
- Add root node to groups: `"interactable"`.

### Modified: `Scripts/walis_1.gd`
Full rewrite mirroring `watering_can.gd`:

```
extends RigidBody3D

@onready var collision := $CollisionShape3D

var key := "Trash Area"
var is_equipped := false

func onPickup():
    collision.disabled = true
    position = Vector3(0, -1, 0)
    is_equipped = true

func onDrop():
    collision.disabled = false
    is_equipped = false
    var player = Characters.characters.get("Player")
    _stop_cleaning(player)

func _process(delta):
    if not is_equipped:
        return
    var player = Characters.characters.get("Player")
    if player == null:
        return
    var ray = player.get("ray")
    var hold_label = player.get_node_or_null("HUD/HoldLabel")

    var on_trash := false
    if ray != null and ray.is_colliding():
        var target = ray.get_collider()
        # Walk up to find the node with slot == key
        var check = target
        while check != null:
            if check.get("slot") == key:
                on_trash = true
                break
            check = check.get_parent()

    if Input.is_action_pressed("interact") and on_trash:
        var target = _get_trash_target(ray)
        if hold_label != null:
            hold_label.visible = false
        if target == null or target.get("_fully_cleaned"):
            _stop_cleaning(player)
            return
        if target.has_method("clean"):
            target.clean(delta)
        var progress_ui = player.get_node_or_null("HUD/TextureProgressBar")
        if progress_ui != null:
            var ratio = clampf(target.current_clean_time / target.CLEAN_DURATION, 0.0, 1.0)
            if ratio < 1.0:
                progress_ui.visible = true
                progress_ui.value = ratio
            else:
                progress_ui.visible = false
    elif on_trash and not Input.is_action_pressed("interact"):
        var target = _get_trash_target(ray)
        if hold_label != null and (target == null or not target.get("_fully_cleaned")):
            hold_label.visible = true
        _stop_cleaning(player)
    else:
        if hold_label != null:
            hold_label.visible = false
        _stop_cleaning(player)

func _get_trash_target(ray) -> Node:
    if ray == null or not ray.is_colliding():
        return null
    var node = ray.get_collider()
    while node != null:
        if node.get("slot") == key:
            return node
        node = node.get_parent()
    return null

func _stop_cleaning(player_node = null):
    if player_node != null:
        var progress_ui = player_node.get_node_or_null("HUD/TextureProgressBar")
        if progress_ui != null:
            progress_ui.visible = false
            progress_ui.value = 0.0
```

**Note on progress reset:** When the player releases E, `_stop_cleaning` hides the bar. The `current_clean_time` on the trash node is reset by calling `target.reset_progress()` in the `elif` branch (not holding). This matches the watering can behavior where releasing resets progress.

**Note on raycast:** The trash node's `slot` is on the root `Node3D`, but the raycast hits the `StaticBody3D` child. The `_get_trash_target` helper walks up the parent chain to find the node with `slot == "Trash Area"`.

---

## Feature 2 — Remove ActionLabel

### Modified: `Scenes/UI.tscn`
- Delete the `ActionLabel` node entirely.

### Modified: `Scripts/ui.gd`
- Remove `@onready var actionLabel` line.
- Remove `Globals.show_action_prompt.connect(_show_action)` from `_ready()`.
- Remove `func _show_action(is_visible)` method.

### Modified: `Scripts/player.gd`
- Remove all `Globals.show_action_prompt.emit(...)` calls (there are 3: one `emit(true)` in the actionable block, two `emit(false)` in the else/early-return paths).

### Modified: `globals.gd`
- Remove `signal show_action_prompt(is_visible)` declaration.

---

## Feature 3 — Font Application

### Approach
Godot 4 allows setting `theme_override_fonts/font` directly on nodes using an `ExtResource` reference to a `.ttf` file. No `.tres` wrapper is needed — Godot imports TTF files as `FontFile` resources automatically.

### Modified: `Scenes/UI.tscn`
- On the root `UI` Control node, replace the existing default theme or add a new `Theme` sub-resource that sets `default_font` to `palatinolinotype_roman.ttf`.
- This propagates to all child labels automatically.

### Modified: `Dialog/Styles/VisualNovelTextbox/custom_visual_novel_textbox.tscn`
- On `DialogicNode_DialogText` (RichTextLabel), add:
  - `theme_override_fonts/normal_font = ExtResource("palatinolinotype_italic")`
  - `theme_override_fonts/bold_font = ExtResource("palatinolinotype_italic")`  
  - `theme_override_fonts/italics_font = ExtResource("palatinolinotype_italic")`
- This scene is used by `style.tres` (the monologue/New_File style).

### Modified: `Scenes/player.tscn`
- On `HUD/HoldLabel`, add `theme_override_fonts/font = ExtResource("palatinolinotype_roman")`.

### For `Dialog.tres` (dialogue style)
- `Dialog.tres` uses the stock `vn_textbox_layer.tscn` which cannot be edited directly without affecting the addon. Instead, create `Dialog/Styles/VisualNovelTextbox/dialogue_visual_novel_textbox.tscn` as a copy of the stock textbox with roman font applied, and update `Dialog.tres` to reference it — OR simply apply the font at the theme level in `UI.tscn` which covers the canvas layer. 
- Simpler approach: The dialogic textbox is rendered in its own CanvasLayer. Apply font overrides directly on the `DialogicNode_DialogText` node inside the stock `vn_textbox_layer.tscn` — but that would affect the addon file. 
- **Chosen approach:** Create a second custom textbox scene `dialogue_vn_textbox.tscn` (copy of `custom_visual_novel_textbox.tscn`) with roman font, and point `Dialog.tres` layer 13 to it.
