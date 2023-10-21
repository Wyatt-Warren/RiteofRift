extends CharacterBody2D

const joystickDeadzone = 0.5
const mouseDeadzone = 20

var motion = Vector2()
var lastInputMouse = true
var holeRotation

@export var grenadeHole: PackedScene
@onready var player = get_parent().get_parent().get_parent().get_node("World").get_node("Player")

var hole

#stats
var speed = 0
var suckerCount = 0
var rotationSpeed = 0
var suckerScale = 0

func _ready():
	hole = grenadeHole.instantiate()
	hole.player = player
	add_child(hole)
	hole.get_node("Timer").stop()
	hole.suckers.rotation = holeRotation
	
	update_stats()

func _unhandled_input(event):
	
	if event is InputEventJoypadMotion:
		lastInputMouse = false
		var horizontal = Input.get_action_strength("Look_Right") - Input.get_action_strength("Look_Left")
		var vertical = Input.get_action_strength("Look_Down") - Input.get_action_strength("Look_Up")
		if abs(horizontal) > joystickDeadzone or abs(vertical) > joystickDeadzone:
			velocity = velocity.lerp(Vector2(horizontal, vertical) * speed, 0.2)
	
	elif event is InputEventMouseMotion:
		lastInputMouse = true
		mouse_mouse()

func _process(delta):
	mouse_mouse()
	move_and_slide()
	
	#If somehow it leaves the area of the camera, move it back in.
	if global_position.x > player.global_position.x + get_viewport_rect().size.x/2:
		global_position.x = player.global_position.x + get_viewport_rect().size.x/2 - 1
	elif global_position.x < player.global_position.x - get_viewport_rect().size.x/2:
		global_position.x = player.global_position.x - get_viewport_rect().size.x/2 - 1
	
	#Same thing but for y
	if global_position.y > player.global_position.y + get_viewport_rect().size.y/2:
		global_position.y = player.global_position.y + get_viewport_rect().size.y/2 - 1
	elif global_position.y < player.global_position.y - get_viewport_rect().size.y/2:
		global_position.y = player.global_position.y - get_viewport_rect().size.y/2 - 1
	
func mouse_mouse():
	var newSpeed = speed
	if global_position.distance_to(get_global_mouse_position()) < 5:
		newSpeed = speed/10.0
		
	motion = (get_global_mouse_position() - global_position).normalized()
	velocity = velocity.lerp(motion * newSpeed, 0.4)

func update_stats():
	hole.suckerCount = suckerCount
	hole.rotationSpeed = rotationSpeed
	hole.suckerScale = suckerScale
	
	hole.update_stats()
