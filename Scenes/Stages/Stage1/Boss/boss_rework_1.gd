extends StaticBody2D

@onready var shaker = get_node("Shaker")
@onready var shakeTimer = get_node("ShakeTimer")
@onready var shootTimer = get_node("ShootTimer")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World/Player")
@onready var sprite = get_node("SpriteHolder/BossSprite")
@onready var collision = get_node("CollisionShape2D")
@onready var shatterParticles = get_node("ShatterParticles")

@export var bullet: PackedScene
@export var fragment: PackedScene

var done = false
var maxHealth = 300
var health = maxHealth

func _ready():
	randomize()

func _physics_process(delta):
	
	if !shakeTimer.is_stopped() && !done:
		shaker.speed_scale = shakeTimer.time_left / shakeTimer.wait_time
		if shaker.speed_scale > .9:
			health -= 1
			if health <= 0:
				shatter()
	
	if sprite.global_position.x > player.global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
func shatter():
	shatterParticles.emitting = true
	
	for n in range(0,10):
		var newFrag = fragment.instantiate()
		
		newFrag.position.x = global_position.x + randi_range(-50, 50)
		newFrag.position.y = global_position.y + randi_range(-50, 50)
		newFrag.get_node("EnemySprite").flip_h = randi_range(0,1) == 0
		
		arena.get_node("World/Enemies").add_child(newFrag)
	
	arena.stopAttacks()
	safeDelete()
	
func shake():
	shakeTimer.start()
	shaker.play("ShakeBoss")

func _on_shake_timer_timeout():
	shaker.stop()
	health = maxHealth

func _on_shoot_timer_timeout():
	var distance = player.global_position.distance_to(global_position)
	
	if distance < 1000:
		var bulletCount = 8
		var target_vec = (player.global_position - global_position).normalized()
		
		for n in range(0, bulletCount):
			var new_bullet = bullet.instantiate()
			
			new_bullet.position.x = global_position.x
			new_bullet.position.y = global_position.y
			new_bullet.target = target_vec.rotated(((2*PI)/bulletCount)*n)
			new_bullet.get_node("Timer").wait_time = 10
		
			arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
			arena.bullets += 1

func safeDelete():
	done = true
	shootTimer.stop()
	sprite.visible = false
	collision.disabled = true

	
	deleteTimer.start()

func _on_delete_timer_timeout():
	queue_free()
