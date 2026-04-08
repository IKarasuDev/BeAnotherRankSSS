extends Node2D

signal map_prepared(path)

@onready var map_container = $MapContainer
@onready var player = $"../Auren"
@onready var transition = $"../Transition"

var current_map: Node

# --- SINGLE PRELOAD (legacy, opcional mantener) ---
var _prepared_map_path: String = ""
var _prepared_spawn: String = ""
var _is_loading: bool = false
var _is_map_ready: bool = false

# --- QUEUE SYSTEM (nuevo) ---
var _load_queue: Array[String] = []
var _current_loading_path: String = ""
var _loaded_maps: Dictionary = {}

func _ready():
	current_map = map_container.get_child(0)
	_connect_teleports()
	_start_preloading_neighbors()

func _process(_delta):
	if _current_loading_path != "":
		var status = ResourceLoader.load_threaded_get_status(_current_loading_path)
		
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
			
			ResourceLoader.THREAD_LOAD_LOADED:
				var res: PackedScene = ResourceLoader.load_threaded_get(_current_loading_path)
				
				_loaded_maps[_current_loading_path] = res
				
				map_prepared.emit(_current_loading_path)
				
				_current_loading_path = ""
				_process_next_in_queue()
			
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load: " + _current_loading_path)
				_current_loading_path = ""
				_process_next_in_queue()

# --------------------------------------------------
# PRELOAD AUTOMÁTICO DE VECINOS
# --------------------------------------------------
func _start_preloading_neighbors():
	var config = current_map.get_node_or_null("MapConfig")
	
	if config == null:
		#print("No MapConfig found")
		return
	
	_load_queue = config.neighbor_maps.duplicate()
	
	#print("Starting preload queue:", _load_queue)
	
	_process_next_in_queue()

func _process_next_in_queue():
	if _load_queue.is_empty():
		return
	
	_current_loading_path = _load_queue.pop_front()
	
	# evitar recargar
	if _loaded_maps.has(_current_loading_path):
		_process_next_in_queue()
		return
	
	#print("Preloading:", _current_loading_path)
	
	var err = ResourceLoader.load_threaded_request(_current_loading_path)
	
	if err != OK:
		push_error("Threaded load failed: " + _current_loading_path)
		_current_loading_path = ""
		_process_next_in_queue()

# --------------------------------------------------
# FALLBACK / COMPATIBILIDAD
# --------------------------------------------------
func prepare_map(_path: String, _spawn: String) -> void:
	# opcional mantener (ya no es necesario con vecinos)
	pass

func switch_to_prepared_map() -> void:
	pass

# --------------------------------------------------
# CORE MAP SWAP
# --------------------------------------------------
func _swap_map(scene: PackedScene, spawn_name: String):
	if current_map:
		current_map.queue_free()
		await current_map.tree_exited
	
	current_map = scene.instantiate()
	map_container.add_child(current_map)

	await get_tree().process_frame

	_connect_teleports()
	_place_player(spawn_name)
	
	var cam = player.get_node("Camera2D")
	cam.position_smoothing_enabled = false
	cam.reset_smoothing()
	cam.force_update_scroll()
	
	await get_tree().process_frame
	
	cam.position_smoothing_enabled = true
	
	# 🔥 IMPORTANTE: iniciar preload del nuevo mapa
	_start_preloading_neighbors()

# --------------------------------------------------
# TELEPORT CONNECTION
# --------------------------------------------------
func _connect_teleports():
	var all_teleports = get_tree().get_nodes_in_group("teleports")
	var teleports = []
	
	for t in all_teleports:
		if current_map.is_ancestor_of(t):
			teleports.append(t)
	
	for t in teleports:
		if not is_instance_valid(t):
			continue
		
		if not t.teleport_requested.is_connected(_on_teleport_requested):
			t.teleport_requested.connect(_on_teleport_requested)

# --------------------------------------------------
# TELEPORT EVENT (USA CACHE)
# --------------------------------------------------
func _on_teleport_requested(path: String, spawn: String):
	await transition.fade_in(1)
	
	var scene: PackedScene = await _await_map_ready(path)
	
	await _swap_map(scene, spawn)
	
	await transition.fade_out(1)

func _change_map_with_transition(scene: PackedScene, spawn: String) -> void:
	await transition.fade_in(1)
	await _swap_map(scene, spawn)
	await transition.fade_out(1)

# --------------------------------------------------
# PLAYER POSITION
# --------------------------------------------------
func _place_player(spawn_name: String):
	var spawn = current_map.get_node_or_null("Spawns/" + spawn_name)
	
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_error("Spawn not found: " + spawn_name)

func _await_map_ready(path: String) -> PackedScene:
	# Si ya está en cache → inmediato
	if _loaded_maps.has(path):
		return _loaded_maps[path]
	
	# Si ya se está cargando en la cola → esperar
	if path == _current_loading_path:
		await map_prepared
	
	# Si NO estaba en cola → fallback: iniciarlo y esperar
	else:
		print("Late preload start:", path)
		var err = ResourceLoader.load_threaded_request(path)
		if err != OK:
			push_error("Failed to start threaded load: " + path)
			return load(path) # fallback duro
		
		_current_loading_path = path
		
		await map_prepared
	
	return _loaded_maps.get(path, load(path))
