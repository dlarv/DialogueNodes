@tool
extends BaseDialogueNode

@onready var path: LineEdit = $BoxContainer/FilePath
@onready var file_path: String = path.text
@onready var ID: LineEdit = $ID
@onready var start_id: String = ID.text
@onready var open_dialog: FileDialog = $OpenDialog
@onready var path_timer := _get_new_timer()
@onready var id_timer := _get_new_timer()

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
	if path.text != file_path:
		path.text = file_path


func set_ID(new_id: String) -> void:
	start_id = new_id
	if ID.text != start_id:
		ID.text = start_id


func _on_browse_button_pressed() -> void:
	open_dialog.popup_centered()


func _on_file_selected(new_path: String) -> void:
	if _is_continuing_action(path_timer): return
	path_timer.start()
	path.text = new_path
	
	undo_redo.create_action('Set file path')
	undo_redo.add_do_method(self, 'set_path', path.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_path', file_path)
	undo_redo.commit_action()


func _on_ID_changed(_id) -> void:
	if _is_continuing_action(id_timer): return
	id_timer.start()
	
	undo_redo.create_action('Set start ID')
	undo_redo.add_do_method(self, 'set_ID', ID.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_ID', start_id)
	undo_redo.commit_action()


