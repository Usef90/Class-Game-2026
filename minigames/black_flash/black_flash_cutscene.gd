extends CanvasLayer
## black_flash_cutscene.gd
## Stylized "clash" freeze-frame moment: both portraits punch toward
## center, hard white flash + brief hitstop (time slows almost to a stop),
## then a snap to black. Call play() and await it; it cleans up after
## itself and the caller (black_flash_card.gd) frees this node.
##
## Fully self-contained -- builds its own UI in code, nothing to wire up
## in a .tscn. Just instance this script's scene (or add_child a node with
## this script attached) and call play(player_tex, enemy_tex).

@onready var root_control: Control = _get_or_create_root()
@onready var player_rect: TextureRect = _get_or_create_portrait("PlayerPortrait")
@onready var enemy_rect: TextureRect = _get_or_create_portrait("EnemyPortrait")
@onready var flash: ColorRect = _get_or_create_solid("Flash", Color(1, 1, 1, 0))
@onready var black_out: ColorRect = _get_or_create_solid("BlackOut", Color(0, 0, 0, 0))
@onready var video_player: VideoStreamPlayer = _get_or_create_video_player()

@export var hitstop_time_scale: float = 0.05
@export var hitstop_duration: float = 0.25 # measured in REAL seconds, unaffected by the slowdown

# Assign a converted .ogv here (Godot's VideoStreamPlayer only supports
# Ogg Theora natively -- convert an mp4 to .ogv first). When set, play()
# shows this video full-screen instead of the procedural portrait-punch
# sequence below. Leave empty to keep using the built-in effect.
@export var video_stream: VideoStream

func _get_or_create_root() -> Control:
	var existing = get_node_or_null("Root")
	if existing:
		return existing
	var c := Control.new()
	c.name = "Root"
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(c)
	return c

func _get_or_create_portrait(node_name: String) -> TextureRect:
	var existing = root_control.get_node_or_null(node_name)
	if existing:
		return existing
	var t := TextureRect.new()
	t.name = node_name
	t.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(360, 360)
	t.size = Vector2(360, 360)
	root_control.add_child(t)
	return t

func _get_or_create_solid(node_name: String, color: Color) -> ColorRect:
	var existing = root_control.get_node_or_null(node_name)
	if existing:
		return existing
	var r := ColorRect.new()
	r.name = node_name
	r.color = color
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(r)
	return r

func _get_or_create_video_player() -> VideoStreamPlayer:
	var existing = root_control.get_node_or_null("VideoPlayer") if root_control else null
	if existing:
		return existing
	var v := VideoStreamPlayer.new()
	v.name = "VideoPlayer"
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.expand = true
	v.visible = false
	root_control.add_child(v)
	return v

func play(player_portrait: Texture2D, enemy_portrait: Texture2D) -> void:
	layer = 100

	if video_stream:
		await _play_video()
		return

	player_rect.texture = player_portrait
	enemy_rect.texture = enemy_portrait
	player_rect.modulate.a = 0.0
	enemy_rect.modulate.a = 0.0
	flash.modulate.a = 0.0
	black_out.modulate.a = 0.0

	var vp := get_viewport().get_visible_rect().size
	player_rect.pivot_offset = player_rect.size * 0.5
	enemy_rect.pivot_offset = enemy_rect.size * 0.5

	var player_rest := Vector2(vp.x * 0.28 - player_rect.size.x * 0.5, vp.y * 0.5 - player_rect.size.y * 0.5)
	var enemy_rest := Vector2(vp.x * 0.72 - enemy_rect.size.x * 0.5, vp.y * 0.5 - enemy_rect.size.y * 0.5)

	player_rect.position = player_rest - Vector2(260, 0)
	enemy_rect.position = enemy_rest + Vector2(260, 0)
	player_rect.scale = Vector2(0.7, 0.7)
	enemy_rect.scale = Vector2(0.7, 0.7)

	# 1. Both portraits punch in toward center, hard and fast.
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(player_rect, "position", player_rest, 0.16)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(enemy_rect, "position", enemy_rest, 0.16)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(player_rect, "scale", Vector2(1.05, 1.05), 0.16)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(enemy_rect, "scale", Vector2(1.05, 1.05), 0.16)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(player_rect, "modulate:a", 1.0, 0.1)
	tw.tween_property(enemy_rect, "modulate:a", 1.0, 0.1)
	await tw.finished

	# 2. The clash: hard white flash + hitstop (time nearly freezes for a
	# beat) -- this is the actual "black flash" impact moment.
	flash.modulate.a = 1.0
	var prev_time_scale := Engine.time_scale
	Engine.time_scale = hitstop_time_scale
	await get_tree().create_timer(hitstop_duration, true).timeout # true = ignore time_scale
	Engine.time_scale = prev_time_scale

	var flash_tw := create_tween()
	flash_tw.tween_property(flash, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_SINE)
	await flash_tw.finished

	# 3. Settle for a beat so the hit registers, then snap to black --
	# this is the handoff point into the rhythm minigame.
	await get_tree().create_timer(0.15).timeout
	var out_tw := create_tween()
	out_tw.tween_property(black_out, "modulate:a", 1.0, 0.12)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await out_tw.finished

func _play_video() -> void:
	video_player.stream = video_stream
	video_player.visible = true
	video_player.play()
	await video_player.finished
	video_player.visible = false
	video_player.stream = null # release the stream so it's not still decoding in the background
