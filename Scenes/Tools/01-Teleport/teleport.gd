extends Area2D

@export var target_scene_path: String
@export var spawn_name: String

signal teleport_requested(path, spawn)

func _on_body_entered(body):
	if body.is_in_group("Auren"):
		teleport_requested.emit(target_scene_path, spawn_name)
