extends Node
##
## StateMachine.gd
##
## RESPONSABILIDAD:
## Controla el estado del personaje (IDLE, WALK, RUN),
## gestiona la dirección lógica y reproduce animaciones.
##
## NO se encarga de física ni de aplicar velocity directamente.
## Devuelve una velocidad calculada al CharacterBody3D.
##
## REQUISITOS DE LA ESCENA PADRE:
## - Debe ser un CharacterBody3D.
## - Debe tener un hijo AnimatedSprite3D.
## - Este nodo (StateMachine) debe ser hijo directo del CharacterBody3D.
##
## ESTRUCTURA ESPERADA:
##
## Auren (CharacterBody3D)
##  ├── StateMachine (Node con este script)
##  ├── AnimatedSprite3D
##
##

@onready var anim = $"../AnimatedSprite2D"
# Se obtiene automáticamente el AnimatedSprite3D del padre.
# Si el nombre cambia, esta ruta debe actualizarse.

# -------------------------
# ENUM DE ESTADOS
# -------------------------

enum State {
	IDLE,
	WALK,
	RUN
}

# Estado actual del personaje.
var current_state: State = State.IDLE

# Última dirección válida del personaje.
# Se usa para reproducir animaciones correctas.
var last_direction: String = "front"


# -------------------------
# INICIALIZACIÓN
# -------------------------

func initialize(body: CharacterBody2D) -> void:
	# Actualmente no usamos directamente el body,
	# pero se deja el parámetro para futura expansión
	# (ataques, rotaciones, acceso a velocity, etc.).
	
	play_animation()


# -------------------------
# PROCESO PRINCIPAL
# -------------------------

func process(input_dir: Vector2, walk_speed: float, run_speed: float) -> Vector2:
	##
	## Método principal llamado desde el CharacterBody.
	##
	## 1. Actualiza dirección según input.
	## 2. Determina el estado actual.
	## 3. Calcula la velocidad correspondiente.
	## 4. Devuelve la velocidad como Vector3.
	##
	
	update_direction(input_dir)
	update_state(input_dir)

	return calculate_velocity(input_dir, walk_speed, run_speed)


# -------------------------
# DIRECCIÓN
# -------------------------

func update_direction(input_dir: Vector2) -> void:
	##
	## Determina la dirección dominante del input.
	## Soporta diagonales priorizando el eje mayor.
	##
	## No cambia dirección si no hay input.
	##
	
	if input_dir == Vector2.ZERO:
		return
	
	var previous = last_direction
	
	if abs(input_dir.x) > abs(input_dir.y):
		last_direction = "right" if input_dir.x > 0 else "left"
	else:
		last_direction = "front" if input_dir.y > 0 else "back"
	
	# Si la dirección cambia, se actualiza animación
	if previous != last_direction:
		play_animation()


# -------------------------
# ESTADO
# -------------------------

func update_state(input_dir: Vector2) -> void:
	##
	## Decide el estado según input:
	##
	## - Sin input → IDLE
	## - Con input + ctrl_left → RUN
	## - Con input → WALK
	##
	
	var new_state: State
	
	if input_dir == Vector2.ZERO:
		new_state = State.IDLE
	else:
		if Input.is_action_pressed("Run"):
			new_state = State.RUN
		else:
			new_state = State.WALK
	
	# Solo cambia si el estado es diferente
	if new_state != current_state:
		current_state = new_state
		play_animation()


# -------------------------
# VELOCIDAD
# -------------------------

func calculate_velocity(input_dir: Vector2, walk_speed: float, run_speed: float) -> Vector2:
	##
	## Calcula la velocidad en el plano XZ
	## según el estado actual.
	##
	
	var direction = input_dir.normalized()
	
	match current_state:
		State.IDLE:
			return Vector2.ZERO
		State.WALK:
			return direction * walk_speed
		State.RUN:
			return direction * run_speed
	
	return Vector2.ZERO


# -------------------------
# ANIMACIÓN
# -------------------------

func play_animation() -> void:
	##
	## Reproduce la animación correspondiente
	## combinando estado + dirección.
	##
	## Formato requerido en AnimatedSprite3D:
	##
	## idle_front
	## idle_back
	## idle_left
	## idle_right
	## walk_front
	## run_front
	## etc.
	##
	
	match current_state:
		State.IDLE:
			anim.play("idle_" + last_direction)
		State.WALK:
			anim.play("walk_" + last_direction)
		State.RUN:
			anim.play("run_" + last_direction)
