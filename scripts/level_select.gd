extends Control

@onready var top_scroll = $TopScrollContainer
@onready var map_scroll = $MapScrollContainer
@onready var hbox = $TopScrollContainer/HBoxContainer
@onready var godot_guy = $MapScrollContainer/Control/TextureRect

# Level Preview UI References
@onready var info_panel = $LevelInfoPanel            
@onready var enemy_preview = $LevelInfoPanel/EnemyIcon 
@onready var stage_title = $LevelInfoPanel/StageTitle 

var level_cards: Array = []
var current_level_index: int = 0
var target_scroll_x: float = 0.0

var level_preview_data: Dictionary = {
	"Tutorial": {
		"title": "Tutorial Stage",
		"icon": "res://Art/john_test.png",
		"description": "John Smith is a very kind and grateful person. Every time he gets low he has to pop ult. He is not a fraud, but the kindest jjs player know to man kind."
	},
	"Level_1": {
		"title": "Stage 1: The Streets",
		"icon": "res://Art/tetoPortraits.png",
		"description": "Random people go."
	},
	"Level_2": {
		"title": "Boss: Socrates",
		"icon": "res://Art/socrates.png",
		"description": "It's the guy who was ragebaiting the skeleton. 
		Why is here in this game? I do not know, but his ragebait technique apparently makes your defence low.
		You can cheese the weaken by just blocking. Intentional game design"
	},
	"Level_3": {
		"title": "Boss: Ivan the Van",
		"icon": "res://Art/ivanthevanprotrait.png",
		"description": "Don't let Ivan the van get you.
		Buddy thinks block would do stuff or something."
	},
	"Level_4": {
		"title": "Boss: Fake Italian Guys",
		"icon": "res://Art/furryKing.png",
		"description": "There is no limit to the larp! 
		They are going to team so it would be very smart to spam Aoe attacks instead of using single attacks."
	},
	"Level_5": {
		"title": "Boss: Cone L",
		"icon": "res://Art/coneL.png",
		"description": "Cat boy ice cream shop?
		He hits hard and heal himself. Just out last him and you will win."
	},
	"Level_6": {
		"title": "Boss: Ze Monke",
		"icon": "res://Art/zemonke.png",
		"description": "A monkey with nuclear weapons.
		Kill him before he nukes you."
	},
	"Level_7": {
		"title": "Boss: Bok choi",
		"icon": "res://Art/bokchoi.png",
		"description": "A peaceful Bok Choy farmer"
	},
	"Level_8": {
		"title": "Boss: That JJS fraud guy",
		"icon": "res://Art/big_wang.png",
		"description": "Mango Maid Cafe
		Trust me this guy is a fraud."
	},
	"Level_9": {
		"title": "Boss: Me67",
		"icon": "res://Art/me67.png",
		"description": "It's the bum that threw you away.
		At this point... words are unnecessary!"
	},
	"Level_10": {
		"title": "Boss: insert Anime girl",
		"icon": "res://Art/anime girl ig.png",
		"description": "Government is going to experiment on you."
	}
}

func _player_stats_change():
	PlayerStats.player_hitpoint = 100
	PlayerStats.luck = 20
	PlayerStats.player_max_energy = 50
	PlayerStats.player_recovery = 15
	PlayerStats.player_aoe_damage = 1
	PlayerStats.player_single_damage = 1
	PlayerStats.player_damage = 1
	PlayerStats.player_hitpoint_recovery = 0
	for i in PlayerStats.upgrades:
		if i["id"] == "lettuce":
			PlayerStats.player_hitpoint += 30
		if i["id"] == "beef_patty":
			PlayerStats.player_damage += 0.10
		if i["id"] == "cheese":
			PlayerStats.player_recovery += 4
		if i["id"] == "bacon":
			PlayerStats.player_hitpoint_recovery += 5
		if i["id"] == "pickle":
			PlayerStats.player_damage += 0.05
			PlayerStats.player_hitpoint += 15
		if i["id"] == "chicken":
			PlayerStats.player_recovery += 3
			PlayerStats.player_max_energy += 10
		if i["id"] == "clover":
			PlayerStats.luck += 10
		if i["id"] == "fish":
			PlayerStats.player_aoe_damage += 0.125
		if i["id"] == "nuts":
			PlayerStats.player_single_damage += 0.125
func _ready():
	_player_stats_change()
	AudioManager.play("LevelSelect")
	level_cards = hbox.get_children()

	if has_node("LeftButton"): $LeftButton.pressed.connect(_on_left_button_pressed)
	if has_node("RightButton"): $RightButton.pressed.connect(_on_right_button_pressed)
	if has_node("PlayButton"): $PlayButton.pressed.connect(_on_play_button_pressed)
	
	await get_tree().process_frame

	_snap_to_level(Globals.level - 1)

	top_scroll.scroll_horizontal = target_scroll_x
	map_scroll.scroll_horizontal = target_scroll_x
	var active_card = level_cards[current_level_index]
	var card_center_global_x = active_card.global_position.x + (active_card.size.x / 2)
	godot_guy.global_position.x = card_center_global_x - (godot_guy.size.x / 2)

func _process(_delta):
	if level_cards.size() == 0: return

	top_scroll.scroll_horizontal = lerp(float(top_scroll.scroll_horizontal), target_scroll_x, 0.1)
	map_scroll.scroll_horizontal = top_scroll.scroll_horizontal

	var active_card = level_cards[current_level_index]
	var card_center_global_x = active_card.global_position.x + (active_card.size.x / 2)
	var target_guy_global_x = card_center_global_x - (godot_guy.size.x / 2)
	godot_guy.global_position.x = lerp(godot_guy.global_position.x, target_guy_global_x, 0.15)
	if info_panel:
		info_panel.global_position = active_card.global_position
	
func _snap_to_level(index: int):
	current_level_index = clamp(index, 0, level_cards.size() - 1)
	var active_card = level_cards[current_level_index]

	var screen_center_offset = top_scroll.size.x / 2
	var card_center = active_card.position.x + (active_card.size.x / 2)
	
	target_scroll_x = card_center - screen_center_offset
	
	# Call update whenever level snaps
	_update_level_preview(active_card.name)

func _update_level_preview(card_name: String):
	if level_preview_data.has(card_name):
		var data = level_preview_data[card_name]
		
		if stage_title:
			stage_title.text = data["title"]
			
		if enemy_preview and ResourceLoader.exists(data["icon"]):
			enemy_preview.texture = load(data["icon"])
			$Panel/Label.text =  data["description"]
		if info_panel:
			info_panel.visible = true

func _on_left_button_pressed():
	_snap_to_level(current_level_index - 1)

func _on_right_button_pressed():
	_snap_to_level(current_level_index + 1)

func _on_play_button_pressed():
	var current_level_node = level_cards[current_level_index]
	var dest_scene: String = ""
	
	if (current_level_node.name == "Card_Cambodia" or current_level_node.name == "Tutorial") and (Globals.level ==1 or Globals.level >11):
		dest_scene = "res://scenes/battle_scene.tscn"
	elif (current_level_node.name == "Card_Philippines" or current_level_node.name == "Level_1") and (Globals.level ==2 or Globals.level >11):
		dest_scene = "res://scenes/level1.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_2") and (Globals.level ==3 or Globals.level >11):
		dest_scene = "res://scenes/socrates_boss_1.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_3") and (Globals.level ==4 or Globals.level >11):
		dest_scene = "res://scenes/ivan_the_van.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_4") and (Globals.level ==5 or Globals.level >11):
		dest_scene = "res://scenes/fake_italian_guys.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_5") and (Globals.level ==6 or Globals.level >11):
		dest_scene = "res://scenes/cone_l.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_6") and (Globals.level ==7 or Globals.level >11):
		dest_scene = "res://scenes/zemonke.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_7") and (Globals.level ==8 or Globals.level >11):
		dest_scene = "res://scenes/bok_choi.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_8") and (Globals.level ==9 or Globals.level >11):
		dest_scene = "res://scenes/big_wang.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_9") and (Globals.level ==10 or Globals.level >11):
		dest_scene = "res://scenes/me_67.tscn"
	elif (current_level_node.name == "Card_Japan" or current_level_node.name == "Level_10") and (Globals.level ==11 or Globals.level >11):
		dest_scene = "res://scenes/final.tscn"
		
	if dest_scene != "":
		TransitionManager.play_transition(dest_scene)


func _on_go_back_button_button_down() -> void:
	TransitionManager.play_transition("res://scenes/main_menu.tscn")


func _on_shop_pressed() -> void:
	TransitionManager.play_transition("res://ShopStuff/shop_scene.tscn")
