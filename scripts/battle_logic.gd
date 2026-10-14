extends Node

var current_turn: int = 0

var enemy_id_turn: int = 0
@export var music_name: String
@export var total_enemies:int = 1
@export var ending_of_story: bool = false
@export var victory_gold: int = 10
@export var achievement_will_gain:String = ""
const MAX_CARDS = 6

var num_of_enemies: int = 0
var current_state
enum States{players_turn, enemies_turn, dialogue} 

var cards_can_spawn = [ "punch", "blocking",  "punch"]

var num_of_cards

var card_list: Control

var enemy_list: Node2D

var victory_panel: Panel
var victory: bool = false

var ending: Panel

var card_choice: int = 0

func _ready() -> void:
	AudioManager.play(music_name)
	for i in PlayerStats.attacks:
		cards_can_spawn.append(i["id"])
	enemy_list = $"../enemies"
	card_list = $"../UI/cards"
	card_list.child_order_changed.connect(_update_card_ids)
	num_of_cards = card_list.get_child_count()
	var children = $"../enemies".get_children()
	for index in range(children.size()):
		num_of_enemies += 1
		children[index].id = index
	current_state = States.players_turn
	victory_panel = get_parent().get_node("UI").get_node("victory")
	ending = get_parent().get_node("UI").get_node("You won")
	victory_panel.hide()
	Events.connect("players_turn", _players_turn)
	Events.connect("enemies_turn", _enemies_turn)
	Events.connect("dialogue", _dialogue)
	Events.connect("check_victory_conditions", _check_victory)
	Events.connect("attack_id", _spawn_attack_choice)
	
	_players_turn()
func _dialogue():
	current_state = States.dialogue
	

func _spawn_attack_choice():
	var choice = _spawn_attack_choice

func _players_turn():
	current_state = States.players_turn
	current_turn += 1
	num_of_cards = card_list.get_child_count()
	for i in card_list.get_children():
		i.queue_free()
	
	for i in range(MAX_CARDS):
		# Increment and automatically wrap around array size
		card_choice = (card_choice + 1) % cards_can_spawn.size()
		
		var card_key = cards_can_spawn[card_choice]
		var card_scene = ListOfCards.get(card_key)
		
		if card_scene:
			var new_card = card_scene.instantiate()
			new_card.card_id = i
			card_list.add_child(new_card)
		
		# Update all IDs sequentially now that the hand is full
	
	
	get_parent().get_node("player").get_node("player_stats").get_node("HP").value += PlayerStats.player_hitpoint_recovery
	get_parent().get_node("player").get_node("player_stats").get_node("Label").text = str(int(get_parent().get_node("player").get_node("player_stats").get_node("HP").value)) + "/" +str(int(get_parent().get_node("player").get_node("player_stats").get_node("HP").max_value))

# Cleaned-up sequential ID assignment function
func _update_card_ids() -> void:
	var children = card_list.get_children()
	num_of_cards = children.size()
	for index in range(children.size()):
		children[index].card_id = index
func _enemies_turn():
	
	current_state = States.enemies_turn
	
	num_of_cards = card_list.get_child_count()
func _process(_delta: float) -> void:
	_check_victory()
func _check_victory():
	
	if enemy_list.get_child_count()  == 0 and !victory and !ending_of_story:
		Globals.achievements[achievement_will_gain] = true
		victory = true
		Globals.level += 1
		victory_gold += int(PlayerStats.luck/5)
		PlayerStats.player_gold +=  victory_gold
		victory_panel.show()
		victory_panel.get_node("stuff you gain").text = "Gain: " + str(victory_gold) + " gold" + "
		Total gold: " + str(PlayerStats.player_gold)  
	elif enemy_list.get_child_count()  == 0 and !victory and ending_of_story:
		Globals.achievements[achievement_will_gain] = true
		victory = true
		Globals.level += 1
		ending.show()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
