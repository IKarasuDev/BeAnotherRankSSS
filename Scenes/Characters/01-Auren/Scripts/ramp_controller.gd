extends Node

@export var camera_path: NodePath
@export var visual_path: NodePath  # Sprite recomendado

var camera: Camera2D
var visual: Node2D

# -------------------------
# Movement
# -------------------------

@export var base_walk_speed: float = 60.0
@export var base_run_speed: float = 120.0

var walk_speed: float
var run_speed: float

var ramp_multiplier: float = 1.0

# -------------------------
# Tweens
# -------------------------

var zoom_tween: Tween
var scale_tween: Tween

func _ready():
	camera = get_node(camera_path)
	visual = get_node(visual_path)

	_update_speeds()

# -------------------------
# Movement logic
# -------------------------

func set_ramp_multiplier(value: float):
	ramp_multiplier = value
	_update_speeds()

func reset_ramp():
	ramp_multiplier = 1.0
	_update_speeds()

func _update_speeds():
	walk_speed = base_walk_speed * ramp_multiplier
	run_speed = base_run_speed * ramp_multiplier

# -------------------------
# Camera (accumulative)
# -------------------------

func add_camera_zoom(delta: float):
	var target = camera.zoom + Vector2(delta, delta)

	if zoom_tween and zoom_tween.is_running():
		zoom_tween.kill()

	zoom_tween = create_tween()
	zoom_tween.tween_property(
		camera,
		"zoom",
		target,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# -------------------------
# Scale (visual only)
# -------------------------

func add_scale(delta: float):
	var target = visual.scale + Vector2(delta, delta)

	if scale_tween and scale_tween.is_running():
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.tween_property(
		visual,
		"scale",
		target,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
