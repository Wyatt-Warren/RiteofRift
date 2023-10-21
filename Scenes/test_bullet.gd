extends Area2D

const SPEED = 2.5
const damage = 1

@onready var arena = get_parent().get_parent().get_parent()

var target = Vector2()

func _physics_process(delta):
	position.x += target.x * SPEED
	position.y += target.y * SPEED

func _on_timer_timeout():
	queue_free()
	arena.bullets -= 1
