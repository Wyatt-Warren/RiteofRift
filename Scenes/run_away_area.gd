extends Area2D

var lerpWeight = 0.7

func _on_timer_timeout():
	for body in get_overlapping_bodies():
		if(body.is_in_group("Enemy") && body.has_method("move")):
			body.move(self, -1, lerpWeight)
