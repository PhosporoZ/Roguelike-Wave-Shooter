extends Node2D

@export var mob_scene: PackedScene = preload("res://scenes/squid_enemy.tscn")

@export var spawn_interval: float = 6.0  # How frequently to spawn a batch.
@export var spawn_count: int = 3         # How many enemies spawn at once.
@export var min_distance_from_player: float = 100.0  # Enemies won't spawn closer than this.

@export var arena_min: Vector2 = Vector2(100, 100)
@export var arena_max: Vector2 = Vector2(600, 400)

@onready var player = $Player
@onready var powerup_canvas = $OverlayCanvasLayer/PowerUpSelection

var spawn_timer: Timer
var game_time: float = 0.0   # Tracking elapsed game time (in seconds).

func _ready():
	randomize()
	var timer_ui = $HUDCanvasLayer/TimerUI
	timer_ui.connect("timer_finished", Callable(self, "_on_timer_finished"))
	
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	spawn_timer.start()

func _process(delta: float) -> void:
	game_time += delta

func _on_timer_timeout() -> void:
	# Spawn a batch of enemies.
	for i in range(spawn_count):
		spawn_enemy()

func spawn_enemy() -> void:
	var angle: float = randf() * TAU  # TAU equals 2*PI.
	var distance: float = randf_range(100, 300)
	var offset: Vector2 = Vector2(cos(angle), sin(angle)) * distance
	
	# Calculate spawn position relative to the player's position.
	var spawn_position: Vector2 = player.global_position + offset
	
	# Ensuring spawn position is inside the arena.
	if not is_inside_arena(spawn_position):
		spawn_position = clamp_to_arena(spawn_position)
	
	# Instance the enemy.
	var new_mob = mob_scene.instantiate()
	new_mob.global_position = spawn_position
	
	# Gradually scale enemy stats based on elapsed time.
	var difficulty_factor: float = 1.2 + (game_time / 60.0)
	
	# Increase enemy speed, damage, and health.
	new_mob.speed *= difficulty_factor
	new_mob.damage = int(new_mob.damage * difficulty_factor)
	new_mob.health = int(new_mob.health * difficulty_factor)
	
	# If more than 30 seconds have passed, modify enemy appearance for extra impact.
	if game_time > 30.0:
		new_mob.scale = Vector2(1.5, 1.5)
		new_mob.modulate = Color(1.0, 0.2, 0.5)  # Change color to a slightly reddish tone.
	
	add_child(new_mob)

func is_inside_arena(pos: Vector2) -> bool:
	return pos.x >= arena_min.x and pos.x <= arena_max.x and pos.y >= arena_min.y and pos.y <= arena_max.y

func clamp_to_arena(pos: Vector2) -> Vector2:
	return Vector2(
		clamp(pos.x, arena_min.x, arena_max.x),
		clamp(pos.y, arena_min.y, arena_max.y)
	)

func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	%GameOver.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if not powerup_canvas.visible:
			powerup_canvas.visible = true
			get_tree().paused = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_timer_ui_timer_finished() -> void:
	$OverlayCanvasLayer/WinScreen.visible = true
	get_tree().paused = true
