extends TextureRect


var card_id: int = 0


var can_attack = false

var selected_card: bool = false
var mouse_is_incard: bool = false

var in_attack_area: bool = false

var luck: int = 0

var card_number: int =0
const POSITION_OF_CARDS:Array = [
	Vector2(100,500),
	Vector2(250,500),
	Vector2(400,500),
	Vector2(550,500),
	Vector2(700,500),
	Vector2(850,500)]

@export var card_name: String = "aksknfk"
@export_multiline var discription: String  = "aksknfk"

@export var damage: float = 2
@export var energy: float = 10

@export var effects: Array[String]
@export var effects_for_enemies: Array[String]

@export var AOE: bool
@export var lucky: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and !selected_card and mouse_is_incard:
		selected_card = true

	if event.is_action_released("click") and selected_card:
		var target_id = get_area_under_mouse()
		var valid_single_target = (!AOE and target_id != null)
		var valid_aoe_target = (AOE and in_attack_area)

		if in_attack_area and can_attack and (valid_single_target or valid_aoe_target):
			var chance = randf_range(0, 100)
			if PlayerStats.luck > 95:
				luck = 95
			else:
				luck = PlayerStats.luck
			_drop(target_id)
			Events.emit_signal("update_id")
			if lucky and chance > luck:
				Globals.failure_counter += 1
				Events.emit_signal("give_side_effects", "lucky_debuff")
				if Globals.failure_counter == 3:
					Globals.achievements["oil_up"] = true
			else:
				Globals.failure_counter =0
		else:
			selected_card = false


func _drop(target_id = null) -> void:
	if !can_attack:
		return

	Events.emit_signal("reduce_energy_by", energy)

	if AOE:
		Events.emit_signal("damaged_enemy", damage)
		for effect in effects_for_enemies: 
			Events.emit_signal("give_side_effects_to_enemies", effect)
	elif target_id != null:
		Events.emit_signal("id_chosen", target_id, damage)
		for effect in effects_for_enemies: 
			Events.emit_signal("id_effect_chosen", target_id, effect)
	for effect in effects: 
		Events.emit_signal("give_side_effects", effect)
	

	queue_free()

func _process(_delta: float) -> void:
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
		position = get_global_mouse_position() + Vector2(-100,-100)
	
func get_area_under_mouse():
	var space_state = get_world_2d().direct_space_state
	var mouse_pos = get_global_mouse_position()
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true   # Must be true to look for Area2Ds
	query.collide_with_bodies = false # Ignore normal physics bodies
	
	var results = space_state.intersect_point(query)
	if results.size() > 0:
		var area = results[0]["collider"] as Area2D 
		return area.get_parent().id# Returns the underlying Area2D
	return null


func _ready() -> void:
	can_attack = true
	Events.connect("total_energy", _stop_fighting)
	Events.connect("players_turn", _can_attack)

func _stop_fighting(total_energy):
	if total_energy < energy:
		can_attack =  false
	
func _can_attack():
	can_attack =  true
	




func _on_mouse_entered() -> void:

	mouse_is_incard = true

func _on_mouse_exited() -> void:

	mouse_is_incard=false
