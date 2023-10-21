extends RigidBody2D

var speed = 45
const shootDistance = 300
const playerLerpWeight =  0.1
const xp = 5
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var runAwayArea = get_node("RunAwayArea")
@onready var shootTimer = get_node("ShootTimer")
@onready var sprite = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")

@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()
	runAwayArea.lerpWeight = 0.1

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
	runAwayArea.scale.x = arena.speedMultiplier * 0.3
	runAwayArea.scale.y = arena.speedMultiplier * 0.3
	
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
		var target = lerp(player.global_position, global_position, 0.5)
		
		var spawnLine = (target - global_position).normalized().rotated(PI/2)
		
		var new_bullet = bullet.instantiate()
		var new_bullet1 = bullet.instantiate()
		var new_bullet2 = bullet.instantiate()
		var new_bullet3 = bullet.instantiate()
		new_bullet.position.x = global_position.x + (spawnLine.x * 20)
		new_bullet.position.y = global_position.y + (spawnLine.y * 20)
		new_bullet.target = (target - new_bullet.position).normalized()
		
		new_bullet1.position.x = global_position.x + (spawnLine.x * 60)
		new_bullet1.position.y = global_position.y + (spawnLine.y * 60)
		new_bullet1.target = (target - new_bullet1.position).normalized()
		
		new_bullet2.position.x = global_position.x + (spawnLine.x * -20)
		new_bullet2.position.y = global_position.y + (spawnLine.y * -20)
		new_bullet2.target = (target - new_bullet2.position).normalized()
		
		new_bullet3.position.x = global_position.x + (spawnLine.x * -60)
		new_bullet3.position.y = global_position.y + (spawnLine.y * -60)
		new_bullet3.target = (target - new_bullet3.position).normalized()
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet1)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet2)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet3)
		arena.bullets += 4
