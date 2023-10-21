extends "res://Scenes/Interface/UpgradeButtons/upgrade_button.gd"

func _on_pressed():
	player.grenadeRotationSpeedLevel += 1
	levelUpWindow.closeMenu(levelUpWindow.ButtonUnlocks.GRENADE)
	disabled = true
