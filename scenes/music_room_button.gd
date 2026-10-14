extends Button

@export var music_name:String = ""



func _on_button_down() -> void:
	AudioManager.play(music_name)
