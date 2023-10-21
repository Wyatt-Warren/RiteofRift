extends RigidBody2D

var speed = 50
const playerLerpWeight =  0.1
const xp = 12
var eggTime
const followDistance = 950

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var eggTimer = get_node("EggTimer")
@onready var sprite = get_node("AnimatedSprite2D")
@onready var sprite2 = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")
@export var egg: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var moveAngle = 90

# Called when the node enters the scene tree for the first time.
func _ready():
	eggTime = eggTimer.wait_time
	eggTimer.wait_time = randf_range(0, eggTime)
	eggTimer.start()
	if randi_range(0,1) == 0:
		moveAngle = -90

func move(target, toAway, lerpWeight):
	enemy_move_vec = enemy_move_vec.lerp((target.global_position - global_position).normalized() * toAway, lerpWeight)

func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if distance > 2000:
		queue_free()
		
	if !fleeing && distance > followDistance:
		move(player, 1, playerLerpWeight)
	elif !fleeing:
		enemy_move_vec = enemy_move_vec.lerp((player.global_position - global_position).normalized().rotated(deg_to_rad(moveAngle)), playerLerpWeight)
	else:
		move(player, -1, 2)
	
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

func _on_egg_timer_timeout():
	eggTimer.wait_time = eggTime
	eggTimer.start()
	
	if arena.enemyLessThanMax():
		var newEgg = egg.instantiate()
		
		newEgg.position = global_position
		
		arena.objectContainer.add_child(newEgg)
