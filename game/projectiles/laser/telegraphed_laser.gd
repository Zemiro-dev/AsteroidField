@tool
extends Node2D
class_name TelegraphedLaser

enum LaserState {INACTIVE, WARNING, ACTIVE, COOLDOWN}


signal on_state_change(prev: LaserState, current: LaserState)


@onready var warning_particles: GPUParticles2D = $WarningParticles
@onready var beam: Line2D = $Beam
@onready var beam_start_particles: GPUParticles2D = $BeamStartParticles
@onready var beam_cast: RayCast2D = $BeamCast
@onready var beam_head_particles: GPUParticles2D = $BeamHeadParticles
@onready var beam_end_particles: GPUParticles2D = $BeamEndParticles
@onready var beam_width_particles: GPUParticles2D = $BeamWidthParticles
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/HurtboxShape
@onready var beam_particles := [beam_width_particles, beam_start_particles, beam_end_particles, beam_head_particles]
@onready var laser_loop_player: ExtendedAudioStreamPlayer2D = $LaserLoopPlayer


## The current state of the beamcast
@export var state := LaserState.INACTIVE: set = set_state
## Speed at which laser is fired out when activated, in pixels per second.
@export var cast_speed := 2000.0
## Max length of the laser in pixel
@export var max_length := 500.0
## Offset to apply to the hurtbox position, in pixels
@export var hurtbox_offset := Vector2.ZERO
@export var beam_head_offset := Vector2.ZERO
@export var beam_end_offset := Vector2.ZERO
## Time to show warning before activating laser, in seconds
@export var warning_time_max := 2.
var warning_time_remaining := 0.
## The linear acceleration for the warning particles
@export var warning_linear_accel := 500.
## Max time for the laser to stay in the active state in seconds, if
## 0.0 then the cast time is infinite and the state must be switched to cooldown
## manually
@export var cast_time_max := 5.
var cast_time_remaining := 0.
@export var cooldown_time_max := 1.
var cooldown_time_remaining := 0.
## Base duration of growth tween in seconds
@export var growth_time := .1
## Max beam width
@export var beam_width_max := 20.
var beam_tween: Tween
const VISIBILITY_MARGIN := 20.
@export_range(-80, 24, 1, "suffix:dB") var laser_loop_max_volumn_db: float = 0.0
var laser_loop_min_volumn_db: float = -60.0
var sound_tween: Tween

@export var zap_sound_scene := preload("res://audio/sound_zap.tscn")


func _ready() -> void:
	set_state(state) # ensure code requiring ready is called
	hurtbox.on_damage_dealt.connect(
		func (_t: Node2D, _d: int):
			GlobalSignals.request_world_sound_spawn.emit(self, zap_sound_scene)
			GlobalSignals.request_camera_shake.emit(.2, 500)
	)


func _physics_process(delta: float) -> void:
	match (state):
		LaserState.WARNING:
			warning_time_remaining -= delta
			if warning_time_remaining <= 0.:
				state = LaserState.ACTIVE
		LaserState.ACTIVE:
			_update_beam_effects(_process_beamcast(delta))
			if cast_time_max > 0:
				cast_time_remaining -= delta
				if cast_time_remaining <= 0.:
					state = LaserState.COOLDOWN
		LaserState.COOLDOWN:
			cooldown_time_remaining -= delta
			if cooldown_time_remaining <= 0.:
				state = LaserState.INACTIVE
	


func set_state(new_value: LaserState) -> void:	
	## Exit State Handlers
	match (state):
		LaserState.WARNING:
			warning_particles.emitting = false
		LaserState.ACTIVE:	
			_deactivate_beam()
	
	## Enter State Handlers
	match (new_value):
		LaserState.WARNING:
			var pm := warning_particles.process_material 
			if pm is ParticleProcessMaterial:
				pm.linear_accel_max = warning_linear_accel
				pm.linear_accel_min = warning_linear_accel
			_set_visibility_rect(warning_particles)
			warning_particles.emitting = true
			warning_time_remaining = warning_time_max
		LaserState.ACTIVE:
			_activate_beam()
		LaserState.COOLDOWN:
			cooldown_time_remaining = cooldown_time_max
	var prev := state
	state = new_value
	on_state_change.emit(prev, state)


func _process_beamcast(delta: float) -> Vector2:
		beam_cast.target_position.x = move_toward(
			beam_cast.target_position.x,
			max_length,
			cast_speed * delta
		)
		beam_cast.force_raycast_update()
		if beam_cast.is_colliding():
			var collision_point = Vector2(to_local(beam_cast.get_collision_point()).x, 0.0)
			beam_cast.target_position.x = collision_point.x
			return collision_point
		return beam_cast.target_position


func _update_beam_effects(end_position: Vector2):
	var half_end_position := end_position * .5
	var half_length := half_end_position.length()
	beam.points[1] = end_position
	beam_head_particles.process_material.emission_shape_offset = Vector3(
		end_position.x + beam_head_offset.x,
		end_position.y + beam_head_offset.y, 
	0.0)
	beam_end_particles.process_material.emission_shape_offset = Vector3(
		end_position.x + beam_end_offset.x,
		end_position.y + beam_end_offset.y,
	0.0)
	beam_width_particles.process_material.emission_shape_offset = Vector3(half_end_position.x, half_end_position.y, 0.0)
	beam_width_particles.process_material.emission_box_extents.x = half_length
	hurtbox.position = half_end_position + hurtbox_offset
	hurtbox_shape.shape.radius = beam.width * .5
	hurtbox_shape.shape.height = half_length * 2.


func _activate_beam() -> void:
	if (!is_node_ready()): return
	_update_beam_effects(Vector2.ZERO)
	for particle in beam_particles:
		if particle is GPUParticles2D:
			_set_visibility_rect(particle)
			particle.emitting = true
	hurtbox.monitoring = true
	cast_time_remaining = cast_time_max
	beam.show()
	if beam_tween: beam_tween.kill()
	beam_tween = beam.create_tween()
	beam_tween.tween_property(beam, "width", beam_width_max, growth_time).from(0.0)
	laser_loop_player.play_at_random_pitch()
	if sound_tween: sound_tween.kill()
	sound_tween = laser_loop_player.create_tween()
	sound_tween.tween_property(laser_loop_player, "volume_db", laser_loop_max_volumn_db, growth_time * 2.).from(laser_loop_min_volumn_db)


func _set_visibility_rect(particle: GPUParticles2D):
	var origin = -max_length - VISIBILITY_MARGIN
	var side_length = max_length * 2.0
	particle.visibility_rect = Rect2(
		origin, origin,
		side_length, side_length
	)


func _deactivate_beam() -> void:
	if (!is_node_ready()): return
	for particle in beam_particles:
		if particle is GPUParticles2D:
			particle.emitting = false
	hurtbox.monitoring = false
	hurtbox_shape.shape.height = 0.
	beam_cast.target_position = Vector2.ZERO
	if beam_tween: beam_tween.kill()
	beam_tween = beam.create_tween()
	beam_tween.tween_property(beam, "width", 0.0, growth_time).from_current()
	beam_tween.tween_callback(beam.hide)
	if sound_tween: sound_tween.kill()
	sound_tween = laser_loop_player.create_tween()
	sound_tween.tween_property(laser_loop_player, "volume_db", laser_loop_min_volumn_db, growth_time ).from_current()
	sound_tween.tween_callback(laser_loop_player.stop)
