extends Resource
class_name BaseOnDeathHandler


@export var explosion_scene: PackedScene


func bind_to_node(node: Node2D):
	var damagable := GameActor.get_damagable(node)
	if damagable:
		damagable.on_death.connect(on_death)


func on_death(game_actor: Node2D) -> void:
	if explosion_scene and explosion_scene.can_instantiate():
		var explosion = explosion_scene.instantiate()
		if explosion is GPUParticles2D or explosion is CPUParticles2D:
			explosion.global_transform = game_actor.global_transform
			explosion.emitting = true
			GlobalSignals.request_particle_spawn.emit(explosion)
	var anim = game_actor.get("animation_player")
	if anim and anim is AnimationPlayer and anim.has_animation('die'):
		anim.play('die')
