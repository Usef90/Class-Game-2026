extends TextureRect
## black_flash_card.gd
## Same input/energy/targeting logic as your normal card.gd, so it behaves
## identically from battle_logic's point of view. The difference is entirely
## in what happens between "energy spent" and "damage applied":
## normal card -> damage this frame.
## black flash  -> spend energy, play cutscene, play minigame, THEN damage,
##                 scaled by how well you did in the minigame.
##
## SETUP:
## - card_name / discription / energy: same as any card, set in Inspector.
## - base_damage: the damage dealt on a perfect minigame run. Worse runs
##   deal a fraction of this (see damage_multiplier_for_accuracy below).
## - cutscene_scene: a PackedScene with a script exposing
##       func play(player_portrait: Texture2D, enemy_portrait: Texture2D) -> void
##   that awaits its own animation and returns when done (see
##   black_flash_cutscene.gd).
## - minigame_scene: a PackedScene with a script exposing
##       signal finished(accuracy: float)  # 0.0 - 1.0
##       func start() -> void
##   (see black_flash_minigame.gd).
## - player_portrait / enemy_portrait: textures passed into the cutscene.
##   Drag whatever "burger bun" / "monkey" art you want here.

var card_id: int = 0
var can_attack = false
var selected_card: bool = false
var mouse_is_incard: bool = false
var in_attack_area: bool = false
var card_number: int = 0

const POSITION_OF_CARDS: Array = [
	Vector2(100, 500),
	Vector2(250, 500),
	Vector2(400, 500),
	Vector2(550, 500),
	Vector2(700, 500),
	Vector2(850, 500)]

@export var card_name: String = "Black Flash"
@export_multiline var discription: String = "A high-cost gamble. Land the timing and it hits like nothing else."
@export var base_damage: float = 60.0
@export var energy: float = 40.0
@export var effects: Array[String]
@export var effects_for_enemies: Array[String]
@export var AOE: bool = false
@export var lucky: bool = false

@export_group("Black Flash Sequence")
@export var cutscene_scene: PackedScene
@export var minigame_scene: PackedScene
@export var player_portrait: Texture2D
@export var enemy_portrait: Texture2D

# Below this accuracy, treat it as a total whiff -- deals minimum damage
# rather than scaling smoothly all the way to zero, so a total miss still
# feels like "the attack happened" rather than "nothing happened."
@export var min_damage_multiplier: float = 0.25

var _is_resolving: bool = false

func _input(event: InputEvent) -> void:
	if _is_resolving:
		return
	if event.is_action_pressed("click") and !selected_card and mouse_is_incard:
		selected_card = true
	if event.is_action_released("click") and selected_card:
		var target_id = get_area_under_mouse()
		var valid_single_target = (!AOE and target_id != null)
		var valid_aoe_target = (AOE and in_attack_area)
		if in_attack_area and can_attack and (valid_single_target or valid_aoe_target):
			var chance = randf_range(0, 100)
			_drop(target_id)
			if lucky and chance < PlayerStats.luck:
				Events.emit_signal("give_side_effects", "lucky_debuff")
		else:
			selected_card = false

func _drop(target_id = null) -> void:
	if !can_attack or _is_resolving:
		return

	_is_resolving = true
	selected_card = false
	visible = false # card is "committed" -- pull it out of the hand visually now

	Events.emit_signal("reduce_energy_by", energy)

	var accuracy := await _play_black_flash_sequence()
	var final_damage := base_damage * _damage_multiplier_for_accuracy(accuracy)

	if AOE:
		Events.emit_signal("damaged_enemy", final_damage)
		for effect in effects_for_enemies:
			Events.emit_signal("give_side_effects_to_enemies", effect)
	elif target_id != null:
		Events.emit_signal("id_chosen", target_id, final_damage)
		for effect in effects_for_enemies:
			Events.emit_signal("id_effect_chosen", target_id, effect)

	for effect in effects:
		Events.emit_signal("give_side_effects", effect)

	Events.emit_signal("update_id")

	# Hand turn flow back to the normal players_turn -> enemies_turn cycle.
	Events.emit_signal("players_turn")

	queue_free()

func _play_black_flash_sequence() -> float:
	var accuracy := 1.0

	if cutscene_scene:
		var cutscene = cutscene_scene.instantiate()
		get_tree().root.add_child(cutscene)
		if cutscene.has_method("play"):
			await cutscene.play(player_portrait, enemy_portrait)
		cutscene.queue_free()

	if minigame_scene:
		var minigame = minigame_scene.instantiate()
		get_tree().root.add_child(minigame)
		if minigame.has_signal("finished") and minigame.has_method("start"):
			minigame.start()
			accuracy = await minigame.finished
		minigame.queue_free()

	return clamp(accuracy, 0.0, 1.0)

func _damage_multiplier_for_accuracy(accuracy: float) -> float:
	# Smooth scale from min_damage_multiplier (total miss) up to 1.0
	# (perfect run), with a little extra kick above ~90% accuracy to make a
	# genuinely clean run feel like a real "critical hit" moment.
	if accuracy >= 0.9:
		return lerp(1.0, 1.5, (accuracy - 0.9) / 0.1)
	return lerp(min_damage_multiplier, 1.0, accuracy / 0.9)

func _process(_delta: float) -> void:
	if _is_resolving:
		return
	if position.x > 235 and position.x < 2000 and position.y > 44 and position.y < 400:
		in_attack_area = true
	else:
		in_attack_area = false
	if !selected_card:

		if card_id >= 0 and card_id < POSITION_OF_CARDS.size():
			position = POSITION_OF_CARDS[card_id]
		else:
			# Fallback so it doesn't crash if card_id is too high
			push_warning("Card ID %d out of bounds! Clamping..." % card_id)
			position = POSITION_OF_CARDS[clamp(card_id, 0, POSITION_OF_CARDS.size() - 1)]
	else:
		position = get_global_mouse_position() + Vector2(-100, -100)

func get_area_under_mouse():
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()

	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results = space_state.intersect_point(query)
	if results.size() > 0:
		var area = results[0]["collider"] as Area2D
		return area.get_parent().id
	return null

func _ready() -> void:
	can_attack = true
	Events.connect("total_energy", _stop_fighting)
	Events.connect("players_turn", _can_attack)

func _stop_fighting(total_energy):
	if total_energy < energy:
		can_attack = false

func _can_attack():
	can_attack = true

func _on_mouse_entered() -> void:
	mouse_is_incard = true

func _on_mouse_exited() -> void:
	mouse_is_incard = false
