extends RigidBody2D

var speed = 45
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 10
var shootTime
var shootTime2

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var shootTimer2 = get_node("ShootTimer2")
@onready var runAwayArea = get_node("RunAwayArea")
@onready var sprite = get_node("AnimatedSprite2D")
@onready var shadow = get_node("Shadow")
@onready var particles = get_node("CPUParticles2D")
@onready var collision = get_node("CollisionShape2D")
@onready var deleteTimer = get_node("DeleteTimer")

@export var bullet: PackedScene
@export var fireBomb: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false

func _ready():
	randomize()
	
	if randi_range(0, 1) == 0:
		sprite.play_backwards("default")
		
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()
	
	shootTime2 = shootTimer2.wait_time
	shootTimer2.wait_time = randf_range(0.1, shootTime2)
	shootTimer2.start()
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
		
	runAwayArea.scale.x = arena.speedMultiplier * 0.3
	runAwayArea.scale.y = arena.speedMultiplier * 0.3
	
	apply_impulse(enemy_move_vec * speed * arena.speedMultiplier, Vector2())

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var bulletCount = 5
		var target_vec = (player.global_position - global_position).normalized()
		
		for n in range(0, bulletCount):
			var new_bullet = bullet.instantiate()
			
			new_bullet.position.x = global_position.x
			new_bullet.position.y = global_position.y
			new_bullet.target = target_vec.rotated(((2*PI)/bulletCount)*n)
		
			arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
			arena.bullets += 1

func _on_shoot_timer_2_timeout():
	shootTimer2.wait_time = shootTime2
	shootTimer2.start()
	
	var target_vec = (player.global_position - global_position).normalized()
	var new_bullet = fireBomb.instantiate()
		
	new_bullet.position.x = global_position.x
	new_bullet.position.y = global_position.y
	new_bullet.target = target_vec
	
	arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
	arena.bullets += 1
	
func safeDelete():
	particles.emitting = false
	sprite.visible = false
	shadow.visible = false
	
	collision.set_deferred("disabled",  true)
	shootTimer.stop()
	shootTimer2.stop()
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
