extends CanvasLayer

@onready var cut_in: Control = $CutIn
@onready var background: TextureRect = $CutIn/Background
@onready var flash: ColorRect = $CutIn/Flash
@onready var black_fade: ColorRect = _get_or_create_black_fade()
@onready var impact_particles: CPUParticles2D = _get_or_create_particles()

# Where the shard art starts/ends off-screen. -1300/1300 matched your
# original art offset -- tweak if it doesn't fully clear your resolution.
@export var offscreen_offset: float = 1300.0

# How long the screen stays fully black between the shatter and the fade-in.
# Bumped way up since there's no actual loading happening to hide -- this is
# now purely a deliberate beat, tune to taste.
@export var black_hold_duration: float = 0.6

# Drag your character portraits in here (any order, any count up to 5 slots
# defined below). Empty slots just won't spawn a shard.
@export var character_textures: Array[Texture2D] = []

@export_group("Impact Particles")
@export var particle_amount: int = 36
@export var particle_scale_min: float = 5.0
@export var particle_scale_max: float = 10.0
@export var particle_velocity_min: float = 300.0
@export var particle_velocity_max: float = 620.0
@export var particle_lifetime: float = 0.7
@export var particle_color: Color = Color(1.0, 0.85, 0.75, 1.0)

# --- Character shard setup -----------------------------------------------
# Each entry: target position as a FRACTION of screen size, the direction
# the shard flies in from, and the bounding size of its shard shape.
# Square-ish sizes suit small sprite portraits; tall sizes suit full-body
# art. Order matches whatever order you drop textures into character_textures.
const SHARD_SLOTS = [
	{"pos": Vector2(0.16, 0.28), "dir": Vector2(-1, -0.5), "size": Vector2(190, 190)},
	{"pos": Vector2(0.50, 0.62), "dir": Vector2(0, -1),    "size": Vector2(170, 260)},
	{"pos": Vector2(0.84, 0.28), "dir": Vector2(1, -0.5),  "size": Vector2(190, 190)},
	{"pos": Vector2(0.30, 0.80), "dir": Vector2(-1, 1),    "size": Vector2(170, 260)},
	{"pos": Vector2(0.70, 0.80), "dir": Vector2(1, 1),     "size": Vector2(170, 260)},
]

var shards_container: Node2D
var shard_nodes: Array = []
var shard_targets: Array = []
var shard_starts: Array = []

func _get_or_create_black_fade() -> ColorRect:
	var existing = get_node_or_null("CutIn/BlackFade")
	if existing:
		return existing

	var rect := ColorRect.new()
	rect.name = "BlackFade"
	rect.color = Color(0, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CutIn.add_child(rect)
	return rect

func _get_or_create_particles() -> CPUParticles2D:
	var existing = get_node_or_null("CutIn/ImpactParticles")
	if existing:
		return existing

	var p := CPUParticles2D.new()
	p.name = "ImpactParticles"
	$CutIn.add_child(p)
	return p

func _ready() -> void:
	cut_in.visible = false
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.modulate.a = 0.0
	black_fade.modulate.a = 0.0

	shards_container = Node2D.new()
	shards_container.name = "Shards"
	cut_in.add_child(shards_container)
	_build_character_shards()

	_setup_particles()

func _setup_particles() -> void:
	impact_particles.emitting = false
	impact_particles.one_shot = true
	impact_particles.amount = particle_amount
	impact_particles.lifetime = particle_lifetime
	impact_particles.direction = Vector2.ZERO
	impact_particles.spread = 180.0 # full radial burst, not a directional cone
	impact_particles.initial_velocity_min = particle_velocity_min
	impact_particles.initial_velocity_max = particle_velocity_max
	impact_particles.gravity = Vector2(0, 260)
	impact_particles.damping_min = 40.0
	impact_particles.damping_max = 90.0
	impact_particles.scale_amount_min = particle_scale_min
	impact_particles.scale_amount_max = particle_scale_max
	impact_particles.color = particle_color

	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))
	scale_curve.add_point(Vector2(0.65, 0.8))
	scale_curve.add_point(Vector2(1.0, 0.0))
	impact_particles.scale_amount_curve = scale_curve

func _build_character_shards() -> void:
	for child in shards_container.get_children():
		child.queue_free()
	shard_nodes.clear()

	var count = min(character_textures.size(), SHARD_SLOTS.size())
	for i in range(count):
		var tex = character_textures[i]
		if tex == null:
			continue

		var slot = SHARD_SLOTS[i]
		var half = slot["size"] * 0.5

		# A slightly irregular quad (not a perfect rectangle) so it reads
		# as a glass shard rather than a plain photo frame.
		var jitter = 18.0
		var poly := Polygon2D.new()
		poly.polygon = PackedVector2Array([
			Vector2(-half.x + randf_range(-jitter, jitter), -half.y + randf_range(-jitter, jitter)),
			Vector2(half.x + randf_range(-jitter, jitter), -half.y + randf_range(-jitter, jitter)),
			Vector2(half.x + randf_range(-jitter, jitter), half.y + randf_range(-jitter, jitter)),
			Vector2(-half.x + randf_range(-jitter, jitter), half.y + randf_range(-jitter, jitter)),
		])
		poly.texture = tex
		_fit_uv_to_polygon(poly)

		shards_container.add_child(poly)
		shard_nodes.append(poly)

func _fit_uv_to_polygon(poly: Polygon2D) -> void:
	# Polygon2D doesn't auto-fit a texture to a custom polygon shape -- map
	# the full portrait into the polygon's bounding box ourselves so it
	# shows cropped-to-shard instead of tiled/misaligned.
	if poly.texture == null:
		return
	var pts = poly.polygon
	var min_p = pts[0]
	var max_p = pts[0]
	for p in pts:
		min_p.x = min(min_p.x, p.x)
		min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x)
		max_p.y = max(max_p.y, p.y)
	var box_size = max_p - min_p
	var tex_size = poly.texture.get_size()
	var uvs := PackedVector2Array()
	for p in pts:
		var t = Vector2(
			(p.x - min_p.x) / max(box_size.x, 0.001),
			(p.y - min_p.y) / max(box_size.y, 0.001)
		)
		uvs.append(Vector2(t.x * tex_size.x, t.y * tex_size.y))
	poly.uv = uvs

func _reset_shards() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	shard_targets.clear()
	shard_starts.clear()

	for i in range(shard_nodes.size()):
		var node = shard_nodes[i]
		var slot = SHARD_SLOTS[i]
		var target = Vector2(slot["pos"].x * viewport_size.x, slot["pos"].y * viewport_size.y)
		var start = target + slot["dir"].normalized() * (viewport_size.length() * 0.75)

		node.position = start
		node.scale = Vector2(0.55, 0.55)
		node.rotation = slot["dir"].angle() * 0.3
		node.modulate.a = 0.0

		shard_targets.append(target)
		shard_starts.append(start)

func play_transition(target_scene_path: String) -> void:
	cut_in.visible = true

	# 1. SLAM IN -- background + character shards fly in and hit hard.
	await _slam_in()

	# 2. SHATTER OUT -- everything flies apart like breaking glass, then
	#    crossfades to solid black -- this is what actually hides the swap.
	await _shatter_out()

	# 3. Swap scenes while the screen is solid black.
	get_tree().change_scene_to_file(target_scene_path)
	await get_tree().process_frame

	# 4. Fade smoothly from black into the new scene.
	await _fade_from_black()

	cut_in.visible = false

func _slam_in() -> void:
	# Center pivot so scale animations grow/shrink symmetrically instead of
	# drifting toward the top-left corner -- that drift is what was leaving
	# gaps at the screen edges.
	background.pivot_offset = background.size * 0.5

	var vp_size := get_viewport().get_visible_rect().size
	# Always at least fully clear the real screen width, regardless of the
	# tuned offscreen_offset value -- prevents gaps if the export var was
	# set for a different resolution than the game is actually running at.
	var start_x: float = -max(offscreen_offset, vp_size.x * 1.2)

	background.position = Vector2(start_x, 0)
	background.scale = Vector2(1.5, 1.5)
	background.rotation_degrees = 0.0
	background.modulate.a = 1.0
	cut_in.modulate = Color(1, 1, 1, 1)
	flash.modulate.a = 0.0
	black_fade.modulate.a = 0.0
	_reset_shards()

	var tw := create_tween()
	tw.set_parallel(true)

	# The background slam: one quick, decisive hit.
	tw.tween_property(background, "position", Vector2(15, 0), 0.14)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(background, "scale", Vector2(0.97, 0.97), 0.14)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	# Character shards fly in with a slight stagger so they don't land as
	# one flat block -- each hits a beat after the last.
	for i in range(shard_nodes.size()):
		var node = shard_nodes[i]
		var delay = 0.035 * i
		tw.tween_property(node, "position", shard_targets[i], 0.22)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(delay)
		tw.tween_property(node, "scale", Vector2.ONE, 0.22)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(delay)
		tw.tween_property(node, "rotation", 0.0, 0.22)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).set_delay(delay)
		tw.tween_property(node, "modulate:a", 1.0, 0.13).set_delay(delay)

	tw.tween_callback(_impact_flash).set_delay(0.10)
	await tw.finished

	# Tiny snap-back to rest -- the "pop" that a straight ease-out can't give.
	# Settles slightly ABOVE 1.0 scale (1.03) as a deliberate small overscan
	# margin, so there's never a 1px gap at the edges even with rounding.
	var settle := create_tween()
	settle.set_parallel(true)
	settle.tween_property(background, "position", Vector2.ZERO, 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	settle.tween_property(background, "scale", Vector2(1.03, 1.03), 0.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	for node in shard_nodes:
		settle.tween_property(node, "scale", Vector2.ONE, 0.08)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await settle.finished

func _shatter_out() -> void:
	var viewport_center := get_viewport().get_visible_rect().size * 0.5
	var tw := create_tween()
	tw.set_parallel(true)

	# The background itself kicks outward and fades.
	tw.tween_property(background, "position", background.position + Vector2(0, -140), 0.22)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(background, "scale", background.scale * 1.5, 0.22)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(background, "modulate:a", 0.0, 0.2)

	# Every character shard flies outward away from screen-center and
	# tumbles, like it's breaking apart -- this is the "glass break."
	for node in shard_nodes:
		var outward = (node.position - viewport_center)
		if outward.length() < 1.0:
			outward = Vector2.UP
		outward = outward.normalized()
		var fly_to = node.position + outward * 420.0
		var spin = randf_range(-2.2, 2.2)

		tw.tween_property(node, "position", fly_to, 0.26)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tw.tween_property(node, "rotation", spin, 0.26)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tw.tween_property(node, "modulate:a", 0.0, 0.22)

	# Black rushes in right on top of the shatter so there's no empty gap
	# between "glass gone" and "screen covered."
	tw.tween_property(black_fade, "modulate:a", 1.0, 0.2).set_delay(0.08)
	await tw.finished

	# Deliberate hold on solid black -- the game has nothing to actually load,
	# so this beat is pure pacing/weight rather than hiding a hitch.
	await get_tree().create_timer(black_hold_duration).timeout

func _fade_from_black() -> void:
	var tw := create_tween()
	tw.tween_property(black_fade, "modulate:a", 0.0, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tw.finished

func _impact_flash() -> void:
	flash.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(flash, "modulate:a", 0.0, 0.2).set_trans(Tween.TRANS_SINE)

	impact_particles.position = get_viewport().get_visible_rect().size * 0.5
	impact_particles.restart()
	impact_particles.emitting = true
