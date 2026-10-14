extends Node

## status effect script
## like make a new node with this script 
## and change the stuff in the editor to make a new side effect


class_name effects_base


var types_of_effect = ["lethal", "buff"]


@export var effect_name = ""

@export var stackable: bool = false

@export var type = "lethal"
@export var damage: float
@export var target_stats: String = ""
@export var duration: int = 5
@export var Effect_strength: float = 1.2

@export_multiline var discription: String = ""

var player_ingame_stats: Node2D
var before_stats: float

@export var startInstantly: bool = false


func _ready() -> void:
	player_ingame_stats = get_parent().get_parent().get_node("player_stats")
	if effect_name in get_parent().effect and !stackable:
		queue_free()
		return
	
	var icon = status_effect_icon.new()
	icon.name = effect_name
	icon.texture = StatusIcon.get(effect_name)
	icon.text = discription
	get_parent().get_parent().get_node("status_effect_viewer").add_child(icon, true)
	get_parent().effect.append(effect_name)
	# type_of_effects[0] == lethal
	# typpe_of_effects[1] == buff
	
	if type == types_of_effect[1]:
		before_stats = player_ingame_stats.get(target_stats)
		duration += 1
	if startInstantly:
		_take_effect()

	
	

# called every turn

func _take_effect():
	if type == types_of_effect[0] and duration  > 0:
		player_ingame_stats.get_node("HP").value -= damage 
		player_ingame_stats.get_node("Label").text = str(snapped(player_ingame_stats.get_node("HP").value, 0.01)) + "/" +str(int(player_ingame_stats.get_node("HP").max_value))
		if player_ingame_stats.get_node("HP").value <=0:
			TransitionManager.play_transition("res://scenes/deathScene.tscn")
	if type == types_of_effect[1] and duration > 0:
		player_ingame_stats.set(target_stats, Effect_strength)
			
	duration -= 1
	if duration <= 0:
		player_ingame_stats.set(target_stats, before_stats)
		get_parent().effect.erase(effect_name)
		for i in get_parent().get_parent().get_node("status_effect_viewer").get_children():
			if i.name == effect_name:
				i.queue_free()
				break

		queue_free()
