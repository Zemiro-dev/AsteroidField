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

## The current state of the beamcast
@export var state := LaserState.INACTIVE: set = set_state
## Speed at which laser is fired out when activated, in pixels per second.
@export var cast_speed := 2000.0
## Max length of the laser in pixel
@export var max_length := 500.0
## Offset to apply to the hurtbox position, in pixels
@export var hurtbox_offset := Vector2.ZERO
## Time to show warning before activating laser, in seconds
@export var warning_time_max := 2.
var warning_time_remaining := 0.
@export var cast_time_max := 5.
var cast_time_remaining := 0.
@export var cooldown_time_max := 1.
var cooldown_time_remaining := 0.
## Base duration of growth tween in seconds
@export var growth_time := .1
## Max beam width
@export var beam_width_max := 20.
var beam_tween: Tween


func _ready() -> void:
	set_state(state) # ensure code requiring ready is called


func _physics_process(delta: float) -> void:
	match (state):
		LaserState.WARNING:
			warning_time_remaining -= delta
			if warning_time_remaining <= 0.:
				state = LaserState.ACTIVE
		LaserState.ACTIVE:
			_process_beamcast(delta)
			_process_beam()
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
			warning_particles.emitting = true
			warning_time_remaining = warning_time_max
		LaserState.ACTIVE:
			_activate_beam()
		LaserState.COOLDOWN:
			cooldown_time_remaining = cooldown_time_max
	var prev := state
	state = new_value
	on_state_change.emit(prev, state)


func _process_beamcast(delta: float) -> void:
		beam_cast.target_position.x = move_toward(
			beam_cast.target_position.x,
			max_length,
			cast_speed * delta
		)
		beam_cast.force_raycast_update()
		if beam_cast.is_colliding():
			beam_cast.target_position.x = to_local(beam_cast.get_collision_point()).x


func _process_beam() -> void:
	var laser_head_position: Vector2 = beam_cast.target_position
	
	beam.points[1] = laser_head_position
	beam_head_particles.position = laser_head_position
	beam_end_particles.position = laser_head_position
	beam_width_particles.position = laser_head_position * .5
	beam_width_particles.process_material.emission_box_extents.x = laser_head_position.length() * .5
	hurtbox.position = laser_head_position * .5 + hurtbox_offset
	hurtbox_shape.shape.radius = beam.width * .5
	hurtbox_shape.shape.height = laser_head_position.length()


func _activate_beam() -> void:
	if (!is_node_ready()): return
	for particle in beam_particles:
		particle.emitting = true
	hurtbox.monitoring = true
	cast_time_remaining = cast_time_max
	beam.show()
	if beam_tween: beam_tween.kill()
	beam_tween = beam.create_tween()
	beam_tween.tween_property(beam, "width", beam_width_max, growth_time).from(0.0)


func _deactivate_beam() -> void:
	if (!is_node_ready()): return
	for particle in beam_particles:
		particle.emitting = false
	hurtbox.monitoring = false
	hurtbox_shape.shape.height = 0.
	beam_cast.target_position = Vector2.ZERO
	if beam_tween: beam_tween.kill()
	beam_tween = beam.create_tween()
	beam_tween.tween_property(beam, "width", 0.0, growth_time).from_current()
	beam_tween.tween_callback(beam.hide)
