extends Area2D

const SPEED = 150

@onready var particles = get_node("CPUParticles2D")
@onready var particles2 = get_node("CPUParticles2D2")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var collision = get_node("CollisionShape2D")

var target = Vector2()

func _process(delta):
	for n in get_overlapping_areas():
		if n.is_in_group("PlayerHitbox"):
			n.get_parent().get_parent().slowTimer.start()
			
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta

func _on_timer_timeout():
	collision.set_deferred("disabled", true)
	particles.emitting = false
	particles2.emitting = false
	
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
