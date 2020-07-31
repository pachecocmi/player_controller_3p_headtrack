extends KinematicBody

# player vars
export var speed:float = 20
export var acceleration:float = 15
export var air_acceleration:float = 5
export var gravity:float = 9.8
export var max_terminal_velocity:float = 54
export var jump_power:float = 100

#camera vars
export(float, 0.1, 1) var mouse_sensitivity:float = 0.3
export(float, -50, 0) var min_pitch:float = -50
export(float, 50, 0) var max_pitch:float = 50

#movement vars
var velocity:Vector3
var y_velocity:float

#references
onready var camera_pivot = $Pivot
onready var camera = $Pivot/SpringArm/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, min_pitch, max_pitch)

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction = Vector3()
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	direction.normalized()
	
	# acceleration check for both floor and midair
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction*speed, accel*delta)
	
	# pin to floor due to floor wobble, otherwise initiate gravity
	if is_on_floor():
		y_velocity = -0.01
	else:
		y_velocity = clamp(y_velocity-gravity, -max_terminal_velocity, max_terminal_velocity)
	
	# jump
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		y_velocity = jump_power
	
	velocity.y = y_velocity
	velocity = move_and_slide(velocity, Vector3.UP)
