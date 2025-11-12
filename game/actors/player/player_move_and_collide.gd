extends Resource
class_name PlayerMoveAndCollide


func move_and_collide(player: Player, delta: float) -> void:
	var collision: KinematicCollision2D = player.move_and_collide(player.velocity * delta)
	if collision:
		var collider: Object = collision.get_collider()
		var collider_type =	GameActor.get_actor_type(collider)
		match (collider_type):
			GameActor.Types.UNKNOWN, GameActor.Types.TERRAIN:
				move_and_collide_terrain(player, delta, collision, collider)
	if (player.velocity.length() > player.get_max_speed()):
		player.velocity = player.velocity.move_toward(player.velocity.normalized() * player.get_max_speed(), player.overspeed_break_force * delta)


func move_and_collide_terrain(player: Player, delta: float, collision: KinematicCollision2D, collider: Object):
	player.velocity = player.velocity.bounce(
		collision.get_normal()
	)
