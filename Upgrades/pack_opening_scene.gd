extends Control

# Signal emitted when the player successfully chooses an upgrade
signal item_chosen(item_data: Dictionary)

@export var card_scene: PackedScene = preload("res://Upgrades/upgrade_pack.tscn")

@onready var choices_container: Control = $VBoxContainer/ChoicesContainer
@onready var title_label: Label = $VBoxContainer/PackTitleLabel
@onready var pack_opener: Node2D = $PackOpener  # instance of res://ShopStuff/pack_opener.tscn

# How long the pack sits on screen (post-intro, pre-pop) so the player
# actually registers it before it explodes.
@export var anticipation_delay: float = 0.5

# Flag to block hover tooltips while opening animations are playing
var can_hover_cards: bool = false


func open_pack(upgrade_pool: Array) -> void:
	# 1. Block hovering and input while opening animation plays
	can_hover_cards = false
	choices_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 2. Show the overlay screen and hide reward UI elements
	visible = true
	title_label.modulate.a = 0.0
	choices_container.modulate.a = 0.0

	# 3. Clear out any old choices left over from previous openings
	for child in choices_container.get_children():
		child.queue_free()

	# 4. Pick up to 3 unique rewards from the pool
	var pool_copy := upgrade_pool.duplicate()
	var choices := []
	for i in range(3):
		if pool_copy.is_empty():
			break
		var chosen_option = pool_copy.pick_random()
		choices.append(chosen_option)
		pool_copy.erase(chosen_option)

	# 5. Instantiate the chosen option cards (invisible for now)
	for option_data in choices:
		var card = card_scene.instantiate()
		choices_container.add_child(card)
		_populate_card(card, option_data)

	# 6. Play the pop sequence
	pack_opener.reset()
	pack_opener.show()
	pack_opener.play_intro()

	await get_tree().create_timer(anticipation_delay).timeout

	pack_opener.open_pack()
	await pack_opener.pack_opened

	# 7. Reveal the reward cards now that the pack exploded
	var reveal_tween := create_tween()
	reveal_tween.tween_property(title_label, "modulate:a", 1.0, 0.25)
	reveal_tween.parallel().tween_property(choices_container, "modulate:a", 1.0, 0.25)

	await reveal_tween.finished

	# 8. Re-enable mouse interaction now that cards are visible
	choices_container.mouse_filter = Control.MOUSE_FILTER_STOP
	can_hover_cards = true


func _populate_card(card: Control, option_data: Dictionary) -> void:
	# Safely grab child text and image nodes
	var name_label = card.get_node_or_null("NameLabel")
	var price_label = card.get_node_or_null("PriceLabel")
	var effect_label = card.get_node_or_null("EffectLabel")
	var icon_rect = card.get_node_or_null("Background")
	var buy_button = card.get_node_or_null("BuyButton")

	if not icon_rect:
		icon_rect = card.get_node_or_null("ItemIcon")

	# Populate visual text data
	if name_label:
		name_label.text = option_data.get("display_name", "")
	if effect_label:
		effect_label.text = option_data.get("effect", "")
	if price_label:
		price_label.text = "CHOOSE!"

	# Assign artwork texture
	if icon_rect and option_data.has("icon"):
		icon_rect.texture = option_data["icon"]

	# Connect button click
	if buy_button:
		buy_button.pressed.connect(func(): _on_reward_selected(option_data))

	# Hover tooltip (guarded by can_hover_cards flag)
	card.mouse_entered.connect(func():
		if can_hover_cards:
			HoverTooltip.show_at(card, option_data.get("display_name", ""), option_data.get("effect", ""))
	)
	card.mouse_exited.connect(func():
		HoverTooltip.hide_tooltip(card)
	)


func _on_reward_selected(chosen_data: Dictionary) -> void:
	can_hover_cards = false
	HoverTooltip.hide_tooltip()

	# Emit choice back to ShopScene
	item_chosen.emit(chosen_data)

	# Hide the pack scene
	visible = false
