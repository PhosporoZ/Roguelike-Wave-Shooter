extends Control

func _ready():

	$VBoxContainer/GraphicsQualityDropdown.selected = 1  # Default to "Medium".
	$VBoxContainer/HBoxContainer/SoundToggleButton.set_pressed(true)  # Default sound enabled.
	$VBoxContainer/GraphicsQualityDropdown.add_item("High")   # Adding dropdown options.
	$VBoxContainer/GraphicsQualityDropdown.add_item("Medium")
	$VBoxContainer/GraphicsQualityDropdown.add_item("Low")

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")  # Go back to Main Menu.

func _on_graphics_quality_selected(value: int):
	print("Graphics Quality set to:", value)  # Log the selected graphics quality.

func _on_sound_toggle_pressed():
	print("Sound Enabled:", $VBoxContainer/SoundToggleButton.pressed())  # Log sound toggle status.
