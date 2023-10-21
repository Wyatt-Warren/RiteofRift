extends CharacterBody2D

const acc = 40
const joystickDeadzone = 0.5
const mouseDeadzone = 20
const radFull = 2*PI

#Stuff
var motion: Vector2
var lastDirection = Vector2()
var angleTo = 0
var playerDisabled = false

#Nodes
@onready var playerBody = get_node("PlayerBody")
@onready var suckers = get_node("Suckers")
@onready var hitTimer = get_node("HitTimer")
@onready var fireTimer = get_node("FireTimer")
@onready var regenTimer = get_node("RegenTimer")
@onready var levelUpTimer = get_node("LevelUpTimer")
@onready var boostTimer = get_node("BoostModeTimer")
@onready var slowTimer = get_node("SlowTimer")
@onready var arena = get_parent().get_parent()
@onready var healthLabel = arena.get_node("UIOverlay").get_node("Interface").get_node("HealthBox").get_node("VBoxContainer").get_node("HealthLabel")
@onready var healthBar = arena.get_node("UIOverlay").get_node("Interface").get_node("HealthBox").get_node("VBoxContainer").get_node("HealthBar")
@onready var regenBar = arena.get_node("UIOverlay").get_node("Interface").get_node("RegenBar")
@onready var levelLabel = arena.get_node("UIOverlay").get_node("Interface").get_node("LevelLabel")
@onready var xpBar = arena.get_node("UIOverlay").get_node("Interface").get_node("XPBar")
@onready var grenadeBar = get_node("GrenadeBar")
@onready var boostBar = get_node("BoostBar")

#Levels
var level = 1
var speedLevel = 0
var maxHealthLevel = 0
var healthRegenSpeedLevel = 0
var mainSuckerRangeLevel = 0
var mainSuckerCountLevel = 0
var grenadeFireSpeedLevel = 0
var grenadeSuckerCountLevel = 0
var grenadeSuckerRangeLevel = 0
var grenadeRotationSpeedLevel = 0
var mouseHoleSpeedLevel = 0
var mouseHoleSuckerCountLevel = 0
var mouseHoleSuckerRangeLevel = 0
var mouseHoleRotationSpeedLevel = 0
var fireHoleFiringSpeedLevel = 0
var fireHoleSuckerCountLevel = 0
var fireHoleSuckerRangeLevel = 0
var fireHoleRotationSpeedLevel = 0

#Stats
@onready var boosted = false
@onready var speed = arena.movementSpeed[speedLevel]
@onready var maxHealth = arena.maxHealth[maxHealthLevel]
@onready var suckerCount = arena.mainSuckerCount[mainSuckerCountLevel]
@onready var suckerScale = arena.mainSuckerRange[mainSuckerRangeLevel]
@onready var grenadeEnabled = false
@onready var grenadeFireSpeed = arena.grenadeFireSpeed[grenadeFireSpeedLevel]
@onready var grenadeSuckerCount = arena.grenadeSuckerCount[grenadeSuckerCountLevel]
@onready var grenadeSuckerScale = arena.grenadeSuckerRange[grenadeSuckerRangeLevel]
@onready var grenadeRotationSpeed = arena.grenadeRotationSpeed[grenadeRotationSpeedLevel]
@onready var mouseHoleEnabled = false
@onready var mouseHoleSpeed = arena.mouseHoleSpeed[mouseHoleSpeedLevel]
@onready var mouseHoleSuckerCount = arena.mouseHoleSuckerCount[mouseHoleSuckerCountLevel]
@onready var mouseHoleRotationSpeed = arena.mouseHoleRotationSpeed[mouseHoleRotationSpeedLevel]
@onready var mouseHoleSuckerScale = arena.mouseHoleSuckerRange[mouseHoleSuckerRangeLevel]
@onready var fireHoleEnabled = false
@onready var fireHoleFiringSpeed = arena.fireHoleFiringSpeed[fireHoleFiringSpeedLevel]
@onready var fireHoleSuckerCount = arena.fireHoleSuckerCount[fireHoleSuckerCountLevel]
@onready var fireHoleRotationSpeed = arena.fireHoleRotationSpeed[fireHoleRotationSpeedLevel]
@onready var fireHoleSuckerScale = arena.fireHoleSuckerRange[fireHoleSuckerRangeLevel]

#Counters
@onready var xp = 0
@onready var levelUpXp = 50
@onready var killCount = 0
@onready var health = maxHealth

@export var sucker: PackedScene
@export var grenade: PackedScene
@export var mouseHole: PackedScene
@export var fireHole: PackedScene
@export var levelUpScreen: PackedScene

func _ready():
	randomize()
	update_stats()
	
func _input(event):
	
	if event is InputEventJoypadMotion:
		var horizontal = Input.get_action_strength("Look_Right") - Input.get_action_strength("Look_Left")
		var vertical = Input.get_action_strength("Look_Down") - Input.get_action_strength("Look_Up")
		if abs(horizontal) > joystickDeadzone or abs(vertical) > joystickDeadzone:
			angleTo = atan2(vertical, horizontal)
	
	elif event is InputEventMouseMotion:
		var lookVec = get_global_mouse_position() - global_position
		angleTo = atan2(lookVec.y, lookVec.x)
		
func _process(delta):
	regenBar.value = ((regenTimer.wait_time - regenTimer.time_left) / regenTimer.wait_time) * 100
	grenadeBar.value = ((fireTimer.wait_time - fireTimer.time_left) / fireTimer.wait_time) * 100
	boostBar.value = (boostTimer.time_left / boostTimer.wait_time) * 100
	
	move_and_slide()
	suckers.rotation = lerp_angle(suckers.rotation, angleTo, 9 * delta)

func _physics_process(delta):
	var hor_input = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var ver_input = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	
	var newSpeed
	
	if slowTimer.is_stopped():
		newSpeed = speed
	else:
		newSpeed = speed * .4
	
	velocity = velocity.lerp(Vector2(hor_input, ver_input) * newSpeed, 0.5)
	
	if(Input.is_action_pressed("Fire") && !playerDisabled):
		fire()

func _on_player_body_enemy_eaten(enemy):
	killCount += 1
	xp += enemy.xp

	updateXpLabel()

	if xp >= levelUpXp:
		levelUpTimer.start()
	
	if enemy.is_in_group("Booster"):
		boost()
		

func _on_player_body_got_shot(damage):
	damage_player(damage)

func fire():
	if(fireTimer.time_left == 0 && grenadeEnabled):
		var new_grenade = grenade.instantiate()
		
		new_grenade.position = global_position
		new_grenade.target = Vector2.RIGHT.rotated(angleTo)
		new_grenade.suckerCount = grenadeSuckerCount
		new_grenade.suckerScale = grenadeSuckerScale
		new_grenade.rotationSpeed = grenadeRotationSpeed
		new_grenade.player = self
		
		arena.get_node("World/Player Bullets").add_child(new_grenade)
		fireTimer.start()
		grenadeBar.show()
		
	elif(fireTimer.time_left == 0 && fireHoleEnabled):
		var newFireHole = fireHole.instantiate()
		
		newFireHole.position = global_position
		newFireHole.target = Vector2.RIGHT.rotated(angleTo)
		newFireHole.suckerCount = fireHoleSuckerCount
		newFireHole.suckerScale = fireHoleSuckerScale
		newFireHole.rotationSpeed = fireHoleRotationSpeed
		newFireHole.player = self
		
		arena.get_node("World/Holes").add_child(newFireHole)
		fireTimer.start()
		grenadeBar.show()

func update_stats():
	var oldMouse
	var oldFireTime = fireTimer.wait_time
	var oldRegenTime = regenTimer.wait_time
	
	#Add max health gain to current health
	health += arena.maxHealth[maxHealthLevel] - maxHealth
	
	#Levels
	speed = arena.movementSpeed[speedLevel]
	maxHealth = arena.maxHealth[maxHealthLevel]
	regenTimer.wait_time = arena.healthRegenSpeed[healthRegenSpeedLevel]
	suckerScale = arena.mainSuckerRange[mainSuckerRangeLevel]
	suckerCount = arena.mainSuckerCount[mainSuckerCountLevel]
	grenadeFireSpeed = arena.grenadeFireSpeed[grenadeFireSpeedLevel]
	grenadeSuckerCount = arena.grenadeSuckerCount[grenadeSuckerCountLevel]
	grenadeSuckerScale = arena.grenadeSuckerRange[grenadeSuckerRangeLevel]
	grenadeRotationSpeed = arena.grenadeRotationSpeed[grenadeRotationSpeedLevel]
	mouseHoleSpeed = arena.mouseHoleSpeed[mouseHoleSpeedLevel]
	mouseHoleSuckerCount = arena.mouseHoleSuckerCount[mouseHoleSuckerCountLevel]
	mouseHoleSuckerScale = arena.mouseHoleSuckerRange[mouseHoleSuckerRangeLevel]
	mouseHoleRotationSpeed = arena.mouseHoleRotationSpeed[mouseHoleRotationSpeedLevel]
	fireHoleFiringSpeed = arena.fireHoleFiringSpeed[fireHoleFiringSpeedLevel]
	fireHoleSuckerCount = arena.fireHoleSuckerCount[fireHoleSuckerCountLevel]
	fireHoleSuckerScale = arena.fireHoleSuckerRange[fireHoleSuckerRangeLevel]
	fireHoleRotationSpeed = arena.fireHoleRotationSpeed[fireHoleRotationSpeedLevel]
	
	#boosted mode
	if boosted:
		speed *= 1.5
		regenTimer.wait_time /= 1.5
		suckerScale *= 1.5
		suckerCount += 1
		grenadeFireSpeed /= 1.5
		grenadeSuckerCount += 1
		grenadeSuckerScale *= 1.5
		grenadeRotationSpeed *= 1.5
		mouseHoleSpeed *= 1.5
		mouseHoleSuckerCount += 1
		mouseHoleSuckerScale *= 1.5
		mouseHoleRotationSpeed *= 1.5
		fireHoleFiringSpeed /= 1.5
		fireHoleSuckerCount += 1
		fireHoleSuckerScale *= 1.5
		fireHoleRotationSpeed *= 1.5
		playerBody.get_node("PlayerHitbox").visible = false
		playerBody.get_node("PlayerHitbox").monitoring = false
	else:
		playerBody.get_node("PlayerHitbox").visible = true
		playerBody.get_node("PlayerHitbox").monitoring = true
		
	if playerDisabled:
		suckerCount = 0
		mouseHoleSuckerCount = 0
		
	
	for child in suckers.get_children():
		if(child.is_in_group("Sucker")):
			child.queue_free()
	
	for node in arena.get_node("World").get_node("Holes").get_children():
		if node.is_in_group("Mouse Hole"):
			oldMouse = node
			if !mouseHoleEnabled:
				node.queue_free()
	
	#Suckers
	for n in range(0, suckerCount):
		var newSucker = sucker.instantiate()
		
		newSucker.rotation = (radFull/suckerCount)*n
		
		suckers.add_child.call_deferred(newSucker)
	suckers.scale.x = suckerScale
	suckers.scale.y = suckerScale
	
	#Grenade/FireHole
	if(grenadeEnabled):
		fireTimer.wait_time = grenadeFireSpeed
	elif(fireHoleEnabled):
		fireTimer.wait_time = fireHoleFiringSpeed
	
	#Mouse hole
	if(mouseHoleEnabled):
		if oldMouse != null:
			oldMouse.speed = mouseHoleSpeed
			oldMouse.suckerCount = mouseHoleSuckerCount
			oldMouse.suckerScale = mouseHoleSuckerScale
			oldMouse.rotationSpeed = mouseHoleRotationSpeed
			
			oldMouse.update_stats()
		else:
			var newMouseHole = mouseHole.instantiate()
			
			newMouseHole.speed = mouseHoleSpeed
			newMouseHole.suckerCount = mouseHoleSuckerCount
			newMouseHole.suckerScale = mouseHoleSuckerScale
			newMouseHole.rotationSpeed = mouseHoleRotationSpeed
			newMouseHole.position = global_position
			newMouseHole.holeRotation = randf_range(0, radFull)
			
			arena.get_node("World/Holes").add_child.call_deferred(newMouseHole)
	
	if oldFireTime != fireTimer.wait_time:
		fireTimer.stop()
		_on_fire_timer_timeout()
	
	if oldRegenTime != regenTimer.wait_time:
		regenTimer.stop()
		_on_regen_timer_timeout()
	
	updateHealthLabel()
	updateXpLabel()
	
func level_up():
	level += 1
	xp -= levelUpXp
	levelUpXp = (level) * 50
	updateXpLabel()
	
	arena.get_node("LevelUpOverlay").add_child(levelUpScreen.instantiate())
	
func damage_player(damage):
	if hitTimer.time_left == 0:
		regenBar.show()
		
		playerBody.hitAnimator.play("HitAnimation")
		
		health -= damage
		if(health <= 0):
			die()
		
		updateHealthLabel()
		
		hitTimer.start()
		if(regenTimer.is_stopped()):
			regenTimer.start()

func die():
	print("Death has taken ye")

func _on_regen_timer_timeout():
	health += 1
	updateHealthLabel()
	if health >= maxHealth:
		regenBar.hide()
		regenTimer.stop()

func updateHealthLabel():
	healthLabel.text = str(health) + "/" + str(maxHealth)
	healthBar.value = ((health * 1.0) / maxHealth) * 100

func updateXpLabel():
	levelLabel.text = "Lvl: " + str(level)
	xpBar.value = ((xp * 1.0) / (levelUpXp*1.0) * 100.0)

func _on_level_up_timer_timeout():
	level_up()
	
func toggleSuckers(disabledYes):
	playerDisabled = disabledYes
	
	if disabledYes:
		for node in arena.get_node("World/Holes").get_children():
			if node.is_in_group("GrenadeHole"):
				node.deleteHole()
		
		for node in arena.get_node("World/Player Bullets").get_children():
			if node.is_in_group("Grenade"):
				node.SPEED = 0
				node.particles.emitting = false
				node.fader.play("GrenadeFade")
	
	update_stats()

func boost():
	boosted = true
	update_stats()
	boostTimer.start()
	boostBar.show()

func _on_fire_timer_timeout():
	grenadeBar.hide()

func _on_boost_mode_timer_timeout():
	boosted = false
	update_stats()
	boostBar.hide()
