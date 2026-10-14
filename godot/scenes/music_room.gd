extends Node2D

func _ready() -> void:
	AudioManager.stop()
	


func _on_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
