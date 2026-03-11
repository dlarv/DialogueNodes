@tool
extends BaseDialogueNode

@onready var value := $SignalValue
@onready var timer := _get_new_timer()

var last_value := ''


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['signalValue'] = value.text
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	value.text = dict['signalValue']
	last_value = value.text
	
	return [dict['link']]


func set_value(new_value: String) -> void:
	if value.text != new_value:
		value.text = new_value
	last_value = new_value


func _on_signal_value_changed(_new_text) -> void:
	if _is_continuing_action(timer): return
	timer.start()
	
	undo_redo.create_action('Set signal value')
	undo_redo.add_do_method(self, 'set_value', value.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_value', last_value)
	undo_redo.commit_action()

