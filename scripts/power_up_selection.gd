extends Control

var powerups = [
	{"icon": preload("res://assets/Icons/Attackspeed_icon.png"), "description": "Increase Attackspeed", "stat": "attackspeed", "value": -0.1},  # Reduce cooldown
	{"icon": preload("res://assets/Icons/Crit-Icon.png"),        "description": "Critical Strike Chance Increase", "stat": "criticalhitchance", "value": 10},
	{"icon": preload("res://assets/Icons/Damage-Icon.png"),       "description": "Percentage Increased Damage", "stat": "damage", "value": 5},
	{"icon": preload("res://assets/Icons/Health-Regen.png"),      "description": "Regen Health per Second", "stat": "healthregen", "value": 2},
	{"icon": preload("res://assets/Icons/lifesteal-icon.png"),    "description": "Chance of Lifesteal on Hit", "stat": "lifesteal", "value": 10},
	{"icon": preload("res://assets/Icons/Movespeed-icon.png"),    "description": "Increased Movespeed", "stat": "movespeed", "value": 15},
	{"icon": preload("res://assets/Icons/Shield-Icon.png"),       "description": "Reduce Damage From Hits", "stat": "armor", "value": 5},
	{"icon": preload("res://assets/Icons/Attack_Range.png"),       "description": "Increase Attack Range", "stat": "attackrange", "value": 20}
]

# UI components.
@onready var button1 = %TextureButton1
@onready var button2 = %TextureButton2
@onready var button3 = %TextureButton3
@onready var description1 = %Label1
@onready var description2 = %Label2
@onready var description3 = %Label3

func _ready():

	update_powerups()

	button1.connect("mouse_entered", Callable(self, "_on_button_hover").bind(button1))
	button2.connect("mouse_entered", Callable(self, "_on_button_hover").bind(button2))
	button3.connect("mouse_entered", Callable(self, "_on_button_hover").bind(button3))
	
	button1.connect("mouse_exited", Callable(self, "_on_button_leave").bind(button1))
	button2.connect("mouse_exited", Callable(self, "_on_button_leave").bind(button2))
	button3.connect("mouse_exited", Callable(self, "_on_button_leave").bind(button3))
	
	button1.connect("pressed", Callable(self, "_on_button_pressed").bind(button1))
	button2.connect("pressed", Callable(self, "_on_button_pressed").bind(button2))
	button3.connect("pressed", Callable(self, "_on_button_pressed").bind(button3))

# This method will run when the node's visibility changes.
func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		# Each time the UI becomes visible, update the power-ups.
		update_powerups()

func update_powerups() -> void:
	# Randomize new power-ups each time the UI is shown.
	var random_powerups = get_random_powerups()
	update_button(button1, description1, random_powerups[0]["icon"], random_powerups[0]["description"], random_powerups[0])
	update_button(button2, description2, random_powerups[1]["icon"], random_powerups[1]["description"], random_powerups[1])
	update_button(button3, description3, random_powerups[2]["icon"], random_powerups[2]["description"], random_powerups[2])
	

# Updates properties on the button without reconnecting signals.
func update_button(button: TextureButton, label: Label, icon, text, powerup_data) -> void:
	button.texture_normal = icon
	button.set_meta("powerup_data", powerup_data)
	label.text = text
	

func _on_button_hover(button: TextureButton):
	button.modulate = Color(1.5, 1.5, 1.5)

func _on_button_leave(button: TextureButton):
	button.modulate = Color(1.0, 1.0, 1.0)

func _on_button_pressed(button: TextureButton) -> void:
	button.scale = Vector2(0.9, 0.9)
	await get_tree().create_timer(0.1).timeout
	button.scale = Vector2(1.0, 1.0)
	
	var powerup = button.get_meta("powerup_data")
	var stat = powerup["stat"]
	var value = powerup["value"]

	var player_node = get_node("/root/Game/Player")
	if player_node:

		var player_stats_node = player_node.get_stats() if player_node.has_method("get_stats") else player_node.stats
		if player_stats_node:
			var current_stat_value = player_stats_node.get(stat)
			player_stats_node.set_stat(stat, current_stat_value + value)
			print("Power-up applied: %s increased by %s" % [stat, value])
		else:
			print("PlayerStats not found on the Player node!")
	else:
		print("Player node not found!")
	
	# Resume the game and hide the power-up UI.
	get_tree().paused = false
	visible = false

func get_random_powerups() -> Array:
	var selected_powerups = []
	var available_powerups = powerups.duplicate()  # Duplicate the list so the original isn't modified.
	while selected_powerups.size() < 3:
		var random_index = randi() % available_powerups.size()
		selected_powerups.append(available_powerups[random_index])
		available_powerups.remove_at(random_index)
	return selected_powerups
