extends "res://Scenes/Stages/Arena.gd"

const bossDistance = 3000

@onready var enemySpawnTimer2 = get_node("World/EnemySpawnTimer2")
@onready var enemySpawnTimer3 = get_node("World/EnemySpawnTimer3")
@onready var boostSpawnTimer = get_node("World/BoostSpawnTimer")
@onready var boostEnableTimer = get_node("World/BoostEnableTimer")
@onready var swarmSpawnTimer = get_node("World/SwarmSpawnTimer")
@onready var swarmContainer = get_node("World/Swarms")

@export var enemy4: PackedScene
@export var mitosis4: PackedScene
@export var lady4: PackedScene
@export var booster4: PackedScene
@export var swarm4: PackedScene
@export var boss4: PackedScene
@export var bossArrow: PackedScene

var splitTimes = [8, 10, 12, 999]
var swarmSpeedMultiplier = 1

func _ready():
	randomize()
	enemyMax = 50

func _on_enemy_spawn_timer_timeout():
	spawnEnemy(enemy4, false)

func _on_enemy_spawn_timer_2_timeout():
	spawnEnemy(mitosis4, false)

func _on_enemy_spawn_timer_3_timeout():
	spawnEnemy(lady4, false)

func _on_boost_spawn_timer_timeout():
	if randi_range(1, 240) == 1:
		spawnEnemy(booster4, true)
		
		boostSpawnTimer.stop()
		boostEnableTimer.start()

func _on_boost_enable_timer_timeout():
	boostSpawnTimer.start()
	boostEnableTimer.stop()

func _on_swarm_spawn_timer_timeout():
	var newSwarm = swarm4.instantiate()
	newSwarm.position = Vector2(500, 0).rotated(randi_range(0, 2*PI)) + player.global_position
	swarmContainer.add_child(newSwarm)

func _on_wave_change_timer_timeout():
	wave += 1
	print(wave)
	
	match wave:
		2:
			enemyMax = 100
			enemySpawnTimer2.start()
		3:
			enemyMax = 200
			enemySpawnTimer2.wait_time = 1
		4:
			enemyMax = 300
			enemySpawnTimer.wait_time = 0.3
		5:
			enemyMax = 400
			enemySpawnTimer2.wait_time = 0.8
			bulletMax = 400
		6:
			enemyMax = 500
			enemySpawnTimer.wait_time = 0.2
		7:
			enemyMax = 600
			enemySpawnTimer2.wait_time = 0.7
		8:
			enemyMax = 750
			enemySpawnTimer3.start()
		9:
			enemyMax = 900
			enemySpawnTimer2.wait_time = 0.6
		10:
			enemySpawnTimer.wait_time = 0.1
		11: 
			enemySpawnTimer3.wait_time = 1.4
			enemySpawnTimer2.wait_time = 0.5
		12: 
			enemySpawnTimer3.wait_time = 1
			enemySpawnTimer2.wait_time = 0.4
			enemySpawnTimer.wait_time = 0.08
		13: 
			enemySpawnTimer3.wait_time = 0.7
			enemySpawnTimer2.wait_time = 0.3
			swarmSpawnTimer.start()
		14: 
			enemySpawnTimer3.wait_time = 0.5
			enemySpawnTimer2.wait_time = 0.2
			enemySpawnTimer.wait_time = 0.06
			swarmSpeedMultiplier = 2
		15: 
			enemySpawnTimer3.wait_time = 0.4
			enemySpawnTimer.wait_time = 0.05
			swarmSpeedMultiplier = 3
		16:
			waveChangeTimer.stop()
			stopSpawns()
			var newBoss = boss4.instantiate()
			var bossDirection = Vector2.RIGHT.rotated(randf_range(0,360))
			
			newBoss.position.x = player.position.x + bossDirection.x * bossDistance
			newBoss.position.y = player.position.y + bossDirection.y * bossDistance
			
			enemyContainer.add_child(newBoss)
			player.add_child(bossArrow.instantiate())

func splitMitosis(generation, spawnPos, xp):
	var newMitosis = mitosis4.instantiate()
	var newMitosis2 = mitosis4.instantiate()
	
	newMitosis.position.x = spawnPos.x - 1
	newMitosis.position.y = spawnPos.y
	newMitosis.generation = generation + 1
	newMitosis.xp = xp
	
	newMitosis2.position.x = spawnPos.x + 1
	newMitosis2.position.y = spawnPos.y
	newMitosis2.generation = generation + 1
	newMitosis2.xp = xp
	
	enemyContainer.add_child(newMitosis)
	enemyContainer.add_child(newMitosis2)
	
	if generation > 2:
		newMitosis.splitTimer.stop()
		newMitosis2.splitTimer.stop()
	else:
		newMitosis.splitTimer.wait_time = splitTimes[generation]
		newMitosis2.splitTimer.wait_time = splitTimes[generation]
		newMitosis.splitTimer.start()
		newMitosis2.splitTimer.start()

func stopSpawns():
	enemySpawnTimer.stop()
	enemySpawnTimer2.stop()
	enemySpawnTimer3.stop()
	boostSpawnTimer.stop()
	boostEnableTimer.stop()
	
func stopAttacks():
	enemySpawnTimer.stop()
	enemySpawnTimer2.stop()
	enemySpawnTimer3.stop()
	boostSpawnTimer.stop()
	boostEnableTimer.stop()
	swarmSpawnTimer.stop()
	for enemy in enemyContainer.get_children():
		if "fleeing" in enemy:
			enemy.fleeing = true
		if enemy.has_node("ShootTimer"):
			enemy.get_node("ShootTimer").stop()
		if enemy.has_node("SplitTimer"):
			enemy.get_node("SplitTimer").stop()
		if enemy.has_node("EyeballTimer"):
			enemy.get_node("EyeballTimer").stop()
		if "speed" in enemy:
			enemy.speed *= 2
	for object in objectContainer.get_children():
		if object.has_method("pop"):
			object.pop()
	for swarm in swarmContainer.get_children():
		if swarm.has_method("deleteSwarm"):
			swarm.deleteSwarm()
