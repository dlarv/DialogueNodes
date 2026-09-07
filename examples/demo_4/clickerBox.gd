extends MeshInstance3D

signal clicked


func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		clicked.emit()
	
