extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite_2d = $AnimatedSprite2D


enum states { idle, run, jump}
var current_state

func _ready():
	current_state = states.idle


func player_falling(delta):
	if not is_on_floor():
		velocity.y += gravity * delta


func player_idle(delta):
	if is_on_floor():
		current_state = states.idle


func player_run(delta):
	if not is_on_floor():
		return
	
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction != 0:
		current_state = states.run
		animated_sprite_2d.flip_h = false if direction > 0 else true


func player_jump(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = states.jump
		
	if not is_on_floor() and current_state == states.jump:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x += direction * SPEED * delta


func player_animations():
	if current_state == states.idle:
		animated_sprite_2d.play("idle")
	elif current_state == states.run:
		animated_sprite_2d.play("run")
	elif current_state == states.jump:
		animated_sprite_2d.play("jump")

func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)

	move_and_slide()
	
	player_animations()
	print("Current State: " , states.keys()[current_state])
