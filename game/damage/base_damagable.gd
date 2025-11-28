extends Resource
class_name BaseDamagable


signal on_damage_taken(damage_dealt: int)
signal on_health_changed(new_health: int, max_health: int)
signal on_death(actor: Node2D)

@export var max_health: int = 10
@export var max_invulnerability_time: float = 0.0
var game_actor: Node2D
var remaining_invulnerability_time: float = 0.0
var current_health: int = 1
var is_dead: bool = false
var is_invincible: bool = false


### Must be called each physics frame by the game actor to
### maintain timers
func physics_process(delta: float) -> void:
	if remaining_invulnerability_time > 0.0:
		remaining_invulnerability_time -= delta


func reset_damagable(_game_actor: Node2D) -> void:
	current_health = max_health
	game_actor = _game_actor
	is_dead = false
	remaining_invulnerability_time = 0.0


func is_damagable() -> bool:
	return !is_dead and !is_invincible and !is_invulnerable()


func is_invulnerable() -> bool:
	return remaining_invulnerability_time > 0.0


func take_damage(damage: int) -> bool:
	if !is_damagable(): return false
	
	current_health -= damage
	on_health_changed.emit(current_health, max_health)
	on_damage_taken.emit(damage)
	if max_invulnerability_time > 0.0 and current_health > 0:
		remaining_invulnerability_time = max_invulnerability_time
	
	if current_health <= 0:
		die()
	
	return true


func die() -> void:
	if game_actor:
		on_death.emit(game_actor)
	is_dead = true


func restore_health(health: int) -> void:
	var previous_health = current_health
	current_health = clampi(current_health + health, current_health, max_health)
	if current_health != previous_health:
		on_health_changed.emit(current_health, max_health)
