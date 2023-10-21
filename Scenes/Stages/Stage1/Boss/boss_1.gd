extends Node2D

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.get_node("World/Player")
@onready var shootTimer = get_node("ShootTimer")
@onready var shootTimer2 = get_node("ShootTimer2")
@onready var waveTimer = get_node("WaveTimer")
@onready var fastTimer = get_node("FastTimer")
@onready var suckerDisableTimer = get_node("SuckerDisableTimer")
@onready var stopFlashTimer = get_node("StopFlashTimer")
@onready var flashParticles = get_node("FlashParticles")
@onready var flashParticlesFinal = get_node("FlashParticlesFinal")
@onready var part1 = get_node("Boss1Part")
@onready var part2 = get_node("Boss1Part2")
@onready var part3 = get_node("Boss1Part3")
@onready var part4 = get_node("Boss1Part4")
@onready var part5 = get_node("Boss1Part5")
@onready var part6 = get_node("Boss1Part6")
@onready var part7 = get_node("Boss1FinalPart")

@export var bullet: PackedScene
@export var lightning: PackedScene
@export var walls: PackedScene

var bulletRotation = 0
var fastShots = 0
var turnDegrees = 0
var fightStarted = false

var phase = 1
@onready var currentPart = part1
var target_vec = Vector2()

func _on_shoot_timer_timeout():
	if currentPart.enabled:
		slowPattern()
	else:
		match phase:
			1:
				phase1pattern1()
			2:
				phase2pattern1()
			3:
				fastTimer.start()
				shootTimer2.start()
				shootTimer.stop()
			4:
				fastTimer.start()
				shootTimer2.start()
				shootTimer.stop()
			5:
				fastTimer.start()
				shootTimer2.start()
				shootTimer.stop()
			6:
				target_vec = (player.global_position - currentPart.global_position).normalized()
				fastTimer.start()
				shootTimer2.start()
				shootTimer.stop()

func _on_shoot_timer_2_timeout():
	if !currentPart.enabled:
		match phase:
			1:
				phase1pattern2()
			2:
				phase2pattern2()
			3:
				phase1pattern2()
			4:
				phase4pattern2()
			5:
				phase5pattern2()
			6:
				phase6pattern2()
	elif phase == 7:
		phase7pattern2()
	

func _on_fast_timer_timeout():
	if !currentPart.enabled:
		match phase:
			1:
				phase1patternFast()
			2:
				phase2patternFast()
			3:
				phase3patternFast()
			4:
				phase4patternFast()
			5:
				phase5patternFast()
			6:
				phase6patternFast()

func slowPattern():
	bulletRotation += 10
	
	if bulletRotation >= 360:
		bulletRotation -= 360

	for n in range(0, 18):
		var newBullet = bullet.instantiate()
		
		newBullet.position = currentPart.global_position
		newBullet.target = Vector2.RIGHT.rotated((((2*PI)/18)*n)+deg_to_rad(bulletRotation))
		arena.get_node("World/Enemy Bullets").add_child(newBullet)

func phase1pattern1():
	target_vec = (player.global_position - currentPart.global_position).normalized()
	fastShots = 0
	fastTimer.start()
	
func phase1pattern2():
	bulletRotation += 5
	
	if bulletRotation >= 360:
		bulletRotation -= 360

	for n in range(0, 36):
		var newBullet = bullet.instantiate()
		
		newBullet.position = currentPart.global_position
		newBullet.target = Vector2.RIGHT.rotated((((2*PI)/36)*n)+deg_to_rad(bulletRotation))
		arena.get_node("World/Enemy Bullets").add_child(newBullet)

func phase1patternFast():
	var newBullets = [bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), bullet.instantiate()]
	
	for newBullet in newBullets:
		newBullet.position = currentPart.global_position
		newBullet.maxSpeed = 12
		newBullet.accel = 0.12
		newBullet.scale.x *= 1.5
		newBullet.scale.y *= 1.5
		
	newBullets[0].target = target_vec
	newBullets[1].target = target_vec.rotated(deg_to_rad(20))
	newBullets[2].target = target_vec.rotated(deg_to_rad(-20))
	newBullets[3].target = target_vec.rotated(deg_to_rad(40))
	newBullets[4].target = target_vec.rotated(deg_to_rad(-40))
	
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBullets[0])
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBullets[1])
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBullets[2])
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBullets[3])
	arena.get_node("World").get_node("Enemy Bullets").add_child(newBullets[4])
	
	fastShots += 1
	
	if fastShots >= 25:
		fastTimer.stop()
		
func phase2pattern1():
	target_vec = Vector2.RIGHT
	fastShots = 0
	fastTimer.start()
	
func phase2pattern2():
	bulletRotation += 18
	
	if bulletRotation >= 360:
		bulletRotation -= 360
			
	for n in range(0, 10):
		var newBullet = bullet.instantiate()
		
		newBullet.position = currentPart.global_position
		newBullet.target = Vector2.RIGHT.rotated((((2*PI)/10)*n)+deg_to_rad(bulletRotation))
		newBullet.accel = 0.17
		newBullet.maxSpeed = 16
		newBullet.scale.x *= 5
		newBullet.scale.y *= 5
		arena.get_node("World/Enemy Bullets").add_child(newBullet)
	
func phase2patternFast():
	fastShots += 1
	if fastShots <= 15:
		
		var newBullets = [bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
		bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
		bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
		bullet.instantiate(), bullet.instantiate(), bullet.instantiate()]
		
		var targetDegrees = 0
		var targetDegreesIncrement = 30

		for newBullet in newBullets:
			newBullet.position = currentPart.global_position
			newBullet.target = target_vec.rotated(deg_to_rad(targetDegrees))
			targetDegrees += targetDegreesIncrement
			arena.get_node("World/Enemy Bullets").add_child(newBullet)
			
		target_vec = target_vec.rotated(deg_to_rad(12))
		
	elif fastShots == 24:
		bulletRotation = 0
		shootTimer2.start()
	elif fastShots == 40:
		shootTimer2.stop()
		fastTimer.stop()

func phase3patternFast():
	var newBullet = bullet.instantiate()
	
	newBullet.position = currentPart.global_position
	newBullet.target = (player.global_position - currentPart.global_position).normalized()
	newBullet.accel = 0.6
	newBullet.maxSpeed = 17
	
	arena.get_node("World/Enemy Bullets").add_child(newBullet)

func phase4pattern2():
	var newBullets = [bullet.instantiate(), bullet.instantiate(), bullet.instantiate()]
	
	var targetDegrees = -15
	var targetDegreesIncrement = 15
	
	for newBullet in newBullets:
		newBullet.position = currentPart.global_position
		newBullet.target = (player.global_position - currentPart.global_position).normalized().rotated(deg_to_rad(targetDegrees))
		newBullet.accel = 0.5
		newBullet.scale.x *= 5
		newBullet.scale.y *= 5
		newBullet.maxSpeed = 12
		targetDegrees += targetDegreesIncrement
		
		arena.get_node("World/Enemy Bullets").add_child(newBullet)

func phase4patternFast():
	if fastShots >= 6:
		fastShots = 0
		target_vec = target_vec.rotated(deg_to_rad(14))
	else:
		
		var newBullets = [bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
		bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
		bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
		bullet.instantiate(), bullet.instantiate(), bullet.instantiate()]
		
		var targetDegrees = 0
		var targetDegreesIncrement = 30

		for newBullet in newBullets:
			newBullet.position = currentPart.global_position
			newBullet.target = target_vec.rotated(deg_to_rad(targetDegrees))
			targetDegrees += targetDegreesIncrement
			arena.get_node("World/Enemy Bullets").add_child(newBullet)
			
		fastShots += 1

func phase5pattern2():
	var newBullets = [bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
	bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
	bullet.instantiate(), bullet.instantiate(), bullet.instantiate(), 
	bullet.instantiate(), bullet.instantiate(), bullet.instantiate()]
	
	var targetDegrees = 0
	var targetDegreesIncrement = 30

	for newBullet in newBullets:
		newBullet.position = currentPart.global_position
		newBullet.target = target_vec.rotated(deg_to_rad(targetDegrees))
		newBullet.scale.x *= 8
		newBullet.scale.y *= 8
		newBullet.accel = 0.6
		newBullet.maxSpeed = 12
		
		targetDegrees += targetDegreesIncrement
		arena.get_node("World/Enemy Bullets").add_child(newBullet)
		
	target_vec = target_vec.rotated(deg_to_rad(13))

func phase5patternFast():
	fastShots += 1
	
	if fastShots >= 6:
		turnDegrees *= -1
		fastShots = 0
	
	bulletRotation += 10
	
	if bulletRotation >= 360:
		bulletRotation -= 360

	for n in range(0, 30):
		var newBullet = bullet.instantiate()
		
		newBullet.position = currentPart.global_position
		newBullet.target = Vector2.RIGHT.rotated((((2*PI)/30)*n)+deg_to_rad(bulletRotation))
		newBullet.turnDegrees = deg_to_rad(turnDegrees)
		newBullet.maxTurned = deg_to_rad(90)
		arena.get_node("World/Enemy Bullets").add_child(newBullet)
		
func phase6pattern2():
	bulletRotation += 23
	
	if bulletRotation >= 360:
		bulletRotation -= 360

	var targetDegrees = 0
	var targetDegreesIncrement = 3
	var targetDegreesIncrementBig = 18
	
	for n in range(0, 8):
		for m in range(0,9):
			var newBullet = bullet.instantiate()
			
			newBullet.position = currentPart.global_position
			newBullet.target = Vector2.RIGHT.rotated(deg_to_rad(targetDegrees + bulletRotation))
			newBullet.maxSpeed = 4 
			
			targetDegrees += targetDegreesIncrement
			arena.get_node("World/Enemy Bullets").add_child(newBullet)
			
		targetDegrees += targetDegreesIncrementBig
	
func phase6patternFast():
	fastShots += 1
	if fastShots < 7:

		var targetDegrees = -75
		var targetDegreesIncrement = 30
		
		for n in range(0, 6):
			var newBullet = bullet.instantiate()
			
			newBullet.position = currentPart.global_position
			newBullet.target = target_vec.rotated(deg_to_rad(targetDegrees))
			
			targetDegrees += targetDegreesIncrement
			arena.get_node("World/Enemy Bullets").add_child(newBullet)
			
	if fastShots >= 18:
		target_vec = (player.global_position - currentPart.global_position).normalized()
		fastShots = 0
		
func phase7pattern2():
	var lightningX = (randi() % 300) - (150) + player.position.x
	var lightningY = (randi() % 300) - (150) + player.position.y
	
	var newLightning = lightning.instantiate()
	newLightning.position.x = lightningX
	newLightning.position.y = lightningY
	
	arena.get_node("World/Lightnings").add_child(newLightning)

func _on_wave_timer_timeout():
	player.toggleSuckers(false)
	fastTimer.stop()
	shootTimer2.stop()
	
	currentPart.enable()
	shootTimer.wait_time = 1
	
	shootTimer.start()
	if phase == 7:
		shootTimer2.start()
	

func _on_boss_1_part_shattered():
	suckerDisableTimer.start()
	fastTimer.stop()
	shootTimer2.stop()
	part7.get_node("Bouncer").speed_scale += 0.5
	flashParticles.emitting = true
	stopFlashTimer.start()
	
	bulletRotation = 0
	phase += 1
	currentPart = part2
	shootTimer.wait_time = 5
	shootTimer2.wait_time = 0.5
	fastTimer.wait_time = 0.1
	
	waveTimer.start()
	shootTimer.start()

func _on_boss_1_part_2_shattered():
	suckerDisableTimer.start()
	fastTimer.stop()
	shootTimer2.stop()
	part7.get_node("Bouncer").speed_scale += 0.5
	
	flashParticles.position = part2.position
	flashParticles.emitting = true
	stopFlashTimer.start()
	
	bulletRotation = 0
	phase += 1
	currentPart = part3
	shootTimer.wait_time = 5
	shootTimer2.wait_time = 0.75
	fastTimer.wait_time = 0.1
	
	waveTimer.start()
	shootTimer.start()

func _on_boss_1_part_3_shattered():
	suckerDisableTimer.start()
	fastTimer.stop()
	shootTimer2.stop()
	part7.get_node("Bouncer").speed_scale += 0.5
	
	flashParticles.position = part3.position
	flashParticles.emitting = true
	stopFlashTimer.start()
	
	fastShots = 0
	bulletRotation = 0
	phase += 1
	currentPart = part4
	shootTimer.wait_time = 5
	shootTimer2.wait_time = 1.5
	fastTimer.wait_time = 0.1
	target_vec = Vector2.RIGHT
	
	waveTimer.start()
	shootTimer.start()

func _on_boss_1_part_4_shattered():
	suckerDisableTimer.start()
	fastTimer.stop()
	shootTimer2.stop()
	part7.get_node("Bouncer").speed_scale += 0.5
	
	flashParticles.position = part4.position
	flashParticles.emitting = true
	stopFlashTimer.start()
	
	fastShots = 0
	bulletRotation = 0
	turnDegrees = 0.2
	phase += 1
	currentPart = part5
	shootTimer.wait_time = 5
	shootTimer2.wait_time = 2.5
	fastTimer.wait_time = 0.5
	target_vec = Vector2.RIGHT
	
	waveTimer.start()
	shootTimer.start()

func _on_boss_1_part_5_shattered():
	suckerDisableTimer.start()
	fastTimer.stop()
	shootTimer2.stop()
	part7.get_node("Bouncer").speed_scale += 0.5
	
	flashParticles.position = part5.position
	flashParticles.emitting = true
	stopFlashTimer.start()
	
	fastShots = 0
	bulletRotation = 0
	phase += 1
	currentPart = part6
	shootTimer.wait_time = 5
	shootTimer2.wait_time = 0.75
	fastTimer.wait_time = 0.1
	target_vec = Vector2.RIGHT
	
	waveTimer.start()
	shootTimer.start()

func _on_boss_1_part_6_shattered():
	suckerDisableTimer.start()
	fastTimer.stop()
	shootTimer.stop()
	shootTimer2.stop()
	part7.get_node("Bouncer").speed_scale += 0.5
	
	flashParticles.position = part6.position
	flashParticles.emitting = true
	stopFlashTimer.start()
	
	bulletRotation = 0
	phase += 1
	currentPart = part7
	shootTimer2.wait_time = 1.5
	waveTimer.wait_time = 5
	
	waveTimer.start()

func _on_boss_1_final_part_shattered():
	player.toggleSuckers(false)
	fastTimer.stop()
	shootTimer.stop()
	shootTimer2.stop()
	
	flashParticlesFinal.emitting = true
	stopFlashTimer.start()

func _on_start_fight_area_body_entered(body):
	if body.is_in_group("Player") && !fightStarted:
		var playerArrow = body.get_node("BossArrow")
		if playerArrow != null:
			playerArrow.queue_free()
		
		add_child.call_deferred(walls.instantiate())
		waveTimer.start()
		shootTimer.start()
		shootTimer2.start()
		fightStarted = true

func _on_stop_flash_timer_timeout():
	flashParticles.emitting = false
	flashParticlesFinal.emitting = false

func _on_sucker_disable_timer_timeout():
	player.toggleSuckers(true)
