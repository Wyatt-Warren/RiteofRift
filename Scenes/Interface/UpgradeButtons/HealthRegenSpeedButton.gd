extends "res://Scenes/Interface/UpgradeButtons/upgrade_button.gd"

func _on_pressed():
	player.healthRegenSpeedLevel += 1
	levelUpWindow.closeMenu(levelUpWindow.ButtonUnlocks.BASIC)
	disabled = true
