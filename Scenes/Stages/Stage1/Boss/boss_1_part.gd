extends CharacterBody2D
  
@onready var shaker = get_node("Shaker")
@onready var shakeTimer = get_node("ShakeTimer")
@onready var arena = get_parent().get_parent().get_parent().get_parent()
@onready var boss = get_parent()
@onready var particles = get_node("CPUParticles2D")
@onready var sprites = [get_node("Enemy1/Enemy1"), get_node("Enemy2/Enemy2"), get_node("Leader1/Leader1"), get_node("Enemy3/Enemy3"), get_node("Enemy4/Enemy4")]

@export var fragment: PackedScene
@export var fragment1: PackedScene

var enabled = false
var maxHealth = 300
var health = maxHealth

signal shattered

func _physics_process(delta):
	if !shakeTimer.is_stopped():
		shaker.speed_scale = shakeTimer.time_left / shakeTimer.wait_time
		if shaker.speed_scale > .9:
			health -= 1
			if health <= 0:
				shatter()
				
	for sprite in sprites:
		if sprite.global_position.x > boss.player.global_position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

func _on_shake_timer_timeout():
	shaker.stop()
	health = maxHealth
	
func shatter():
	var newFrags = [fragment.instantiate(), fragment.instantiate(), fragment1.instantiate(), fragment.instantiate(), fragment.instantiate()]
	
	for n in range(0,5):
		var newFrag = newFrags[n]
		
		newFrag.position.x = sprites[n].global_position.x - newFrag.get_node("EnemySprite").position.x
		newFrag.position.y = sprites[n].global_position.y - newFrag.get_node("EnemySprite").position.y
		newFrag.get_node("EnemySprite").flip_h = sprites[n].flip_h
		
		arena.get_node("World/Enemies").add_child(newFrag)
	
	shattered.emit()
	
	queue_free()
	
func shake():
	shakeTimer.start()
	shaker.play("ShakeBossPart")
	
func enable():
	enabled = true
	particles.amount = 2
