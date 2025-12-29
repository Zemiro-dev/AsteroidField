extends CharacterBody2D
class_name LaserBase


@export var damagable: BaseDamagable
@export var on_death_handler: BaseOnDeathHandler
@export var tween_damaged: TweenDamaged
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var body: Sprite2D = $Body

var laser_cannons: Array[LaserCannon] = []

var actor_type := GameActor.ActorType.ENEMY


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		if on_death_handler:
			on_death_handler.bind_to_node(self)
		if tween_damaged:
			tween_damaged.bind_to_node(self, body)
	for child in get_children():
		if child is LaserCannon:
			laser_cannons.append(child)
			child.show_behind_parent = true


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)


func disable_cannons() -> void:
	for laser in laser_cannons:
		laser.active = false
