extends TextureRect

class_name status_effect_icon

var text = ""
var is_hovered: bool = false

var effect_name: String=""

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not is_hovered:
		is_hovered = true
		Events.emit_signal("show_status_text", text)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_hovered:
		if not get_global_rect().has_point(get_global_mouse_position()):
			is_hovered = false
			Events.emit_signal("hide_status_text")
