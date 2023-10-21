extends Area2D

const radFull = 2*PI
var SPEED = 480

var target = Vector2()
var notHit = true #Sometimes the grenade hits two guys at once, spawning two grenade holes. This should only allow one to be created per grenade
var collidable = false #Set by a timer so that the grenade doesnt land on an enemy as soon as it appears
var suckerCount = 0
var suckerScale = 0
var rotationSpeed = 0

@onready var arena = get_parent().get_parent().get_parent()
@onready var fader = get_node("FadeAwayAnimator")
@onready var particles = get_node("Particles")
@export var grenadeHole: PackedScene

var player

func _ready():
	randomize()

func _process(delta):
	position.x += target.x * SPEED * delta
	position.y += target.y * SPEED * delta
	
func _on_body_entered(body):
	if(!body.is_in_group("player") && notHit && collidable):
		notHit = false
		var new_hole = grenadeHole.instantiate()
		
		new_hole.position = global_position
		new_hole.suckerCount = suckerCount
		new_hole.suckerScale = suckerScale
		new_hole.rotationSpeed = rotationSpeed
		new_hole.player = player
		new_hole.get_node("Suckers").rotation = (body.global_position - global_position).angle()
		
		arena.get_node("World").get_node("Holes").call_deferred("add_child", new_hole)
		
		SPEED = 0
		particles.emitting = false
		fader.play("GrenadeFade")

func _on_area_entered(area):
	if((area.is_in_group("EnemyHitbox") || area.is_in_group("BossHitbox")) && notHit && collidable):
		notHit = false
		var new_hole = grenadeHole.instantiate()
		
		new_hole.position = global_position
		new_hole.suckerCount = suckerCount
		new_hole.suckerScale = suckerScale
		new_hole.rotationSpeed = rotationSpeed
		new_hole.player = player
		new_hole.get_node("Suckers").rotation = (area.get_parent().global_position - global_position).angle()
		
		arena.get_node("World").get_node("Holes").call_deferred("add_child", new_hole)
		
		SPEED = 0
		particles.emitting = false
		fader.play("GrenadeFade")

func _on_despawn_timer_timeout():
	SPEED = 0
	particles.emitting = false
	fader.play("GrenadeFade")


func _on_collidable_timer_timeout():
	collidable = true


func _on_fade_away_animator_animation_finished(anim_name):
	queue_free()

