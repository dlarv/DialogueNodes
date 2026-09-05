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


static func process(parser: DialogueParser, dict: Dictionary):
	var key: Variant = dict.signal_value.value
	if dict.signal_value.use_enum:
		key = StoryManager.get_signal_from_key(dict.signal_value.value)

	parser.dialogue_signal.emit(key)
	parser.proceed(dict.link)
