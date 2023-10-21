extends Area2D

const speed = 180
const damage = 1

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World/Player")
@onready var collision = get_node("CollisionShape2D")
@onready var particles = get_node("CPUParticles2D")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var damageTimer = get_node("DamageTimer")

func _process(delta):
	var playerVector = (player.global_position - global_position).normalized()
	
	position.x += playerVector.x * speed * delta * arena.cloudSpeedMultiplier
	position.y += playerVector.y * speed * delta * arena.cloudSpeedMultiplier
	
	if damageTimer.is_stopped():
		for area in get_overlapping_areas():
			if area.is_in_group("PlayerHitbox") && !player.boosted:
				player.damage_player(damage)
				damageTimer.start()

func deleteCloud():
	particles.emitting = false
	
	collision.set_deferred("disabled",  true)
	deleteTimer.start()

func _on_disappear_timer_timeout():
	queue_free()
