extends Area2D


@onready var arena = get_parent().get_parent().get_parent()
@onready var animator = get_node("AnimationPlayer")

var damage = 3
var maxSpeed = 9.5
var accel = 0.07
var target = Vector2()
var actualSpeed = 0
var turnDegrees = 0
var turned = 0
var maxTurned = 0

func _physics_process(delta):
	if actualSpeed < maxSpeed:
		actualSpeed += accel
		if actualSpeed > maxSpeed:
			actualSpeed = maxSpeed
	
	position.x += target.x * actualSpeed
	position.y += target.y * actualSpeed
	
	if turned < maxTurned:
		target = target.rotated(turnDegrees)
		turned += abs(turnDegrees)

func _on_timer_timeout():
	bullet_delete()
	
func bullet_delete():
	set_deferred("monitoring", false)
	arena.bullets -= 1
	animator.play("Disappear")

func _on_body_entered(body):
	if body.is_in_group("BossWalls"):
		bullet_delete()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
