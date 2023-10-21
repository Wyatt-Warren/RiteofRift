extends StaticBody2D

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var shakeTimer = get_node("ShakeTimer")
@onready var shootTimer = get_node("ShootTimer")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var shaker = get_node("Shaker")
@onready var particles = get_node("CPUParticles2D")
@onready var shatteredParticles = get_node("ShatteredParticles")
@onready var bouncer = get_node("Bouncer")
@onready var collision = get_node("CollisionShape2D")
@onready var mushroom1 = get_node("Mushroom1Holder/Mushroom1")
@onready var mushroom2 = get_node("Mushroom2Holder/Mushroom2")
@onready var mushroom3 = get_node("Mushroom3Holder/Mushroom3")
@onready var mushroom4 = get_node("Mushroom4Holder/Mushroom4")
@onready var mushroom5 = get_node("Mushroom5Holder/Mushroom5")
@onready var mushroom6 = get_node("Mushroom6Holder/Mushroom6")

@export var bullet: PackedScene
@export var fragment1: PackedScene
@export var fragment2: PackedScene
@export var fragment3: PackedScene

var maxHealth = 300
var health = maxHealth
var done = false

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
	
	for n in range(0, 50):
		var newPos = Vector2()
		
		while true:
			newPos.x = randi_range(-125, 125)
			newPos.y = randi_range(-125, 125)
			
			if newPos.length() <= 125:
				break
			
		var newFrag = frags[randi_range(0, 2)].instantiate()
		
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
	shootTimer.stop()
	collision.disabled = true
	particles.emitting = false
	mushroom1.visible = false
	mushroom2.visible = false
	mushroom3.visible = false
	mushroom4.visible = false
	mushroom5.visible = false
	mushroom6.visible = false
	
	deleteTimer.start()

func _on_shoot_timer_timeout():
	var distance = player.global_position.distance_to(global_position)
	
	if distance < 1000:
		var newBullet = bullet.instantiate()
		
		newBullet.position = global_position
		newBullet.target = (player.global_position - global_position).normalized()
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(newBullet)

func _on_delete_timer_timeout():
	queue_free()
