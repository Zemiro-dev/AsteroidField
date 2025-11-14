extends Resource
class_name BaseSteerable


@export var base_max_speed: float = 1250.0
@export var base_max_acceleration: float = 2000.0
@export var power_multiplier: float = 1.0
@export var turn_around_multiplier: float = 2.0
@export var overspeed_break_force: float = 10000.0
@export var velocity: Vector2 = Vector2.ZERO
@export var steering_strategies: Array[SteeringStrategy]


func steer(delta: float) -> void:
	var steering_result := combined_steering()
	var turn_around_dot := steering_result.heading.normalized().dot(velocity.normalized())
	print(turn_around_dot)
	var acceleration := steering_result.acceleration * (1.0 if turn_around_dot >= 0 else turn_around_multiplier)
	velocity += acceleration * delta


func slow(delta: float):
	velocity = velocity.move_toward(Vector2.ZERO, get_max_acceleration() * delta)


func should_overspeed_break() -> bool:
	return velocity.length() > get_max_speed()


func overspeed_break(delta: float) -> void:
	velocity = velocity.move_toward(velocity.normalized() * get_max_speed(), overspeed_break_force)


func combined_steering() -> SteeringResult:
	var combined_result := SteeringResult.new(Vector2.ZERO, Vector2.ZERO)
	
	for steering_strategy in steering_strategies:
		var result := steering_strategy.steer(self)
		combined_result.add(result)
	
	combined_result.limit_length(get_max_acceleration(), get_max_speed())
	
	return combined_result
	

func get_max_speed() -> float:
	return base_max_speed * power_multiplier


func get_max_acceleration() -> float:
	return base_max_acceleration * power_multiplier
