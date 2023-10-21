extends RigidBody2D

const xp = 2

@onready var arena = get_parent().get_parent().get_parent()
@onready var particles = get_node("CPUParticles2D")
@onready var sprite = get_node("EnemySprite")
@onready var particleTimer = get_node("ParticleTimer")
@onready var animator = get_node("AnimationPlayer")

@export var baby: PackedScene

func _ready():
	animator.advance(randf_range(0,  animator.current_animation_length))

func _on_hatch_timer_timeout():
	pop()
	var newEnemy = baby.instantiate()
	
	newEnemy.position = global_position
	
	arena.enemyContainer.add_child(newEnemy)

func pop():
	sprite.visible = false
	particles.emitting = true
	particleTimer.start()

func _on_particle_timer_timeout():
	queue_free()
