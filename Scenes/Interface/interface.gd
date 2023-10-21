extends Control

var time = 0

@onready var timeLabel = get_node("TimeLabel")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	timeLabel.text = ("%02d" % (time/60)) + ":" + ("%02d" % (int(floor(time)) % 60))
