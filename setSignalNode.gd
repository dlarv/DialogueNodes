@tool
extends BaseDialogueNode

var last_type: int
var last_variable_value: String
var last_signal_value: Variant


func _ready() -> void:
	_register_timer(%Value, "text_changed", _on_variable_changed)
	%Variable.undo_redo = undo_redo

	_register_timer(%SignalValue, "text_changed", _on_signal_value_text_changed)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	# Set
	dict['variable'] = %Variable.curr_variable
	dict['type'] = %Type.selected
	dict['value'] = %Value.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'

	# Signal
	dict['signal_value'] = $SignalValue.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	# Set Value
	%Variable.setup(dict['variable'])

	%Type.selected = dict['type']
	%Value.text = dict['value']
	
	last_type = %Type.selected
	last_variable_value = %Value.text


	# Signal Value
	# To preserve backwards compatibility
	if dict.has('signalValue'):
		$SignalValue.text = dict['signalValue']
	elif dict.has('signal_value'):
		$SignalValue.text =  dict['signal_value']

	last_signal_value = $SignalDropdown.text
	
	return [dict['link']]


func set_value(new_value: String) -> void:
	if %Value.text != new_value:
		%Value.text = new_value
	last_variable_value = new_value


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


func _on_variable_changed() -> void:
	if not undo_redo:
		set_value(%Value.text)
		return

	undo_redo.create_action('Set %Value')
	undo_redo.add_do_method(self, 'set_value', %Value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_variable_value)
	undo_redo.commit_action()


func _on_variables_updated(variables_list: Array[String]) -> void:
	%Variable.update_variables(variables_list)


func set_signal(new_value: Variant) -> void:
	if new_value is String:
		%SignalValue.text = new_value
	elif $SignalDropdown.selected != new_value:
		$SignalDropdown.selected = new_value
	last_signal_value = new_value


func _on_signal_value_changed() -> void:
	if not undo_redo:
		set_signal($SignalDropdown.selected)
		return
	
	undo_redo.create_action('Set signal SignalValue')
	undo_redo.add_do_method(self, 'set_signal', $SignalDropdown.selected)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_signal', last_signal_value)
	undo_redo.commit_action()


func _on_signal_value_text_changed() -> void:
	if not undo_redo:
		return
	undo_redo.create_action('Set signal SignalValue')
	undo_redo.add_do_method(self, 'set_signal', $SignalValue.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_signal', last_signal_value)
	undo_redo.commit_action()


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
	parser.dialogue_signal.emit(dict.signal_value)
	parser.proceed(dict.link)
