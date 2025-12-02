extends Area2D
class_name Collectible


enum Action { GIVE_HEALTH, GIVE_XP }

@onready var attraction_zone: Area2D = $AttractionZone

@export var action: Action = Action.GIVE_HEALTH
@export var action_amount: float = 1.
@export var steerable: BaseSteerable
@export var collect_sound: AudioStream
@export_range(-80, 24, 1, "suffix:dB") var collect_sound_volumn_db: float = 0.0

var direction_steering: DirectionSteeringStrategy
var player: Player
var has_been_collected: bool = false


func _ready() -> void:
	init_steering()
	attraction_zone.body_entered.connect(
		func(body: Node2D):
			if body is Player: 
				player = body
	)
	body_entered.connect(handle_on_body_entered)


func _physics_process(delta: float) -> void:
	if player != null and steerable:
		direction_steering.goal_vector = global_position.direction_to(player.global_position) * steerable.get_max_speed()
		steerable.steer(delta)
		global_position += steerable.velocity * delta


func handle_on_body_entered(body: Node2D) -> void:
	if not has_been_collected and body == player:
		collect()


func collect() -> void:
	if not player:
		return

	has_been_collected = true
	hide()
	
	if collect_sound:
		GlobalSignals.request_play_sound_at.emit(
			global_position,
			collect_sound,
			collect_sound_volumn_db
		)
	match action:
		Action.GIVE_HEALTH:
			var damagable := GameActor.get_damagable(player)
			if damagable:
				damagable.restore_health(int(action_amount))
		Action.GIVE_XP:
			var levelable := GameActor.get_levelable(player)
			if levelable:
				levelable.give_xp(int(action_amount))
	queue_free()


func init_steering() -> void:
	if steerable:
		direction_steering = DirectionSteeringStrategy.new()
		steerable.reset()
		steerable.steering_strategies.append(direction_steering)
