extends Area2D

@export var uphill_multiplier := 0.9
@export var downhill_multiplier := 1.1

@export var zoom_uphill := 0.2
@export var zoom_downhill := -0.2

var bodies_inside := {}

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not body.is_in_group("Auren"):
		return

	if bodies_inside.has(body):
		return

	bodies_inside[body] = true

	var local_pos = to_local(body.global_position)

	if local_pos.y < 0:
		apply_downhill(body)
	else:
		apply_uphill(body)

func _on_body_exited(body):
	if not body.is_in_group("Auren"):
		return

	if not bodies_inside.has(body):
		return

	bodies_inside.erase(body)
	reset(body)

# -------------------------
# Logic
# -------------------------

func apply_uphill(body):
	if "set_ramp_multiplier" in body:
		body.set_ramp_multiplier(uphill_multiplier)

	if "add_camera_zoom" in body:
		body.add_camera_zoom(zoom_uphill)

	if "add_scale" in body:
		body.add_scale(0.1)

func apply_downhill(body):
	if "set_ramp_multiplier" in body:
		body.set_ramp_multiplier(downhill_multiplier)

	if "add_camera_zoom" in body:
		body.add_camera_zoom(zoom_downhill)

	if "add_scale" in body:
		body.add_scale(-0.1)

func reset(body):
	if "reset_ramp" in body:
		body.reset_ramp()
