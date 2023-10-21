extends RigidBody2D

var speed = 40
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 2
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var sprite = get_node("AnimatedSprite2D")
@onready var sprite2 = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")
@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false

func _ready():
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()

func move(target, toAway, lerpWeight):
	enemy_move_vec = enemy_move_vec.lerp((target.global_position - global_position).normalized() * toAway, lerpWeight)

func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if distance > 2000:
		queue_free()
		
	if !fleeing:
		move(player, 1, playerLerpWeight)
	else:
		move(player, -1, 2)
	
	apply_impulse(enemy_move_vec * speed * arena.speedMultiplier, Vector2())
	
	if linear_velocity.x < -25:
		sprite.flip_h = true
		sprite2.flip_h = true
	elif linear_velocity.x > 25:
		sprite.flip_h = false
		sprite2.flip_h = false
		
	if abs(linear_velocity.length()) < 25:
		animator.pause()
		sprite.pause()
	else:
		animator.play("Walking")
		sprite.play("default")

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		var new_bullet2 = bullet.instantiate()
		var new_bullet3 = bullet.instantiate()
		
		new_bullet.position.x = global_position.x
		new_bullet.position.y = global_position.y
		new_bullet.target = target_vec.rotated(deg_to_rad(15))
		
		new_bullet2.position.x = global_position.x
		new_bullet2.position.y = global_position.y
		new_bullet2.target = target_vec.rotated(deg_to_rad(-15))
		
		new_bullet3.position.x = global_position.x
		new_bullet3.position.y = global_position.y
		new_bullet3.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet2)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet3)
		arena.bullets += 3
