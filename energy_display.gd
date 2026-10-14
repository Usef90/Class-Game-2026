extends Label

var max_energy: float

var total_energy: float
var total_regeneration: float

func _ready() -> void:
	$"../flash".play("RESET")
	total_regeneration = PlayerStats.player_recovery
	max_energy = PlayerStats.player_max_energy
	total_energy = 10
	$"../energyBar".max_value = max_energy
	$"../energyBar".value = 10
	text = str(total_energy)
	Events.connect("reduce_energy_by", _reduced_energy)
	Events.connect("players_turn", _regenerate_energy)
	
func _regenerate_energy():
	$"../flash".stop()
	total_energy += total_regeneration
	$"../energyBar".value = total_energy
	if total_energy >= max_energy:
		total_energy = max_energy

	$"../ColorRect".visible = false
	
	text = str(total_energy)
func _reduced_energy(cost: float):
	if cost<= total_energy:
		total_energy -= cost
	$"../energyBar".value = total_energy
	if total_energy ==0:
		$"../flash".play("flash")
	Events.emit_signal("total_energy", total_energy)
	text = str(total_energy)
	
