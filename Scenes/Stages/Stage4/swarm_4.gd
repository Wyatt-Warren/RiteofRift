extends Area2D

const speed = 60
const damage = 1

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World/Player")
@onready var collision = get_node("CollisionShape2D")
@onready var particles = get_node("CPUParticles2D")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var damageTimer = get_node("DamageTimer")
@onready var shootTimer = get_node("ShootTimer")
@onready var lifeTimer = get_node("LifeTimer")

@export var bullet: PackedScene

func _process(delta):
	var playerVector = (player.global_position - global_position).normalized()
	
	position.x += playerVector.x * speed * delta * arena.swarmSpeedMultiplier
	position.y += playerVector.y * speed * delta * arena.swarmSpeedMultiplier
	
	if damageTimer.is_stopped():
		for area in get_overlapping_areas():
			if area.is_in_group("PlayerHitbox") && !player.boosted:
				player.damage_player(damage)
				damageTimer.start()

func deleteSwarm():
	particles.emitting = false
	
	collision.set_deferred("disabled",  true)
	shootTimer.stop()
	lifeTimer.stop()
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()

func _on_shoot_timer_timeout():
	for n in range(0, 6):
		var newPos = Vector2()
		
		while true:
			newPos.x = randi_range(-125, 125)
			newPos.y = randi_range(-125, 125)
			
			if newPos.length() <= 125:
				break
				
		var target_vec = (player.global_position - (global_position + newPos)).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position = global_position + newPos
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1

func _on_life_timer_timeout():
	deleteSwarm()
