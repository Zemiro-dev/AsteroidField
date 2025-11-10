extends Resource
class_name BaseDamagable

signal on_damage_taken(attacker: Node2D, damage_dealt: int)
signal on_health_changed(new_health: int, max_health: int)
signal on_death(actor: Node2D)

@export var max_health: int = 1
var current_health: int = 1
var is_dead: bool = false
var is_invincible: bool = false


func initialize() -> void:
	current_health = max_health


func is_damagable() -> bool:
	return !is_dead && !is_invincible


func take_damage(damage: int, attacker: Node2D) -> void:
	pass


func _die() -> void:
	pass
	

func restore_health(health: int) -> void:
	pass
