@tool
extends BaseDialogueNode

var data: Dictionary

func _from_dict(dict: Dictionary) -> Array[String]: 
	data = dict
	$Label.text = str(dict)

	return [dict['link']]


func _to_dict(graph: GraphEdit) -> Dictionary: 
	var dict := {}
	dict.merge(data)

	var connections: Array = graph.get_connections(name)
	dict['link'] = connections[0]['to_node'] if connections.size() > 0 else 'END'
	
	return dict
