extends AnimatedSprite2D

var SPEED : int = 400
var direction : int

func _physics_process(delta):
	move_local_x(direction * SPEED * delta)


func _on_timer_timeout():
	queue_free()
