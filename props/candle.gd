extends Node3D

@onready var light: OmniLight3D = $OmniLight3D
@onready var flame: MeshInstance3D = $Flame        # Main outer flame
@onready var inner_flame: MeshInstance3D = $InnerFlame  # Smaller inner flame

@export var base_energy: float = 8.0
@export var light_range: float = 2.3
@export var attenuation: float = 2.8
@export var warm_color: Color = Color8(255,178,107)
@export var flicker_amp: float = 2.0
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
	light.light_energy = base_energy
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
	var n: float = _noise.get_noise_1d(t * flicker_speed)

	# Clamp so we never blind the player
	light.light_energy = base_energy + flicker_amp * n

	# Subtle candle color breathing
	var shift: float = clamp(n * 0.02, -0.05, 0.05)
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

	# --- Inner flame dance ---
	var n2: float = _noise.get_noise_1d((t + 37.17) * (flicker_speed * 1.43))
	var inner_sxz: float = 0.57 + 0.10 * n2   # Slightly smaller, more jitter
	var inner_sy: float = 0.72 - 0.08 * n2
	inner_flame.scale = Vector3(inner_sxz, inner_sy, inner_sxz)
	inner_flame.rotation_degrees = Vector3(tilt_wobble_deg * 0.7 * n2, 0.0, tilt_wobble_deg * 0.2 * n2)
