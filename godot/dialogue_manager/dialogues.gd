extends Control

var count: int = 0
var current_dialogue: Array
var doing_dialogue: bool = false

# --- Typewriter Settings ---
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
		
		# IF TYPING: Skip the typing animation and instantly reveal all text
		if is_typing:
			_complete_text_instantly()
		# IF DONE TYPING: Advance to the next line of dialogue
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
	# Setup paragraph text
	var paragraph_node = $Panel/paragraph
	var full_text: String = current_dialogue[count].paragraphs
	
	paragraph_node.text = full_text
	paragraph_node.visible_characters = 0  # Hide text initially
	
	var total_chars = full_text.length()
	if total_chars == 0:
		return

	# Stop previous tween if active
	if tween and tween.is_running():
		tween.kill()

	is_typing = true
	var duration = total_chars / characters_per_second
	
	# Animate visible_characters from 0 to full length
	tween = create_tween()
	tween.tween_property(paragraph_node, "visible_characters", total_chars, duration)
	
	# Play blip sound whenever a new character is revealed
	tween.step_finished.connect(_on_character_revealed)
	
	# Mark typing as finished when tween completes
	tween.finished.connect(func(): is_typing = false)

func _on_character_revealed(_idx: int) -> void:
	var paragraph_node = $Panel/paragraph
	var current_idx = paragraph_node.visible_characters - 1
	
	if current_idx >= 0 and current_idx < paragraph_node.text.length():
		# Avoid playing voice sound on spaces/newlines
		var char_at_idx = paragraph_node.text[current_idx]
		if char_at_idx != " " and char_at_idx != "\n":
			# Ensure you have an AudioStreamPlayer node named VoiceSound!
			if current_dialogue[count].voice:
				AudioManager.play_oneshot(current_dialogue[count].voice)

func _complete_text_instantly() -> void:
	if tween and tween.is_running():
		tween.kill()
	$Panel/paragraph.visible_characters = -1  # Show all characters
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
