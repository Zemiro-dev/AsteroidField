extends Resource
class_name SteeringStrategy


func steer(_steerable: BaseSteerable) -> SteeringResult:
	return SteeringResult.new(Vector2.ZERO, Vector2.ZERO)
