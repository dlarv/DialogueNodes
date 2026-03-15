@tool
extends TabContainer


@onready var files = $Editor.files
var undo_redo: EditorUndoRedoManager:
	set(val):
		undo_redo = val
		$Editor.undo_redo = val


func _enter_tree() -> void:
	$Editor.undo_redo = undo_redo


func save_all_files() -> void:
	$Editor.files.save_all()
