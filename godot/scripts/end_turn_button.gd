extends Button

var animation_playing: bool = false

var enemy_id_turn: int
@onready var card_in_hand: Control
var battle_logic_script: Node
var enemy_list: Node2D
var total_enemies: int

func _ready() -> void:
	battle_logic_script = $"../../BattleLogic"
	card_in_hand = get_parent().get_node("cards")
	enemy_list = $"../../enemies"
	total_enemies = enemy_list.get_child_count() -1
	enemy_id_turn = total_enemies
	Events.connect("damaged_player", playing_animation)
	Events.connect("players_turn", stop_animation)
	$"../You won".visible = false
func playing_animation():
	animation_playing = true

func stop_animation():
	animation_playing = false


func _on_button_down() -> void:
	if battle_logic_script.current_state != battle_logic_script.States.players_turn:
		return
	if animation_playing:
		return
	var children = enemy_list.get_children()
	
	for index in range(children.size()):
		children[index].id = index
	total_enemies = enemy_list.get_child_count() -1
	enemy_id_turn +=1
	if enemy_id_turn > total_enemies:
		enemy_id_turn = 0
	Events.emit_signal("enemies_turn", enemy_id_turn)

	


func _on_next_button_down() -> void:
	TransitionManager.play_transition("res://scenes/level_select.tscn")


func _on_play_testing_purpose_button_down() -> void:
	for i in enemy_list.get_children():
		i.queue_free()


func _on_ending_cutscene_button_down() -> void:
	get_tree().change_scene_to_file("res://cutscene/ending_cutscene.tscn")
