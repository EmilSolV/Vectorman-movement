extends CharacterBody2D

const SPEED = 500.0
const ACCELERATION = 5000.0
const FRICTION = 5000.0
const GRAVITY = 2200.0
const JUMP_VELOCITY = -700.0
const DOUBLE_JUMP_VELOCITY = -760.0
const INPUT_BUFFER_PATIENCE = 0.1
const COYOTE_TIME = 0.08

var input_buffer : Timer
var coyote_timer : Timer
var coyote_jump_available := true
var double_jump_used := false
var is_ducking := false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)

	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)

func _physics_process(delta):
	var horizontal_input = Input.get_axis("move_left", "move_right")
	var jump_pressed = Input.is_action_just_pressed("jump")

	handle_jump(jump_pressed)
	handle_duck()
	handle_gravity(delta)
	handle_horizontal_movement(delta, horizontal_input)
	move_and_slide()
	update_animation(horizontal_input)

func handle_jump(jump_pressed: bool):
	if jump_pressed or input_buffer.time_left > 0:
		if coyote_jump_available:
			velocity.y = JUMP_VELOCITY
			coyote_jump_available = false
			double_jump_used = false
			animated_sprite_2d.play("jump")
		elif not double_jump_used:
			velocity.y = DOUBLE_JUMP_VELOCITY
			double_jump_used = true
			animated_sprite_2d.play("double_jump")
			await get_tree().create_timer(0.1).timeout
		elif jump_pressed:
			input_buffer.start()

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4

func handle_duck():
	if Input.is_action_pressed("duck") and not is_ducking:
		is_ducking = true
		animated_sprite_2d.play("duck")
	elif Input.is_action_just_released("duck") and is_ducking:
		is_ducking = false
		animated_sprite_2d.play("duck_reverse")

func handle_gravity(delta: float):
	if is_on_floor():
		coyote_jump_available = true
		double_jump_used = false
		coyote_timer.stop()
	else:
		if coyote_jump_available and coyote_timer.is_stopped():
			coyote_timer.start()
		velocity.y += GRAVITY * delta

func handle_horizontal_movement(delta: float, horizontal_input: float):
	var floor_damping = 1.0 if is_on_floor() else 0.2
	var dash_multiplier = 2.0 if Input.is_action_pressed("dash") else 1.0

	if sign(horizontal_input) != sign(velocity.x) and horizontal_input != 0 and abs(velocity.x) > 50:
		velocity.x = 0

	if horizontal_input:
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED * dash_multiplier, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta * floor_damping)

func update_animation(horizontal_input: float):
	if is_ducking:
		return

	if not is_on_floor():
		if animated_sprite_2d.animation != "double_jump" and velocity.y > 0:
			animated_sprite_2d.play("jump")
	elif abs(velocity.x) > 10:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	animated_sprite_2d.flip_h = velocity.x < 0

func coyote_timeout():
	coyote_jump_available = false
