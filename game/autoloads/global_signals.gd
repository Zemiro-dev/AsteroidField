extends Node

@warning_ignore_start("unused_signal")
signal request_camera_shake(duration: float, strength: float)
signal request_hitstop(hitstop_time_ms: float)
signal request_particle_spawn(particle: Node)
signal request_projectile_spawn(projectile: Node)
signal request_explosion_spawn(source: Node2D, explosion_scene: PackedScene)
signal request_collectible_spawn(position: Vector2, scene: PackedScene)
signal request_sound_spawn(sound: AudioStreamPlayer2D)
signal request_world_sound_spawn(source: Node2D, sound_scene: PackedScene)
signal request_play_sound_at(position: Vector2, stream: AudioStream, volumn_db: float)
@warning_ignore_restore("unused_signal")
