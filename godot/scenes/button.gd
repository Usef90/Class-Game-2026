extends Node2D

var background_no:int = 0
var background1 = preload("res://Art/gordoTitleScreen.png")
var background2 = preload("res://Art/furry king mainmenu.png")
var background3 = preload("res://Art/domainexpansion.png")
var background4 = preload("res://Art/john vs socrates.png")
var background5 = preload("res://Art/mainMenu caleb and jacon.png")
var background6 = preload("res://Art/sitDown.png")
var background7 = preload("res://Art/yuta and ryu thing.png")
var background8 = preload("res://Art/we are larp.png")
var background9 = preload("res://Art/cooking.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play("MainMenu")
	AudioManager.changeVolume()



func _on_button_pressed() -> void:
	PlayerStats.attacks = []
	PlayerStats.upgrades = []
	Globals.level = 1
	PlayerStats.player_gold = 20
	TransitionManager.play_transition("res://cutscene/begining_cutscene.tscn")


func _on_timer_timeout() -> void:
	background_no += 1
	if background_no > 8:
		background_no =0
	if background_no == 0:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background1
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 1:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background2
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 2:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background3
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 3:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background4
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 4:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background5
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 5:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background6
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 6:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background7
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 7:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background8
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout
	if background_no == 8:
		var tween = get_tree().create_tween()
		tween.tween_property($CanvasLayer/TextureRect, "modulate", Color.BLACK, 1.0)
		await get_tree().create_timer(1).timeout
		$CanvasLayer/TextureRect.texture = background9
		var reverse = get_tree().create_tween()
		reverse.tween_property($CanvasLayer/TextureRect, "modulate", Color.WHITE, 1.0)
		await get_tree().create_timer(1).timeout

func _on_button_2_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_button_3_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/music_room.tscn")


func _on_continue_pressed() -> void:
	TransitionManager.play_transition("res://scenes/level_select.tscn")


func _on_achievements_pressed() -> void:
	TransitionManager.play_transition("res://scenes/achievements.tscn")
