extends "res://Scenes/Interface/UpgradeButtons/upgrade_button.gd"

func _on_pressed():
	player.mouseHoleRotationSpeedLevel += 1
	levelUpWindow.closeMenu(levelUpWindow.ButtonUnlocks.MOUSEHOLE)
	disabled = true
