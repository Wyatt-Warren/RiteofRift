extends RigidBody2D

const playerLerpWeight =  0.1
const xp = 20

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var sprite = get_node("AnimatedSprite2D")
@onready var sprite2 = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")
@onready var particles = get_node("BoosterParticles")
@onready var collision = get_node("CollisionShape2D")
@onready var deleteTimer = get_node("DeleteTimer")

var speed = 60
var enemy_move_vec = Vector2()
var distance
var fleeing = false
var turnAngle = 0

func _ready():
	turnAngle = randi_range(-1, 1) * 60

func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	if distance < 300:
		turnAngle = 0
	
	if distance > 2000:
		queue_free()
		
	if fleeing:
		move(player, -1, 2)
	else:
		move(player, 1, playerLerpWeight)
		
	
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


func move(target, toAway, lerpWeight):
	var targetVec = (target.global_position - global_position).normalized().rotated(deg_to_rad(turnAngle))
	
	enemy_move_vec = enemy_move_vec.lerp(targetVec * toAway, lerpWeight)

func _on_flee_timer_timeout():
	fleeing = true
	speed *= 1.2

func _on_turn_timer_timeout():
	turnAngle = randi_range(-1, 1) * 60
	
func safeDelete():
	particles.emitting = false
	sprite.visible = false
	collision.set_deferred("disabled",  true)
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
