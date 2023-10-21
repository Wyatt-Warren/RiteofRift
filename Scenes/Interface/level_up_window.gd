extends Control

const grenadeUnlockLevel = 10
const mouseUnlockLevel = 20
const fireHoleUnlockLevel = 30
const optionCount = 3

enum ButtonUnlocks {
	BASIC,
	GRENADE,
	MOUSEHOLE,
	FIREHOLE
}

@onready var arena = get_parent().get_parent()
@onready var player = arena.get_node("World").get_node("Player")
@onready var mainBox = get_node("HBoxContainer")
@onready var upgradeBox = get_node("HBoxContainer/UpgradeBox")
@onready var grenadeButton = get_node("HBoxContainer/UnlockBox/GrenadeButton")
@onready var mouseHoleButton = get_node("HBoxContainer/UnlockBox/MouseHoleButton")
@onready var fireHoleButton = get_node("HBoxContainer/UnlockBox/FireHoleButton")
@onready var particles = get_node("CPUParticles2D")
@onready var spinningGrenade = get_node("HBoxContainer/UnlockBox/GrenadeButton/SpinningGrenadeRune")
@onready var spinningMouse = get_node("HBoxContainer/UnlockBox/MouseHoleButton/SpinningeMouseHoleRune")
@onready var spinningFire = get_node("HBoxContainer/UnlockBox/FireHoleButton/SpinningFireHoleRune")
@onready var grenadeAnimator = get_node("GrenadeAnimator")
@onready var mouseAnimator = get_node("MouseAnimator")
@onready var fireAnimator = get_node("FireAnimator")

@onready var basicTexture = preload("res://Assets/UI/Level Up Screen/BasicRuneBig.png")
@onready var grenadeTexture = preload("res://Assets/UI/Level Up Screen/ShotRuneBig.png")
@onready var mouseHoleTexture = preload("res://Assets/UI/Level Up Screen/CloneRuneBig.png")
@onready var fireHoleTexture = preload("res://Assets/UI/Level Up Screen/LaunchRuneBig.png")
@onready var blankTexture = preload("res://Assets/UI/Level Up Screen/BlankRune.png")

@export var maxHealthButton: PackedScene
@export var healthRegenSpeedButton: PackedScene
@export var movementSpeedButton: PackedScene
@export var suckerCountButton: PackedScene
@export var suckerRangeButton: PackedScene
@export var grenadeFireSpeedButton: PackedScene
@export var grenadeRotationSpeedButton: PackedScene
@export var grenadeSuckerCountButon: PackedScene
@export var grenadeSuckerRangeButton: PackedScene
@export var mouseHoleRotationButton: PackedScene
@export var mouseHoleSpeedButton: PackedScene
@export var mouseHoleSuckerCountButton: PackedScene
@export var mouseHoleSuckerRangeButton: PackedScene
@export var fireHoleRotationButton: PackedScene
@export var fireHoleFireSpeedButton: PackedScene
@export var fireHoleSuckerCountButton: PackedScene
@export var fireHoleSuckerRangeButton: PackedScene
@export var levelUpRune: PackedScene

func _ready():
	randomize()
	get_tree().paused = true
	visible = true
	
	for button in upgradeBox.get_children():
		button.queue_free()
	
	if player.level >= fireHoleUnlockLevel:
		fireHoleButton.text = "Rift Launch  "
		fireHoleButton.disabled = false
		fireHoleButton.focus_mode = FocusMode.FOCUS_ALL
		fireHoleButton.icon = blankTexture
		spinningFire.visible = true
	else:
		fireHoleButton.text = "Unlocks at level " + str(fireHoleUnlockLevel) + "  "
		fireHoleButton.disabled = true
		fireHoleButton.focus_mode = FocusMode.FOCUS_NONE
			
	if player.level >= mouseUnlockLevel:
		mouseHoleButton.text = "Rift Clone  "
		mouseHoleButton.disabled = false
		mouseHoleButton.focus_mode = FocusMode.FOCUS_ALL
		mouseHoleButton.icon = blankTexture
		spinningMouse.visible = true
	else:
		mouseHoleButton.text = "Unlocks at level " + str(mouseUnlockLevel) + "  "
		mouseHoleButton.disabled = true
		mouseHoleButton.focus_mode = FocusMode.FOCUS_NONE
			
	if player.level >= grenadeUnlockLevel:
		grenadeButton.text = "Rift Shot  "
		grenadeButton.disabled = false
		grenadeButton.focus_mode = FocusMode.FOCUS_ALL
		grenadeButton.icon = blankTexture
		spinningGrenade.visible = true
	else:
		grenadeButton.text = "Unlocks at level " + str(grenadeUnlockLevel) + "  "
		grenadeButton.disabled = true
		grenadeButton.focus_mode = FocusMode.FOCUS_NONE
	
	if player.fireHoleEnabled:
		fireAnimator.queue_free()
		mouseAnimator.queue_free()
		grenadeAnimator.queue_free()
		fireHoleButton.queue_free()
		mouseHoleButton.queue_free()
		grenadeButton.queue_free()
	elif player.mouseHoleEnabled:
		mouseAnimator.queue_free()
		grenadeAnimator.queue_free()
		mouseHoleButton.queue_free()
		grenadeButton.queue_free()
	elif player.grenadeEnabled:
		grenadeAnimator.queue_free()
		grenadeButton.queue_free()
	
	var baseButtons = [maxHealthButton.instantiate(), healthRegenSpeedButton.instantiate(), movementSpeedButton.instantiate(), suckerCountButton.instantiate(), suckerRangeButton.instantiate()] 
	var grenadeButtons = [grenadeFireSpeedButton.instantiate(), grenadeRotationSpeedButton.instantiate(), grenadeSuckerCountButon.instantiate(), grenadeSuckerRangeButton.instantiate()]
	var mouseButtons = [mouseHoleRotationButton.instantiate(), mouseHoleSpeedButton.instantiate(), mouseHoleSuckerCountButton.instantiate(), mouseHoleSuckerRangeButton.instantiate()]
	var fireButtons = [fireHoleRotationButton.instantiate(), fireHoleFireSpeedButton.instantiate(), fireHoleSuckerCountButton.instantiate(), fireHoleSuckerRangeButton.instantiate()]

	var baseLevels = [player.maxHealthLevel, player.healthRegenSpeedLevel, player.speedLevel, player.mainSuckerCountLevel, player.mainSuckerRangeLevel]
	var grenadeLevels = [player.grenadeFireSpeedLevel, player.grenadeRotationSpeedLevel, player.grenadeSuckerCountLevel, player.grenadeSuckerRangeLevel]
	var mouseLevels = [player.mouseHoleRotationSpeedLevel, player.mouseHoleSpeedLevel, player.mouseHoleSuckerCountLevel, player.mouseHoleSuckerRangeLevel]
	var fireLevels = [player.fireHoleRotationSpeedLevel, player.fireHoleFiringSpeedLevel, player.fireHoleSuckerCountLevel, player.fireHoleSuckerRangeLevel]
	
	var potentialButtons = []
	
	for n in range(0,5):
		if baseLevels[n] < 4:
			potentialButtons.append(baseButtons[n])
			
	if player.grenadeEnabled:
		for n in range(0,4):
			if grenadeLevels[n] < 4:
				potentialButtons.append(grenadeButtons[n])
	
	if player.mouseHoleEnabled:
		for n in range(0,4):
			if mouseLevels[n] < 4:
				potentialButtons.append(mouseButtons[n])
				
	if player.fireHoleEnabled:
		for n in range(0,4):
			if fireLevels[n] < 4:
				potentialButtons.append(fireButtons[n])
	
	for n in range(0,optionCount):
		if potentialButtons.size() == 0:
			break;
			
		var randInt = randi() % potentialButtons.size()
		upgradeBox.add_child(potentialButtons[randInt])
		potentialButtons.remove_at(randInt)
	
	for n in range(0, optionCount):
		if n-1 >= 0:
			upgradeBox.get_children()[n].focus_neighbor_top = upgradeBox.get_children()[n-1].get_path()
		if n+1 < upgradeBox.get_children().size():
			upgradeBox.get_children()[n].focus_neighbor_bottom = upgradeBox.get_children()[n+1].get_path()
		
	
	if upgradeBox.get_children().size() != 0:
		upgradeBox.get_children()[0].grab_focus()

func closeMenu(buttonType):
	if grenadeAnimator != null:
		grenadeAnimator.stop()
	if mouseAnimator != null:
		mouseAnimator.stop()
	if fireAnimator != null:
		fireAnimator.stop()
	mainBox.queue_free()
	var newRune = levelUpRune.instantiate()
	
	if buttonType == ButtonUnlocks.BASIC:
		newRune.texture = basicTexture
	elif buttonType == ButtonUnlocks.GRENADE:
		newRune.texture = grenadeTexture
	elif buttonType == ButtonUnlocks.MOUSEHOLE:
		newRune.texture = mouseHoleTexture
	elif buttonType == ButtonUnlocks.FIREHOLE:
		newRune.texture = fireHoleTexture
	
	newRune.position = Vector2(960, 540)
	add_child(newRune)
	
	newRune.get_node("AnimationPlayer").play("SpinRune")

func reallyCloseMenu():
	get_tree().paused = false
	visible = false
	
	queue_free()
	player.update_stats()
	
	if player.xp >= player.levelUpXp:
		player.levelUpTimer.start()

func _on_grenade_button_pressed():
	player.grenadeEnabled = true
	player.mouseHoleEnabled = false
	player.fireHoleEnabled = false
	closeMenu(ButtonUnlocks.GRENADE)
	
func _on_mouse_hole_button_pressed():
	player.grenadeEnabled = false
	player.mouseHoleEnabled = true
	player.fireHoleEnabled = false
	closeMenu(ButtonUnlocks.MOUSEHOLE)

func _on_fire_hole_button_pressed():
	player.grenadeEnabled = false
	player.mouseHoleEnabled = false
	player.fireHoleEnabled = true
	closeMenu(ButtonUnlocks.FIREHOLE)

func _on_particle_timer_timeout():
	particles.emitting = false
