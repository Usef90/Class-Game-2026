extends Control

## are we going to have dialogues

var count: int = 0
var current_dialogue: Array # a custom resource in it
var doing_dialogue: bool = false

# writer setting but is changed via the custom resource of the diagolue
var characters_per_second: float = 30.0
var tween: Tween
var is_typing: bool = false

func _ready() -> void:
	Events.connect("dialogue", _set_up)

func _set_up(dialgoue: Array):
	
	current_dialogue = dialgoue
	doing_dialogue = true
	count = 0
	
	_say_stuff()

func _process(_delta: float) -> void:
	if !doing_dialogue:
		return
	
	if Input.is_action_just_pressed("click"):
		
		if is_typing:
			_complete_text_instantly()
		else:
			count += 1
			if count > current_dialogue.size() - 1:
				_end_dialogue()
			else:
				_say_stuff()

func _say_stuff():
	if count > current_dialogue.size() - 1:
		return
		
	if current_dialogue[count].music != "":
		AudioManager.play(current_dialogue[count].music)
		
	visible = true
	$Name.text = current_dialogue[count].character_name
	$protraits.texture = current_dialogue[count].portrait
	characters_per_second = current_dialogue[count].speak_speed

	var paragraph_node = $Panel/paragraph
	var full_text: String = current_dialogue[count].paragraphs
	
	paragraph_node.text = full_text
	paragraph_node.visible_characters = 0  
	
	var total_chars = full_text.length()
	if total_chars == 0:
		return


	if tween and tween.is_running():
		tween.kill()

	is_typing = true
	var duration = total_chars / characters_per_second
	

	tween = create_tween()
	tween.tween_property(paragraph_node, "visible_characters", total_chars, duration)

	tween.step_finished.connect(_on_character_revealed)

	tween.finished.connect(func(): is_typing = false)

func _on_character_revealed(_idx: int) -> void:
	var paragraph_node = $Panel/paragraph
	var current_idx = paragraph_node.visible_characters - 1
	
	if current_idx >= 0 and current_idx < paragraph_node.text.length():

		var char_at_idx = paragraph_node.text[current_idx]
		if char_at_idx != " " and char_at_idx != "\n":
			#  does not work could not be bother to fix
			if current_dialogue[count].voice:
				AudioManager.play_oneshot(current_dialogue[count].voice)

func _complete_text_instantly() -> void:
	if tween and tween.is_running():
		tween.kill()
	$Panel/paragraph.visible_characters = -1  
	is_typing = false

func _end_dialogue() -> void:
	if tween and tween.is_running():
		tween.kill()
	visible = false
	count = 0
	doing_dialogue = false
	Events.emit_signal("players_turn")

func _on_skip_dialogue_button_down() -> void:
	_end_dialogue()
