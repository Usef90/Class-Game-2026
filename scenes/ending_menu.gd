extends Node2D

var not_vegan = ["beef_patty","cheese","bacon","chicken","fish"]
var vegan = ["lettuce","pickle","clover","nuts"]
var vegan_teacher_unimpress: bool = true
var vegan_teacher_impress: bool = true
var pickle:bool = true
var nut:bool = true
var fih:bool = true

func _ready() -> void:
	if PlayerStats.upgrades == [] and !Globals.achievements["nothing_burger"]:
		Globals.achievements["nothing_burger"] = true
		vegan_teacher_unimpress = false
		vegan_teacher_impress = false
		pickle = false
	else:
		for i in PlayerStats.upgrades:
			if Globals.achievements["meat_eater"]: break
			if i["id"] not in not_vegan:
				vegan_teacher_unimpress = false
				break
		for i in PlayerStats.upgrades:
			if Globals.achievements["vegan"]: break
			if i["id"] not in vegan:
				vegan_teacher_impress = false
				break
		for i in PlayerStats.upgrades:
			if Globals.achievements["pickle"]: break
			if i["id"] != "pickle":
				pickle = false
				break
		for i in PlayerStats.upgrades:
			if Globals.achievements["nuts"]: break
			if i["id"] != "nuts":
				nut = false
				break
		for i in PlayerStats.upgrades:
			if Globals.achievements["fih"]: break
			if i["id"] != "fish":
				fih = false
				break
	
	Globals.achievements["meat_eater"] = vegan_teacher_unimpress
	Globals.achievements["vegan"] = vegan_teacher_impress
	Globals.achievements["pickle"] = pickle
	Globals.achievements["nuts"] = nut
	Globals.achievements["fih"] = fih
			
func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	PlayerStats.player_gold =20
	PlayerStats.attacks = []
	PlayerStats.upgrades = []
	Globals.level = 1


func _on_replay_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
