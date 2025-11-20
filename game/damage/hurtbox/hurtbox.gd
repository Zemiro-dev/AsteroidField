extends Area2D
class_name Hurtbox

### Damage per enter
@export var damage: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var damagable: BaseDamagable = GameActor.get_damagable(body)
	if damagable:
		damagable.take_damage(damage)
