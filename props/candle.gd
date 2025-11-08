extends Node3D

@onready var light: OmniLight3D = $OmniLight3D
@onready var flame: MeshInstance3D = $Flame        # Main outer flame
@onready var inner_flame: MeshInstance3D = $InnerFlame  # Smaller inner flame

@export var base_energy: float = 8.0
@export var light_range: float = 2.3
@export var attenuation: float = 2.8
@export var warm_color: Color = Color8(255,178,107)
@export var flicker_amp: float = 12.0
@export var flicker_speed: float = 7.0
@export var shape_wobble: float = 0.08
@export var tilt_wobble_deg: float = 5.0
@export var is_lit: bool = true

var _noise: FastNoiseLite = FastNoiseLite.new()

func _ready():
	_noise.seed = randi()
	_noise.frequency = 1.4
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	light.light_color = warm_color
	light.light_energy = randf_range(0.0, 100.0)
	light.omni_range = light_range
	light.omni_attenuation = attenuation
	light.shadow_enabled = true

func _process(_delta: float) -> void:
	if not is_lit:
		light.light_energy = 0.0
		flame.visible = false
		inner_flame.visible = false
		return

	flame.visible = true
	inner_flame.visible = true

	var t: float = Time.get_ticks_msec() * 0.001

	# Layered base noise
	var n: float = (
		0.5 * _noise.get_noise_1d(t * flicker_speed) +
		0.3 * _noise.get_noise_1d(t * (flicker_speed * 2.4 + 7.1)) +
		0.2 * _noise.get_noise_1d(t * (flicker_speed * 5.3 + 13.7))
	)

	# Add "hard" random jitter sometimes, NOT every frame
	if randi() % 13 == 0:
		n += randf_range(-0.25, 0.3)
	if randi() % 53 == 0:
		n += randf_range(-0.5, 0.6)
	if randi() % 79 == 0:
		n += randf_range(-0.8, 0.9)
	n = clamp(n, -1.0, 1.0)

	light.light_energy = base_energy + flicker_amp * n

	var shift: float = clamp(n * 0.02, -0.06, 0.06)
	light.light_color = Color(
		clamp(warm_color.r + shift, 0.0, 1.0),
		clamp(warm_color.g + shift * 0.5, 0.0, 1.0),
		clamp(warm_color.b - shift, 0.0, 1.0),
		1.0
	)

	# Outer flame shape wobble (squash & stretch + tiny tilt)
	var sxz: float = 1.0 + shape_wobble * n
	var sy: float = 1.0 - shape_wobble * n * 0.7
	flame.scale = Vector3(sxz, sy, sxz)
	flame.rotation_degrees = Vector3(tilt_wobble_deg * n, 0.0, tilt_wobble_deg * 0.5 * n)
	print("Flicker value: ", n)

	# Inner flame: unique, faster jitter
	var n2: float = (
		0.6 * _noise.get_noise_1d((t + 19.1) * (flicker_speed * 1.9)) +
		0.4 * _noise.get_noise_1d((t + 5.9) * (flicker_speed * 4.1))
	)
	if randi() % 17 == 0:
		n2 += randf_range(-0.35, 0.4)
	if randi() % 71 == 0:
		n2 += randf_range(-0.7, 0.8)
	n2 = clamp(n2, -1.0, 1.0)

	var inner_sxz: float = 0.57 + 0.11 * n2
	var inner_sy: float = 0.72 - 0.08 * n2
	inner_flame.scale = Vector3(inner_sxz, inner_sy, inner_sxz)
	inner_flame.rotation_degrees = Vector3(tilt_wobble_deg * 0.7 * n2, 0.0, tilt_wobble_deg * 0.2 * n2)
