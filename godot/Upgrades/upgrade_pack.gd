extends Control

@onready var name_label = $NameLabel
@onready var price_label = $PriceLabel
@onready var buy_button = $BuyButton

# Variables to remember what this specific card is selling
var current_item_name: String = ""
var current_item_price: int = 0

func _ready():
	buy_button.pressed.connect(_on_buy_button_pressed)

# The shop connects to this Kevin so uhhh don't touch this
func setup_item(item_name: String, price: int):
	current_item_name = item_name
	current_item_price = price
	
	name_label.text = current_item_name
	price_label.text = str(current_item_price) + " Gold"

func _on_buy_button_pressed():
	print("Player is trying to buy: ", current_item_name)
	
