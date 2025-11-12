extends CharacterBody2D
class_name Player

@onready var impulse_particles: GPUParticles2D = $ImpulseParticles
@onready var dash_duration_timer: Timer = $DashDurationTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


@export var controller: BaseController
@export var player_move_and_collide: PlayerMoveAndCollide
@export var base_impulse_acceleration: float = 2000.0
@export var base_max_speed: float = 1250.0
@export var dash_multiplier: float = 6.0
@export var overspeed_break_force: float = 10000.0

# Instead of improving handling moments, have breaking power
# be higher. Then use that when they're turning.


func _physics_process(delta: float) -> void:
	dash()
	
	var direction := controller.get_direction_vector()
	if not direction and is_dashing(): direction = velocity.normalized()
	if is_dashing(): direction = direction.normalized()

	if direction:
		var goal_velocity := direction * get_max_speed()
		var handling_dot := goal_velocity.normalized().dot(velocity.normalized())
		var handling_impulse := get_impulse_acceleration() * (1.0 if handling_dot > 0 else 2.0)
		var acceleration := seek(velocity, goal_velocity, handling_impulse)
		velocity += acceleration * delta
		impulse_particles.emitting = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, get_impulse_acceleration() * delta)
		impulse_particles.emitting = false
	
	player_move_and_collide.move_and_collide(self, delta)


func get_max_speed() -> float:
	return base_max_speed if !is_dashing() else base_max_speed * dash_multiplier


func get_impulse_acceleration() -> float:
	return base_impulse_acceleration if !is_dashing() else base_impulse_acceleration * dash_multiplier


func dash() -> void:
	if controller.is_dash_just_pressed() and dash_cooldown_timer.is_stopped() and dash_duration_timer.is_stopped():
		dash_cooldown_timer.start()
		dash_duration_timer.start()


func is_dashing() -> bool:
	return not dash_duration_timer.is_stopped()


func seek(current_velocity: Vector2, goal_velocity: Vector2, force: float ) -> Vector2:
	var steer = (goal_velocity - current_velocity).normalized() * force
	return steer


func get_actor_type() -> GameActor.Types:
	return GameActor.Types.PLAYER
