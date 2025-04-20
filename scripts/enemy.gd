extends CharacterBody2D

@onready var player = get_node("/root/Game/Player")
@onready var animation_player = $AnimationPlayer
@export var speed = 40
@onready var sprite = $"SquidThing-sheet"
@export var drop_chance: float = 0.08  # Chance to drop a chest. 8%
@export var chest_scene: PackedScene = preload("res://scenes/drops.tscn")

var health: int = 5
var damage: int = 5
var is_hurt: bool = false

func _ready() -> void:
	add_to_group("Enemy")
			
func _process(_delta):
	if player and not is_hurt:
		var vec_to_player = player.global_position - global_position
		var distance_to_player = vec_to_player.length()
		var stop_threshold: float = 10.0
		animation_player.play("Run")
		
		if distance_to_player > stop_threshold:
			var direction = vec_to_player.normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		
		if velocity.x > 0:
			sprite.flip_h = true
		elif velocity.x < 0:
			sprite.flip_h = false
		
		move_and_slide()

func damage_player(area) -> void:
	if area.name == "Hurtbox":
		area.get_parent().apply_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	animation_player.play("Hurt")
	is_hurt = true
	
	await get_tree().create_timer(0.07).timeout
	
	if health <= 0:
		var drop_roll: float = randf()
		if drop_roll < drop_chance:
			var chest = chest_scene.instantiate()
			chest.global_position = global_position
			get_tree().current_scene.add_child(chest)
		queue_free()
	else:
		is_hurt = false
