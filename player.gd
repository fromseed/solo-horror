extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
var mouse_sens := 0.002
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") as float

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		$Pivot.rotate_y(-event.relative.x * mouse_sens)
		var cam = $Pivot/Camera3D
		cam.rotate_x(-event.relative.y * mouse_sens)
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -80, 80)

	# Esc: first press frees mouse, second press quits
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			get_tree().quit()

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	var player_basis = $Pivot.global_transform.basis
	var forward = -player_basis.z
	var right = player_basis.x

	var direction = (forward * input_dir.y + right * input_dir.x).normalized()

	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	move_and_slide()
