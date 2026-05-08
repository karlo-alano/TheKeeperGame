extends TextureProgressBar

# This script is intentionally minimal.
# The watering_can.gd directly updates this node's `value` and `visible` properties.
# No signal connection needed.

func _ready():
	max_value = 1.0
	step = 0.01
	value = 0.0
	visible = false
