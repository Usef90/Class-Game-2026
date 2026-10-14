extends CanvasLayer

signal loading_screen_ready

@export var animation_player: AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_ready.emit()
	
func _on_progress_changed(new_value: float ) -> void:
	pass #this is like loading bars and stuff just keep it like ts we change later
	
func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
