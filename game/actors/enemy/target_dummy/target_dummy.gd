extends CharacterBody2D
class_name TargetDummy


@export var damagable: BaseDamagable

var actor_type := GameActor.ActorType.ENEMY

var modulate_tween: Tween


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		damagable.on_death.connect(on_death)
		damagable.on_damage_taken.connect(on_damage_taken)


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)


func on_damage_taken(damage_taken: int):
	if modulate_tween != null:
		modulate_tween.kill()
		modulate = Color(1, 1, 1, 1)
	
	modulate_tween =	 create_tween()
	modulate_tween.tween_property(self, "modulate", Color(1, 0, 0, 1), max(damagable.max_invulnerability_time / 2.0, .1))
	modulate_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), max(damagable.max_invulnerability_time / 2.0, .1))


func on_death(game_actor: Node2D) -> void:
	print("Target Dummy died!")
