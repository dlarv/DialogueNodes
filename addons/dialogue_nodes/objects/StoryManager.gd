@tool
extends Node
#

@export var characters: Array[Character]:
	get:
		return _story_state.characters

@export var variables: Dictionary[String, Dictionary]:
	get:
		return _story_state.variables

var _story_state: StoryState

func _enter_tree() -> void:
	_story_state = ResourceLoader.load("res://story_state.tres")


# ## Takes mixed local and global vars and updates global var values
func update_variables(data: Dictionary) -> void:
	for key in data:
		if variables.has(key):
			variables[key].value = data[key]
