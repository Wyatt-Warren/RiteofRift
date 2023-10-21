extends RigidBody2D

var speed = 40
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 2
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var shootTimer2 = get_node("ShootTimer2")
@onready var sprite = get_node("AnimatedSprite2D")
@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var remainingBullets = 0

func _ready():
	randomize()
	
	if randi_range(0, 1) == 0:
		sprite.play_backwards("default")
		
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

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var secondaryBullets = 2
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position.x = global_position.x
		new_bullet.position.y = global_position.y
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		
		arena.bullets += 1
		
		shootSecondaryBullets(secondaryBullets)
		
	
func shootSecondaryBullets(count):
	remainingBullets = count
	shootTimer2.start()

func _on_shoot_timer_2_timeout():
	if remainingBullets > 0:
		
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position.x = global_position.x
		new_bullet.position.y = global_position.y
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		
		arena.bullets += 1
		
		remainingBullets -= 1
		shootTimer2.start()
