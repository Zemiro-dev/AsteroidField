extends SteeringStrategy
class_name DirectionSteeringStrategy


@export var goal_vector: Vector2


func steer(steerable: BaseSteerable) -> SteeringResult:
	return SteeringResult.new(
		(goal_vector - steerable.velocity).normalized() * steerable.get_max_acceleration(),
	 	goal_vector
	)
