extends Resource
class_name BaseSteerable


@export var base_max_speed: float = 1250.0
@export var base_max_acceleration: float = 2000.0
@export var turn_around_multiplier: float = 2.0
@export var overspeed_break_force: float = 10000.0
var power_multiplier: float = 1.0
var velocity: Vector2 = Vector2.ZERO
@export var steering_strategies: Array[SteeringStrategy]
var levelable: Levelable


func reset() -> void:
	steering_strategies = []
	velocity = Vector2.ZERO


func steer() -> Callable:
	var steering_result := combined_steering()
	var turn_around_dot := steering_result.heading.normalized().dot(velocity.normalized())
	var acceleration := steering_result.acceleration * (1.0 if turn_around_dot >= 0 else turn_around_multiplier)
	return func(delta: float): velocity += acceleration * delta
	


func combined_steering() -> SteeringResult:
	var combined_result := SteeringResult.new(Vector2.ZERO, Vector2.ZERO)
	
	for steering_strategy in steering_strategies:
		var result := steering_strategy.steer(self)
		combined_result.add(result)
	
	combined_result.limit_length(get_max_acceleration(), get_max_speed())
	
	return combined_result


func slow() -> Callable:
	return func(delta: float): velocity = velocity.move_toward(Vector2.ZERO, get_max_acceleration() * delta)


func halt() -> Callable:
	return func(_delta: float = 0.): velocity = Vector2.ZERO


func knockback(knockback_vector: Vector2) -> void:
	velocity = velocity / 2.
	velocity += knockback_vector


func should_overspeed_break() -> bool:
	return velocity.length() > get_max_speed()


func overspeed_break(_delta: float) -> void:
	velocity = velocity.move_toward(velocity.normalized() * get_max_speed(), overspeed_break_force)


func get_max_speed() -> float:
	var levelableBonus := 0.
	if levelable and levelable.stats:
		levelableBonus = levelable.stats.max_speed_up
	return (base_max_speed + levelableBonus) * power_multiplier


func get_max_acceleration() -> float:
	var levelableBonus := 0.
	if levelable and levelable.stats:
		levelableBonus = levelable.stats.max_acceleration_up
	return (base_max_acceleration + levelableBonus) * power_multiplier
