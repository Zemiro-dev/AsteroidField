extends CharacterBody2D
class_name Player


@export var controller: BaseController
@export var impulse_acceleration: float = 1000.0
@export var max_speed: float = 2500.0


func _physics_process(delta: float) -> void:
	# resource that takes in velocity start and return velocity after, goal velocity, actual velocity, apply
	# Collisions come after?``````````````````````````````````````````````````````````````
	var direction := controller.get_direction_vector()
	if direction:
		var goal_velocity := direction * max_speed
		velocity = velocity.move_toward(goal_velocity, impulse_acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, impulse_acceleration * delta)
	
	Vector.clamp_vector2_length(velocity, max_speed)
	move_and_slide()


func get_actor_type() -> GameActor.Types:
	return GameActor.Types.PLAYER
