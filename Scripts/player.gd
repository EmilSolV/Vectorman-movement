extends CharacterBody2D

const SPEED = 350.0
const SCCELERATION = 1200.0
const FRICTION = 1400.0

const GRAVITY = 2000.0
const FALL_GRAVITY = 3000.0
const DAST_FALL_GRAVITY = 5000.0
const WALL_GRAVITY = 25.0

const JUMP_VELOCITY = -700.0
const WALL_JUMP_VELOCITY = -700.0
const WALL_JUMP_PUSHBACK = 300.0

const INPUT_BUFFER_PATIENCE = 0.1
const COYOTE_TIME = 0.08

var input_buffer : Timer
var coyote_timer : Timer
var coyote_jump_available : bool = true

func _ready():
	input_buffer
