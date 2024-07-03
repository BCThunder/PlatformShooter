extends CharacterBody2D


var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var SPEED : int = 300
@export var JUMP_VELOCITY : int = -300

@onready var animated_sprite_2d = $AnimatedSprite2D

enum states { idle, run, jump}
var current_state : states

func _ready():
	current_state = states.idle


func player_falling(delta : float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta


func player_idle(delta : float):
	if is_on_floor():
		current_state = states.idle


func player_run(delta : float):
	if not is_on_floor():
		return
	
	var direction = input_movement()

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction != 0:
		current_state = states.run
		animated_sprite_2d.flip_h = false if direction > 0 else true


func player_jump(delta : float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = states.jump
		
	if not is_on_floor() and current_state == states.jump:
		var direction = input_movement()
		velocity.x += direction * SPEED * delta


func player_animations():
	if current_state == states.idle:
		animated_sprite_2d.play("idle")
	elif current_state == states.run:
		animated_sprite_2d.play("run")
	elif current_state == states.jump:
		animated_sprite_2d.play("jump")


func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction


func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)

	move_and_slide()
	
	player_animations()
	print("Current State: " , states.keys()[current_state])
