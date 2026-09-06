@tool
extends PanelContainer

const PATH := "res://addons/dialogue_nodes/objects/StoryManager.tscn"
const StoryManagerScene := preload(PATH)

func _ready() -> void:
	load_data()


func load_data() -> void:
	$Variables.load_data(StoryEditor.variables, false)


func save_data() -> void:
	StoryEditor.update_variables($Variables.get_data())
	StoryEditor.save_data()


func _on_variables_variable_added(name: String, _data: Dictionary) -> void:
	StoryEditor.new_variable(name)


func _on_variables_variable_removed(name: String) -> void:
	StoryEditor.remove_variable(name)


func _on_variables_variable_name_updated(old_name: String, new_name: String) -> void:
	StoryEditor.rename_variable(old_name, new_name)


func _on_variables_modified() -> void:
	%SaveButton.text = "Save*"

