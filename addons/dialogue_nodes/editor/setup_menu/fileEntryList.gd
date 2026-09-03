@tool
extends MarginContainer

const FileEntry := preload("res://addons/dialogue_nodes/editor/setup_menu/entry.tscn")

@export var title: String:
	set(val):
		title = val
		%Title.text = val
@export_multiline var description: String:
	set(val):
		description = val
		%Description.text = val

@export var valid_type_is_node := true

var add_func: Callable
var remove_func: Callable
var update_func: Callable

var _data: Array[Control]


func load_data(data: Array[String]) -> void:
	_data = []
	for d in data:
		add_entry(d)


func add_entry(path:="") -> void:
	var entry := FileEntry.instantiate()
	_data.append(entry)
	%Scroller.add_child(entry)

	entry.is_node = valid_type_is_node

	entry.file_dialog_requested.connect(_on_file_dialog_requested)
	entry.value_set.connect(_on_value_set)
	entry.removal_requested.connect(_on_removal_requested)
	
	if path != "":
		entry.set_file(path)


func _on_add_button_pressed() -> void:
	add_entry()
	add_func.call()


func _on_file_dialog_requested(entry: Control) -> void:
	%FileDialog.show()
	var path: String = await %FileDialog.file_selected
	%FileDialog.hide()

	if path == null or path == "": return

	entry.set_file(path)


func _on_value_set(entry: Control) -> void:
	var idx := _data.find(entry)
	update_func.call(idx, entry.get_file())


func _on_removal_requested(entry: Control) -> void:
	var idx := _data.find(entry)
	_data.remove_at(idx)
	%Scroller.remove_child(entry)
	remove_func.call(idx)
