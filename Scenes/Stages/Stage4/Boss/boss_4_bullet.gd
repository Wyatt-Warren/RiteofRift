extends Area2D

const SPEED = 360
const damage = 2

@onready var deleteTimer = get_node("DeleteTimer")
@onready var particles = get_node("CPUParticles2D")
@onready var collision = get_node("CollisionShape2D")

var target = Vector2()

func _process(delta):
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta
	
func bullet_delete():
	collision.set_deferred("disabled", true)
	particles.emitting = false
	deleteTimer.start()

func _on_timer_timeout():
	bullet_delete()

func _on_delete_timer_timeout():
	queue_free()
