extends RigidBody2D

var speed = 45
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 16
var shootTime
var phaseTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var runAwayArea = get_node("RunAwayArea")
@onready var moveTimer = get_node("MoveTimer")
@onready var shootTimer = get_node("ShootTimer")
@onready var shootTimer2 = get_node("ShootTimer2")
@onready var phaseTimer = get_node("PhaseTimer")
@onready var phaseTimer2 = get_node("PhaseTimer2")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var sprites = get_node("Sprites")
@onready var shadow = get_node("Shadow")
@onready var collision = get_node("CollisionShape2D")
@onready var particles = get_node("CPUParticles2D")
@onready var particles2 = get_node("CPUParticles2D2")
@onready var hitbox = get_node("Hitbox")
@export var bullet: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var remainingBullets = 0
var targetPosition = Vector2()

func _ready():
	randomize()
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()
	
	phaseTime = phaseTimer.wait_time
	phaseTimer.wait_time = randf_range(0.1, phaseTime)
	phaseTimer.start()
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
	
	if linear_velocity.x < -25:
		sprites.scale.x = -1
	elif linear_velocity.x > 25:
		sprites.scale.x = 1

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var secondaryBullets = 3
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

func _on_phase_timer_timeout():
	phaseTimer.wait_time = phaseTime
	phaseTimer.start()
	
	sprites.visible = false
	shadow.visible = false
	collision.set_deferred("disabled",  true)
	hitbox.set_deferred("monitorable", false)
	shootTimer.paused = true
	shootTimer2.paused = true
	moveTimer.paused = true
	particles.emitting = true
	particles2.emitting = true
	
	targetPosition = ((global_position - player.global_position) * -1)
	
	phaseTimer2.start()

func _on_phase_timer_2_timeout():
	sprites.visible = true
	shadow.visible = true
	collision.set_deferred("disabled",  false)
	hitbox.set_deferred("monitorable", true)
	shootTimer.paused = false
	shootTimer2.paused = false
	moveTimer.paused = false
	particles.emitting = true
	particles2.emitting = true
	
	if targetPosition.length() < 600:
		targetPosition = targetPosition.normalized() * 600
	
	position = targetPosition + player.global_position

func safeDelete():
	sprites.visible = false
	shadow.visible = false
	collision.set_deferred("disabled",  true)
	hitbox.set_deferred("monitorable", false)
	
	shootTimer.stop()
	shootTimer2.stop()
	phaseTimer.stop()
	phaseTimer2.stop()
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
