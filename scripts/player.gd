extends CharacterBody2D

signal health_depleted

@onready var animation_player = $AnimationPlayer
@onready var sprite = $"GunslingerDude-sheet"
@onready var damage_timer = $DamageTimer
@onready var healthbar = %Healthbar
@onready var stats = $Playerstats
@onready var health_regen_timer = $HealthRegenTimer

var health
var speed
var damage
var armor
var lifesteal
var criticalhitchance
var healthregen
var attackrange

var is_hurt = false

# Array to track enemies overlapping the Hurtbox.
var damaging_enemies: Array = []

func _ready() -> void:
	damage_timer.start()
	health_regen_timer.start()
	add_to_group("Player")
	
	# Initialize the player's variables from the Playerstats node.
	health = stats.health
	speed = stats.movespeed
	damage = stats.damage
	armor = stats.armor
	lifesteal = stats.lifesteal
	criticalhitchance = stats.criticalhitchance
	healthregen = stats.healthregen
	attackrange = stats.attackrange

	healthbar.init_health(health)
	
	stats.connect("stats_changed", Callable(self, "_on_stats_changed"))
	
	# Connect the player's lifesteal handler to the global signal.
	GlobalSignals.connect("enemy_damaged", Callable(self, "_on_enemy_damaged"))

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _process(_delta):
	if not is_hurt:
		if velocity.length() > 0:
			animation_player.play("Run")
		else:
			animation_player.play("Idle")
	
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func _physics_process(_delta):
	get_input()
	move_and_slide()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body not in damaging_enemies:
		damaging_enemies.append(body)
		# When applying damage, calculate effective damage with armor.
		apply_damage(body.damage)
		damage_timer.start()  # Start cooldown

func _on_hurtbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy") and body in damaging_enemies:
		damaging_enemies.erase(body)

func _on_damage_timer_timeout() -> void:
	for enemy in damaging_enemies:
		apply_damage(enemy.damage)
	damage_timer.start()

func apply_damage(amount: int) -> void:
	# Calculate effective damage using diminishing returns (armor reduces damage)
	var effective_damage = amount * (100.0 / (100.0 + stats.armor))
	effective_damage = int(round(effective_damage))
	
	health -= effective_damage
	is_hurt = true
	animation_player.play("Hurt")
	
	await get_tree().create_timer(0.2).timeout
	is_hurt = false
	
	healthbar.health = health
	
	if health <= 0:
		emit_signal("health_depleted")
		
func _on_health_regen_timer_timeout() -> void:
	if health <= 0:
		return

	health += stats.healthregen
	if health > stats.health:
		health = stats.health
	healthbar.health = health

func _on_enemy_damaged(_damage: int) -> void:
	apply_lifesteal()

func apply_lifesteal() -> void:
	var random_chance = randi() % 100
	if random_chance < stats.lifesteal:
		health += 1
		if health > stats.health:
			health = stats.health
		healthbar.health = health
		

func _on_stats_changed(stat: String, new_value) -> void:
	match stat:
		"movespeed":
			speed = new_value
		"damage":
			damage = new_value
		"armor":
			armor = new_value
		"lifesteal":
			lifesteal = new_value
		"criticalhitchance":
			criticalhitchance = new_value
		"healthregen":
			healthregen = new_value
		"attackrange":
			attackrange = new_value
		_:
			print("Stat %s changed to %s" % [stat, new_value])
