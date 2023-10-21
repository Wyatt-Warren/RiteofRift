extends Button

func _process(delta):
	if !disabled && is_hovered():
		grab_focus()
