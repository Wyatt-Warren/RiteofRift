extends RigidBody2D

var speed = 40
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

@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var colors = [[80, 140, 190], [190, 80, 140], [80, 150, 80]]

func _ready():
	randomize()
	var colorIndex = randi_range(0, 2)
	sprite.modulate.r8 = colors[colorIndex][0]
	sprite.modulate.g8 = colors[colorIndex][1]
	sprite.modulate.b8 = colors[colorIndex][2]
	
	rotation = randf_range(0, 2 * PI)
	
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
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position = global_position
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1
		
		shootTimer2.start()

func _on_shoot_timer_2_timeout():
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		var new_bullet2 = bullet.instantiate()
		
		new_bullet.position = global_position
		new_bullet.target = target_vec.rotated(deg_to_rad(30))
		
		new_bullet2.position = global_position
		new_bullet2.target = target_vec.rotated(deg_to_rad(-30))
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet2)
		arena.bullets += 2
