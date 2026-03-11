@abstract
@tool
extends GraphNode
class_name BaseDialogueNode

signal modified()

var undo_redo: EditorUndoRedoManager

@abstract func _from_dict(dict: Dictionary) -> Array[String]
@abstract func _to_dict(graph: GraphEdit) -> Dictionary


func _on_modified() -> void:
	modified.emit()
