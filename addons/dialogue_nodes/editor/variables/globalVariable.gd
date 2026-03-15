@tool
extends PanelContainer

const PATH := "res://addons/dialogue_nodes/objects/StoryManager.tscn"
const StoryManagerScene := preload(PATH)

func _ready() -> void:
	load_data()


func load_data() -> void:
	$Variables.load_data(StoryManager.variables, true)


func save_data() -> void:
	%SaveButton.text = "Save"

	# Determines whether scene should be opened or closed after saving sequence
	var _already_opened := PATH in EditorInterface.get_open_scenes()
	StoryManager.variables = $Variables.get_data()

	var scene := PackedScene.new()
	scene.pack(StoryManager)
	ResourceSaver.save(scene, PATH)

	# even though we know if it was open, we don't know if its active, hence this line
	EditorInterface.open_scene_from_path(PATH)
	# Scene will not officially save until it is closed and opened again.
	EditorInterface.close_scene()
	if _already_opened:
		EditorInterface.open_scene_from_path(PATH)


func _on_variables_variable_added(name: String, _data: Dictionary) -> void:
	StoryManager.new_variable(name)


func _on_variables_variable_removed(name: String) -> void:
	StoryManager.remove_variable(name)


func _on_variables_variable_name_updated(old_name: String, new_name: String) -> void:
	StoryManager.rename_variable(old_name, new_name)


func _on_variables_modified() -> void:
	%SaveButton.text = "Save*"

