extends Area2D

const radFull = 2*PI

signal enemy_eaten

var suckerCount = 0
var rotationSpeed = 0
var suckerScale = 0

@export var sucker: PackedScene
@export var faller: PackedScene

@onready var suckers = get_node("Suckers")
@onready var shrink = get_node("ShrinkAnimation")
@onready var fallers = get_node("Fallers")

var player

func _ready():
	update_stats()
	

func _process(delta):
	suckers.rotation_degrees += rotationSpeed * delta

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		var newFaller = faller.instantiate()
		var totalRotation = body.rotation + body.get_node("EnemySprite").rotation
		
		newFaller.get_node("Sprite2D").rotation = totalRotation
		newFaller.get_node("Sprite2D").texture = body.get_node("EnemySprite").texture
		newFaller.get_node("Sprite2D").flip_h = body.get_node("EnemySprite").flip_h
		newFaller.get_node("Sprite2D").position = body.get_node("EnemySprite").global_position - global_position
		newFaller.get_node("Sprite2D").scale = body.get_node("EnemySprite").scale
		newFaller.get_node("Sprite2D").modulate = body.get_node("EnemySprite").modulate
		
		fallers.add_child(newFaller)
		
		newFaller.posTween.play()
		newFaller.rotTween.play()
		newFaller.scaleTween.play()
		newFaller.modTween.play()
		
		if body.has_method("safeDelete"):
			body.safeDelete()
		else:
			body.queue_free()
			
		player._on_player_body_enemy_eaten(body)

func _on_timer_timeout():
	deleteHole()
	
func update_stats():
	for child in suckers.get_children():
		if(child.is_in_group("Sucker")):
			child.queue_free()
	
	for n in range(0, suckerCount):
		var newSucker = sucker.instantiate()
		
		newSucker.rotation = (radFull/suckerCount)*n
		
		suckers.add_child.call_deferred(newSucker)
		
	suckers.scale.x = suckerScale
	suckers.scale.y = suckerScale

func _on_shrink_animation_animation_finished(anim_name):
	queue_free()

func deleteHole():
	for oldSucker in suckers.get_children():
		if oldSucker.is_in_group("Sucker"):
			oldSucker.get_node("CPUParticles2D").emitting = false
			
	shrink.play("HoleShrinkDisappear")
