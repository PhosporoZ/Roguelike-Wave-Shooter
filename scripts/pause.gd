extends Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.echo:
		var new_state = not get_tree().paused
		get_tree().paused = new_state
		visible = new_state
