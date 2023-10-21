extends RigidBody2D

var speed = 50
const targetLerpWeight =  0.7
const xp = 1

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var sprite = get_node("EnemySprite")
@onready var animator = get_node("AnimationPlayer")

var leader
var enemy_move_vec = Vector2()
var distance
var fleeing = false

func move(target, toAway, lerpWeight):
	enemy_move_vec = enemy_move_vec.lerp((target.global_position - global_position).normalized() * toAway, lerpWeight)

func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if distance > 2000:
		queue_free()
	
	var toAway = 1
	var target = leader
	
	if !fleeing:
		if leader == null:
			var leaders = []
			for enemy in arena.get_node("World").get_node("Enemies").get_children():
				if enemy.is_in_group("Leader"):
					leaders.append(enemy)
			
			if leaders.size() != 0:
				target = leaders[0]
				
				for n in leaders:
					if n.global_position.distance_to(global_position) < target.global_position.distance_to(global_position):
						target = n
					
				leader = target
			else:
				target = player
				toAway = -1
		
		move(target, toAway, targetLerpWeight)
	else:
		move(player, -1, 2)
		
	apply_impulse(enemy_move_vec * speed * arena.speedMultiplier, Vector2())
	
	if linear_velocity.x < -25:
		sprite.flip_h = true
	elif linear_velocity.x > 25:
		sprite.flip_h = false
		
	if abs(linear_velocity.length()) < 25:
		animator.pause()
	else:
		animator.play("Walking")
