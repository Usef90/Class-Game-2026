extends Node2D


func _ready() -> void:
	AudioManager.play("death")


func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	PlayerStats.player_gold = 20
	PlayerStats.attacks = []
	PlayerStats.upgrades = []
	Globals.level = 1


func _on_replay_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
