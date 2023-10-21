extends Node2D

const tweenDuration = 0.3

@onready var sprite = get_node("Sprite2D")
@onready var posTween = create_tween()
@onready var rotTween = create_tween()
@onready var scaleTween = create_tween()
@onready var modTween = create_tween()

func _ready():
	randomize()
	
	posTween.tween_property(sprite, "position", Vector2(randi_range(-20, 20), randi_range(-20, 20)), tweenDuration)
	posTween.tween_callback(queue_free)
	
	rotTween.tween_property(sprite, "rotation",  deg_to_rad(randf_range(-180, 180)), tweenDuration)
	rotTween.tween_callback(queue_free)
	
	scaleTween.tween_property(sprite, "scale", Vector2(0, 0), tweenDuration)
	scaleTween.tween_callback(queue_free)
	
	modTween.tween_property(sprite, "modulate", Color.BLACK, tweenDuration)
	modTween.tween_callback(queue_free)
