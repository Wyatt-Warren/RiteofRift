extends RigidBody2D

var speed = 50
const shootDistance = 250
const playerLerpWeight =  0.1
var xp = 10

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var runAwayArea = get_node("RunAwayArea")
@onready var sprite = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")
@onready var moveTimer = get_node("MoveTimer")
@onready var eyeballs = get_node("Eyeballs4")
@onready var eyeballTimer = get_node("EyeballTimer")
@onready var collision = get_node("CollisionShape2D")
@onready var deleteTimer = get_node("DeleteTimer")

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var nextEye = 1

func _ready():
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
		
	if linear_velocity.x < -25:
		sprite.flip_h = true
	elif linear_velocity.x > 25:
		sprite.flip_h = false
		
	if abs(linear_velocity.length()) < 25:
		animator.pause()
	else:
		animator.play("Walking")

func _on_eyeball_timer_timeout():
	xp += 1
	eyeballs.addEyeball(nextEye)
	
	if nextEye >= 4:
		eyeballTimer.stop()
	else:
		nextEye += 1

func safeDelete():
	sprite.visible = false
	eyeballs.shrink()
	linear_velocity = Vector2(0, 0)
	
	collision.set_deferred("disabled",  true)
	moveTimer.stop()
	eyeballTimer.stop()
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
