@tool
extends BaseDialogueNode

@onready var file_path: String = %FilePath.text
@onready var start_id: String = $ID.text

func _ready() -> void:
	_register_timer(%FilePath, "text_changed", _on_file_selected)
	_register_timer($ID, "text_changed", _on_ID_changed)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['file_path'] = file_path
	dict['start_id'] = start_id
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	set_path(dict['file_path'])
	set_ID(dict['start_id'])
	
	return [dict['link']]


func set_path(new_path: String) -> void:
	file_path = new_path
	if %FilePath.text != file_path:
		%FilePath.text = file_path


func set_ID(new_id: String) -> void:
	start_id = new_id
	if $ID.text != start_id:
		$ID.text = start_id


func _on_browse_button_pressed() -> void:
	$OpenDialog.popup_centered()


func _on_file_selected() -> void:
	if not undo_redo: 
		set_path(%FilePath.text)
		return

	undo_redo.create_action('Set file FilePath')
	undo_redo.add_do_method(self, 'set_path', %FilePath.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_path', file_path)
	undo_redo.commit_action()


func _on_ID_changed() -> void:
	if not undo_redo:
		set_ID($ID.text)
		return
	
	undo_redo.create_action('Set start ID')
	undo_redo.add_do_method(self, 'set_ID', $ID.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_ID', start_id)
	undo_redo.commit_action()


