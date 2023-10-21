extends Area2D

const damage = 1

@onready var arena =  get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var particles = get_node("CPUParticles2D")
@onready var collision = get_node("CollisionShape2D")
@onready var animator = get_node("AnimationPlayer")
@onready var deleteTimer = get_node("DeleteTimer")

func _physics_process(delta):
	for area in get_overlapping_areas():
			if area.is_in_group("PlayerHitbox") && !player.boosted:
				player.damage_player(damage)

func _on_animation_player_animation_finished(anim_name):
	queue_free()

func deleteZone():
	particles.emitting = false
	animator.pause()
	collision.set_deferred("disabled", true)
	
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
