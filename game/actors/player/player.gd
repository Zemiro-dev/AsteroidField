extends CharacterBody2D
class_name Player


signal on_boost_duration_changed(new_duration: float, max_duration: float, player: Player)


@onready var impulse_particles: GPUParticles2D = $ImpulseParticles
@onready var boost_reset_timer: Timer = $BoostResetTimer
@onready var audio_listener_2d: AudioListener2D = $AudioListener2D
@onready var engine_sound: AudioStreamPlayer2D = $EngineSound
@onready var cannon_hardpoint: CannonHardpoint = $CannonHardpoint
@onready var screen_edge_navigation: ScreenEdgeNavigation = $ScreenEdgeNavigation

@export var controller: BaseController
@export var steerable: BaseSteerable
@export var player_move_and_collide: PlayerMoveAndCollide
@export var dash_multiplier: float = 3.
@export var damagable: BaseDamagable
@export var max_boost_duration: float = 1.0
@export var boost_recharge_ratio: float = 1.0
## Value between 0-1, percentage where boost resets after full empty
@export var boost_cd_reset: float = .75
@export var on_death_handler: BaseOnDeathHandler
@export var engine_sound_volumn_db: float = -20.
@export var engine_sound_rev_speed: float = 200.

var remaining_boost_duration: float = 0.0
var is_boost_on_cd: bool = false
var direction_steering: DirectionSteeringStrategy
var levelable: Levelable

var actor_type := GameActor.ActorType.PLAYER


func _ready() -> void:
	levelable = Levelable.new()
	levelable.stat_modifiers = [
		LevelableStatModifier.ProjectileAttackSpeedUpPerLevel.new(),
		LevelableStatModifier.ProjectileDamageUpPerLevel.new()
	]
	init_steering()
	damagable.reset_damagable(self)
	update_boost_duration(get_max_boost_duration())
	if on_death_handler:
		on_death_handler.bind_to_node(self)
	damagable.on_damage_taken.connect(
		func(_damage_dealt: int):
			GlobalSignals.request_hitstop.emit(70)
	)
	damagable.on_death.connect(
		func(_actor: Node2D):
			if has_node("Cannon"):
				var cannon: Cannon = get_node("Cannon")
				cannon.enabled = false
			steerable.halt().call()
			modulate = Color(Color.WHITE, 0.)
	)
	GlobalSignals.request_game_win.connect(
		func():
			damagable.is_invincible = true
	)
	audio_listener_2d.make_current()
	if cannon_hardpoint.get_child_count() == 0:
		cannon_hardpoint.add_cannon(cannon_hardpoint.BOLT_CANNON, self)


func init_steering():
	direction_steering = DirectionSteeringStrategy.new()
	steerable.reset()
	steerable.steering_strategies.append(direction_steering)
	steerable.levelable = levelable


func _physics_process(delta: float) -> void:
	
	if damagable:
		if damagable.is_dead: return
		damagable.physics_process(delta)
	
	dash(delta)
	
	var direction := controller.get_direction_vector()
	if is_dashing(): direction = direction.normalized()

	if direction:
		engine_sound.volume_db = move_toward(engine_sound.volume_db, engine_sound_volumn_db, engine_sound_rev_speed * delta)
		direction_steering.goal_vector = direction * steerable.get_max_speed()
		steerable.steer().call(delta)
		impulse_particles.emitting = true
	else:
		engine_sound.volume_db = move_toward(engine_sound.volume_db, -100, engine_sound_rev_speed * delta)
		steerable.slow().call(delta)
		impulse_particles.emitting = false
	
	player_move_and_collide.move_and_collide(self, delta)
	
	#var is_empty := Physics.is_circle_empty(global_position, 200., collision_mask)
	#if (is_empty): 
		#print('Open Space')
	#else:
		#print('Closed Space')


func dash(delta: float) -> void:
	if is_dashing():
		steerable.power_multiplier = get_dash_multiplier()
		update_boost_duration(-delta)
		if levelable.stats.slow_time_on_boost:
			Engine.time_scale = lerpf(
				Engine.time_scale,
				levelable.stats.slow_time_on_boost_intensity, 
				delta * levelable.stats.slow_time_on_boost_power_up_speed
			)
	else:
		steerable.power_multiplier = 1
		update_boost_duration(delta * (boost_recharge_ratio + levelable.stats.boost_recharge_ratio))
		if is_zero_approx(Engine.time_scale - 1.):
			Engine.time_scale = 1.
		if levelable.stats.slow_time_on_boost:
			Engine.time_scale = lerpf(Engine.time_scale, 1, delta * 20.)


func is_dashing() -> bool:
	if controller.is_dash_pressed() and remaining_boost_duration > 0.0 and !is_boost_on_cd:
		return true
	return false


func get_dash_multiplier() -> float:
	return dash_multiplier + levelable.stats.boost_power_up


func update_boost_duration(delta: float) -> void:
	remaining_boost_duration += delta
	remaining_boost_duration = clampf(remaining_boost_duration, 0, get_max_boost_duration())
	
	if remaining_boost_duration / get_max_boost_duration() > boost_cd_reset:
		is_boost_on_cd = false
	
	if is_zero_approx(remaining_boost_duration):
		is_boost_on_cd = true
		
	on_boost_duration_changed.emit(remaining_boost_duration, get_max_boost_duration(), self)


func get_max_boost_duration() -> float:
	return max_boost_duration + levelable.stats.boost_duration_increase


func add_goal(node: Node2D) -> void:
	screen_edge_navigation.add_goal(node)
