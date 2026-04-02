extends CharacterBody2D

@onready var state_machine = $StateMachine

@export var walk_speed: float = 100.0
@export var run_speed: float = 200.0

func _ready() -> void:
	state_machine.initialize(self)

func _physics_process(_delta: float) -> void:
	var input_dir = get_input_direction()

	# La FSM decide estado, dirección y velocidad
	var movement_velocity = state_machine.process(input_dir, walk_speed, run_speed)

	velocity = movement_velocity

	move_and_slide()


func get_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("D") - Input.get_action_strength("A"),
		Input.get_action_strength("S") - Input.get_action_strength("W")
	).normalized()
