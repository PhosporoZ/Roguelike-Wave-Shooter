extends Area2D

var damage: int = 0
var travelled_distance: float = 0
var hit: bool = false  # Flag to ensure only one collision is processed

func _physics_process(delta):
	const SPEED = 800
	const RANGE = 100

	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta

	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if hit:
		return
	hit = true

	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
