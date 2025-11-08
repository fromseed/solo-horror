extends Node3D

@onready var pickup_label: Label = $HUD/PickupLabel

func show_pickup_notification(text):
	pickup_label.text = text
	pickup_label.modulate.a = 0
	pickup_label.visible = true
	var tween = pickup_label.create_tween()
	tween.tween_property(pickup_label, "modulate:a", 1, 0.5)
	tween.tween_interval(2)
	tween.tween_property(pickup_label, "modulate:a", 0, 1)
	tween.tween_callback(Callable(pickup_label, "hide"))
	
