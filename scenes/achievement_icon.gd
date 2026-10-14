extends Area2D

@export_multiline() var discripttion: String
@export var display_title: String

@export var achievement_name: String

var discription_text:Label
var title_name:Label
var panel: Panel

var Icon: Sprite2D
var MouseIsInArea = false

var Is_achieved: bool = false


func _ready() -> void:
	if Globals.achievements[achievement_name]:
		Is_achieved = true
		
	Icon = get_node("Icon")
	panel= get_parent().get_parent().get_parent().find_child("achievement_viewer")
	discription_text = panel.find_child("discription")
	title_name = panel.find_child("title")
	if !Is_achieved:
		Icon.modulate = Color(0.078, 0.078, 0.078, 1.0)

func _process(_delta: float) -> void:
	if MouseIsInArea:
		if Is_achieved:
			discription_text.text = discripttion
			title_name.text = display_title
		else:
			discription_text.text = discripttion
			title_name.text = "???"
		
	
func _on_mouse_entered() -> void:
	MouseIsInArea = true


func _on_mouse_exited() -> void:
	MouseIsInArea = false
	discription_text.text = ""
	title_name.text = ""
