extends Node

class_name effects_base


var types_of_effect = ["lethal", "buff"]


@export var effect_name = ""

@export var stackable: bool = false

@export var type = "lethal"
@export var damage: float
@export var target_stats: String = ""
@export var duration: int = 5
@export var Effect_strength: float = 1.2

@export_multiline var discription: String = ""

		
