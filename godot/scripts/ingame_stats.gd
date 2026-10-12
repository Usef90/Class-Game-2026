extends Node2D



var HP: float


var enemy_thats_attacking: String

var def_stats: float = 0
const MAX_DEF: float = 20

var attack_name: String = ""

var damage_multiplier: float = 1
var damage_sfx: AudioStream = preload("res://sfx/player dmagae.mp3")

var incoming_damage: float = 0

@onready var animation_player = $"../animations"

func _is_player_killed_achievements(killer:String):
	if Globals.level == 1:
		Globals.achievements["john"] = true
	if Globals.level == 2 and killer == "Pearto":
		Globals.achievements["lagtrain"] = true
		
	if Globals.level == 7 and attack_name == "banana_nuke":
		Globals.achievements["nuked"] = true
		
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HP.max_value = PlayerStats.player_hitpoint
	$HP.value = PlayerStats.player_hitpoint
	$Label.text = str(snapped($HP.value, 0.01)) + "/" +str(int($HP.max_value))
	Events.connect("damaged_player", _take_damage)
	

func _on_animations_animation_finished() -> void:
	animation_player.visible = false
	$HP.value -= incoming_damage * ((MAX_DEF - def_stats)/MAX_DEF)
	$Label.text = str(snapped($HP.value, 0.01)) + "/" +str(int($HP.max_value))
	
	if $HP.value<=0:
		_is_player_killed_achievements(enemy_thats_attacking)
		get_tree().change_scene_to_file("res://scenes/deathScene.tscn")
	Events.emit_signal("players_turn")
	
	

func _take_damage(damage: float, animation: String, enemy_name:String) -> void:
	if damage > 0 :
		AudioManager.play_oneshot(damage_sfx)
	attack_name = animation
	incoming_damage = damage
	animation_player.visible = true
	enemy_thats_attacking = enemy_name
	animation_player.play(animation)
	
	


		
		
