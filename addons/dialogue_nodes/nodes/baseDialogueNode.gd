@abstract
@tool
extends GraphNode
class_name BaseDialogueNode

signal modified()
signal disconnection_from_request(from_node: String, from_port: int)
signal connection_shift_request(from_node: String, old_port: int, new_port: int)


var undo_redo: EditorUndoRedoManager

@abstract func _from_dict(dict: Dictionary) -> Array[String]
@abstract func _to_dict(graph: GraphEdit) -> Dictionary
## If node needs access to variable list, define this function in its script.
#func _on_variables_updated(variables_list: Array[String]) -> void: pass
## If node needs access to character list, define this function in its script.
#func _on_characters_updated(character_list: Array[Character]) -> void: pass


func _on_modified() -> void:
	modified.emit()
