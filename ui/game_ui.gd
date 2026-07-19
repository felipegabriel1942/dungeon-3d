extends CanvasLayer
class_name GameUI

@onready var life_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/LifeLabel

func _ready() -> void:
	EventBus.health_changed.connect(on_health_changed)

func on_health_changed(current, max) -> void:
	life_label.text = "%03d / %03d" % [current, max]
