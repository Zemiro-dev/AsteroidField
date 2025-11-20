extends CharacterBody2D
class_name TargetDummy


@export var damagable: BaseDamagable

var actor_type := GameActor.ActorType.ENEMY


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		damagable.on_death.connect(on_death)


func on_death(game_actor: Node2D) -> void:
	print("Target Dummy died!")
