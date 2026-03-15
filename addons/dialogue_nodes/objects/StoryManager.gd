@tool
extends Node

signal character_list_updated

@export var characters: Array[Character]
var variables: Dictionary[String, Variant]


func add_character(character: Character) -> void:
	characters.append(character)
	character_list_updated.emit()


func remove_character(character: Character) -> void:
	var idx: int = StoryManager.characters.find(character)
	StoryManager.characters.remove_at(idx)
	character_list_updated.emit()
