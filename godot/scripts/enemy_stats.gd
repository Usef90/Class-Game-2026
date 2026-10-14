extends Node2D


var HP: float
var speed:float

var damage_multiplier: float = 1

var def:float = 1
var player_damge_multiplier
var battle_logic_script: Node



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	battle_logic_script =  get_parent().get_parent().get_parent().get_node("BattleLogic")
	HP = get_parent().setted_HP
	$HP.max_value = HP
	$HP.value = HP
	$Label.text = str(int($HP.value)) + "/" +str(int($HP.max_value))
	Events.connect("damaged_enemy", _take_damage)
	Events.connect("id_chosen",_damage_yourself)
	Events.connect("players_turn", _take_effect)
	
func _damage_yourself(id: int ,damage: int) -> void:
	player_damge_multiplier = get_parent().get_parent().get_parent().get_node("player").get_node("player_stats").damage_multiplier
	if id != get_parent().id:
		return
	
	$HP.value -= damage * player_damge_multiplier * def * PlayerStats.player_damage * PlayerStats.player_single_damage
	
	$Label.text = str(snapped($HP.value, 0.01)) + "/" +str(int($HP.max_value))
	if $HP.value <= 0:
		Explosions.spawn(get_parent().global_position)
		AudioManager.play_oneshot(get_parent().enemy_dying)
		get_parent().queue_free()
		Events.emit_signal("check_victory_conditions")


func _take_damage(damage: int) -> void:
	player_damge_multiplier = get_parent().get_parent().get_parent().get_node("player").get_node("player_stats").damage_multiplier
	$HP.value -= damage * player_damge_multiplier * def * PlayerStats.player_damage * PlayerStats.player_aoe_damage
	$Label.text = str(int($HP.value)) + "/" +str(int($HP.max_value))
	if $HP.value <= 0:
		Explosions.spawn(get_parent().global_position, null, get_parent().death_particle)
		get_parent().queue_free()
		Events.emit_signal("check_victory_conditions")
		
func _take_effect():
	if battle_logic_script.current_state == battle_logic_script.States.dialogue:
		return
	for i in $"../status".get_children():
		i._take_effect()
