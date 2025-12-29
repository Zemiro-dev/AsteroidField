extends Area2D
class_name LaserCannon

enum FiringStyle { AT_REPEATING, ROTATING }


@onready var laser_container: Node2D = $LaserContainer

## Will this cannon fire lasers
@export var active := true : set = set_active
## The firing style this laser cannon should use.
@export var firing_style := FiringStyle.AT_REPEATING
## Offset to place new lasers at
@export var laser_pivot_offset := Vector2.ZERO
## Scene to use for the laser
@export var laser_scene := preload("res://projectiles/laser/telegraphed_yellow_laser.tscn")
## Number of lasers
@export var laser_pool_count := 1
## Max time for the laser to stay in the active state in seconds, if
## 0.0 then the cast time is infinite and the state must be switched to cooldown
## manually
@export var laser_cast_time_max := 5.
## Time to show warning before activating laser, in seconds
@export var laser_warning_time_max := 2.
## The linear acceleration for the warning particles
@export var laser_warning_linear_accel := 500.
## Max length of the laser in pixel
@export var laser_max_length := 500.0
var lasers: Array[TelegraphedLaser] = [] 
var laser_pivots: Array[Node2D] = []

## Initial rotation to use when rotating
@export var initial_rotation := 0.
@onready var laser_rotation := initial_rotation
@export var laser_rotation_step := PI / 4
@export var activation_laser_count: int = 1

class Target extends RefCounted:
	## The actual target body
	var body: Node2D
	## The age of this target
	var age: float = 0.
	func _init(_body: Node2D, _age: float = 0.) -> void:
		body = _body
		age = _age

## Time after a target has entered before they can be fired upon, in seconds
@export var target_lock_time := 2.
## Time between activations, in seconds
@export var activation_cooldown := 0.
var activation_cooldown_remaining := 0.
var targets: Array[Target] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exit)
	## Add the lasers and pivots to the laser_container
	for i in range(laser_pool_count):
		if laser_scene and laser_scene.can_instantiate():
			var laser_pivot := Node2D.new()
			var laser := laser_scene.instantiate()
			if laser is TelegraphedLaser:
				lasers.append(laser)
				laser_pivots.append(laser_pivot)
				laser_pivot.add_child(laser)
				laser_container.add_child(laser_pivot)
				laser.position += laser_pivot_offset
				laser.cast_time_max = laser_cast_time_max
				laser.warning_time_max = laser_warning_time_max
				laser.max_length = laser_max_length
				laser.warning_linear_accel = laser_warning_linear_accel
				laser_pivot.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func set_active(new_value: bool) -> void:
	if !new_value:
		for laser in lasers:
			if laser.state != TelegraphedLaser.LaserState.INACTIVE:
				laser.state = TelegraphedLaser.LaserState.COOLDOWN
	active = new_value

func _physics_process(delta: float) -> void:
	if activation_cooldown_remaining > 0.:
		activation_cooldown_remaining -= delta
	for target in targets:
		if target.age < target_lock_time:
			target.age += delta
		else:
			if activation_cooldown_remaining <= 0. && active:
				fire_laser(target.body)


func fire_laser(target: Node2D) -> void:
	var fire_success := false
	match (firing_style):
		FiringStyle.AT_REPEATING:
			fire_success = fire_laser_at_repeating(target)
		FiringStyle.ROTATING:
			fire_success = fire_laser_rotating(target)
	if fire_success:
		activation_cooldown_remaining = activation_cooldown


func fire_laser_at_repeating(target: Node2D) -> bool:
	var inactive_laser_indexes := get_inactive_lasers_indexes(activation_laser_count)
	for i in inactive_laser_indexes:
		laser_pivots[i].rotation = (target.global_position - global_position).angle()
		lasers[i].state = TelegraphedLaser.LaserState.WARNING
	return !inactive_laser_indexes.is_empty()


func fire_laser_rotating(_target: Node2D) -> bool:
	var inactive_laser_indexes := get_inactive_lasers_indexes(activation_laser_count)
	if inactive_laser_indexes.size() == activation_laser_count:
		for i in range(activation_laser_count):
			var laser_index := inactive_laser_indexes[i]
			laser_pivots[laser_index].rotation = laser_rotation + (TAU / activation_laser_count * i)
			lasers[laser_index].state = TelegraphedLaser.LaserState.WARNING
		laser_rotation += laser_rotation_step
		if laser_rotation > TAU:
			laser_rotation -= TAU
		return true
	return false


## Looks for the specific number of inactive laser and if found
## returns their indexes. If the proper number cannot be found
## an empty array is returned
func get_inactive_lasers_indexes(count: int) -> Array[int]:
	var inactive_lasers: Array[int] = []
	for i in range(lasers.size()):
		if lasers[i].state == TelegraphedLaser.LaserState.INACTIVE:
			inactive_lasers.append(i)
		if inactive_lasers.size() >= count:
			return inactive_lasers
	return []


func _on_body_entered(body: Node2D) -> void:
	if !targets.any(func(target: Target): target.body == body):
		targets.append(Target.new(body))


func _on_body_exit(body: Node2D) -> void:
	targets = targets.filter(func(target: Target): target.body == body)
