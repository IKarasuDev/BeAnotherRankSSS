extends Area2D

@export var target_scene_path: String
@export var spawn_name: String

signal teleport_requested(scene, spawn)

func _on_body_entered(body):
	if body.is_in_group("Auren"):
		var scene = load(target_scene_path)
		
		if scene == null:
			push_error("No se pudo cargar escena: " + target_scene_path)
			return
		
		teleport_requested.emit(scene, spawn_name)
