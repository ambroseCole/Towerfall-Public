extends Node

#Use this object for important data
var coins = 0
#var max_health = 100
#var speed = 100
#var damage = 1
#var attackSpeed = 1
var cost = [100,100,100,100] #hp,atk,spd,atkspd
var level = [0,0,0,0] #hp,atk,spd,atkspd
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

signal upgradeActivate
var upgradeOne = upgradeClass.new()
var upgradeTwo = upgradeClass.new()
var upgradeThree = upgradeClass.new()
var upgradeList = [upgradeOne,upgradeTwo,upgradeThree]
var random = RandomNumberGenerator.new()
var chosenGod = ""
var alreadyHas = false
@onready var probabilityList = range(7)
@onready var player = get_node_or_null("/root/Node2D/CharacterBody2D")
@onready var prevNums = []



func giveUpgrade():
	get_tree().paused = true
	if 6 in prevNums:
		probabilityList = range(6)
	chosenGod = player.chosenGod
	probabilityList.shuffle()
	print_debug(prevNums)
	for i in upgradeList:
		i.code = probabilityList[upgradeList.find(i)]
		match i.code:
			0:
				i.title = "Max Health Up"
				i.description = "Learn to walk it off. Increase max health by 30%"
				i.type = "Stat Up"
				i.imgpath = "res://icons/HEALTH UP.png"
			1:
				i.title = "Speed Up"
				i.description = "Put some pep in your step! Increase speed by 10%"
				i.type = "Stat Up"
				i.imgpath = "res://icons/SPEED UP.png"
			2:
				i.title = "Attack Damage Up"
				i.description = "Hit a little harder. Attacks do 30% more damage"
				i.type = "Stat Up"
				i.imgpath = "res://icons/DAMAGE UP.png"
			3:
				i.title = "Attack Speed Up"
				i.description = "If you can't hit harder, hit faster. Attacks are 15% faster"
				i.type = "Stat Up"
				i.imgpath = "res://icons/ATTACK SPEED UP.png"
			4:
				match chosenGod:
					"moon":
						i.title = "Crescent Strike"
						i.description = "A sweeping attack in the shape of a crescent moon"
						i.type = "Ability"
						i.imgpath = "res://icons/Sprite-0002.png"
						i.cooldown = 15
						i.short = "Crescent"
					"fire":
						i.title = "Flame Burst"
						i.description = "Send a burst of flames in all directions, scorching enemies"
						i.type = "Ability"
						i.imgpath = "res://icons/Fire Burst.png"
						i.cooldown = 20
						i.short = "Flame"
					"thunder":
						i.title = "Thunderclap"
						i.description = "Stun all nearby enemies with a deafening sound"
						i.type = "Ability"
						i.imgpath = "res://icons/THUNDER CLAP.png"
						i.cooldown = 45
						i.short = "Clap"
					"war":
						i.title = "Bow"
						i.description = "Notch, draw back, release. It's as easy as that"
						i.type = "Ability"
						i.imgpath = "res://icons/bo an arro.png"
						i.cooldown = 5
						i.short = "Bow"

			5:
				match chosenGod:
					"moon":
						i.title = "Guarding Light"
						i.description = "Become invincible to attacks for a short period of time"
						i.type = "Ability"
						i.imgpath = "res://icons/Sprite-0001.png"
						i.cooldown = 30
						i.short = "Guard"
					"fire":
						i.title = "Healing Warmth"
						i.description = "Like sitting at a nice campfire. Regain a portion of lost health"
						i.type = "Ability"
						i.imgpath = "res://icons/HEALING WARMTH.png"
						i.cooldown = 10
						i.short = "Heal"
					"thunder":
						i.title = "Lightning-Quick Speed"
						i.description = "Put the pedal to the metal. Speed is greatly increased for a short period of time"
						i.type = "Ability"
						i.imgpath = "res://icons/Lightning Speed.png"
						i.cooldown = 50
						i.short = "Speed"
					"war":
						i.title = "Parry"
						i.description = "Say \"nuh uh.\" Correct timing of a parry will negate all damage and stun an enemy"
						i.type = "Ability"
						i.imgpath = "res://icons/shield parry.png"
						i.cooldown = 3
						i.short = "Parry"
			6:
				match chosenGod:
					"moon":
						i.title = "Moon's Veil"
						i.description = "Become invisible to enemies for a short period of time"
						i.type = "Ultimate Ability"
						i.imgpath = "res://icons/Sprite-0004.png"
						i.cooldown = 120
						i.short = "Veil"
					"fire":
						i.title = "Phoenix"
						i.description = "Obtain the life force of a phoenix. Gain one extra life."
						i.type = "Ultimate Ability"
						i.imgpath = "res://icons/Phoenix.png"
						i.cooldown = 100000
						
					"thunder":
						i.title = "Lightspeed Slash"
						i.description = "With an instant slash, kill all nearby enemies (negates XP)"
						i.type = "Ultimate Ability"
						i.imgpath = "res://icons/DMC 3 TYPE BEEEEAAAAATTTTT.png"
						i.cooldown = 150
						i.short = "Slash"
					"war":
						i.title = "Warrior's Rage"
						i.description = "Become much stronger and more resilient for a short period of time"
						i.type = "Ultimate Ability"
						i.imgpath = "res://icons/war special.png"
						i.cooldown = 100
						i.short = "Rage"
		if i.type == "Ability":
			i.extra = " Level 1"
			for y in player.abilities:
				if y.title == i.title:
					i.extra = " Level " + str(y.level + 1)
					#match i.title:
					
					
		else:
			i.extra = ""
	get_node("/root/Node2D/Camera2D/Control/UpgradeButtonLayer").visible = true
	player.handleInput = false
	upgradeActivate.emit(upgradeList)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player == null:
		player = get_node_or_null("/root/Node2D/CharacterBody2D")
