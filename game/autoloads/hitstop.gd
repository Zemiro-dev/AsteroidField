extends Node


var hitstop_end_time_ms := 0.0
var is_in_hitstop := false


func _ready() -> void:
	GlobalSignals.request_hitstop.connect(on_hitstop_requested)


func _process(_delta: float) -> void:
	if is_in_hitstop:
		Engine.time_scale = 0
	if Time.get_ticks_msec() > hitstop_end_time_ms and is_in_hitstop:
		exit_hitstop()


func exit_hitstop() -> void:
	is_in_hitstop = false
	Engine.time_scale = 1


func on_hitstop_requested(hitstop_time_ms: float) -> void:
	Engine.time_scale = 0
	is_in_hitstop = true
	hitstop_end_time_ms = Time.get_ticks_msec() + hitstop_time_ms
