extends Node2D
func _ready() -> void:
	$AnimationPlayer.play("finale")
	AudioManager.play("MainMenu")


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/ending_menu.tscn")
