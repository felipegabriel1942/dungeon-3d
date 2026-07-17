extends Node3D
class_name Sword

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_attacking := false

func attack() -> void:
	animation_player.play("attack_01")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)
