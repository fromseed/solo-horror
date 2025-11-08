extends Node3D

var is_locked: bool = true

@onready var area: Area3D = $Area3D
@onready var static_body: StaticBody3D = $StaticBody3D

func _ready():
	area.body_entered.connect(_on_area_entered)
	var tape = get_node_or_null("/root/Main/Tape")
	if tape:
		tape.tape_collected.connect(_on_tape_collected)

func _on_tape_collected():
	is_locked = false

func _on_area_entered(body):
	if body.name == "Player":
		if is_locked:
			get_node("/root/Main").show_pickup_notification("The door is locked.")
		else:
			open_door()

func open_door():
	$StaticBody3D/CollisionShape3D.disabled = true
	# Tween the Y rotation to swing open (90 degrees)
	var tween = create_tween()
	tween.tween_property(static_body, "rotation_degrees:y", 90.0, 1.2) # 1.2 seconds to open
