extends CharacterBody2D
class_name TargetDummy


@export var damagable: BaseDamagable
@export var on_death_handler: BaseOnDeathHandler
@export var tween_damaged: TweenDamaged

var actor_type := GameActor.ActorType.ENEMY


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		if on_death_handler:
			on_death_handler.bind_to_node(self)
		if tween_damaged:
			tween_damaged.bind_to_node(self)


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)
