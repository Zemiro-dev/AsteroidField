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

var audio_streams: AudioStreams
var current_bg_music: String
var menu_music := preload("res://assets/jukebox/sci_fi_dreamscape.mp3")

func _ready() -> void:
	audio_streams = AudioStreams.new()
	add_child(audio_streams)


func play_menu_music():
	if current_bg_music != menu_music.resource_path:
		current_bg_music = menu_music.resource_path
		audio_streams.set_bg_music(menu_music)
		audio_streams.play_bg_music()
