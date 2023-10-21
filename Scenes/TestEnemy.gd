extends RigidBody2D

const speed = 48
const followDistance = 500
const shootDistance = 250
const playerLerpWeight =  0.1
const xp = 1

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@export var bullet: PackedScene

var enemy_move_vec = Vector2()

func _physics_process(delta):
	pass

func move(target, toAway, lerpWeight):
	enemy_move_vec = enemy_move_vec.lerp((target.global_position - global_position).normalized() * speed * toAway, lerpWeight)

func _on_shoot_timer_timeout():
	var distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		new_bullet.position = global_position
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1


func _on_move_timer_timeout():
	var distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	move(player, 1, playerLerpWeight)
	apply_impulse(enemy_move_vec, Vector2())
