extends CharacterBody2D

var bullet = preload("res://scenes/entities/bullet.tscn")

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var SPEED : int = 200
@export var FRICTION : int = 1000
@export var AIR_RESISTANCE : int = 2000
@export var AIR_ACCELERATION : int = 200
@export var ACCELERATION : int = 300
@export var JUMP_VELOCITY : int = -300

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var muzzle = $Muzzle

enum states { idle, run, jump, shoot}
var current_state : states
var muzzle_position


func _ready():
	current_state = states.idle
	muzzle_position = muzzle.position


func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_muzzle_position()
	player_shoot(delta)
	player_friction(delta)

	move_and_slide()
	
	player_animations()
	print("Current State: " , states.keys()[current_state])


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
		velocity.x  = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)
		
	if direction != 0:
		current_state = states.run
		animated_sprite_2d.flip_h = false if direction > 0 else true


func player_jump(delta : float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		current_state = states.jump
		
	if not is_on_floor() and current_state == states.jump:
		var direction = input_movement()
		velocity.x = move_toward(velocity.x, SPEED * direction, AIR_ACCELERATION * delta)


func player_friction(delta : float):
	var direction = input_movement()
	if direction == 0:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		elif not is_on_floor():
			velocity.x = move_toward(velocity.x, 0, AIR_RESISTANCE * delta)


func player_shoot(delta : float):
	var direction = input_movement()
	
	if direction != 0 and Input.is_action_just_pressed("shoot"):
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = states.shoot


func player_muzzle_position():
	var direction = input_movement()
	
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x

func player_animations():
	if current_state == states.idle:
		animated_sprite_2d.play("idle")
	elif current_state == states.run and animated_sprite_2d.animation != "run_shoot":
		animated_sprite_2d.play("run")
	elif current_state == states.jump:
		animated_sprite_2d.play("jump")
	elif current_state == states.shoot:
		animated_sprite_2d.play("run_shoot")


func input_movement():
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction
