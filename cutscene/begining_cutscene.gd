extends Node2D

var current = 0
var playing = false
var dialogue_tween: Tween


@export_multiline var pannel_1 ="" 
@export_multiline var pannel_2 ="" 
@export_multiline var pannel_3 ="" 

@export_multiline var pannel_4 ="" 
@export_multiline var pannel_5 ="" 
@export_multiline var pannel_6 ="" 

const image1 = preload("res://Art/cutscene/once a time.png")
const image2 = preload("res://Art/cutscene/what the hell.png")
const image3 = preload("res://Art/cutscene/lore 3.png")
const image4 = preload("res://Art/cutscene/lore 4.png")
const image5 = preload("res://Art/cutscene/lore6.png")
const image6 = preload("res://Art/cutscene/lore5.png")

func _ready() -> void:
	_change_stuff(pannel_1, image1, 40)
	
	
	

func _change_stuff(dialogue, image, speed):
	playing = true
	current += 1
	$Panel/Label.visible_characters = 0
	$TextureRect.texture = image
	$Panel/Label.text = dialogue
	
	dialogue_tween = create_tween()
	dialogue_tween.tween_property($Panel/Label, "visible_characters",dialogue.length(), dialogue.length()/speed)
	dialogue_tween.play()
	dialogue_tween.finished.connect(func(): playing = false)

func _input(event: InputEvent) -> void:
	if !playing:
		if Input.is_action_just_pressed("click") and current == 1:
			_change_stuff(pannel_2, image2, 40)
		elif Input.is_action_just_pressed("click") and current == 2:
			_change_stuff(pannel_3, image3, 40)
		elif Input.is_action_just_pressed("click") and current == 3:
			_change_stuff(pannel_4, image4, 40)
		elif Input.is_action_just_pressed("click") and current == 4:
			_change_stuff(pannel_5, image5, 40)
		elif Input.is_action_just_pressed("click") and current == 5:
			_change_stuff(pannel_6, image6, 40)
		elif Input.is_action_just_pressed("click") and current == 6:
			TransitionManager.play_transition("res://scenes/level_select.tscn")
	else:
		if Input.is_action_just_pressed("click"):
			dialogue_tween.kill()
			$Panel/Label.visible_characters = -1 
			playing = false


func _on_button_button_down() -> void:
	TransitionManager.play_transition("res://scenes/level_select.tscn")
