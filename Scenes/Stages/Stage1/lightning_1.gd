extends Area2D

const damage = 2

@onready var hurtTimer = get_node("HurtTimer")
@onready var particles = get_node("CPUParticles2D")
@onready var arena =  get_parent().get_parent().get_parent()
@onready var player = arena.player

var bigAmount = 100
var hurting = false

func _physics_process(delta):
	if hurting:
		for area in get_overlapping_areas():
			if area.is_in_group("PlayerHitbox") && !player.boosted:
				player.damage_player(damage)

func _on_pre_timer_timeout():
	hurtTimer.start()
	particles.amount = bigAmount
	hurting = true

func _on_hurt_timer_timeout():
	queue_free()
	
func changeScale(lightningScale):
	scale.x = lightningScale
	scale.y = lightningScale
	
	particles.amount *= lightningScale
	bigAmount *= lightningScale

