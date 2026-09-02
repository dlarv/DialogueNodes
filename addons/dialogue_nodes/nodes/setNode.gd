@tool
extends BaseDialogueNode

var last_type: int
var last_value: String

func _ready() -> void:
	_register_timer(%Value, "text_changed", _on_value_changed)
	%Variable.undo_redo = undo_redo


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['variable'] = %Variable.curr_variable
	dict['type'] = %Type.selected
	dict['value'] = %Value.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	%Variable.setup(dict['variable'])

	%Type.selected = dict['type']
	%Value.text = dict['value']
	
	last_type = %Type.selected
	last_value = %Value.text
	
	return [dict['link']]


func set_value(new_value: String) -> void:
	if %Value.text != new_value:
		%Value.text = new_value
	last_value = new_value


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
	%Variable.update_variables(variables_list)


static func process(parser: DialogueParser, dict: Dictionary):
	var variables := parser.variables
	if not variables.has(dict.variable):
		printerr('Variable ', dict.variable, ' not found in variables list')
		parser.proceed(dict.link)
		return
	
	var type = typeof(variables[dict.variable])
	var value = dict.value
	if value.count("{{"):
		value = parser.parse_variables(value)
	
	var operator = dict.type
	
	# set datatype of value
	match typeof(variables[dict.variable]):
		TYPE_STRING:
			value = str(value)

			# check for invalid operators
			if operator > 2:
				printerr('Invalid operator for type: String')
				parser.proceed(dict.link)
				return
		TYPE_INT:
			value = int(value)
		TYPE_FLOAT:
			value = float(value)
		TYPE_BOOL:
			value = (value == 'true') if value is String else bool(value)

			# check for invalid operators
			if operator > 0:
				printerr('Invalid operator for type: Boolean')
				parser.proceed(dict.link)
				return

	# perform operation
	match operator:
		0:
			variables[dict.variable] = value
		1:
			variables[dict.variable] += value
		2:
			variables[dict.variable] -= value
		3:
			variables[dict.variable] *= value
		4:
			variables[dict.variable] /= value
	
	parser.variable_changed.emit(dict.variable, variables[dict.variable])
	parser.proceed(dict.link)

