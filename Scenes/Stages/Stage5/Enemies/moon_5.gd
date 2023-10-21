extends RigidBody2D

const speed = 35
const shootDistance = 250
const targetLerpWeight =  0.7
const xp = 1
var shootTime

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var sprite = get_node("EnemySprite")

@export var bullet: PackedScene

var planet
var enemy_move_vec = Vector2()
var distance
var fleeing = false
var colors = [[140, 160, 180], [180, 140, 160], [110, 140, 110]]
var turnAngle = 0
var persistOnDistance = false
var spinDistance = 100
var farShot = false
var direction = 1

func _ready():
	randomize()
	var colorIndex = randi_range(0, 2)
	sprite.modulate.r8 = colors[colorIndex][0]
	sprite.modulate.g8 = colors[colorIndex][1]
	sprite.modulate.b8 = colors[colorIndex][2]
	
	rotation = randf_range(0, 2 * PI)
	
	shootTime = shootTimer.wait_time
	shootTimer.wait_time = randf_range(0.1, shootTime)
	shootTimer.start()

func move(target, toAway, lerpWeight):
	var targetVec = (target.global_position - global_position).normalized().rotated(deg_to_rad(turnAngle))
	
	enemy_move_vec = enemy_move_vec.lerp(targetVec * toAway, lerpWeight)

func _on_move_timer_timeout():
	distance = Vector2(player.global_position).distance_to(Vector2(global_position))
	
	if distance > 2000 && !persistOnDistance:
		queue_free()
		
	var toAway = 1
	var target = planet
	
	if !fleeing:
		if planet == null:
			var planets = []
			for enemy in arena.get_node("World").get_node("Enemies").get_children():
				if enemy.is_in_group("Planet"):
					planets.append(enemy)
			
			if planets.size() != 0:
				target = planets[0]
				
				for n in planets:
					if n.global_position.distance_to(global_position) < target.global_position.distance_to(global_position):
						target = n
						
				planet = target
				direction = planet.moonDirection
				
			else:
				target = player
				toAway = -1
		
		var planetDistance = Vector2(target.global_position).distance_to(Vector2(global_position))
		
		if target != player && planetDistance < spinDistance:
			turnAngle = 60 * direction
		else:
			turnAngle = 0
	
		move(target, toAway, targetLerpWeight)
	else:
		move(player, -1, 2)
	
	apply_impulse(enemy_move_vec * speed * arena.speedMultiplier, Vector2())

func _on_shoot_timer_timeout():
	shootTimer.wait_time = shootTime
	shootTimer.start()
	
	if arena.bullets < arena.bulletMax && distance > shootDistance:
		var target_vec = (player.global_position - global_position).normalized()
		var new_bullet = bullet.instantiate()
		
		new_bullet.position = global_position
		new_bullet.target = target_vec
		if farShot:
			new_bullet.speedMultiplier = 2.5
		
		arena.get_node("World").get_node("Enemy Bullets").add_child(new_bullet)
		arena.bullets += 1
