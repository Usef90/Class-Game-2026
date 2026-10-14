extends Node2D




var passives = []
var lettuce = preload("res://Art/lectuce.png")
var beef_patty = preload("res://Art/patty.png")
var cheese = preload("res://Art/cheese.png")
var bacon = preload("res://Art/bacon.png")
var pickle = preload("res://Art/pickle.png")
var chicken = preload("res://Art/fried_chicken.png")
var clover = preload("res://Art/clover.png")
var nuts = preload("res://Art/peanut.png")
var fish = preload("res://Art/fish.png")
const gap_size: float = 15
const offset: float = 60
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	passives = PlayerStats.upgrades
	for i in range(passives.size()):
		var toppings = Sprite2D.new()
		toppings.position.y = i  * -gap_size - offset
		toppings.texture = get(passives[i]["id"])
		$toppings_group.add_child(toppings)

	
