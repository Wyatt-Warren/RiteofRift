extends Area2D

const SPEED = 150
const damage = 1

@onready var arena = get_parent().get_parent().get_parent()
@onready var animator = get_node("AnimationPlayer")
@onready var rotator = get_node("Rotator")
@onready var collision = get_node("CollisionPolygon2D")

var target = Vector2()
var speedMultiplier = 1

func _ready():
	if randi_range(0,1) == 1:
		rotator.play_backwards("RotateBullet")

func _process(delta):
	position.x += target.x * SPEED * delta * speedMultiplier
	position.y += target.y * SPEED * delta * speedMultiplier

func _on_timer_timeout():
	bullet_delete()

func _on_animation_player_animation_finished(anim_name):
	queue_free()
	
func bullet_delete():
	collision.set_deferred("disabled", true)
	arena.bullets -= 1
	animator.play("Disappear")

func _on_body_entered(body):
	if body.is_in_group("BossWalls"):
		bullet_delete()
