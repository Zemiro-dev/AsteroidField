extends Node2D
class_name PinwheelScanner


@export var enabled: bool = true:
	set(value):
		if (value != enabled):
			for_each_ray(
				func(ray: RayCast2D, _i: int): 
					ray.enabled = value
					ray.force_raycast_update()
			)
			enabled = value
@export var spinning: bool = true
@export var forward_ray: Vector2 = Vector2(100., 0)
@export var rotation_speed: float = TAU * 6.
@export_flags_2d_physics var collision_mask: int


func _ready() -> void:
	var ray_count: int = get_ray_count()
	var angle: float = 2.0 * PI / float(ray_count)
	for_each_ray(
		func(ray: RayCast2D, i: int): 
			ray.target_position = Vector2(forward_ray).rotated(i * angle)
			ray.collision_mask = collision_mask
			ray.enabled = enabled
	)


func _physics_process(delta: float) -> void:
	if spinning:
		rotation += delta * rotation_speed


func scan() -> Vector2:	
	var sense := { "value" : Vector2.ZERO }
	for_each_ray(func(ray: RayCast2D, _i: int): sense.value += scan_ray(ray))
	sense.value = Vector.clamp_vector2_length(sense.value, 1.)
	return sense.value


func scan_ray(ray: RayCast2D) -> Vector2:
	if !ray.is_colliding(): return Vector2.ZERO	
	var collision_point: Vector2 = ray.get_collision_point() - global_position
	return -collision_point.normalized()


func get_ray_count() -> int:
	var count := { "value" : 0}
	for_each_ray(func(_ray: RayCast2D, _i: int): count.value += 1)
	return count.value


func for_each_ray(callable: Callable):
	var index := 0
	for ray in get_children():
		if ray is RayCast2D:
			callable.call(ray, index)
			index += 1
