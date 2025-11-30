extends Node


class AudioStreams extends Node:
	var bg_music_player: AudioStreamPlayer

	func set_bg_music(stream: Resource):
		if !bg_music_player:
			bg_music_player = AudioStreamPlayer.new()
			add_child(bg_music_player)
		else:
			bg_music_player.stop()
		bg_music_player.stream = stream
	
	
	func play_bg_music():
		if bg_music_player:
			bg_music_player.play()

class WorldSounds extends Node2D:
	pass

var audio_streams: AudioStreams
var world_sounds: WorldSounds
var current_bg_music: String
var menu_music := preload("res://assets/jukebox/sci_fi_dreamscape.mp3")

func _ready() -> void:
	audio_streams = AudioStreams.new()
	add_child(audio_streams)
	
	world_sounds = WorldSounds.new()
	add_child(world_sounds)
	
	GlobalSignals.request_sound_spawn.connect(add_sound_to_world)
	GlobalSignals.request_world_sound_spawn.connect(handle_request_world_sound_spawn)


func play_menu_music():
	if current_bg_music != menu_music.resource_path:
		current_bg_music = menu_music.resource_path
		audio_streams.set_bg_music(menu_music)
		audio_streams.play_bg_music()


func add_sound_to_world(sound: AudioStreamPlayer2D):
	world_sounds.add_child(sound)
	if sound is ExtendedAudioStreamPlayer2D:
		sound.play_at_random_pitch()
	else:
		sound.play()


func handle_request_world_sound_spawn(source: Node2D, sound_scene: PackedScene):
	if sound_scene and sound_scene.can_instantiate():
		var sound := sound_scene.instantiate()
		if sound is AudioStreamPlayer2D:
			sound.global_position = source.global_position
			GlobalSignals.request_sound_spawn.emit(sound)
