extends Node


enum ActorType { PLAYER, ENEMY, TERRAIN, UNKNOWN }


func get_actor_type(o: Object) -> ActorType:
	if o.has_method("get_actor_type"):
		var actor_type = o.get_actor_type()
		if ActorType.has(actor_type):
			return actor_type
	var actor_type = o.get("actor_type")
	if actor_type != null and ActorType.has(actor_type):
		return actor_type
	return ActorType.UNKNOWN


func get_steerable(o: Object) -> BaseSteerable:
	if o.has_method("get_steerable"):
		var steerable = o.get_steerable()
		if steerable is BaseSteerable:
			return steerable
	var steerable = o.get("steerable")
	if steerable != null and steerable is BaseSteerable:
		return steerable
	return null


func get_damagable(o: Object) -> BaseDamagable:
	if o.has_method("get_damagable"):
		var damagable = o.get_damagable()
		if damagable is BaseSteerable:
			return damagable
	var damagable = o.get("damagable")
	if damagable != null and damagable is BaseDamagable:
		return damagable
	return null
