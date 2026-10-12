extends Node

var active_music_stream: AudioStreamPlayer

@export_group("Main")
@export var music: Node
@export var sfx: Node
@export var audio_one_scene: PackedScene
var nameOfMusicPlaying: String

func changeVolume():
	for i in music.get_children():
		i.set_volume_db(Globals.MusicVolume)
	
func stop():
	for i in music.get_children():

		i.stop()

func play(audio_name: String, from_position: float = 0.0) -> void:
	if audio_name == "":
		return
	for i in music.get_children():
		if i.name != audio_name:
			i.stop()
		else:
			nameOfMusicPlaying = i.name
	if active_music_stream == music.get_node(audio_name):
		return
	active_music_stream = music.get_node(audio_name)
	active_music_stream.play(from_position)

	
func play_oneshot(audioStream: AudioStream, volume_db: float = 0, from_positon:float = 0.0)-> AudioOneshot:
	var audioOneShot: AudioOneshot = audio_one_scene.instantiate()
	audioOneShot.stream = audioStream
	audioOneShot.volume_db = volume_db
	audioOneShot.from_position = from_positon
	
	sfx.add_child(audioOneShot)
	return audioOneShot
