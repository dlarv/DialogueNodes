@tool
extends Control

var undo_redo: EditorUndoRedoManager
var last_signal_text: String
var last_signal_index: int

func _ready() -> void:
	_on_story_manager_changed()


func _on_button_toggled(use_text: bool) -> void:
	if not undo_redo: return
	undo_redo.create_action('Toggle Signal Mode')
	undo_redo.add_do_property(%OptionButton, "visible", not use_text)
	undo_redo.add_do_property(%LineEdit, "visible", use_text)
	undo_redo.add_undo_property(%OptionButton, "visible", use_text)
	undo_redo.add_undo_property(%LineEdit, "visible", not use_text)
	undo_redo.commit_action()


func _on_story_manager_changed() -> bool:
	if not populate_dropdown(StoryManager.get_valid_signals()):
		%Button.hide()
		_on_button_toggled(true)
		return false
	return true


func from_dict(v: Variant) -> void:
	var dict: Dictionary
	if v is Dictionary:
		dict = v
	else:
		# Preserve backwards compatibility
		dict = {
			"use_enum": false,
			"value": v
		}

	# Only preserve use_enum if StoryManager has enum values
	dict.use_enum = dict.use_enum and _on_story_manager_changed()

	if dict.use_enum:
		_on_button_toggled(false)
		var val: Variant = dict.value
		var idx: int = val if val is int else StoryManager.get_valid_signals().find(val)
		set_signal_index(idx)
	else:
		_on_button_toggled(true)
		set_signal_text(dict.value)


func to_dict() -> Dictionary:
	return {
		"use_enum": %OptionButton.visible,
		"value": last_signal_text
	}


func populate_dropdown(options: Array) -> bool:
	if len(options) == 0:
		return false

	%OptionButton.clear()
	for opt: String in options:
		%OptionButton.add_item(opt)

	return true


func _on_line_edit_text_changed(new_text: String) -> void:
	$LineEditTimer.stop()
	$LineEditTimer.start()


func _on_line_edit_timer_timeout() -> void:
	if not undo_redo: return
	undo_redo.create_action('Change Signal Text')
	undo_redo.add_do_method(self, "set_signal_text", %LineEdit.text)
	undo_redo.add_undo_method(self, "set_signal_text", last_signal_text)
	undo_redo.commit_action()


func set_signal_text(val: String) -> void:
	if %LineEdit.text != val:
		%LineEdit.text = val
	last_signal_text = val


func _on_option_button_item_selected(idx: int) -> void:
	if not undo_redo: return
	undo_redo.create_action('Change Selected Signal')
	undo_redo.add_do_method(self, "set_signal_index", idx)
	undo_redo.add_undo_property(self, "set_signal_index", last_signal_index)
	undo_redo.commit_action()


func set_signal_index(idx: int) -> void:
	last_signal_index = idx
	last_signal_text = %OptionButton.get_item_text(idx)
	%OptionButton.select(idx)
