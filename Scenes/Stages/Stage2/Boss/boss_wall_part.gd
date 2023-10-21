extends Node2D

@onready var bouncer = get_node("Bouncer")
@onready var startTimer = get_node("StartTimer")
@onready var grower = get_node("Grower")

func _ready():
	randomize()
	startTimer.wait_time = randf_range(0, startTimer.wait_time)
	startTimer.start()

func _on_grower_animation_finished(anim_name):
	bouncer.play("BounceWallPart")


func _on_start_timer_timeout():
	grower.play("GrowWallPart")
