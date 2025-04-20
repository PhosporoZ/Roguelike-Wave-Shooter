extends Control

@export var duration: float = 60.0
var time_left: float

signal timer_finished

@onready var timer_label: Label = $TimerLabel

func _ready():
	time_left = duration
	set_process(true)
	
func _process(delta: float) -> void:
	if time_left > 0:
		time_left -= delta
		timer_label.text = str(int(time_left))
	else:
		time_left = 0
		set_process(false)
		emit_signal("timer_finished")
