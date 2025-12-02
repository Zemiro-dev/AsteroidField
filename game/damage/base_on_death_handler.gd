extends Resource
class_name BaseOnDeathHandler


@export var explosion_scene: PackedScene
@export var chance_to_spawn_health: float = 0.
@export var health_drop_scene: PackedScene = preload("res://collectibles/collectible_health_small.tscn")
var rng := RandomNumberGenerator.new()


func bind_to_node(node: Node2D):
	var damagable := GameActor.get_damagable(node)
	if damagable:
		damagable.on_death.connect(on_death)


func on_death(game_actor: Node2D) -> void:
	GlobalSignals.request_explosion_spawn.emit(game_actor, explosion_scene)
	if health_drop_scene and rng.randf() <= chance_to_spawn_health:
		GlobalSignals.request_collectible_spawn.emit(game_actor.global_position, health_drop_scene)
	var anim = game_actor.get("animation_player")
	if anim and anim is AnimationPlayer and anim.has_animation('die'):
		anim.play('die')
	if game_actor.has_method("on_death"):
		game_actor.on_death()
