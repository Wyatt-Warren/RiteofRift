extends Area2D

const SPEED = 210

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var timer = get_node("Timer")
@onready var deleteTimer = get_node("DeleteTimer")
@onready var sprite = get_node("Sprite2D")
@onready var collision = get_node("CollisionShape2D")
@onready var particles = get_node("CPUParticles2D")

@export var iceArea: PackedScene

var target = Vector2()
var disableEffect = false

func _process(delta):
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta
	
	for area in get_overlapping_areas():
			if area.is_in_group("PlayerHitbox") && !player.boosted:
				timer.stop()
				_on_timer_timeout()

func _on_timer_timeout():
	if !disableEffect:
		var newIce = iceArea.instantiate()
		
		newIce.position = position
		
		arena.get_node("World/FireIces").add_child(newIce)
	
	particles.emitting = false
	sprite.visible = false
	collision.set_deferred("disabled", true)
	deleteTimer.start()
	
func _on_delete_timer_timeout():
	queue_free()


