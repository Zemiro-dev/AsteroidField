extends Area2D
class_name Hurtbox

signal on_damage_dealt(target: Node2D, damage_dealt: int)


### Damage per enter
@export var damage: int = 1
@export var will_knockback: bool = false
@export var raw_knockback_vector: Vector2 = Vector2(1250.0, 0)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var damagable: BaseDamagable = GameActor.get_damagable(body)
	#TODO damagable might alter damage, should return what is actually dealt
	#	and pass both.
	if damagable and damagable.take_damage(damage):
		on_damage_dealt.emit(body, damage)
		var steerable: BaseSteerable = GameActor.get_steerable(body)
		if steerable:
			var knockback_vector: Vector2 = Vector2(raw_knockback_vector).rotated(
				global_position.angle_to_point(body.global_position)
			)
			steerable.knockback(knockback_vector)
