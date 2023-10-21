extends Node2D

const enemyTotalMax = 1500
const spawnDistance = 300 #Max distance from edge of screen an enemy can spawn

var bulletMax = 250
var enemyMax = 5
var bullets = 0
var speedMultiplier = 1
var wave = 1

#UpgradeLevels
var movementSpeed = [200, 250, 300, 350, 400]
var maxHealth = [10, 15, 20, 25, 30]
var healthRegenSpeed = [10, 9, 8, 7, 6]
var mainSuckerRange = [0.6, 0.7, 0.8, 0.9, 1]
var mainSuckerCount = [1, 2, 3, 4, 5]
var grenadeFireSpeed = [5, 3, 2, 1.5, 0.75]
var grenadeSuckerCount = [1, 2, 3, 4, 5]
var grenadeSuckerRange = [0.7, 0.8, 0.9, 1, 1.1]
var grenadeRotationSpeed = [60, 90, 120, 180, 240]
var mouseHoleSpeed = [300, 350, 400, 450, 500]
var mouseHoleSuckerCount = [1, 2, 3, 4, 5]
var mouseHoleSuckerRange = [0.6, 0.7, 0.8, 0.9, 1]
var mouseHoleRotationSpeed = [60, 90, 120, 180, 240]
var fireHoleFiringSpeed = [4, 2, 1.5, 1, 0.75]
var fireHoleSuckerCount = [1, 2, 3, 4, 5]
var fireHoleSuckerRange = [0.7, 0.8, 0.9, 1, 1.1]
var fireHoleRotationSpeed = [60, 90, 120, 180, 240]

@onready var player = get_node("World").get_node("Player")
@onready var enemyContainer = get_node("World").get_node("Enemies")
@onready var objectContainer = get_node("World").get_node("Objects")
@onready var waveChangeTimer = get_node("World/WaveChangeTimer")
@onready var enemySpawnTimer = get_node("World/EnemySpawnTimer")
@onready var enemyBulletContainer = get_node("World/Enemy Bullets")

func _ready():
	randomize()

func enemyLessThanMax():
	return enemyContainer.get_child_count() < enemyTotalMax and enemyContainer.get_child_count() < enemyMax
	
func enemySpawnPosition():
	var enemyX
	var enemyY
	
	while true:
		enemyX = (randi() % int(get_viewport_rect().size.x + (spawnDistance*2))) - (get_viewport_rect().size.x/2 + spawnDistance)
		enemyY = (randi() % int(get_viewport_rect().size.y + (spawnDistance*2))) - (get_viewport_rect().size.y/2 + spawnDistance)
		if abs(enemyX) > get_viewport_rect().size.x/2 + (spawnDistance/2) or abs(enemyY) > get_viewport_rect().size.y/2 + (spawnDistance/2):
			break
	return Vector2(enemyX + player.position.x, enemyY + player.position.y)
	
func spawnEnemy(enemy, alwaysSpawn):
	if enemyLessThanMax() or alwaysSpawn:
		var newEnemy = enemy.instantiate()
		
		newEnemy.position = enemySpawnPosition()
		
		enemyContainer.add_child(newEnemy)
