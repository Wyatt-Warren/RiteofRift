extends Area2D

const SPEED = 360
const damage = 2

@onready var timer2 = get_node("Timer2")
@onready var particles = get_node("CPUParticles2D")
@onready var collision = get_node("CollisionShape2D")

var target = Vector2()

func _process(delta):
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta
	
func bullet_delete():
	collision.set_deferred("disabled", true)
	particles.emitting = false
	timer2.start()

func _on_timer_timeout():
	bullet_delete()

func _on_timer_2_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("BossWalls"):
		bullet_delete()
