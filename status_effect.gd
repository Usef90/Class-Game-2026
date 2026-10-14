extends Node



var effect = []
@onready var status_effect_viewer = $"../status_effect_viewer"
func _ready() -> void:
	Events.connect("players_turn", _take_side_effects)
	Events.connect("give_side_effects", _new_side_effects)
	
	
func _take_side_effects():
	if get_parent().get_parent().get_node("BattleLogic").current_state == get_parent().get_parent().get_node("BattleLogic").States.dialogue:
		return
	for i in get_children():
		i._take_effect()
	
func _new_side_effects(effects:String):
	var new_effect =ListOfStatusEffects.get(effects).instantiate()
	new_effect.player_ingame_stats = get_parent().get_parent().find_child("player_stats")
	
	add_child(new_effect,true)
