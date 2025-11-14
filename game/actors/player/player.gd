extends CharacterBody2D
class_name Player

@onready var impulse_particles: GPUParticles2D = $ImpulseParticles
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


@export var controller: BaseController
@export var steerable: BaseSteerable
@export var direction_steering: DirectionSteeringStrategy
@export var player_move_and_collide: PlayerMoveAndCollide
@export var dash_multiplier: float = 6.0

# Instead of improving handling moments, have breaking power
# be higher. Then use that when they're turning.


func _ready() -> void:
	steerable.steering_strategies.append(direction_steering)
	dash_duration_timer.timeout.connect(
		func():
			steerable.power_multiplier = 1
	)
	


func _physics_process(delta: float) -> void:
	dash()
	
	var direction := controller.get_direction_vector()
	if not direction and is_dashing(): direction = velocity.normalized()
	if is_dashing(): direction = direction.normalized()

	if direction:
		direction_steering.goal_vector = direction * get_steerable().get_max_speed()
		get_steerable().steer(delta)
		impulse_particles.emitting = true
	else:
		get_steerable().slow(delta)
		impulse_particles.emitting = false
	
	player_move_and_collide.move_and_collide(self, delta)


func get_steerable() -> BaseSteerable:
	return steerable


func get_actor_type() -> GameActor.ActorType:
	return GameActor.Types.PLAYER


func dash() -> void:
	if controller.is_dash_just_pressed() and dash_cooldown_timer.is_stopped() and dash_duration_timer.is_stopped():
		dash_cooldown_timer.start()
		dash_duration_timer.start()
		steerable.power_multiplier = dash_multiplier


func is_dashing() -> bool:
	return not dash_duration_timer.is_stopped()
