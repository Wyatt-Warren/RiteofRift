extends RigidBody2D

const shootDistance = 250
const xp = 2
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var sprite = get_node("EnemySprite")
@onready var bouncer = get_node("Bouncer")
@onready var shootTimer = get_node("ShootTimer")

@export var bullet: PackedScene

var distance

func _ready():
	randomize()
	sprite.flip_h = randi_range(0,1) == 0
	
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0, shootTime)
	shootTimer.start()
	
func _physics_process(delta):
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))

func _on_grower_animation_finished(anim_name):
	bouncer.play("BounceSmall")
	shootTimer.start()

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var newBullet = bullet.instantiate()
		
		newBullet.position = global_position
		newBullet.target = (player.global_position - global_position).normalized()
		newBullet.speedMultiplier = 2
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(newBullet)
		arena.bullets += 1
