@tool
extends PanelContainer

signal file_dialog_requested(node: Control)
signal value_set(node: Control)
signal removal_requested(node: Control)

var is_node := true

func _on_button_pressed() -> void:
	file_dialog_requested.emit(self)


func _on_line_edit_text_submitted(new_text: String) -> void:
	if _validate_type(new_text):
		%LineEdit.text = new_text
		value_set.emit(self)
	else:
		%LineEdit.text = ""
		push_error("Invalid type selected. Expected %s" % "BaseDialogueNode" if is_node else "RichTextEffect")


func set_file(path: String) -> void:
	if _validate_type(path):
		%LineEdit.text = path
		value_set.emit(self)
	else:
		push_error("Invalid type selected. Expected %s" % "BaseDialogueNode" if is_node else "RichTextEffect")


func get_file() -> String:
	return %LineEdit.text


func _on_remove_button_pressed() -> void:
	removal_requested.emit(self)


func _validate_type(path: String) -> bool:
	var file = ResourceLoader.load(path)
	if file == null: return false

	if file is PackedScene:
		var obj = file.instantiate()
		return is_node and obj is BaseDialogueNode
	elif file is GDScript:
		return file.get_instance_base_type() == "RichTextEffect"
	return false
