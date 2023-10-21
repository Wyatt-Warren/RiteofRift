extends Node2D

const SmallSpawningTime = 1
const SmallBounds = 1100

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World/Player")
@onready var part1 = get_node("Boss2Part")
@onready var part2 = get_node("Boss2Part2")
@onready var part3 = get_node("Boss2Part3")
@onready var part4 = get_node("Boss2Part4")
@onready var currentPart = part1
@onready var smallTimer = get_node("SpawnSmallTimer")
@onready var shootTimer = get_node("MiddleShootTimer")
@onready var startNextWaveTimer = get_node("StartNextWaveTimer")
@onready var checkWaveEndTimer = get_node("CheckWaveEndTimer")
@onready var stopFlashTimer = get_node("StopFlashTimer")
@onready var partShatteredParticles = get_node("PartShatteredParticles")

@export var walls: PackedScene
@export var small: PackedScene
@export var boss2Bullet: PackedScene

var fightStarted = false
var phase = 0
var smallRemaining = 0

func _ready():
	randomize()

func _on_start_fight_area_body_entered(body):
	if body.is_in_group("Player") && !fightStarted:
		var playerArrow = body.get_node("BossArrow")
		if playerArrow != null:
			playerArrow.queue_free()
		
		var newWalls = walls.instantiate()
		
		newWalls.position = global_position
		
		arena.enemyContainer.add_child.call_deferred(newWalls)
		fightStarted = true
		startNextWaveTimer.start()

func spawnSmallMushrooms(count):
	smallRemaining = count
	smallTimer.wait_time = (SmallSpawningTime * 1.0) / count
	smallTimer.start()

func _on_spawn_small_timer_timeout():
	if smallRemaining > 0:
		var smallX
		var smallY
		
		while(true):
			var goodSpot = true
			
			smallX = randi_range(SmallBounds * -1, SmallBounds) + global_position.x
			smallY = randi_range(SmallBounds * -1, SmallBounds) + global_position.y
			
			if global_position.distance_to(Vector2(smallX, smallY)) > 300:
				for object in arena.enemyContainer.get_children():
					if (abs(object.global_position.x - smallX) < 90 and abs(object.global_position.y - smallY) < 90):
						goodSpot = false
				
				if goodSpot:
					break
		
		var newSmall = small.instantiate()
		
		newSmall.position = Vector2(smallX, smallY)
		
		arena.enemyContainer.add_child(newSmall)
		
		checkWaveEndTimer.start()
		smallRemaining -= 1
		smallTimer.start()

func _on_middle_shoot_timer_timeout():
	var newBullet = boss2Bullet.instantiate()
	
	newBullet.position = currentPart.global_position
	newBullet.target = (player.global_position - global_position).normalized()
	
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBullet)

func _on_start_next_wave_timer_timeout():
	phase += 1
	match phase:
		1:
			spawnSmallMushrooms(25)
			shootTimer.start()
		2:
			spawnSmallMushrooms(30)
			currentPart = part2
			shootTimer.start()
		3:
			spawnSmallMushrooms(40)
			currentPart = part3
			shootTimer.start()
		4:
			spawnSmallMushrooms(60)
			currentPart = part4
			shootTimer.start()

func _on_boss_2_part_shattered():
	startNextWaveTimer.start()
	shootTimer.stop()
	
	partShatteredParticles.position = part1.position
	partShatteredParticles.emitting = true
	stopFlashTimer.start()
	

func _on_boss_2_part_2_shattered():
	startNextWaveTimer.start()
	shootTimer.stop()
	
	partShatteredParticles.position = part2.position
	partShatteredParticles.emitting = true
	stopFlashTimer.start()

func _on_boss_2_part_3_shattered():
	startNextWaveTimer.start()
	shootTimer.stop()
	
	partShatteredParticles.position = part3.position
	partShatteredParticles.emitting = true
	stopFlashTimer.start()

func _on_boss_2_part_4_shattered():
	shootTimer.stop()
	
	partShatteredParticles.position = part4.position
	partShatteredParticles.emitting = true
	stopFlashTimer.start()
	
func _on_check_wave_end_timer_timeout():
	var anySmall = false
	
	for enemy in arena.enemyContainer.get_children():
		if enemy.is_in_group("SmallMushroom"):
			anySmall = true
			break
	
	if !anySmall:
		currentPart.enable()
		checkWaveEndTimer.stop()

func _on_stop_flash_timer_timeout():
	partShatteredParticles.emitting = false
