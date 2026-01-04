extends CharacterBody2D

#class_name playerClass

var input = Vector2()
var last_direction = Vector2.ZERO
var guarding = false
@export var current_room = []
@onready var camera = %Camera2D
@onready var SlashAnim = $SlashAnim
@onready var slashMarker = $Marker2D
@onready var healthBar = %healthBar
@onready var expBar = %expBar
@export var speed := 750.0
@export var friction := 0.6
@export var acceleration := 0.6
@export var health := 100.0
@export var max_health := 100.0
@export var abilities = []
@onready var levels = %Levels
@export var coins = 0 : set = set_coins
@export var damage = 1
@export var attackSpeed = 1
@onready var GameManager = get_node("/root/GameManager")
@export var chosenGod = ""
@export var exper = 0 : set = set_exp
@onready var timer1 = $slot1
@onready var timer2 = $slot2
@onready var meleeTimer = $Melee
@onready var timers = [timer1, timer2, $slot3]
@onready var cooldisps = [get_node("/root/Node2D/Camera2D/Control2/CanvasLayer/Panel3"),get_node("/root/Node2D/Camera2D/Control2/CanvasLayer/Panel4"),get_node("/root/Node2D/Camera2D/Control2/CanvasLayer/Panel5"),get_node("/root/Node2D/Camera2D/Control2/CanvasLayer/Panel6")]
@onready var soundplayer = $AudioStreamPlayer
@export var deathParticle = preload("res://Scenes//ParticleScene.tscn")
@onready var soundplayer2 = $AudioStreamPlayer2
var lives = 1
var levelReq = 15
var level = 1
var isInShrine = false
var SkillStore = preload("res://youdied.tscn")
var handleInput = true
var swordRotation = 0
@export var packed_arrow = preload("res://Prefabs/arrow.tscn")
var attackSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/12_Player_Movement_SFX/56_Attack_03.wav")
var healSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Buffs_Heals_SFX/02_Heal_02.wav")
var fireSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Atk_Magic_SFX/04_Fire_explosion_04_medium.wav")
var bowSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Atk_Magic_SFX/25_Wind_01.wav")
var thunderSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Atk_Magic_SFX/18_Thunder_02.wav")
var levelSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Buffs_Heals_SFX/16_Atk_buff_04.wav")
var slashSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/12_Player_Movement_SFX/88_Teleport_02.wav")
var beamSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Atk_Magic_SFX/13_Ice_explosion_01.wav")
var speedSound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/8_Atk_Magic_SFX/45_Charge_05.wav")
var parrySound = preload("res://Assets/Leohpaz/RPG_Essentials_Free/10_Battle_SFX/39_Block_03.wav")

#Movement input
func get_input():
	input = Vector2()
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	if Input.is_action_pressed('up'):
		input.y -= 1
	return input

func get_other_input():
	if Input.is_action_just_pressed('ability 1') and abilities != []:
		doAbility(abilities[0], 0, abilities[0].level)
	if Input.is_action_just_pressed('ability 2') and abilities.size() > 1 and abilities[1] != null:
		doAbility(abilities[1], 1, abilities[1].level)
	if Input.is_action_just_pressed('ultimate') and abilities.size() > 2:
		doAbility(abilities[2], 2, abilities[2].level)
	if Input.is_action_just_pressed('attack') and not Input.is_key_pressed(4194325):
		if !slashMarker.visible:
			attack()
	if Input.is_action_just_pressed('dash') and chosenGod == "thunder":
		dash()
	if Input.is_action_just_pressed('pause'):
		get_tree().paused = true
		%grindtime.visible = true
#handles movement physics
func _physics_process(_delta):
	if health < max_health and chosenGod == "moon":
		health += 0.01
		healthBar.update(health)
	var direction = get_input()
	if direction.length() > 0 and handleInput:
		if not soundplayer2.playing:
			soundplayer2.playing = true
		last_direction = direction
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
		$AnimatedSprite2D.animation = "run"
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		soundplayer2.playing = false
		$AnimatedSprite2D.animation = "default"
		velocity = velocity.lerp(Vector2.ZERO, friction)
	move_and_slide()
	get_other_input()
	alignSword()
	
func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
#handles new upgrades and adds effects
func upgradeHandle(upgrade):
	if upgrade.title == "Phoenix":
		lives += 1
	elif upgrade.type == "Ability" and upgrade.extra == " Level 1":

		abilities.append(upgrade.duplicate())
		cooldisps[abilities.size()].activate(abilities.size() - 1)
	elif upgrade.type == "Ultimate Ability":
		abilities.append(upgrade.duplicate())
		cooldisps[abilities.size()].activate(abilities.size() - 1)
	elif upgrade.type == "Ability" and upgrade.extra != " Level 1":
		abilities[findInAbilities(upgrade)].level += 1
		abilities[findInAbilities(upgrade)].cooldown *= 0.7
	else:
		match upgrade.title:
			
			"Max Health Up":
				max_health *= 1.3
				healthBar.updateMax(max_health)
			"Speed Up":
				speed *= 1.1
			"Attack Speed Up":
				attackSpeed *= 1.15
			"Attack Damage Up":
				damage *= 1.5
				

func findInAbilities(i):
	var x = 0
	for y in abilities:
		if y.title == i.title:
			return x
		else:
			x += 1
#This will be used later
func handleSceneChange():
#	levels.get_child(0).queue_free()
	%Control4.visible = true
	get_tree().paused = true

#Go to skill store scene after death
func die():
	if chosenGod == "fire" and lives > 1:
		lives -= 1
		health = max_health*3/4
		healthBar.update(health)
	else:
		handleSceneChange()
	
	
func _on_dialogic_signal(arg:String):
	match arg:
		"moon","fire","war","thunder":
			chosenGod = arg

func set_coins(_newValue):
	pass

func set_exp(newValue):
	exper = newValue
	if expBar:
		expBar.update(newValue)
	if exper >= levelReq:
		levelUp()

func levelUp():
	soundplayer.stream = levelSound
	soundplayer.play()
	level += 1
	exper = 0
	levelReq += 20
	expBar.update(0)
	expBar.updateMax(levelReq, level)
	GameManager.giveUpgrade()


func doAbility(ability, slot, ulevel):
	if timers[slot].is_stopped():
		match ability.title:
			"Crescent Strike":
				soundplayer.stream = slashSound
				soundplayer.play()
				crescentStrike(ulevel)
			"Guarding Light":
				soundplayer.stream = beamSound
				soundplayer.play()
				guard(ulevel)
			"Moon's Veil":
				veil()
			"Bow":
				soundplayer.stream = bowSound
				soundplayer.play()
				bow(ulevel)
			"Parry":
				parry()
			"Warrior's Rage":
				rage()
			"Thunderclap":
				soundplayer.stream = thunderSound
				soundplayer.play()
				stunNearby(ulevel)
			"Lightning-Quick Speed":
				soundplayer.stream = speedSound
				soundplayer.play()
				LQS(ulevel)
			"Lightspeed Slash":
				soundplayer.stream = thunderSound
				soundplayer.play()
				judgementCut()
			"Flame Burst":
				soundplayer.stream = fireSound
				soundplayer.play()
				explode(ulevel)
			"Healing Warmth":
				soundplayer.stream = healSound
				soundplayer.play()
				heal(ulevel)
		timers[slot].start(ability.cooldown)
		cooldisps[slot + 1].modulate = Color("ffffff5c")
		await timers[slot].timeout
		cooldisps[slot + 1].modulate = Color("ffffff")
		timers[slot].stop()


func guard(ulevel):
	guarding = true
	var guardtimer = Timer.new()
	add_child(guardtimer)
	guardtimer.start(3+2*ulevel)
	await guardtimer.timeout
	guarding = false
	

func explode(ulevel=1):
	var _particleScene = deathParticle.instantiate()
	var _particle = _particleScene.get_node("Particles2D")
	speed = 0
	
	_particle.rotation = global_rotation
	_particle.emitting = true
	var time = 0.4+((ulevel-1)*.2)
	_particle.lifetime = time
	self.add_child(_particleScene)
	await get_tree().create_timer(time).timeout
	speed = 750
	var bodies = _particleScene.get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("enemies"):
			body.health -= damage
			var timer = Timer.new()
			add_child(timer)
			timer.start(0.2)
			var color = body.modulate
			if body:
				body.modulate = Color("ff0000")
			await timer.timeout
			if body:
				body.modulate = color
			timer.queue_free()
			if body.health <= 0:
				body.onDie(true)
	
	_particleScene.queue_free()

func alignSword():
	match input:
		Vector2(1,0):
			swordRotation = 180
		Vector2(1,1):
			swordRotation = -135
		Vector2(0,1):
			swordRotation = -90
		Vector2(-1,0):
			swordRotation = 0
		Vector2(-1,-1):
			swordRotation = 45
		Vector2(0,-1):
			swordRotation = 90
		Vector2(-1,1):
			swordRotation = -45
		Vector2(1,-1):
			swordRotation = 135

func veil():
	modulate = Color("ffffff5c")
	var veilTimer = Timer.new()
	add_child(veilTimer)
	veilTimer.start(15)
	await veilTimer.timeout
	modulate = Color("ffffff")
	

func attack():
	#play attack anim
	#do \
	var randScale = randf_range(0.1,0.5)
	var randSpeed = 1 + randf_range(0.1,0.5)
	slashMarker.visible = true
	slashMarker.rotation_degrees = swordRotation
	slashMarker.scale = Vector2(1 + randScale,1+randScale)
	SlashAnim.play("Slash",-1,0.5+randSpeed)
	soundplayer.pitch_scale += randSpeed*3
	soundplayer.stream = attackSound
	soundplayer.play()
	soundplayer.pitch_scale = 1
	cooldisps[0].modulate = Color("ffffff5c")
	await SlashAnim.animation_finished
	meleeTimer.start(0.75/attackSpeed)
	slashMarker.get_child(0).visible = false
	slashMarker.scale = Vector2(1,1)
	await meleeTimer.timeout
	cooldisps[0].modulate = Color("ffffff")
	slashMarker.visible = false
	slashMarker.get_child(0).visible = true
	
	
	
func dash():
		var direction = get_input()
		velocity = velocity.lerp(direction.normalized() * 22500, acceleration*1.7)


func stunNearby(upgulevel):
	for i in get_tree().get_nodes_in_group("enemies"):
		if i.get_parent().visible == true:
			i.stunned(2.5+0.5*upgulevel)

func heal(upglevel):
	health += max_health/(4-upglevel)
	healthBar.update(health)


func judgementCut():
	for i in get_tree().get_nodes_in_group("enemies"):
		if i.get_parent().visible == true:
			i.onDie(false)

func parry():
#	slashMarker.visible = true
#	$Marker2D/parry2D.monitoring = true
	slashMarker.rotation_degrees = swordRotation
	var nearEnemies = $Marker2D/parry2D.get_overlapping_bodies()
	for i in nearEnemies:
		if i.is_in_group("enemies"):
			if i.attacking and i.parryable and not i.parried:
				soundplayer.stream = parrySound
				soundplayer.play()
				i.parried = true
				i.velocity = i.velocity.lerp(Vector2(1,0).rotated(deg_to_rad(swordRotation)) * -8, acceleration*1.3)
#	$Marker2D/parry2D.monitoring = false
#	slashMarker.visible = false

func LQS(upglevel):
	var LQStimer = Timer.new()
	add_child(LQStimer)
	LQStimer.start(3+upglevel*1.2)
	speed *= 1.5+0.2*upglevel
	await LQStimer.timeout
	LQStimer.queue_free()
	speed /= 1.5+0.2*upglevel

func crescentStrike(upglevel):
	slashMarker.visible = true
	slashMarker.rotation_degrees = swordRotation
	damage += upglevel
	slashMarker.scale = Vector2(1.5,4)
	SlashAnim.play("Crescent",-1, 0.7)
	await SlashAnim.animation_finished
	damage -= upglevel
	slashMarker.visible = false
	slashMarker.scale = Vector2(1,1)


func rage():
	var ragetimer = Timer.new()
	add_child(ragetimer)
	ragetimer.start(3+2*1)
	speed *= 1.3+0.2*1
	damage *= 1.3+0.2*1
	await ragetimer.timeout
	ragetimer.queue_free()
	speed /= 1.3+0.2*1
	damage /= 1.3+0.2*1


func bow(upglevel):
	slashMarker.rotation_degrees = swordRotation
	var arrow = packed_arrow.instantiate()
	arrow.damage = upglevel
	arrow.global_position = slashMarker.get_child(0).global_position
	arrow.rotation = (Vector2(-1,-1) * last_direction).angle() 
	get_parent().add_child(arrow)
	

func align_camera(room):
	
	#get_window().size = Vector2i(672, 672)
	var vect_pos = room[2]
	var rm = room[0]
	var ref_pos = room[1]

	camera.global_position.y = vect_pos.y+640
	camera.global_position.x = vect_pos.x+640
	camera.set_as_top_level(true)


