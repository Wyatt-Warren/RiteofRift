extends "res://Scenes/Stages/Arena.gd"

const bossDistance = 3000

@export var leader1: PackedScene
@export var leader1_2: PackedScene
@export var goon1: PackedScene
@export var goon1_2: PackedScene
@export var enemy1: PackedScene
@export var booster1: PackedScene
@export var lightning1: PackedScene
@export var boss1: PackedScene
@export var bossArrow: PackedScene

@onready var enemySpawnTimer2 = get_node("World/EnemySpawnTimer2")
@onready var enemySpawnTimer3 = get_node("World/EnemySpawnTimer3")
@onready var lightningTimer = get_node("World/LightningTimer")
@onready var boostSpawnTimer = get_node("World/BoostSpawnTimer")
@onready var boostEnableTimer = get_node("World/BoostEnableTimer")

var lightningScale = 1

func _ready():
	randomize()
	enemyMax = 50

func _on_enemy_spawn_timer_timeout():
	if enemyLessThanMax():
		var enemyPosVec = enemySpawnPosition()
		var enemyX = enemyPosVec.x
		var enemyY = enemyPosVec.y
		
		var leader = leader1.instantiate()
		leader.position.x = enemyX
		leader.position.y = enemyY
		enemyContainer.add_child(leader)
		
		for n in range(0,8):
			var goon = goon1.instantiate()
			goon.leader = leader
			goon.position.x = leader.position.x + randf_range(-30, 30)
			goon.position.y = leader.position.y + randf_range(-30, 30)
			enemyContainer.add_child(goon)
		

func _on_enemy_spawn_timer_2_timeout():
	spawnEnemy(enemy1, false)

func _on_enemy_spawn_timer_3_timeout():
	if enemyLessThanMax():
		var enemyPosVec = enemySpawnPosition()
		var enemyX = enemyPosVec.x
		var enemyY = enemyPosVec.y
		
		var leader = leader1_2.instantiate()
		leader.position.x = enemyX
		leader.position.y = enemyY
		enemyContainer.add_child(leader)
		
		for n in range(0,5):
			var goon = goon1.instantiate()
			goon.leader = leader
			goon.position.x = leader.position.x + randf_range(-30, 30)
			goon.position.y = leader.position.y + randf_range(-30, 30)
			enemyContainer.add_child(goon)
			
		for n in range(0,5):
			var goon = goon1_2.instantiate()
			goon.leader = leader
			goon.position.x = leader.position.x + randf_range(-30, 30)
			goon.position.y = leader.position.y + randf_range(-30, 30)
			enemyContainer.add_child(goon)

func _on_wave_change_timer_timeout():
	wave += 1
	print(wave)
	
	match wave:
		2:
			enemyMax = 100
			enemySpawnTimer.start()
		3:
			enemyMax = 200
			enemySpawnTimer.wait_time = 1
		4:
			enemyMax = 300
			enemySpawnTimer2.wait_time = 0.3
		5:
			enemyMax = 400
			enemySpawnTimer.wait_time = 0.8
			bulletMax = 400
		6:
			enemyMax = 500
			enemySpawnTimer2.wait_time = 0.2
		7:
			enemyMax = 600
			enemySpawnTimer.wait_time = 0.7
		8:
			enemyMax = 750
			enemySpawnTimer3.start()
		9:
			enemyMax = 900
			enemySpawnTimer.wait_time = 0.6
		10:
			enemySpawnTimer2.wait_time = 0.1
		11: 
			enemySpawnTimer3.wait_time = 0.8
			enemySpawnTimer.wait_time = 0.5
		12: 
			enemySpawnTimer3.wait_time = 0.7
			enemySpawnTimer.wait_time = 0.4
			enemySpawnTimer2.wait_time = 0.08
		13: 
			enemySpawnTimer3.wait_time = 0.5
			enemySpawnTimer.wait_time = 0.3
			lightningTimer.start()
		14: 
			enemySpawnTimer3.wait_time = 0.4
			enemySpawnTimer.wait_time = 0.2
			enemySpawnTimer2.wait_time = 0.06
			lightningScale = 1.5
			lightningTimer.wait_time = 3
		15: 
			enemySpawnTimer3.wait_time = 0.3
			enemySpawnTimer2.wait_time = 0.05
			lightningScale = 2
			lightningTimer.wait_time = 2
		16:
			waveChangeTimer.stop()
			stopSpawns()
			var newBoss = boss1.instantiate()
			var bossDirection = Vector2.RIGHT.rotated(randf_range(0,360))
			
			newBoss.position.x = player.position.x + bossDirection.x * bossDistance
			newBoss.position.y = player.position.y + bossDirection.y * bossDistance
			
			enemyContainer.add_child(newBoss)
			player.add_child(bossArrow.instantiate())

func _on_lightning_timer_timeout():
	var lightningX = (randi() % 300) - (150) + player.position.x
	var lightningY = (randi() % 300) - (150) + player.position.y
	
	var newLightning = lightning1.instantiate()
	newLightning.position.x = lightningX
	newLightning.position.y = lightningY
	
	get_node("World/Lightnings").add_child(newLightning)
	newLightning.changeScale(lightningScale)

func _on_boost_spawn_enable_timer_timeout():
	boostSpawnTimer.start()
	boostEnableTimer.stop()

func _on_boost_spawn_timer_timeout():
	if randi_range(1, 240) == 1:
		spawnEnemy(booster1, true)
		
		boostSpawnTimer.stop()
		boostEnableTimer.start()

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
	lightningTimer.stop()
	boostSpawnTimer.stop()
	boostEnableTimer.stop()	
	for enemy in enemyContainer.get_children():
		if "fleeing" in enemy:
			enemy.fleeing = true
		if enemy.has_node("ShootTimer"):
			enemy.get_node("ShootTimer").stop()
		if enemy.has_node("EggTimer"):
			enemy.get_node("EggTimer").stop()
		if "speed" in enemy:
			enemy.speed *= 2
	for object in objectContainer.get_children():
		if object.has_method("pop"):
			object.pop()
	
