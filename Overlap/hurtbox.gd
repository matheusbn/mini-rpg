extends Area2D

const HitEffect = preload("res://Effects/hit_effect.tscn")

var invincible = false : set = set_invincible

@onready var timer = $Timer
@onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	emit_signal("invincibility_started" if invincible else "invincibility_ended")
	
func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var hitEffect = HitEffect.instantiate()
	hitEffect.global_position = global_position
	var world = get_tree().current_scene
	world.add_child(hitEffect)

func take_damage(damage):
	create_hit_effect()
	owner.stats.health -= damage


func _on_timer_timeout():
	self.invincible = false


func _on_invincibility_started():
	collisionShape.set_deferred("disabled", true)


func _on_invincibility_ended():
	collisionShape.set_deferred("disabled", false)
