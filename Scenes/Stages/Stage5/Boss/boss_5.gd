extends StaticBody2D

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var shakeTimer = get_node("ShakeTimer")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var shaker = get_node("Shaker")
@onready var shatteredParticles = get_node("ShatteredParticles")
@onready var collision = get_node("CollisionShape2D")
@onready var sprite = get_node("BossSprite")

@export var moon5: PackedScene
@export var fragment1: PackedScene
@export var fragment2: PackedScene
@export var fragment3: PackedScene

var maxHealth = 300
var health = maxHealth
var done = false
var moonDirection = 1

func _ready():
	randomize()
	var directions = [-1, 1]
	
	moonDirection = directions[randi_range(0,1)]
	
	spawnMoons(moonDirection)

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
	
	for n in range(0, 25):
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
	collision.disabled = true
	sprite.visible = false
	
	deleteTimer.start()
	
func _on_delete_timer_timeout():
	queue_free()

func spawnMoons(direction):
	for n in range(0, 45):
		var newMoon = moon5.instantiate()
		var moonPosition = Vector2(150, 0).rotated(((2*PI)/5) * n)
		
		newMoon.persistOnDistance = true
		newMoon.spinDistance = 200
		newMoon.position = global_position + moonPosition
		newMoon.planet = self
		newMoon.direction = direction
		
		arena.enemyContainer.add_child(newMoon)
