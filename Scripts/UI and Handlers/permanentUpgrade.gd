extends Button

@onready var GameManager = get_node("/root/GameManager")
@export var index = 0
#@onready var level = GameManager.level[index]
#@onready var cost = GameManager.cost[index]
@onready var coinText = %CoinText
@onready var levelText = $LevelText
@onready var costText = $CostText
# Called when the node enters the scene tree for the first time.
func _ready():
	update()

#Give upgrade to player, subtract cost
func _pressed():
	if GameManager.coins >= GameManager.cost[index] and GameManager.level[index] < 4:
		GameManager.level[index] += 1
		GameManager.coins -= GameManager.cost[index]
		GameManager.cost[index] = 50 * (1+2*(2**GameManager.level[index]))
		update()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	

#Get new info and update textboxes
func update():
	if GameManager.level[index] == 4:
		levelText.text = "Current Level: MAX"
		costText.text = "Cost to Upgrade: N/A"
	else: 
		levelText.text = "Current Level: " + str(GameManager.level[index])
		costText.text = "Cost to Upgrade: " + str(GameManager.cost[index])
	coinText.text = "Current Coins: " + str(GameManager.coins)
func _on_pressed():
	pass # Replace with function body.
