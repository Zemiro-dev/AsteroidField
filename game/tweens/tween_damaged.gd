extends Resource
class_name TweenDamaged


@export var damaged_color: Color
var _tween: Tween
var _color: Color


func bind_to_node(node: Node2D):
	var damagable := GameActor.get_damagable(node)
	_color = node.modulate
	if damagable:
		damagable.on_damage_taken.connect(
			func(_dmg: int): 
				tween(node, max(damagable.max_invulnerability_time, .2))
		)


func tween(node: Node2D, duration: float):
	if _tween != null:
		_tween.kill()
	
	if _color != null:
		node.modulate = _color
	
	if damaged_color:
		_color = node.modulate
		_tween = node.create_tween()
		_tween.tween_property(node, "modulate", damaged_color, duration / 4.)
		_tween.tween_property(node, "modulate", _color, duration / 4.)
		_tween.tween_property(node, "modulate", damaged_color, duration / 4.)
		_tween.tween_property(node, "modulate", _color, duration / 4.)

	
