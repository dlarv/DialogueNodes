@tool
extends Node

signal character_list_updated
signal variable_list_updated(list: Array[String])

@export var characters: Array[Character]
@export var variables: Dictionary[String, Dictionary]


func add_character(character: Character) -> void:
	characters.append(character)
	character_list_updated.emit()


func remove_character(character: Character) -> void:
	var idx: int = StoryManager.characters.find(character)
	StoryManager.characters.remove_at(idx)
	character_list_updated.emit()


func new_variable(key: String) -> void:
	if variables.has(key):
		push_error("Could not add var. '%s' already exists" % key)
		return
	variables[key] = {}
	variable_list_updated.emit(get_variable_list())


func remove_variable(key: String) -> void:
	if not variables.has(key):
		push_error("Could not remove var. '%s' not found" % key)
		return
	variables.erase(key)
	variable_list_updated.emit(get_variable_list())


func rename_variable(old_name: String, new_name: String) -> void:
	if not variables.has(old_name):
		push_error("Could not rename var. '%s' not found" % old_name)
		return

	var data := variables.get(old_name)
	variables.erase(old_name)
	variables[new_name] = data

	variable_list_updated.emit(get_variable_list())

func get_variable_list() -> Array[String]:
	return variables.keys()
