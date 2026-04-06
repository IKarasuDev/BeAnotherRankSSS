extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect

func _ready() -> void:
	fade_rect.modulate.a = 0.0
	await fade_in_out()
	

func fade_in(duration: float = 2.0) -> void:
	var tween = create_tween()
	tween.tween_property(
		fade_rect,
		"modulate:a",
		1.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func fade_out(duration: float = 1.5) -> void: 
	var tween = create_tween()
	tween.tween_property(
		fade_rect,
		"modulate:a",
		0.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	

func fade_in_out() -> void:
	await fade_in(2.0)
	await fade_out(1.5)
