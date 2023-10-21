extends Node2D

@onready var enemyContainer = get_parent().get_parent().get_node("Enemies")
@onready var sprite = get_node("Icon")

func _process(delta):
	var bossExists = false
	
	for node in enemyContainer.get_children():
		if node.is_in_group("Boss"):
			var bossVector = node.global_position - global_position
			
			bossExists = true
			
			if bossVector.length() < 500:
				sprite.visible = false
			else:
				sprite.visible = true
			
			rotation = bossVector.angle()
	
	if !bossExists:
		sprite.visible = false
