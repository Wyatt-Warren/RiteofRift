extends CharacterBody2D

@onready var shaker = get_node("Shaker")
@onready var shakeTimer = get_node("ShakeTimer")
@onready var arena = get_parent().get_parent().get_parent().get_parent()
@onready var boss = get_parent()
@onready var particles = get_node("CPUParticles2D")
@onready var sprite = get_node("Sprite2D")

@export var fragment: PackedScene

var enabled = false
var maxHealth = 300
var health = maxHealth

signal shattered

func _ready():
	randomize()

func _physics_process(delta):
	if !shakeTimer.is_stopped():
		shaker.speed_scale = shakeTimer.time_left / shakeTimer.wait_time
		if shaker.speed_scale > .9:
			health -= 1
			if health <= 0:
				shatter()
	
	if sprite.global_position.x > boss.player.global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
func shatter():
	for n in range(0,10):
		var newFrag = fragment.instantiate()
		
		newFrag.position.x = global_position.x + randi_range(-50, 50)
		newFrag.position.y = global_position.y + randi_range(-50, 50)
		newFrag.get_node("EnemySprite").flip_h = randi_range(0,1) == 0
		
		arena.get_node("World/Enemies").add_child(newFrag)
		
	shattered.emit()
	
	queue_free()
	
func shake():
	shakeTimer.start()
	shaker.play("ShakeBossPart")
	
func enable():
	enabled = true
	particles.amount = 3

func _on_shake_timer_timeout():
	shaker.stop()
	health = maxHealth
