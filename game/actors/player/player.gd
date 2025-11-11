extends CharacterBody2D
class_name Player

@onready var impulse_particles: GPUParticles2D = $ImpulseParticles

@export var controller: BaseController
@export var player_move_and_collide: PlayerMoveAndCollide
@export var impulse_acceleration: float = 500.0
@export var max_speed: float = 1500.0

# Instead of improving handling moments, have breaking power
# be higher. Then use that when they're turning.


func _physics_process(delta: float) -> void:
	# resource that takes in velocity start and return velocity after, goal velocity, actual velocity, apply
	# Collisions come after?``````````````````````````````````````````````````````````````
	var direction := controller.get_direction_vector()
	if direction:
		var goal_velocity := direction * max_speed
		velocity = velocity.move_toward(goal_velocity, impulse_acceleration * delta)
		impulse_particles.emitting = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, impulse_acceleration * delta)
		impulse_particles.emitting = false
	
	player_move_and_collide.move_and_collide(self, delta)


func get_actor_type() -> GameActor.Types:
	return GameActor.Types.PLAYER
