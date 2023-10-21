extends StaticBody2D

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World/Player")
@onready var shakeTimer = get_node("ShakeTimer")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var shaker = get_node("Shaker")
@onready var shatteredParticles = get_node("ShatteredParticles")
@onready var shatteredParticles2 = get_node("ShatteredParticles2")
@onready var collision = get_node("CollisionShape2D")
@onready var sprites = get_node("Sprites")

@export var fragment1: PackedScene
@export var fragment2: PackedScene
@export var bullet: PackedScene

var maxHealth = 300
var health = maxHealth
var done = false

func _ready():
	randomize()

func _physics_process(delta):
	if !shakeTimer.is_stopped() && !done:
		shaker.speed_scale = shakeTimer.time_left / shakeTimer.wait_time
		if shaker.speed_scale > .9:
			health -= 1
			if health <= 0:
				shatter()
				
func shatter():
	shatteredParticles.emitting = true
	shatteredParticles2.emitting = true
	var frags = [fragment1, fragment2]
	
	for n in range(0, 25):
		var newPos = Vector2()
		
		while true:
			newPos.x = randi_range(-125, 125)
			newPos.y = randi_range(-125, 125)
			
			if newPos.length() <= 125:
				break
			
		var newFrag = frags[randi_range(0, 1)].instantiate()
		
		newFrag.position.x = newPos.x + global_position.x
		newFrag.position.y = newPos.y + global_position.y
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
	collision.disabled = true
	sprites.visible = false
	
	deleteTimer.start()
	
func _on_delete_timer_timeout():
	queue_free()

func _on_shoot_timer_timeout():
	var distance = player.global_position.distance_to(global_position)
	
	if distance < 1000:
		var bulletCount = 10
		var target_vec = (player.global_position - global_position).normalized()
		
		for n in range(0, bulletCount):
			var new_bullet = bullet.instantiate()
			
			new_bullet.position.x = global_position.x
			new_bullet.position.y = global_position.y
			new_bullet.target = target_vec.rotated(((2*PI)/bulletCount)*n)
			new_bullet.get_node("Timer").wait_time = 10
		
			arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
			arena.bullets += 1
