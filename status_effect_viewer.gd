extends Panel


const offset = Vector2(-50, -20)

func _ready() -> void:
	Events.connect("show_status_text", _show_text)
	Events.connect("hide_status_text", _hide_text)

func _process(delta: float) -> void:
	position = get_viewport().get_mouse_position()  + offset
	
func _show_text(text: String):
	$giga_label.text = text
	visible = true
	
func _hide_text():
	visible = false
