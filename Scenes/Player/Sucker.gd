extends Area2D

const suckForce = 350

@onready var particles = get_node("CPUParticles2D")
@onready var collision = get_node("CollisionPolygon2D")
@onready var timer = get_node("Timer")

func _on_timer_timeout():
	for area in get_overlapping_areas():
		if area.monitorable:
			if area.is_in_group("EnemyHitbox"):
				var enemy_move_vec = (global_position - area.get_parent().global_position).normalized()
				area.get_parent().apply_impulse(enemy_move_vec * suckForce, Vector2())
			elif area.is_in_group("BossHitbox"):
				if area.get_parent().has_method("shake"):
					area.get_parent().shake()
