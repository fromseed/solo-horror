extends Node3D

signal tape_collected

@onready var area: Area3D = $Area3D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		tape_collected.emit()  # <-- Use your signal!
		get_node("/root/Main").show_pickup_notification("Tape Collected")
		queue_free()
