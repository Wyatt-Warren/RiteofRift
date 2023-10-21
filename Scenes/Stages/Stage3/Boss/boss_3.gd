extends StaticBody2D

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var shakeTimer = get_node("ShakeTimer")
@onready var shootTimer = get_node("ShootTimer")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var animator = get_node("AnimationPlayer")
@onready var shaker = get_node("Shaker")
@onready var particles = get_node("CPUParticles2D")
@onready var shatteredParticles = get_node("ShatteredParticles")
@onready var collision = get_node("CollisionShape2D")
@onready var sprite = get_node("BossSprite")

@export var fireBomb: PackedScene
@export var iceBomb: PackedScene
@export var fragment1: PackedScene
@export var fragment2: PackedScene
@export var fragment3: PackedScene

var maxHealth = 300
var health = maxHealth
var done = false
var alternateShot = false

func _physics_process(delta):
	if !shakeTimer.is_stopped() && !done:
		shaker.speed_scale = shakeTimer.time_left / shakeTimer.wait_time
		if shaker.speed_scale > .9:
			health -= 1
			if health <= 0:
				shatter()

func shatter():
	shatteredParticles.emitting = true
	var frags = [fragment1, fragment2, fragment3]
	
	for n in range(0, 15):
		var newPos = Vector2()
		
		while true:
			newPos.x = randi_range(-100, 100)
			newPos.y = randi_range(-100, 100)
			
			if newPos.length() <= 100:
				break
			
		var newFrag = frags[randi_range(0, 2)].instantiate()
		
		newFrag.position.x = newPos.x + global_position.x
		newFrag.position.y = newPos.y + global_position.y
		newFrag.get_node("AnimationPlayer").advance(animator.current_animation_position)
		newFrag.rotation = randf_range(0, 2 * PI)
		
		arena.get_node("World/Enemies").add_child(newFrag)
	
	arena.stopAttacks()
	safeDelete()
	
func shake():
	shakeTimer.start()
	shaker.play("ShakeBoss")

func _on_shake_timer_timeout():
	shaker.stop()
	health = maxHealth
	
func safeDelete():
	done = true
	shootTimer.stop()
	collision.disabled = true
	particles.emitting = false
	sprite.visible = false
	
	deleteTimer.start()

func _on_shoot_timer_timeout():
	var newBomb
	
	if alternateShot:
		newBomb = fireBomb.instantiate()
	else:
		newBomb = iceBomb.instantiate()
		
	newBomb.position = global_position
	newBomb.target = (player.global_position - global_position).normalized()
	
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBomb)
	
	alternateShot = !alternateShot

func _on_delete_timer_timeout():
	queue_free()
