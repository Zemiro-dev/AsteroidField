@tool
extends Area2D
class_name LaserCannon

enum FiringStyle { AT_REPEATING, ROTATING }


@onready var laser_container: Node2D = $LaserContainer

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
var lasers: Array[TelegraphedLaser] = [] 
var laser_pivots: Array[Node2D] = []

class Target extends RefCounted:
	## The actual target body
	var body: Node2D
	## The age of this target
	var age: float = 0.
	func _init(_body: Node2D, _age: float = 0.) -> void:
		body = _body
		age = _age

## Time after a target has entered before they can be fired upon, in seconds
@export var target_lock_time := 5.
## Time between activations, in seconds
@export var activation_cooldown := 0.
var activation_cooldown_remaining := 0.
var targets: Array[Target] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	## Add the lasers and pivots to the laser_container
	for i in range(laser_pool_count):
		if laser_scene and laser_scene.can_instantiate():
			var laser_pivot := Node2D.new()
			var laser := laser_scene.instantiate()
			lasers.append(laser)
			laser_pivots.append(laser_pivot)
			laser_pivot.add_child(laser)
			laser_container.add_child(laser_pivot)
			laser.position += laser_pivot_offset
			laser.cast_time_max = laser_cast_time_max
			laser_pivot.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF


func _physics_process(delta: float) -> void:
	if activation_cooldown_remaining > 0.:
		activation_cooldown_remaining -= delta
	for target in targets:
		if target.age < target_lock_time:
			target.age += delta
		else:
			if activation_cooldown_remaining <= 0.:
				fire_laser(target.body)


func fire_laser(target: Node2D) -> void:
	var fire_success := false
	match (firing_style):
		FiringStyle.AT_REPEATING:
			fire_success = fire_laser_at_repeating(target)
	if fire_success:
		activation_cooldown_remaining = activation_cooldown


func fire_laser_at_repeating(target: Node2D) -> bool:
	for i in range(lasers.size()):
		if lasers[i].state == TelegraphedLaser.LaserState.INACTIVE:
			laser_pivots[i].rotation = (target.global_position - global_position).angle()
			lasers[i].state = TelegraphedLaser.LaserState.WARNING
			return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if !targets.any(func(target: Target): target.body == body):
		targets.append(Target.new(body))


func _on_body_exit(body: Node2D) -> void:
	targets = targets.filter(func(target: Target): target.body == body)
