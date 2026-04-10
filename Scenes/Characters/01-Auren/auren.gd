extends CharacterBody2D

@onready var state_machine = $StateMachine
@onready var ramp_controller = $RampController

func _ready() -> void:
	state_machine.initialize(self)

func _physics_process(_delta: float) -> void:
	var input_dir = get_input_direction()

	var movement_velocity = state_machine.process(
		input_dir,
		ramp_controller.walk_speed,
		ramp_controller.run_speed
	)

	velocity = movement_velocity
	move_and_slide()

func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("D") - Input.get_action_strength("A"),
		Input.get_action_strength("S") - Input.get_action_strength("W")
	).normalized()

# -------------------------
# API para RampArea
# -------------------------

func set_ramp_multiplier(value: float):
	ramp_controller.set_ramp_multiplier(value)

func reset_ramp():
	ramp_controller.reset_ramp()

func add_camera_zoom(delta: float):
	ramp_controller.add_camera_zoom(delta)
