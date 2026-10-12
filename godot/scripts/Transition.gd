extends Node

signal progress_changed(process)
signal load_finished

var loading_screen: PackedScene = preload("uid://c78n0yfbk1p4q")
var loaded_resource: PackedScene = null
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true #Kevin keeps ts always on true it makes transitions load faster using more strings

func _ready() -> void:
	set_process(false)
	
func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
	var new_load_scene = loading_screen.instantiate()
	add_child(new_load_scene)
	progress_changed.connect(new_load_scene._on_progress_changed)
	load_finished.connect(new_load_scene._on_load_finished)
	
	await new_load_scene.loading_screen_ready
	
	start_load()
	
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)
	
func _process(delta: float) -> void: 
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()
