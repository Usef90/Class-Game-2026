extends CanvasLayer


var panel: PanelContainer
var title_label: Label
var desc_label: Label
var vbox: VBoxContainer

var _current_target: Control = null
var _request_id: int = 0

const MAX_WIDTH := 260.0
const POP_DURATION := 0.12
const GAP_FROM_CARD := 14.0

func _ready() -> void:
	layer = 100 #puts above every layer
	_build_ui()

func _build_ui() -> void:
	panel = PanelContainer.new()
	panel.name = "TooltipPanel"
	panel.visible = false
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.top_level = true

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.11, 0.96)
	style.border_color = Color(1, 1, 1, 0.18)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)

	vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	title_label = Label.new()
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.75))
	vbox.add_child(title_label)

	desc_label = Label.new()
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.9))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(MAX_WIDTH, 0)
	vbox.add_child(desc_label)

	add_child(panel)


func show_at(target: Control, title_text: String, desc_text: String) -> void:
	if title_text.strip_edges() == "" and desc_text.strip_edges() == "":
		return

	_current_target = target
	_request_id += 1
	var this_request := _request_id

	title_label.text = title_text
	desc_label.visible = desc_text.strip_edges() != ""
	desc_label.text = desc_text

	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.85, 0.85)

	await get_tree().process_frame
	if this_request != _request_id or _current_target != target:
		return

	_reposition(target)

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(panel, "modulate:a", 1.0, POP_DURATION)
	tw.tween_property(panel, "scale", Vector2.ONE, POP_DURATION)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_tooltip(target: Control = null) -> void:
	if target != null and target != _current_target:
		return
	_current_target = null
	_request_id += 1
	panel.visible = false

func _reposition(target: Control) -> void:
	var target_rect := target.get_global_rect()
	var panel_size := panel.size
	panel.pivot_offset = panel_size * 0.5

	var pos := Vector2(
		target_rect.position.x + target_rect.size.x * 0.5 - panel_size.x * 0.5,
		target_rect.position.y - panel_size.y - GAP_FROM_CARD
	)

	var viewport_size := get_viewport().get_visible_rect().size
	pos.x = clamp(pos.x, 8.0, max(8.0, viewport_size.x - panel_size.x - 8.0))
	if pos.y < 8.0:
		# Not enough room above -- show below the card instead.
		pos.y = target_rect.position.y + target_rect.size.y + GAP_FROM_CARD

	panel.position = pos
