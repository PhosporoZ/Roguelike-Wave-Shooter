extends Area2D

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):

		var powerup_canvas = get_node("/root/Game/OverlayCanvasLayer/PowerUpSelection") 
		if powerup_canvas:
			powerup_canvas.visible = true
			get_tree().paused = true
		else:
			print("Powerup Canvas not found!")

		queue_free()
