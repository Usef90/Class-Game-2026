class_name DialogueEntry
extends Resource

@export var character_name: String = ""
@export var portrait: Texture2D
@export_multiline var paragraphs: String = "" 

@export var music: String = ""
@export var voice: AudioStream 

@export var speak_speed: float = 30
# This forces the big text box!
