extends Node2D

@export var wander_range = 32

@onready var start_position = global_position
@onready var target_position = global_position
@onready var timer = $Timer

func _ready(): 
	update_target_position()

func update_target_position():
	var r = wander_range
	var target_vector = Vector2(randi_range(-r, r), randi_range(-r, r))
	target_position = target_vector + start_position

func get_time_left():
	return timer.time_left

func start_wander_time(duration):
	timer.start(duration)

func _on_timer_timeout():
	update_target_position()
