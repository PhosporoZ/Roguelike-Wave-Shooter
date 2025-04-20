extends Area2D

var enemies_in_range = []
var facing_left = false

# Default positions and rotation when facing right.
var default_gun_pos := Vector2(7, 1)
var default_shootpoint_pos := Vector2(8, -4)
var idle_rotation_right = 0.0

# Flipped positions and rotation when enemy is on the left.
var flipped_gun_pos := Vector2(-7, 1)
var flipped_shootpoint_pos := Vector2(-8, -4)
var idle_rotation_left = 0.0

@onready var player_stats = get_parent().get_node("Playerstats")
@onready var timer_node = $Timer
@onready var collision_shape = $CollisionShape2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	timer_node.wait_time = player_stats.attackspeed
	timer_node.start()
	
	# Listen for any stat changes.
	player_stats.connect("stats_changed", Callable(self, "_on_stats_changed"))
	
	update_range(player_stats.attackrange)

func _on_stats_changed(stat: String, new_value) -> void:
	if stat == "attackspeed":
		timer_node.wait_time = new_value
	elif stat == "attackrange":
		update_range(new_value)

func update_range(new_range: float) -> void:
	if collision_shape and collision_shape.shape is CircleShape2D:
		var shape = collision_shape.shape
		shape.radius = new_range
		collision_shape.shape = shape

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.append(body)

func _on_body_exited(body):
	if body.is_in_group("Enemy"):
		enemies_in_range.erase(body)

# Helper function to get the closest enemy using squared distance.
func _get_closest_enemy() -> Node:
	var pos = global_position
	var closest_enemy = enemies_in_range[0]
	var closest_dist_sq = (closest_enemy.global_position - pos).length_squared()
	for enemy in enemies_in_range:
		var dist_sq = (enemy.global_position - pos).length_squared()
		if dist_sq < closest_dist_sq:
			closest_enemy = enemy
			closest_dist_sq = dist_sq
	return closest_enemy

func _update_pivot_state(flip: bool, gun_pos: Vector2, shoot_pos: Vector2, rotation_val: float) -> void:
	$Pivot/Arms.flip_h = flip
	$Pivot/PixelRevolver.flip_h = flip
	$Pivot/PixelRevolver.position = gun_pos
	%ShootPoint.position = shoot_pos
	$Pivot.rotation = rotation_val

func _physics_process(_delta):
	if enemies_in_range.size() > 0:
		var closest_enemy = _get_closest_enemy()
		var direction = closest_enemy.global_position - global_position
		var angle = direction.angle()
		
		facing_left = (direction.x < 0)
		if facing_left:
			angle += PI
			_update_pivot_state(true, flipped_gun_pos, flipped_shootpoint_pos, angle)
		else:
			_update_pivot_state(false, default_gun_pos, default_shootpoint_pos, angle)
	else:
		if facing_left:
			_update_pivot_state(true, flipped_gun_pos, flipped_shootpoint_pos, idle_rotation_left)
		else:
			_update_pivot_state(false, default_gun_pos, default_shootpoint_pos, idle_rotation_right)
			
func shoot():
	const BULLET = preload("res://scenes/rev_bullet.tscn")
	var new_bullet = BULLET.instantiate()

	var sp = %ShootPoint
	new_bullet.global_position = sp.global_position
	new_bullet.global_rotation = sp.global_rotation
	if facing_left:
		new_bullet.global_rotation += PI
	
	var base_damage = player_stats.damage
	var crit_chance = player_stats.criticalhitchance
	var final_damage = base_damage
	if (randi() % 100) < crit_chance:
		final_damage = base_damage * 2
		print("Critical Hit! Damage:", final_damage)
	else:
		print("Normal hit. Damage:", final_damage)
		
	new_bullet.damage = final_damage
	get_tree().current_scene.add_child(new_bullet)

func _on_timer_timeout() -> void:
	if enemies_in_range.size() > 0:
		shoot()
