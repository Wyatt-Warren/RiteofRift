extends Area2D

signal enemy_eaten
signal got_shot

@export var faller: PackedScene

@onready var fallers = get_node("Fallers")
@onready var hitAnimator = get_node("PlayerHitbox/HitAnimation")

func _on_player_hitbox_area_entered(area):
	if area.is_in_group("Bullet"):
		
		area.bullet_delete()
		got_shot.emit(area.damage)

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
		
		enemy_eaten.emit(body)
