extends CharacterBody2D
class_name TargetDummy


@export var damagable: BaseDamagable
@export var tween_damaged: TweenDamaged
@export var explosion_scene: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var actor_type := GameActor.ActorType.ENEMY


var modulate_tween: Tween


func _ready() -> void:
	if damagable:
		damagable.reset_damagable(self)
		damagable.on_death.connect(on_death)
		if tween_damaged:
			tween_damaged.bind_to_node(self)


func _physics_process(delta: float) -> void:
	if damagable:
		damagable.physics_process(delta)


func on_death(game_actor: Node2D) -> void:
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		if explosion is GPUParticles2D or explosion is CPUParticles2D:
			explosion.global_transform = global_transform
			explosion.emitting = true
			GlobalSignals.request_particle_spawn.emit(explosion)
	animation_player.play("die")
