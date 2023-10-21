extends RigidBody2D

var speed = 50
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 12
var shootTime
var shootTime2

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var shootTimer2 = get_node("ShootTimer")
@onready var sprite = get_node("AnimatedSprite2D")
@onready var sprite2 = get_node("EnemySprite")
@export var bullet: PackedScene
@export var beam: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false

func _ready():
	randomize()
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()
	
	shootTime2 = shootTimer2.wait_time
	shootTimer2.wait_time = randf_range(0.1, shootTime2)
	shootTimer2.start()

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

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var target_vec = (player.global_position - global_position).normalized()
		var bulletCount = randi_range(5, 7)
		
		for n in range(0, bulletCount):
			var newBullet = bullet.instantiate()
			
			newBullet.position = global_position
			newBullet.target = target_vec.rotated(((2*PI)/bulletCount)*n)
			
			arena.enemyBulletContainer.add_child(newBullet)
			arena.bullets += 1

func _on_shoot_timer_2_timeout():
	shootTimer2.wait_time = shootTime2
	shootTimer2.start()
	
	var target_vec = (player.global_position - global_position).normalized()
	var newBeam = beam.instantiate()
	
	newBeam.position = global_position
	newBeam.target = target_vec
	
	arena.beamContainer.add_child(newBeam)
