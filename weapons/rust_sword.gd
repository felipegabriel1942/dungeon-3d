extends Node3D
class_name RustSword

signal hit_body(body)

func _on_body_entered(body: Node3D) -> void:
	hit_body.emit(body)
