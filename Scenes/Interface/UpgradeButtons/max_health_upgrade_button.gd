extends "res://Scenes/Interface/UpgradeButtons/upgrade_button.gd"

func _on_pressed():
	player.maxHealthLevel += 1
	levelUpWindow.closeMenu(levelUpWindow.ButtonUnlocks.BASIC)
	disabled = true
