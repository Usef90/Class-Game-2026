extends Label

# Tell what action the enemies are doing.
# opposite of show not tell
func _ready() -> void:
	Events.connect("update_display", _change)
	visible = false
	
func _change(sentence):
	visible = true
	text = sentence
	await get_tree().create_timer(3).timeout
	visible = false
