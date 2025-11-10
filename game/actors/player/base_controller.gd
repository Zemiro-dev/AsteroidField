extends Resource
class_name BaseController

func get_direction_vector() -> Vector2:
	return Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

func is_dash_just_pressed() -> bool:
	return Input.is_action_just_pressed("dash")
