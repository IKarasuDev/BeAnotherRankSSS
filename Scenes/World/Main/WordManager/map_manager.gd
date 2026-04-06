extends Node2D

@onready var map_container = $MapContainer
@onready var player = $"../Auren"
@onready var transition = $"../Transition"

var current_map: Node

func _ready():
	current_map = map_container.get_child(0)
	_connect_teleports()

# --------------------------------------------------
# CARGA DE MAPA
# --------------------------------------------------
func load_map(scene: PackedScene, spawn_name: String):
	if scene == null:
		push_error("Scene es null! Teleport mal configurado")
		return
	
	# Eliminar mapa actual correctamente
	if current_map:
		current_map.queue_free()
		await current_map.tree_exited
	
	# Instanciar nuevo mapa
	current_map = scene.instantiate()
	map_container.add_child(current_map)

	# Esperar un frame para asegurar que todo esté listo
	await get_tree().process_frame

	_connect_teleports()
	_place_player(spawn_name)

# --------------------------------------------------
# CONECTAR TELEPORTS (solo del mapa actual)
# --------------------------------------------------
func _connect_teleports():
	var all_teleports = get_tree().get_nodes_in_group("teleports")
	var teleports = []
	
	for t in all_teleports:
		if current_map.is_ancestor_of(t):
			teleports.append(t)
	
	#print("Teleports encontrados:", teleports.size())
	
	for t in teleports:
		if not is_instance_valid(t):
			continue
		
		if not t.teleport_requested.is_connected(_on_teleport_requested):
			#print("Conectando teleport:", t)
			t.teleport_requested.connect(_on_teleport_requested)

# --------------------------------------------------
# EVENTO TELEPORT
# --------------------------------------------------
func _on_teleport_requested(scene: PackedScene, spawn: String):
	_change_map_with_transition(scene, spawn)

func _change_map_with_transition(scene: PackedScene, spawn: String) -> void:
	await transition.fade_in(1)
	
	await load_map(scene, spawn)
	
	var cam = player.get_node("Camera2D")
	
	cam.position_smoothing_enabled = false
	cam.reset_smoothing()
	cam.force_update_scroll()
	
	await get_tree().process_frame
	
	cam.position_smoothing_enabled = true
	await transition.fade_out(1)

# --------------------------------------------------s
# POSICIONAR PLAYER
# --------------------------------------------------
func _place_player(spawn_name: String):
	var spawn = current_map.get_node_or_null("Spawns/" + spawn_name)
	
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_error("Spawn no encontrado: " + spawn_name)
