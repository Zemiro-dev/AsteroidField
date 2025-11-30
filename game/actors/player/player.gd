extends CharacterBody2D
class_name Player


signal on_boost_duration_changed(new_duration: float, max_duration: float, player: Player)


@onready var impulse_particles: GPUParticles2D = $ImpulseParticles
@onready var boost_reset_timer: Timer = $BoostResetTimer

@export var controller: BaseController
@export var steerable: BaseSteerable
@export var direction_steering: DirectionSteeringStrategy
@export var player_move_and_collide: PlayerMoveAndCollide
@export var dash_multiplier: float = 3.0
@export var damagable: BaseDamagable
@export var max_boost_duration: float = 1.0
@export var boost_recharge_ratio: float = 1.0
## Value between 0-1, percentage where boost resets after full empty
@export var boost_cd_reset: float = .75
@export var on_death_handler: BaseOnDeathHandler

var remaining_boost_duration: float = 0.0
var is_boost_on_cd: bool = false

var actor_type := GameActor.ActorType.PLAYER


func _ready() -> void:
	steerable.reset()
	steerable.steering_strategies.append(direction_steering)
	damagable.reset_damagable(self)
	damagable.on_damage_taken.connect(func(damage_taken: int): print(damage_taken))
	update_boost_duration(max_boost_duration)
	if on_death_handler:
		on_death_handler.bind_to_node(self)
	damagable.on_death.connect(
		func(actor: Node2D):
			if has_node("Cannon"):
				var cannon: Cannon = get_node("Cannon")
				cannon.enabled = false
			steerable.halt()
			modulate = Color(Color.WHITE, 0.)
	)


func _physics_process(delta: float) -> void:
	if damagable.is_dead: return
	
	dash(delta)
	
	var direction := controller.get_direction_vector()
	if is_dashing(): direction = direction.normalized()

	if direction:
		direction_steering.goal_vector = direction * steerable.get_max_speed()
		steerable.steer(delta)
		impulse_particles.emitting = true
	else:
		steerable.slow(delta)
		impulse_particles.emitting = false
	
	player_move_and_collide.move_and_collide(self, delta)


func dash(delta: float) -> void:
	if is_dashing():
		steerable.power_multiplier = dash_multiplier
		update_boost_duration(-delta)
	else:
		steerable.power_multiplier = 1
		update_boost_duration(delta * boost_recharge_ratio)
	


func is_dashing() -> bool:
	if controller.is_dash_pressed() and remaining_boost_duration > 0.0 and !is_boost_on_cd:
		return true
	return false


func update_boost_duration(delta: float) -> void:
	remaining_boost_duration += delta
	remaining_boost_duration = clampf(remaining_boost_duration, 0, max_boost_duration)
	
	if remaining_boost_duration / max_boost_duration > boost_cd_reset:
		is_boost_on_cd = false
	
	if is_zero_approx(remaining_boost_duration):
		is_boost_on_cd = true
		
	on_boost_duration_changed.emit(remaining_boost_duration, max_boost_duration, self)
