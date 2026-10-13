extends Node2D
## black_flash_minigame.gd (v3 -- osu! style, mouse-driven)
##
## Circles appear on screen with a shrinking "approach ring." Click inside
## the circle right as the ring collapses onto it. Judged Perfect/Good/Miss
## by timing accuracy, same scoring shape as before.
##
## Fully self-contained: everything is drawn procedurally (no sprite sheet
## needed), no external autoload. Uses the same "click" input action your
## cards already use, so it matches your game's existing mouse controls.
##
## Interface (unchanged, so black_flash_card.gd needs no edits):
##   signal finished(accuracy: float)
##   func start() -> void

signal finished(accuracy: float)

# Each entry: [x_fraction, y_fraction, hit_time_in_seconds].
# x/y are fractions of the viewport (0.0-1.0) so layout is resolution
# independent. Keep this SHORT -- a few seconds, not a full song.
@export var chart: Array = [
	[0.30, 0.35, 132.865],
	[0.62, 0.30, 133.631],
	[0.45, 0.55, 134.374],
	[0.70, 0.50, 135.175],
	[0.28, 0.60, 135.953],
	[0.55, 0.40, 136.731],
	[0.40, 0.28, 137.497],
	[0.65, 0.62, 138.275],
	[0.30, 0.35, 139.053],
	[0.62, 0.30, 139.819],
	[0.45, 0.55, 140.597],
	[0.70, 0.50, 141.363],
	[0.28, 0.60, 142.141],
	[0.55, 0.40, 142.919],
	[0.40, 0.28, 143.697],
	[0.65, 0.62, 144.463],
	[0.30, 0.35, 145.218],
	[0.62, 0.30, 146.019],
	[0.45, 0.55, 146.785],
	[0.70, 0.50, 147.563],
	[0.28, 0.60, 148.341],
	[0.55, 0.40, 149.107],
	[0.40, 0.28, 149.885],
	[0.30, 0.35, 0.6], [0.62, 0.30, 1.15], [0.45, 0.55, 1.7],
	[0.70, 0.50, 2.25], [0.28, 0.60, 2.8], [0.55, 0.40, 3.35],
	[0.40, 0.28, 3.9], [0.65, 0.62, 4.45], [0.50, 0.45, 5.0],
]

@export var circle_radius: float = 48.0
@export var approach_time: float = 1.0 # seconds from ring appearing to landing
@export var approach_start_scale: float = 2.4
@export var perfect_window: float = 0.08 # seconds
@export var good_window: float = 0.18 # seconds
@export var end_padding: float = 1.0
@export var music_player_path: NodePath = ^"MusicPlayer"

@export_group("Difficulty")
# Higher = less reaction time per note (the approach ring collapses
# faster) -- this is PURELY visual/reaction-based and has zero effect on
# audio speed or pitch, unlike chart_time_scale below. Use this one if you
# want the click-timing challenge to be harder while the song (and its
# beat-sync) stays untouched. 1.5-2.5 is a reasonable "actually osu-like"
# range; 1.0 is the original easy pace.
@export var reaction_speed: float = 1.0

@export_group("Pacing")
# Scales every note's timing. 0.5 = notes arrive twice as fast (whole thing
# takes half as long). 2.0 = everything comes in at half speed. 1.0 = as
# authored/generated. NOTE: this also speeds up/slows down the music's
# pitch to match (see start()) -- it will desync from the song's actual
# beat if you use it without also accepting the pitch shift. For "harder
# but still on-beat," use reaction_speed above instead.
@export var chart_time_scale: float = 1.0
# Hard cutoff in seconds -- any note scheduled after this is simply dropped,
# so a long chart (e.g. a full song) can be capped to a short burst without
# re-authoring it. 0 = no cutoff, play the whole chart.
@export var max_duration: float = 15.0

@export_group("Song Sync")
# If > 0, the chart is auto-generated to match this song's tempo instead of
# using the hardcoded `chart` array above -- lets you drop in any song
# without hand-authoring timestamps, as long as you know its BPM (look it
# up -- I can't listen to the audio and detect it myself).
@export var song_bpm: float = 0.0
@export var beats_per_note: int = 2 # 1 = a note every beat (busy), 2 = every other beat, etc.
@export var first_beat_offset: float = 0.5 # seconds of intro silence before the first beat
@export var song_length_override: float = 0.0 # 0 = use the AudioStream's own reported length

# Shown in the on-screen threshold readout. Should match whatever
# black_flash_card.gd uses for its own bonus-damage cutoff (currently 0.9).
@export var critical_accuracy_threshold: float = 0.9

# Turn on ONLY for standalone testing (Run Current Scene). Leave off for
# real play -- black_flash_card.gd calls start() itself.
@export var autostart_for_testing: bool = false

const PERFECT_SCORE = 300
const GOOD_SCORE = 150
const NOTE_COLORS = [
	Color(0.28, 0.75, 1.0), Color(1.0, 0.55, 0.75), Color(0.55, 1.0, 0.55),
	Color(1.0, 0.85, 0.35), Color(0.75, 0.55, 1.0),
]

class OsuNote extends Node2D:
	var hit_time: float
	var judged: bool = false
	var radius: float = 48.0
	var approach_start_scale: float = 2.4
	var progress: float = 0.0 # 0 = just appeared, 1 = exactly on hit_time
	var note_color: Color = Color.WHITE

	func _draw() -> void:
		draw_circle(Vector2.ZERO, radius, note_color)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(1, 1, 1, 0.9), 3.0)
		if progress < 1.2:
			var approach_radius = lerp(radius * approach_start_scale, radius, clamp(progress, 0.0, 1.0))
			draw_arc(Vector2.ZERO, approach_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.85), 3.0)

	func set_progress(p: float) -> void:
		progress = p
		queue_redraw()

var _pending: Array = [] # chart entries not yet spawned
var _notes: Array = [] # OsuNote currently on screen
var _notes_container: Node2D

var _score: int = 0
var _max_score: int = 0
var _started: bool = false
var _elapsed: float = 0.0

var _score_label: Label
var _threshold_label: Label
var _hint_label: Label

func _ready() -> void:
	_notes_container = Node2D.new()
	add_child(_notes_container)
	_build_hud()
	set_process(false)
	if autostart_for_testing:
		start()

func _build_hud() -> void:
	_score_label = Label.new()
	_score_label.add_theme_font_size_override("font_size", 28)
	_score_label.add_theme_color_override("font_color", Color.WHITE)
	_score_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_score_label.add_theme_constant_override("outline_size", 5)
	_score_label.position = Vector2(24, 20)
	add_child(_score_label)

	_threshold_label = Label.new()
	_threshold_label.add_theme_font_size_override("font_size", 18)
	_threshold_label.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	_threshold_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_threshold_label.add_theme_constant_override("outline_size", 4)
	_threshold_label.position = Vector2(24, 58)
	add_child(_threshold_label)

	_hint_label = Label.new()
	_hint_label.text = "Click the circles right as the ring closes in!"
	_hint_label.add_theme_font_size_override("font_size", 16)
	_hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	_hint_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_hint_label.add_theme_constant_override("outline_size", 4)
	add_child(_hint_label)

	_update_hud()

func _update_hud() -> void:
	_score_label.text = "Score: %d" % _score
	var live_accuracy := 0.0
	if _max_score > 0:
		live_accuracy = float(_score) / float(_max_score)
	var pct := int(round(live_accuracy * 100.0))
	var crit_pct := int(round(critical_accuracy_threshold * 100.0))
	_threshold_label.text = "Accuracy: %d%%  (need %d%% for CRITICAL damage)" % [pct, crit_pct]

func start() -> void:
	if _started:
		return
	_started = true

	var vp := get_viewport().get_visible_rect().size
	_hint_label.position = Vector2(vp.x * 0.5 - 220, vp.y - 50)

	var music_player = get_node_or_null(music_player_path)

	var active_chart: Array = chart
	if song_bpm > 0.0 and music_player and music_player.stream:
		active_chart = _generate_chart_from_bpm(music_player.stream)

	# Apply chart_time_scale (compress/stretch every note's timing) and
	# max_duration (drop anything past the cutoff) to get the actual
	# playable set of notes for this run.
	var scale: float = chart_time_scale if chart_time_scale > 0.0 else 1.0
	_pending = []
	for entry in active_chart:
		var scaled_time: float = entry[2] * scale
		if max_duration <= 0.0 or scaled_time <= max_duration:
			_pending.append([entry[0], entry[1], scaled_time])

	_pending.sort_custom(func(a, b): return a[2] < b[2])
	_notes.clear()
	_score = 0
	_max_score = _pending.size() * PERFECT_SCORE
	_elapsed = 0.0
	_update_hud()

	if music_player:
		# Keep the music in sync with the compressed/stretched timeline.
		# Side effect: this also shifts pitch up/down, since Godot doesn't
		# have a built-in pitch-independent time-stretch. Fine for a quick
		# attack minigame, but worth knowing.
		music_player.pitch_scale = 1.0 / scale
		music_player.play()

	set_process(true)

func _generate_chart_from_bpm(stream: AudioStream) -> Array:
	var beat_duration := 60.0 / song_bpm
	var note_interval := beat_duration * float(beats_per_note)
	var length := song_length_override if song_length_override > 0.0 else stream.get_length()

	# Cycle through a handful of on-screen spots for a bit of visual variety
	# instead of every note landing in the same place.
	var positions := [
		Vector2(0.30, 0.35), Vector2(0.62, 0.30), Vector2(0.45, 0.55),
		Vector2(0.70, 0.50), Vector2(0.28, 0.60), Vector2(0.55, 0.40),
		Vector2(0.40, 0.28), Vector2(0.65, 0.62),
	]

	var generated: Array = []
	var t := first_beat_offset + note_interval
	var i := 0
	while t < length - end_padding:
		var p: Vector2 = positions[i % positions.size()]
		generated.append([p.x, p.y, t])
		t += note_interval
		i += 1
	return generated

func _process(delta: float) -> void:
	_elapsed += delta
	var effective_approach: float = approach_time / max(reaction_speed, 0.01)

	while _pending.size() > 0 and _pending[0][2] - effective_approach <= _elapsed:
		var entry = _pending.pop_front()
		_spawn_note(entry[0], entry[1], entry[2])

	for note in _notes.duplicate():
		if note.judged:
			continue
		var t_left = note.hit_time - _elapsed
		var progress = 1.0 - (t_left / effective_approach)
		note.set_progress(progress)
		if t_left < -good_window:
			_judge(note, "MISS", 0)

	if Input.is_action_just_pressed("click"):
		_try_click(get_global_mouse_position())

	if _pending.is_empty() and _notes.is_empty():
		_finish()

func _spawn_note(x_frac: float, y_frac: float, hit_time: float) -> void:
	var vp := get_viewport().get_visible_rect().size
	var note := OsuNote.new()
	note.hit_time = hit_time
	note.radius = circle_radius
	note.approach_start_scale = approach_start_scale
	note.note_color = NOTE_COLORS[_notes.size() % NOTE_COLORS.size()]
	note.position = Vector2(x_frac * vp.x, y_frac * vp.y)
	_notes_container.add_child(note)
	_notes.append(note)

func _try_click(mouse_pos: Vector2) -> void:
	var best_note = null
	var best_diff := INF
	for note in _notes:
		if note.judged:
			continue
		if note.global_position.distance_to(mouse_pos) > note.radius:
			continue
		var diff = absf(note.hit_time - _elapsed)
		if diff < best_diff:
			best_diff = diff
			best_note = note

	if best_note == null or best_diff > good_window:
		return

	if best_diff <= perfect_window:
		_judge(best_note, "PERFECT", PERFECT_SCORE)
	else:
		_judge(best_note, "GOOD", GOOD_SCORE)

func _judge(note: OsuNote, label_text: String, points: int) -> void:
	note.judged = true
	_score += points
	_update_hud()
	_show_popup(label_text, note.position, points > 0)
	_burst_and_free(note, points > 0)
	_notes.erase(note)

func _burst_and_free(note: OsuNote, was_hit: bool) -> void:
	var tw := create_tween()
	if was_hit:
		tw.tween_property(note, "scale", Vector2(1.4, 1.4), 0.15)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(note, "modulate:a", 0.0, 0.18)
	else:
		tw.tween_property(note, "modulate:a", 0.0, 0.12)
	tw.tween_callback(note.queue_free)

func _show_popup(text: String, pos: Vector2, was_hit: bool) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color.WHITE if was_hit else Color(1, 0.4, 0.4))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	label.position = pos + Vector2(-30, -circle_radius - 30)
	add_child(label)

	var tw := create_tween()
	tw.tween_property(label, "position:y", label.position.y - 30, 0.4)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.4)
	tw.tween_callback(label.queue_free)

func _finish() -> void:
	set_process(false)
	_started = false
	var accuracy := 0.0
	if _max_score > 0:
		accuracy = float(_score) / float(_max_score)
	finished.emit(clamp(accuracy, 0.0, 1.0))
