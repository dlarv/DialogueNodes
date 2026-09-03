@tool
extends PanelContainer

var undo_redo: EditorUndoRedoManager

func load_data(nodes: Array[String], effects: Array[String]) -> void:
	%CustomNodeList.add_func = StoryEditor.add_custom_node
	%CustomNodeList.remove_func = StoryEditor.remove_custom_node
	%CustomNodeList.update_func = StoryEditor.set_custom_node_path
	%CustomNodeList.load_data(nodes)

	%CustomEffectList.load_data(effects)
