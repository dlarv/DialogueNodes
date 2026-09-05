@tool
extends Node
class_name BaseStoryManager

## When inheriting from this script, declaring this enum will allow you to use these values inside of signal nodes
# enum DialogSignal {}

var characters: Array[Character]:
	get:
		if len(characters) == 0:
			load_data()
		return characters

var variables: Dictionary[String, Dictionary]:
	get:
		if len(variables) == 0:
			load_data()
		return variables 

var custom_node_functions: Array[Callable]:
	get:
		if len(custom_node_functions):
			load_data()
		return custom_node_functions

var custom_text_effects: Array[RichTextEffect]:
	get:
		if len(custom_text_effects):
			load_data()
		return custom_text_effects
	

func _enter_tree() -> void:
	load_data()


func load_data() -> void:
	var story_state := StoryState.load_story_state()
	variables = story_state.variables
	characters = story_state.characters

	custom_node_functions = []
	for node in story_state.get_custom_nodes():
		custom_node_functions.append(node.instantiate().process)
	
	custom_text_effects = story_state.get_custom_text_effects()


# ## Takes mixed local and global vars and updates global var values
func update_variables(data: Dictionary) -> void:
	for key in data:
		if variables.has(key):
			variables[key].value = data[key]


func get_valid_signals() -> Array:
	return []


func get_signal_from_key(key: String) -> Variant: 
	return key
