@tool
extends Node

signal character_list_updated

@export var characters: Array[Character]
var variables: Dictionary[String, Variant]


func add_character(character: Character) -> void:
	characters.append(character)
	character_list_updated.emit()


