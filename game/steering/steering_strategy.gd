extends Resource
class_name SteeringStrategy


func steer(steerable: BaseSteerable) -> SteeringResult:
	return SteeringResult.new(Vector2.ZERO, Vector2.ZERO)
