extends Node2D
## PackOpener
## Drop-in "Balatro style" buffoon pack opening transition.
##
## SETUP:
## 1. Add this scene (PackOpener.tscn) wherever your pack currently shows
##    (e.g. as a child of your pack-selection screen, positioned where the
##    pack should appear).
## 2. Select the "Body" node and drag Pack_Body.png onto its Texture slot.
## 3. Select the "Foil" node and drag your foil/edge overlay png onto its
##    Texture slot (the mostly-transparent one with the scalloped top).
## 4. From your existing code:
##       var pack = $PackOpener
##       pack.play_intro()                 # pack drops/pops into view
##       ... when the player clicks the pack ...
##       pack.open_pack()
##       await pack.pack_opened            # then reveal your card UI
##
## Everything below is tunable via the @export vars in the Inspector.

signal pack_opened

@export_group("Timing")
@export var intro_duration: float = 0.35
@export var idle_bob_amount: float = 4.0
@export var idle_bob_speed: float = 1.6
@export var anticipation_shakes: int = 2
@export var open_duration: float = 0.55

@export_group("Look")
@export var pop_scale_overshoot: float = 1.18
@export var flash_color: Color = Color(1, 1, 1, 1)
@export var particle_color: Color = Color(1, 0.95, 0.6, 1)

@export_subgroup("Particles")
@export var particle_amount: int = 40
@export var particle_scale_min: float = 6.0
@export var particle_scale_max: float = 11.0
@export var particle_velocity_min: float = 260.0
@export var particle_velocity_max: float = 520.0
@export var particle_lifetime: float = 0.9

@onready var pivot: Node2D = $Pivot
@onready var body: Sprite2D = $Pivot/Body
@onready var foil: Sprite2D = $Pivot/Foil
@onready var flash: ColorRect = $Flash
@onready var particles: CPUParticles2D = $Particles

var _idle_tween: Tween
var _is_open := false

func _ready() -> void:
	# Start hidden/collapsed so play_intro() has something to animate from.
	pivot.scale = Vector2.ZERO
	flash.color = flash_color
	flash.modulate.a = 0.0
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_setup_particles()

func _setup_particles() -> void:
	particles.emitting = false
	particles.one_shot = true
	particles.amount = particle_amount
	particles.lifetime = particle_lifetime
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.initial_velocity_min = particle_velocity_min
	particles.initial_velocity_max = particle_velocity_max
	particles.gravity = Vector2(0, 620)
	particles.scale_amount_min = particle_scale_min
	particles.scale_amount_max = particle_scale_max
	particles.color = particle_color

	# Shrink each particle over its lifetime
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))
	scale_curve.add_point(Vector2(0.7, 0.85))
	scale_curve.add_point(Vector2(1.0, 0.0))
	
	# Pass the Curve straight to CPUParticles2D
	particles.scale_amount_curve = scale_curve

## Call once the pack should appear on screen.
func play_intro() -> void:
	pivot.scale = Vector2.ZERO
	pivot.rotation = 0.0
	var tw := create_tween()
	tw.tween_property(pivot, "scale", Vector2.ONE, intro_duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.finished.connect(_start_idle_bob)

func _start_idle_bob() -> void:
	if _is_open:
		return
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(pivot, "position:y", -idle_bob_amount, idle_bob_speed * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(pivot, "position:y", 0.0, idle_bob_speed * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Call when the player clicks/taps the pack to open it.
func open_pack() -> void:
	if _is_open:
		return
	_is_open = true
	if _idle_tween:
		_idle_tween.kill()

	var tw := create_tween()

	# --- Anticipation: a couple of quick shakes, like it's straining ---
	for i in anticipation_shakes:
		var shake_angle := 6.0 if i % 2 == 0 else -6.0
		tw.tween_property(pivot, "rotation_degrees", shake_angle, 0.06)\
			.set_trans(Tween.TRANS_SINE)
	tw.tween_property(pivot, "rotation_degrees", 0.0, 0.05)

	# --- Squash just before the pop ---
	tw.tween_property(pivot, "scale", Vector2(1.15, 0.85), 0.08)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# --- The pop: overshoot scale + white flash + particle burst, all at once ---
	tw.tween_callback(_on_pop)
	tw.tween_property(pivot, "scale", Vector2(pop_scale_overshoot, pop_scale_overshoot), 0.09)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# --- Flash fades out quickly ---
	tw.parallel().tween_property(flash, "modulate:a", 0.0, 0.25)\
		.set_delay(0.02).from(1.0)

	# --- Foil piece launches up/away and fades ---
	tw.tween_callback(_launch_foil)

	# --- Body scales down and fades, "unwrapping" out of view ---
	tw.parallel().tween_property(body, "modulate:a", 0.0, open_duration * 0.7)\
		.set_delay(0.05)
	tw.parallel().tween_property(pivot, "scale", Vector2(0.6, 0.6), open_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(body, "position:y", 20.0, open_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tw.tween_callback(func():
		pack_opened.emit()
	)

func _on_pop() -> void:
	flash.modulate.a = 1.0
	particles.restart()
	particles.emitting = true

func _launch_foil() -> void:
	var foil_tw := create_tween()
	foil_tw.set_parallel(true)
	foil_tw.tween_property(foil, "position:y", foil.position.y - 90.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	foil_tw.tween_property(foil, "rotation_degrees", 18.0, 0.4)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	foil_tw.tween_property(foil, "modulate:a", 0.0, 0.35).set_delay(0.05)

## Reset the pack so it can be reused (e.g. object pooling / next pack).
func reset() -> void:
	_is_open = false
	show()
	pivot.rotation = 0.0
	pivot.position = Vector2.ZERO
	body.modulate.a = 1.0
	body.position = Vector2.ZERO
	foil.modulate.a = 1.0
	foil.rotation = 0.0
	foil.position = Vector2.ZERO
