extends CharacterBody2D

const DeathEffect = preload("res://Effects/enemy_death_effect.tscn")

@export var ACCELERATION = 300
@export var FRICTION = 200
@export var MAX_SPEED = 50

@onready var sprite = $AnimatedSprite2D
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var blinkAnimationPlayer = $BlinkAnimationPlayer

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE 

var timer = 1.0
var dmg_interval = 1.0
var dmg = 1
var enemy_hurtbox = null

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	match(state):
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			chase_player()		
			if wanderController.get_time_left() == 0:
				update_wander()
			
		WANDER:
			chase_player()			
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)			
			if global_position.distance_to(wanderController.target_position) <= 4:
				update_wander()
			
		CHASE:
			var player = playerDetectionZone.player
			if player:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	move_and_slide()
	
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
	
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_time(randi_range(1, 3))
			
func chase_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(states):
	states.shuffle()
	return states.pop_front()
	
func _on_hurtbox_area_entered(area):
	stats.health -= area.damage
	velocity = area.knockback_vector * 140
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_stats_no_health():
	var deathEffect = DeathEffect.instantiate()
	deathEffect.global_position = global_position
	get_parent().add_child(deathEffect)
	
	queue_free()

#func dot(delta):
#	timer -= delta
#
#	if timer <= 0 and enemy_hurtbox:
#		print('hit')
#		enemy_hurtbox.take_damage(dmg)
#		timer = dmg_interval
#
#func _on_hitbox_area_entered(area):
#	enemy_hurtbox = area
#
#func _on_hitbox_area_exited(area):
#	enemy_hurtbox = null


func _on_hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")


func _on_hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
