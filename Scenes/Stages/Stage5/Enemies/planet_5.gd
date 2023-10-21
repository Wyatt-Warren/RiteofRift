extends RigidBody2D

var speed = 45
const playerLerpWeight =  0.1
const xp = 6

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var runAwayArea = get_node("RunAwayArea")
@onready var sprite = get_node("EnemySprite")

@export var moon5: PackedScene

var enemy_move_vec = Vector2()
var distance
var fleeing = false
var colors = [[80, 140, 190], [190, 80, 140], [80, 150, 80]]
var moonDirection = 1

func _ready():
	runAwayArea.lerpWeight = 0.1
	
	randomize()
	var colorIndex = randi_range(0, 2)
	sprite.modulate.r8 = colors[colorIndex][0]
	sprite.modulate.g8 = colors[colorIndex][1]
	sprite.modulate.b8 = colors[colorIndex][2]
	
	rotation = randf_range(0, 2 * PI)
	
	var directions = [-1, 1]
	
	moonDirection = directions[randi_range(0,1)]
	
	spawnMoons(moonDirection)

func move(target, toAway, lerpWeight):
	enemy_move_vec = enemy_move_vec.lerp((target.global_position - global_position).normalized() * toAway, lerpWeight)

func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if distance > 2000:
		queue_free()
		
	if !fleeing:
		move(player, 1, playerLerpWeight)
	else:
		move(player, -1, 2)
		
	runAwayArea.scale.x = arena.speedMultiplier * 0.3
	runAwayArea.scale.y = arena.speedMultiplier * 0.3
	
	apply_impulse(enemy_move_vec * speed * arena.speedMultiplier, Vector2())
	
func spawnMoons(direction):
	for n in range(0, 8):
		var newMoon = moon5.instantiate()
		var moonPosition = Vector2(75, 0).rotated(((2*PI)/5) * n)
		
		newMoon.position = global_position + moonPosition
		newMoon.planet = self
		newMoon.direction = direction
		
		arena.enemyContainer.add_child(newMoon)
