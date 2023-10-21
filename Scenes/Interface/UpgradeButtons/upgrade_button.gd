extends Button

@onready var levelUpWindow = get_parent().get_parent().get_parent()
@onready var player = levelUpWindow.player

func _process(delta):
	if is_hovered():
		grab_focus()
