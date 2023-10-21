extends Sprite2D

@onready var flipper = get_node("Flipper")

func flipHorizontal(flipped):
	if !flipper.is_playing():
		if flipped && !flip_h:
			flipper.play("FlipHorizontalOn")
		elif !flipped && flip_h:
			flipper.play("FlipHorizontalOff")


func _on_flipper_animation_finished(anim_name):
	if anim_name == "FlipHorizontalOn":
		flip_h = true
	else:
		flip_h = false
