extends StaticBody2D

@onready var arena = get_parent().get_parent().get_parent().get_parent()
@onready var shakeTimer = get_node("ShakeTimer")
@onready var shaker = get_node("Shaker")
@onready var particles = get_node("CPUParticles2D")
@onready var bouncer = get_node("Bouncer")

@export var fragment1: PackedScene
@export var fragment2: PackedScene
@export var fragment3: PackedScene

var enabled = false
var maxHealth = 300
var health = maxHealth

signal shattered

func _ready():
	bouncer.advance(randf_range(0,  bouncer.current_animation_length))

func _physics_process(delta):
	if !shakeTimer.is_stopped():
		shaker.speed_scale = shakeTimer.time_left / shakeTimer.wait_time
		if shaker.speed_scale > .9:
			health -= 1
			if health <= 0:
				shatter()

func shatter():
	var frags = [fragment1, fragment2, fragment3]
	
	for x in range(-30, 50, 20):
		for y in range(-70, 90, 20):
			var newFrag = frags[randi_range(0, 2)].instantiate()
			
			newFrag.position.x = x + global_position.x
			newFrag.position.y = y + global_position.y
			newFrag.rotation = randf_range(0, 2 * PI)
			
			arena.get_node("World/Enemies").add_child(newFrag)
	
	shattered.emit()
	
	queue_free()
	
func shake():
	shakeTimer.start()
	shaker.play("ShakeBossPart")

func _on_shake_timer_timeout():
	shaker.stop()
	health = maxHealth
	
func enable():
	enabled = true
	particles.emitting = false
