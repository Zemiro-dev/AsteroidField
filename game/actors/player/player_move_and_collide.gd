extends Resource
class_name PlayerMoveAndCollide


func move_and_collide(player: Player, delta: float) -> void:
	var steerable: BaseSteerable = GameActor.get_steerable(player)
	var collision: KinematicCollision2D = player.move_and_collide(steerable.velocity * delta)
	if collision:
		var collider: Object = collision.get_collider()
		var collider_type =	GameActor.get_actor_type(collider)
		match (collider_type):
			GameActor.ActorTypes.UNKNOWN, GameActor.ActorTypes.TERRAIN:
				steerable.velocity = steerable.velocity.bounce(collision.get_normal())
	if steerable.should_overspeed_break():
		steerable.overspeed_break(delta)
