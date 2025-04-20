extends Node2D

@export var movespeed = 100.0
@export var health = 100
@export var damage = 5
@export var attackspeed = 0.5
@export var healthregen = 2
@export var armor = 5
@export var criticalhitchance = 1
@export var lifesteal = 0
@export var attackrange = 70.0

signal stats_changed(stat: String, new_value)

func set_stat(stat: String, value) -> void:
	match stat:
		"movespeed":
			movespeed = value
		"health":
			health = value
		"damage":
			damage = value
		"attackspeed":
			attackspeed = value
		"healthregen":
			healthregen = value
		"armor":
			armor = value
		"criticalhitchance":
			criticalhitchance = value
		"lifesteal":
			lifesteal = value
		"attackrange":
			attackrange = value
		_:
			push_error("Stat '%s' not found!" % stat)
			return
	emit_signal("stats_changed", stat, value)
