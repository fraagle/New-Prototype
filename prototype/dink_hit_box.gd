extends Area2D

class_name DinkHitBox

signal player_dink_hit

func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body is Dink:
		player_dink_hit.emit()
		
