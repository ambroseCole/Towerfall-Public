extends ProgressBar

@export var sizeRatio = 0.0
@export var defaultV = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	value = defaultV

func update(newHealth):
	value = newHealth
	
func updateMax(newMax, text = null):
	size.x = sizeRatio*newMax**0.75
	max_value = newMax
	if text:
		%LevelText.text = "[center]LV " + str(text)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
