extends Area2D

const SPEED = 150

@onready var shrinker = get_node("Shrinker")
@onready var collision = get_node("CollisionShape2D")

var target = Vector2()

func _process(delta):
	for n in get_overlapping_areas():
		if n.is_in_group("PlayerHitbox"):
			n.get_parent().get_parent().slowTimer.start()
			
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta

func _on_timer_timeout():
	bullet_delete()

func bullet_delete():
	collision.set_deferred("disabled", true)
	shrinker.play("Disappear")

func _on_shrinker_animation_finished(anim_name):
	queue_free()
