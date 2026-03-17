@tool
extends BaseDialogueNode

var last_variable_list: Array[String]
var last_variable: String
var last_type: int
var last_value: String
var cur_variable := -1

func _ready() -> void:
	_register_timer(%Value, "text_changed", _on_value_changed)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	# var variables := graph.last_variable_list + StoryManager.get_variable_list()
	
	dict['cur_variable'] = cur_variable
	dict['%Variable'] = %Variable.text
	dict['%Type'] = %Type.selected
	dict['%Value'] = %Value.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	cur_variable = dict['cur_variable']
	%Type.selected = dict['%Type']
	%Value.text = dict['%Value']
	
	last_variable = %Variable.text
	last_type = %Type.selected
	last_value = %Value.text
	
	return [dict['link']]


func set_variable(new_variable: String) -> void:
	if %Variable.text != new_variable:
		%Variable.text = new_variable
	last_variable = new_variable


func set_value(new_value: String) -> void:
	if %Value.text != new_value:
		%Value.text = new_value
	last_value = new_value


func _on_variable_changed(_new_text) -> void:
	if not undo_redo: 
		set_variable(%Variable.text)
		return
	
	undo_redo.create_action('Set %Variable name')
	undo_redo.add_do_method(self, 'set_variable', %Variable.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_variable', last_variable)
	undo_redo.commit_action()


func _on_type_selected(idx: int) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set operator %Type')
	undo_redo.add_do_method(%Type, 'select', idx)
	undo_redo.add_do_property(self, 'last_type', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(%Type, 'select', last_type)
	undo_redo.add_undo_property(self, 'last_type', last_type)
	undo_redo.commit_action()


func _on_value_changed() -> void:
	if not undo_redo:
		set_value(%Value.text)
		return

	undo_redo.create_action('Set %Value')
	undo_redo.add_do_method(self, 'set_value', %Value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()


func _on_variables_updated(variables_list: Array[String]) -> void:
	%Variable.clear()
	
	for variable_name in variables_list:
		%Variable.add_item(variable_name)
	
	if variables_list.size() > 0:
		if cur_variable > variables_list.size():
			cur_variable = 0
		%Variable.select(cur_variable)
	else:
		%Variable.select(-1)


func _on_variable_selected(idx: int) -> void:
	if not undo_redo: 
		cur_variable = idx
		%Variable.select(idx)
		_on_modified()
		return
	
	undo_redo.create_action('Set %Variable')
	undo_redo.add_do_property(self, 'cur_variable', idx)
	undo_redo.add_do_method(%Variable, 'select', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_property(self, 'cur_variable', cur_variable)
	undo_redo.add_undo_method(%Variable, 'select', cur_variable)
	undo_redo.commit_action()
