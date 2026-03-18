@tool
extends BaseDialogueNode

var last_value := ''

func _ready() -> void:
	_register_timer($SignalValue, "text_changed", _on_signal_value_changed)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['signalValue'] = $SignalValue.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	$SignalValue.text = dict['signalValue']
	last_value = $SignalValue.text
	
	return [dict['link']]


func set_value(new_value: String) -> void:
	if $SignalValue.text != new_value:
		$SignalValue.text = new_value
	last_value = new_value


func _on_signal_value_changed() -> void:
	if not undo_redo:
		set_value($SignalValue.text)
	
	undo_redo.create_action('Set signal SignalValue')
	undo_redo.add_do_method(self, 'set_value', $SignalValue.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()

