extends Node


enum ActorType { PLAYER, ENEMY, TERRAIN, DESTRUCTIBLE, UNKNOWN }


func get_actor_type(o: Object) -> ActorType:
	if o == null: return ActorType.UNKNOWN
	if o.has_method("get_actor_type"):
		var m_actor_type = o.get_actor_type()
		if ActorType.has(m_actor_type):
			return m_actor_type
	var actor_type = o.get("actor_type")
	if actor_type != null and ActorType.values().has(actor_type):
		return actor_type
	return ActorType.UNKNOWN


func get_steerable(o: Object) -> BaseSteerable:
	if o == null: return null
	if o.has_method("get_steerable"):
		var m_steerable = o.get_steerable()
		if m_steerable is BaseSteerable:
			return m_steerable
	var steerable = o.get("steerable")
	if steerable != null and steerable is BaseSteerable:
		return steerable
	return null


func get_damagable(o: Object) -> BaseDamagable:
	if o == null: return null
	if o.has_method("get_damagable"):
		var m_damagable = o.get_damagable()
		if m_damagable is BaseDamagable:
			return m_damagable
	var damagable = o.get("damagable")
	if damagable != null and damagable is BaseDamagable:
		return damagable
	return null


func get_levelable(o: Object) -> Levelable:
	if o == null: return null
	if o.has_method("get_levelable"):
		var m_levelable = o.get_levelable()
		if m_levelable is Levelable:
			return m_levelable
	var levelable = o.get("levelable")
	if levelable != null and levelable is Levelable:
		return levelable
	return null
	
