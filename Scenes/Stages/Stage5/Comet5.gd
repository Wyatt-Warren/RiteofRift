extends Area2D

const SPEED = 600
const damage = 1

@onready var arena = get_parent().get_parent().get_parent()
@onready var player = arena.player
@onready var damageTimer = get_node("DamageTimer")
@onready var rotator = get_node("Rotator")

var target = Vector2()
var speedMultiplier = 1

func _ready():
	if randi_range(0,1) == 1:
		rotator.play_backwards("SpinComet")

func _process(delta):
	position.x += target.x * SPEED * delta * speedMultiplier
	position.y += target.y * SPEED * delta * speedMultiplier
	
	if damageTimer.is_stopped():
		for area in get_overlapping_areas():
			if area.is_in_group("PlayerHitbox") && !player.boosted:
				player.damage_player(damage)
				damageTimer.start()
	
	if Vector2(player.global_position).distance_to(Vector2(global_position)) > 1500:
		queue_free()
