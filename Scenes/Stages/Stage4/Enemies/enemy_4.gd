extends RigidBody2D

var speed = 45
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 2
const bulletSpread = 25
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var shootTimer2 = get_node("ShootTimer2")
@onready var sprite = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")
@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var remainingBullets = 0
var secondaryBulletAngle = 0
var bulletStartPos = Vector2()
var target_vec = Vector2()

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
	elif linear_velocity.x > 25:
		sprite.flip_h = false
		
	if abs(linear_velocity.length()) < 25:
		animator.pause()
	else:
		animator.play("Walking")

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var secondaryBullets = 2
		target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		bulletStartPos = global_position
		
		new_bullet.position.x = bulletStartPos.x
		new_bullet.position.y = bulletStartPos.y
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1
		
		shootSecondaryBullets(secondaryBullets)

func shootSecondaryBullets(count):
	secondaryBulletAngle = bulletSpread
	remainingBullets = count
	shootTimer2.start()

func _on_shoot_timer_2_timeout():
	if remainingBullets > 0:
		
		var new_bullet = bullet.instantiate()
		var new_bullet2 = bullet.instantiate()
		
		new_bullet.position.x = bulletStartPos.x
		new_bullet.position.y = bulletStartPos.y
		new_bullet.target = target_vec.rotated(deg_to_rad(secondaryBulletAngle))
		
		new_bullet2.position.x = bulletStartPos.x
		new_bullet2.position.y = bulletStartPos.y
		new_bullet2.target = target_vec.rotated(deg_to_rad(secondaryBulletAngle * -1))
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet2)
		
		arena.bullets += 2
		
		secondaryBulletAngle += bulletSpread
		remainingBullets -= 1
		shootTimer2.start()
