@tool
extends Resource
class_name StoryState

signal character_list_updated
signal variable_list_updated(list: Array[String])

@export var characters: Array[Character]
@export var variables: Dictionary[String, Dictionary]
@export var custom_dialog_nodes: Array[String]
@export var custom_text_effects: Array[String]


func get_variable_list() -> Array[String]:
	return variables.keys()


## Takes mixed local and global vars and updates global var values
func update_variables(data: Dictionary) -> void:
	for key in data:
		if variables.has(key):
			variables[key].value = data[key]


func get_custom_nodes() -> Array[PackedScene]:
	if not ProjectSettings.has_setting("application/story_manager/custom_nodes"):
		return []

	var output: Array[PackedScene] = []
	for path in ProjectSettings.get_setting("application/story_manager/custom_nodes"):
		var node := load(path)
		if node is PackedScene:
			if not node.instantiate() is BaseDialogueNode:
				push_error("CustomNode(%s) does not inherit BaseDialogueNode! Skipping...")
				continue
			output.append(node)
	return output
