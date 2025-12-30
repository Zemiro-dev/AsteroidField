extends Resource
class_name BaseController

@export var controllable := true

func get_direction_vector() -> Vector2:
	if !controllable: return Vector2.ZERO
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

func is_dash_just_pressed() -> bool:
	if !controllable: return false
	return Input.is_action_just_pressed("dash")


func is_dash_pressed() -> bool:
	if !controllable: return false
	return Input.is_action_pressed("dash")
