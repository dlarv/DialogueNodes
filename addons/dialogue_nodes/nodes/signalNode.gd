@tool
extends BaseDialogueNode

func _ready() -> void:
	%SignalSelector.undo_redo = undo_redo


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var connections: Array = graph.get_connections(name)
	
	dict['signal_value'] = %SignalSelector.to_dict()
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	%SignalSelector.from_dict(dict['signal_value'])
	
	return [dict['link']]


# func set_value(new_value: String) -> void:
# 	if $SignalValue.text != new_value:
# 		$SignalValue.text = new_value
# 	last_value = new_value
#
#
# func _on_signal_value_changed() -> void:
# 	if not undo_redo:
# 		set_value($SignalValue.text)
#
# 	undo_redo.create_action('Set signal SignalValue')
# 	undo_redo.add_do_method(self, 'set_value', $SignalValue.text)
# 	undo_redo.add_do_method(self, '_on_modified')
# 	undo_redo.add_undo_method(self, '_on_modified')
# 	undo_redo.add_undo_method(self, 'set_value', last_value)
# 	undo_redo.commit_action()


static func process(parser: DialogueParser, dict: Dictionary):
	var key: Variant = dict.signal_value.value
	if dict.use_enum:
		key = StoryManager.get_signal_from_key(dict.signal_value.value)

	parser.dialogue_signal.emit(key)
	parser.proceed(dict.link)
