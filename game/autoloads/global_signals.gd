extends Node


signal request_camera_shake(duration: float, strength: float)
signal request_hitstop(hitstop_time_ms: float)
signal request_particle_spawn(particle: Node)
signal request_projectile_spawn(projectile: Node)
signal request_explosion_spawn(source: Node2D, explosion_scene: PackedScene)
signal request_sound_spawn(sound: AudioStreamPlayer2D)
signal request_world_sound_spawn(source: Node2D, sound_scene: PackedScene)
