extends "res://Scenes/Stages/Arena.gd"

const bossDistance = 3000

@onready var enemySpawnTimer2 = get_node("World/EnemySpawnTimer2")
@onready var enemySpawnTimer3 = get_node("World/EnemySpawnTimer3")
@onready var boostSpawnTimer = get_node("World/BoostSpawnTimer")
@onready var boostEnableTimer = get_node("World/BoostEnableTimer")

@export var enemy7: PackedScene
@export var confuser7: PackedScene
@export var mom7: PackedScene
@export var booster7: PackedScene

func _ready():
	randomize()
	enemyMax = 50
	
func _on_enemy_spawn_timer_timeout():
	spawnEnemy(enemy7, false)

func _on_enemy_spawn_timer_2_timeout():
	spawnEnemy(confuser7, false)

func _on_enemy_spawn_timer_3_timeout():
	spawnEnemy(mom7, false)


func _on_boost_spawn_timer_timeout():
	if randi_range(1, 240) == 1:
		spawnEnemy(booster7, true)
		
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
		14: 
			enemySpawnTimer3.wait_time = 0.5
			enemySpawnTimer2.wait_time = 0.2
			enemySpawnTimer.wait_time = 0.06
		15: 
			enemySpawnTimer3.wait_time = 0.4
			enemySpawnTimer.wait_time = 0.05
		16:
			waveChangeTimer.stop()
			stopSpawns()
			
func stopSpawns():
	enemySpawnTimer.stop()
	enemySpawnTimer2.stop()
	enemySpawnTimer3.stop()
	boostSpawnTimer.stop()
	boostEnableTimer.stop()
