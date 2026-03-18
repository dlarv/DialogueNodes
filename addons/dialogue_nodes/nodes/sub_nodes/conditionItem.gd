@tool
extends BoxContainer

signal modified
signal delete_requested

@export var is_last := false :
	set(value):
		is_last = value
		if is_instance_valid(%Combiner):
			%Combiner.visible = not is_last
@export var show_delete := false :
	set(value):
		show_delete = value
		if is_instance_valid(%DeleteButton):
			%DeleteButton.visible = show_delete

var undo_redo: EditorUndoRedoManager
var cur_condition := {}
var cur_variable := -1

func _to_dict() -> Dictionary:
	if is_empty():
		print_rich('[color=yellow]Condition is empty![/color]')
		return {}
	
	var dict:= {
		# 'cur_variable': %Value1.selected,
		'value1': %Value1.curr_variable,
		'operator': %Operator.selected,
		'value2': %Value2.text
	}

	
	if not is_last:
		dict['combiner'] = %Combiner.selected
	
	return dict


func _from_dict(dict: Dictionary) -> void:
	cur_condition = dict
	if dict.is_empty():
		dict = {
			'value1': '',
			'operator': 0,
			'value2': '',
			'combiner': 0
		}
		%ResetButton.hide()
	else:
		%ResetButton.show()

	%Value1.setup(dict['value1'])

	if %Operator.selected != dict['operator']:
		%Operator.selected = dict['operator']
	if %Value2.text != dict['value2']:
		%Value2.text = dict['value2']
	if dict.has('combiner'):
		%Combiner.selected = dict['combiner']

	%Value1.undo_redo = undo_redo


func is_empty() -> bool:
	return (%Value1.selected == -1) and (%Operator.selected == 0) and (%Value2.text == '')


func _on_condition_changing(_a=0) -> void:
	%Timer.stop()
	%Timer.start()


func _on_condition_changed() -> void:
	if not undo_redo: return
	
	var new_condition: Dictionary = _to_dict()
	
	undo_redo.create_action('Set condition')
	undo_redo.add_do_method(self, '_from_dict', new_condition)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_from_dict', cur_condition)
	undo_redo.commit_action()


func _on_condition_reset() -> void:
	if not undo_redo: return
	
	var new_condition := {}
	
	undo_redo.create_action('Reset condition')
	undo_redo.add_do_method(self, '_from_dict', new_condition)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_from_dict', cur_condition)
	undo_redo.commit_action()


func _on_delete_button_pressed() -> void:
	delete_requested.emit()


func _on_modified() -> void:
	modified.emit()


func _on_variables_updated(variable_list: Array[String]) -> void:
	%Value1.update_variables(variable_list)
