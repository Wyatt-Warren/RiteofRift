extends RigidBody2D

var speed = 50
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 9
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shadow = get_node("Shadow")
@onready var sprite = get_node("AnimatedSprite2D")
@onready var collision = get_node("CollisionShape2D")
@onready var particles = get_node("CPUParticles2D")
@onready var particles2 = get_node("CPUParticles2D2")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var shootTimer = get_node("ShootTimer")
@onready var accelerator = get_node("Accelerator")

@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false

func _ready():
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()
	
	randomize()
	
	if randi_range(0, 1) == 0:
		sprite.play_backwards("default")

func move(target, toAway, lerpWeight):
	enemy_move_vec = enemy_move_vec.lerp((target.global_position - global_position).normalized() * toAway, lerpWeight)
	
func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if distance < 200:
		accelerator.pause()
	elif distance > 2000:
		queue_free()
	else:
		accelerator.play("AccelerateBombSpeed")
		
	if !fleeing:
		move(player, 1, playerLerpWeight)
	else:
		move(player, -1, 2)
	
	apply_impulse(enemy_move_vec * speed * arena.speedMultiplier, Vector2())

func _on_accelerator_animation_finished(anim_name):
	var bulletCount = 6
	var target_vec = (player.global_position - global_position).normalized()
	
	for n in range(0, bulletCount):
		var new_bullet = bullet.instantiate()
		
		new_bullet.position.x = global_position.x
		new_bullet.position.y = global_position.y
		new_bullet.target = target_vec.rotated(((2*PI)/bulletCount)*n)
	
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1
	
	explode()

func explode():
	sprite.visible = false
	shadow.visible = false
	collision.set_deferred("disabled", true)
	
	particles2.emitting = true
	particles.emitting = true
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position.x = global_position.x
		new_bullet.position.y = global_position.y
		new_bullet.target = target_vec.rotated(deg_to_rad(15))
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1
