@tool
extends HBoxContainer

signal modified
signal text_changed(new_text : String)

@export var show_filter_button: bool = true

@onready var line_edit = $LineEdit
@onready var filter_button = $FilterButton
@onready var filter_panel = $FilterPanel
@onready var condition_list = $FilterPanel/ConditionList

var undo_redo : EditorUndoRedoManager :
	set(value):
		undo_redo = value
		if is_instance_valid(condition_list):
			condition_list.undo_redo = undo_redo
var text := ''
var filter_popup_offset := 50


func _ready():
	text = line_edit.text


func get_slot_index():
	var parent := get_parent_control()
	if parent == null:
		return null
	var children := parent.get_children()
	return children.filter(func(val): return val is Control).find(self)


func get_condition():
	return condition_list._to_dict()


func set_condition(new_condition: Array):
	if !show_filter_button:
		push_warning('Cannot set condition on a ForkOption with <show_filter_button> to FALSE!')
		return
	
	condition_list._from_dict(new_condition)
	filter_button.text = '' if condition_list.is_empty() else '*'


# Godot defaults the var to false even if the PackedScene export says otherwise, so this is needed.
func toggle_expand_to_text(toggled_on : bool):
	if !is_node_ready():
		await ready
	line_edit.expand_to_text_length = toggled_on


func set_text(new_text : String):
	if line_edit.text != new_text:
		line_edit.text = new_text
		filter_button.visible = show_filter_button and new_text != ''
	text = new_text


func is_empty():
	return text == ''


func _on_filter_button_pressed():
	var popup_pos : Vector2 = global_position + filter_button.position + Vector2(0, filter_button.size.y + size.y + filter_popup_offset)
	filter_panel.popup(Rect2i(popup_pos, filter_panel.size))


func _on_text_changed(new_text : String):
	filter_button.visible = show_filter_button and new_text != ''
	text_changed.emit(new_text)


func _on_text_focus_exited():
	focus_exited.emit()


func _on_modified():
	filter_button.text = '' if condition_list.is_empty() else '*'
	filter_panel.size.y = 0
	modified.emit()
