extends "res://Scenes/Player/GrenadeHole.gd"

var speed = 360
var target = Vector2()

func _process(delta):
	suckers.rotation_degrees += rotationSpeed * delta
	position.x += target.x * speed * delta
	position.y += target.y * speed * delta
