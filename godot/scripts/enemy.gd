extends Node2D
class_name enemy

@export var death_particle: String = "blood"
@export var enemy_dying: AudioStream


@export var achievement_will_gain:String = ""

@export var id: int = 0

@export var attacks_name:Array[String] = []
@export var def_stats: int = 1
@export var setted_HP: float = 50
var current_attack_choice :int = -1
var attacks:Array[Dictionary] = []

var can_attack: bool = false

var damage_multiplier: float = 1

var playing_animation = false

func _ready() -> void:
	Events.connect("players_turn",allow_attack)
	Events.connect("enemies_turn",_attacked_player)
	Events.connect("give_side_effects_to_enemies", _add_status)
	Events.connect("id_effect_chosen", _add_status_id)
	
	for i in attacks_name:
		attacks.append(EnemyAttacks.get(i))
func allow_attack():
	playing_animation = false
func _add_status_id(targeted_id: int,status:String):
	if targeted_id != id:
		return
		
	if $enemy_stats.get_node("HP").value == 0:
		return
	var type = ListEnemyStatusEffects.get(status).instantiate()
	type.name = status
	$status.add_child(type, true)

func _add_status(status:String):
	if $enemy_stats.get_node("HP").value == 0:
		return
	var type = ListEnemyStatusEffects.get(status).instantiate()
	type.name = status
	$status.add_child(type, true)
	
func _attacked_player(attack_id):
	if playing_animation == true:
		return
	playing_animation = true
	if current_attack_choice  >= attacks.size() -1:
		current_attack_choice = 0
	else:
		current_attack_choice += 1
	var sentence = ""
	
	if attack_id != id:
		return
	
	var damage =(attacks[current_attack_choice].get("damage")) * damage_multiplier
	
	sentence = name+ " use " + attacks[current_attack_choice].get("name")
	#yes kallum i used ai for this if statement lmao

	var all_effects = attacks[current_attack_choice]["status_effects"]
	for effect in all_effects: 
		Events.emit_signal("give_side_effects", effect)
	if attacks[current_attack_choice]["buff"] != null:
		var all_buffs = attacks[current_attack_choice]["buff"]
		for effect in all_buffs: 
			Events.emit_signal("give_side_effects_to_enemies", effect)
	if get_tree() == null:
		return
	Events.emit_signal("update_display", sentence)
	Events.emit_signal("damaged_player", damage, attacks[current_attack_choice].get("animation"), name)
	



	

	
