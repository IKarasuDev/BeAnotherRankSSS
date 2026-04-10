extends Node

@export var camera_path: NodePath
@export var visual_path: NodePath  # Sprite recomendado
@export var reset_delay: float = 3.0

var reset_timer: Timer
var base_zoom := Vector2(1.5, 1.5)
var base_scale := Vector2(1.0, 1.0)

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
	
	#Timer setup
	reset_timer = Timer.new()
	reset_timer.one_shot = true
	reset_timer.wait_time = reset_delay
	reset_timer.timeout.connect(_on_reset_timeout)
	add_child(reset_timer)

# -------------------------
# Movement logic
# -------------------------

func set_ramp_multiplier(value: float):
	ramp_multiplier = value
	_update_speeds()
	_restart_reset_timer()

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
	zoom_tween.tween_property(camera, "zoom", target, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_restart_reset_timer()

#Reset despues de "reset_delay"

func _restart_reset_timer():
	reset_timer.start()
	

func _on_reset_timeout():
	# Reset velocidades
	ramp_multiplier = 1.0
	_update_speeds()

	# Reset zoom (suave)
	if zoom_tween and zoom_tween.is_running():
		zoom_tween.kill()

	zoom_tween = create_tween()
	zoom_tween.tween_property(camera, "zoom", base_zoom, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
