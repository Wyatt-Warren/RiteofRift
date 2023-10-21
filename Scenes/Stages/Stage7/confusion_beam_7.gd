extends Area2D

const SPEED = 150

@onready var collision = get_node("CollisionShape2D")
@onready var particles = get_node("CPUParticles2D")
@onready var particles2 = get_node("CPUParticles2D2")
@onready var particles3 = get_node("CPUParticles2D3")

var target = Vector2()

func _process(delta):
	
	#TODO, CONFUSE PLAYER
	
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta

func bullet_delete():
	collision.set_deferred("disabled", true)
	particles.emitting = false
	particles2.emitting = false
	particles3.emitting = false

func _on_timer_timeout():
	bullet_delete()

func _on_delete_timer_timeout():
	queue_free()
