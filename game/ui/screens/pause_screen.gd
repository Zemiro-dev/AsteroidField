extends CanvasLayer


@export var max_cooldown: float = .05
var remaining_cooldown: float = 0.0
var paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameManager.paused.connect(func(): visible = true)
	GameManager.unpaused.connect(func(): visible = false)


func _physics_process(delta: float) -> void:
	if remaining_cooldown > 0.:
		remaining_cooldown -= delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and remaining_cooldown <= 0.:
		remaining_cooldown = max_cooldown
		if get_tree().paused == true and paused:
			paused = false
			GameManager.request_unpause.emit()
		elif get_tree().paused != true and !paused:
			paused = true
			GameManager.request_pause.emit()
