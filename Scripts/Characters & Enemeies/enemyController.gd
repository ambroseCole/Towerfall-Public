extends CharacterBody2D

@onready var player = get_node("/root/Node2D/CharacterBody2D")
var playerInSight : bool = false
@export var speed = 200
@onready var timer = $Timer
var attacking = false
@export var health = 1
@export var expValue = 0
@export var goldValue = 0
@onready var healthBar = get_node("/root/Node2D/Camera2D/Control2/UI_Layer/healthBar")
var parryable = false
var parried = false
var new_velocity = Vector2(0,0)
@export var pushback_speed: float = 150
@export var damage = 20
@onready var soundplayer = $AudioStreamPlayer
var attackSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/10_Battle_SFX/03_Claw_03.wav")
var dieSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/10_Battle_SFX/15_Impact_flesh_02.wav")
@export var pushback_complete_distance: float = 0.5
@export var use_constant_speed: bool = true
@export var lerp_weight: float = 5
var target_position: Vector2 = Vector2.ZERO
var is_being_pushed = false

func _ready():
	add_to_group("enemies")
	
#Check if can see player
func _process(delta):
	if is_instance_valid(player): sightCheck()
	if is_being_pushed:
		if use_constant_speed:
			position += position.direction_to(target_position) * pushback_speed  * delta * 2
		else:
			position = lerp(position, target_position, lerp_weight * delta * 2)
			
		if (position.distance_to(target_position) < pushback_complete_distance):
			position = target_position
			is_being_pushed = false
	
#handle movement physics
func _physics_process(delta):
	if playerInSight and is_instance_valid(player) and not parried and player.modulate == Color("ffffff"):
		new_velocity = global_position.direction_to(player.global_position)
		if new_velocity.x < 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
		var collide = move_and_collide(new_velocity * speed * delta)
		if not attacking and not collide:
			$AnimatedSprite2D.animation = "move"
		if collide and collide.get_collider() == player and not attacking:
			attack()
	elif playerInSight and is_instance_valid(player) and parried:
		move_and_collide(velocity * speed * delta)
	else:
		$AnimatedSprite2D.animation = "default"

#Check if player in line of sight
func sightCheck():
	
	if global_position.distance_to(player.global_position) < 10000:
		var space_state = get_world_2d().direct_space_state
		var params = PhysicsRayQueryParameters2D.create(global_position, player.position)

		params.exclude = [self]

		params.collision_mask = 1
		var sight_check = space_state.intersect_ray(params)
		if sight_check.has('collider') and sight_check.collider.name == "CharacterBody2D" and player.modulate == Color("ffffff"):
			playerInSight = true
		else:
			pass
	else:
		pass


#Attack player, will replace timers with anims soon
func attack():
	parried = false
	print_debug("attacking")
	attacking = true
	$AnimatedSprite2D.animation = "attack"
	parryable = true
	timer.start(0.3)
	speed *= 0.5
	await timer.timeout
	soundplayer.stream = attackSound
	soundplayer.play()
	timer.start(0.7)
	await timer.timeout
	parryable = false
	if player in $Area2D.get_overlapping_bodies() and not parried and not player.guarding:
		player.health -= damage
		if player.health <= 0:
			player.die()
		else:
			healthBar.update(player.health)
	elif parried:
		$RichTextLabel.text = "Parried!"
		$RichTextLabel.visible = true
		stunned()
	elif player.guarding:
		$RichTextLabel.text = "Blocked!"
		$RichTextLabel.visible = true
		stunned()
	timer.start(0.25)
	await timer.timeout
	parried = false
	$AnimatedSprite2D.animation = "move"
	timer.start(1)
	speed *= 2
	await timer.timeout
	attacking = false
	
#Delete on death
func onDie(giveLoot):
	soundplayer.stream = dieSound
	soundplayer.play()
	if giveLoot:
		player.coins += goldValue
		player.exper = player.exper + expValue
	self.queue_free()


func stunned(length=0.7):
	$Timer2.start(length)
	speed = 0
	attacking = true
	await $Timer2.timeout
	$RichTextLabel.visible = false
	speed = 200
	attacking = false


func on_arrow(dir, str):
	target_position = position - dir * str
	is_being_pushed = true
	
