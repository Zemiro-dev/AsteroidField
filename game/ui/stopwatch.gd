extends Label
class_name StopwatchLabel

var time_elapsed := 0.0
var is_stopped := false


func _physics_process(delta: float) -> void:
	if !is_stopped:
		time_elapsed += delta
		update_text()


func update_text() -> void:
	var seconds := fmod(time_elapsed, 60.0)
	var minutes := floori(time_elapsed / 60.0)
	var hours := floori(minutes / 60.0)
	minutes = minutes % 60
	text = '%s:%s:%s' % [str(hours).pad_zeros(2), str(minutes).pad_zeros(2), str(seconds).pad_zeros(2).pad_decimals(2)]

func reset() -> void:
	time_elapsed = 0.0
	is_stopped = false
