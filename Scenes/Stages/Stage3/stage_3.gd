extends "res://Scenes/Stages/Arena.gd"

const bossDistance = 3000

@onready var boostSpawnTimer = get_node("World/BoostSpawnTimer")
@onready var boostEnableTimer = get_node("World/BoostEnableTimer")
@onready var enemySpawnTimer2 = get_node("World/EnemySpawnTimer2")
@onready var enemySpawnTimer3 = get_node("World/EnemySpawnTimer3")
@onready var enemySpawnTimer4 = get_node("World/EnemySpawnTimer4")
@onready var fireIceContainer = get_node("World/FireIces")

@export var enemy3: PackedScene
@export var bomb3: PackedScene
@export var fire3: PackedScene
@export var ice3: PackedScene
@export var booster3: PackedScene
@export var boss3: PackedScene
@export var bossArrow: PackedScene

func _ready():
	randomize()
	enemyMax = 50

func _on_enemy_spawn_timer_timeout():
	spawnEnemy(enemy3, false)

func _on_enemy_spawn_timer_2_timeout():
	spawnEnemy(bomb3, false)

func _on_enemy_spawn_timer_3_timeout():
	spawnEnemy(fire3, false)

func _on_enemy_spawn_timer_4_timeout():
	spawnEnemy(ice3, false)

func _on_boost_spawn_timer_timeout():
	if randi_range(1, 240) == 1:
		spawnEnemy(booster3, true)
		
		boostSpawnTimer.stop()
		boostEnableTimer.start()

func _on_boost_enable_timer_timeout():
	boostSpawnTimer.start()
	boostEnableTimer.stop()

func _on_wave_change_timer_timeout():
	wave += 1
	print(wave)
	
	match wave:
		2:
			enemyMax = 100
			enemySpawnTimer2.start()
		3:
			enemyMax = 200
			enemySpawnTimer2.wait_time = 1.5
		4:
			enemyMax = 300
			enemySpawnTimer.wait_time = 0.3
		5:
			enemyMax = 400
			enemySpawnTimer2.wait_time = 1.2
			bulletMax = 400
		6:
			enemyMax = 500
			enemySpawnTimer.wait_time = 0.2
		7:
			enemyMax = 600
			enemySpawnTimer2.wait_time = 1
		8:
			enemyMax = 750
			
			enemySpawnTimer4.start()
		9:
			enemyMax = 900
			enemySpawnTimer2.wait_time = 0.9
			
			enemySpawnTimer3.start()
			enemySpawnTimer4.stop()
		10:
			enemySpawnTimer.wait_time = 0.1
			enemySpawnTimer3.wait_time = 1.7
			enemySpawnTimer4.wait_time = 1.7
			
			enemySpawnTimer4.start()
			enemySpawnTimer3.stop()
		11: 
			enemySpawnTimer3.wait_time = 1.4
			enemySpawnTimer4.wait_time = 1.4
			enemySpawnTimer2.wait_time = 0.8
			
			enemySpawnTimer3.start()
			enemySpawnTimer4.stop()
		12: 
			enemySpawnTimer3.wait_time = 1
			enemySpawnTimer4.wait_time = 1
			enemySpawnTimer2.wait_time = 0.6
			enemySpawnTimer.wait_time = 0.08
			
			enemySpawnTimer4.start()
			enemySpawnTimer3.stop()
		13: 
			enemySpawnTimer3.wait_time = 0.7
			enemySpawnTimer4.wait_time = 0.7
			enemySpawnTimer2.wait_time = 0.5
			
			enemySpawnTimer3.start()
			enemySpawnTimer4.stop()
		14: 
			enemySpawnTimer3.wait_time = 0.5
			enemySpawnTimer4.wait_time = 0.5
			enemySpawnTimer2.wait_time = 0.3
			enemySpawnTimer.wait_time = 0.06
			
			enemySpawnTimer4.start()
			enemySpawnTimer3.stop()
		15: 
			enemySpawnTimer3.wait_time = 0.4
			enemySpawnTimer4.wait_time = 0.4
			enemySpawnTimer.wait_time = 0.05
			
			enemySpawnTimer3.start()
		16:
			waveChangeTimer.stop()
			stopSpawns()
			var newBoss = boss3.instantiate()
			var bossDirection = Vector2.RIGHT.rotated(randf_range(0,360))
			
			newBoss.position.x = player.position.x + bossDirection.x * bossDistance
			newBoss.position.y = player.position.y + bossDirection.y * bossDistance
			
			enemyContainer.add_child(newBoss)
			player.add_child(bossArrow.instantiate())

func stopSpawns():
	enemySpawnTimer.stop()
	enemySpawnTimer2.stop()
	enemySpawnTimer3.stop()
	enemySpawnTimer4.stop()
	boostSpawnTimer.stop()
	boostEnableTimer.stop()
			
func stopAttacks():
	enemySpawnTimer.stop()
	enemySpawnTimer2.stop()
	enemySpawnTimer3.stop()
	enemySpawnTimer4.stop()
	boostSpawnTimer.stop()
	boostEnableTimer.stop()
	for enemy in enemyContainer.get_children():
		if "fleeing" in enemy:
			enemy.fleeing = true
		if enemy.has_node("ShootTimer"):
			enemy.get_node("ShootTimer").stop()
		if enemy.has_node("ShootTimer2"):
			enemy.get_node("ShootTimer2").stop()
		if enemy.has_node("EggTimer"):
			enemy.get_node("EggTimer").stop()
		if "speed" in enemy:
			enemy.speed *= 2
	for object in objectContainer.get_children():
		if object.has_method("pop"):
			object.pop()
	for fireIce in fireIceContainer.get_children():
		if fireIce.has_method("deleteZone"):
			fireIce.deleteZone()
	for bullet in enemyBulletContainer.get_children():
		if "disableEffect" in bullet:
			bullet.disableEffect = true
