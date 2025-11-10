It annoys me that I still don't have a system I really like for this.

# Types of Things

## Physics Layers

terrain: asteroids

# Game Entities


## World


# Move and Resolve

```gdscript
func move_and_resolve(entity: Entity, delta: float) -> void:
	entity.cap_velocity()
	var collision: KinematicCollision2D = entity.move_and_collide(entity.velocity * delta)
		if collision:q/ 
		var collider: Object = collision.get_collider(A)
		if collider is Entity:
			var v = entity.velocity
			var bouncingVelocity = entity.velocity.project(collision.get_normal())
			var nonBouncingVelocity = entity.velocity.slide(collision.get_normal())
			collider.velocity += 2 * entity.mass / (entity.mass + collider.mass) * bouncingVelocity
			entity.velocity = (
				(
					bouncingVelocity * (entity.mass - collider.mass) / (entity.mass + collider.mass)
				) + nonBouncingVelocity
			)
		else:
			entity.velocity = entity.velocity.bounce(
				collision.get_normal()
			)
		entity.current_knockback = Vector2.ZERO
```