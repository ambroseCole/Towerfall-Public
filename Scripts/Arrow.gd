extends Area2D
var pushback_strength = 50
var speed = 1200
var damage = 1

func _process(delta):
	position += Vector2.LEFT.rotated(rotation) * speed * delta


func _on_body_entered(area):
	if area.is_in_group("enemies"):
		area.health -= damage
		if area.health <= 0:
			area.onDie(true)
		area.on_arrow(Vector2.RIGHT.rotated(rotation), pushback_strength)
		queue_free()
