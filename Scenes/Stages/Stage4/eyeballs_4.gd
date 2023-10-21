extends Node2D

@onready var lady = get_parent()
@onready var arena = get_parent().get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var eyeball1 = get_node("EyeballHolder1/Eyeball1")
@onready var eyeball2 = get_node("EyeballHolder2/Eyeball2")
@onready var eyeball3 = get_node("EyeballHolder3/Eyeball3")
@onready var eyeball4 = get_node("EyeballHolder4/Eyeball4")
@onready var eyeball5 = get_node("EyeballHolder5/Eyeball5")
@onready var shrinker = get_node("Shrinker")
@onready var shootTimer = get_node("ShootTimer")

@onready var eyeArray = [eyeball1, eyeball2, eyeball3, eyeball4, eyeball5]
@onready var enabledEyes = [true, false, false, false, false]

@export var bullet: PackedScene

var shootingEye = 0

func _on_shoot_timer_timeout():
	if arena.bullets < arena.bulletMax && lady.distance > lady.shootDistance && enabledEyes[shootingEye]:
		var target_vec = (player.global_position - eyeArray[shootingEye].global_position).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position = eyeArray[shootingEye].global_position
		new_bullet.target = target_vec
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1
	
	
	if shootingEye == 4:
		shootingEye = 0
	else:
		shootingEye += 1

func addEyeball(index):
	enabledEyes[index] = true
	eyeArray[index].get_parent().get_node("Grower").play("GrowEyeball")
	
func shrink():
	shrinker.play("Shrink")
	shootTimer.stop()
	enabledEyes = [false, false, false, false, false]
