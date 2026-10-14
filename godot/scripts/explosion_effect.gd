extends Node
@export var particle_list:Array[GPUParticles2D] = []
## explosion_manager.gd  (autoload: "Explosions")
##
## Global entry point for the death-explosion VFX. Call this from anywhere
## a player or enemy dies:
##
##   Explosions.spawn(global_position)
##
## It instances explosion_effect.tscn at the given position, parents it to
## the current scene (or a parent you pass in), and the effect frees itself
## once it's done playing -- no cleanup needed on your end.

const ExplosionEffectScene := preload("res://scenes/explosion_effect.tscn")

func _ready() -> void:
	for i in particle_list:
		i.emitting = true
		
func _on_sparks_finished() -> void:
	queue_free()
