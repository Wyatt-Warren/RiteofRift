extends "res://Scenes/Interface/UpgradeButtons/upgrade_button.gd"

func _on_pressed():
	player.fireHoleRotationSpeedLevel += 1
	levelUpWindow.closeMenu(levelUpWindow.ButtonUnlocks.FIREHOLE)
	disabled = true
