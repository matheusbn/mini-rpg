extends Node2D

const GrassEffect = preload("res://Effects/grass_effect.tscn")

func _on_hurtbox_area_entered(_area):
	var grassEffect = GrassEffect.instantiate()
	grassEffect.global_position = global_position
	get_parent().add_child(grassEffect)
	
	queue_free()
