@tool
extends BoxContainer


signal modified
signal delete_requested

const operator_texts := ['==', '!=', '>', '<', '>=', '<=']
const combiner_texts := ['OR', 'AND']

var undo_redo : EditorUndoRedoManager :
	set(value):
		undo_redo = value
		if is_instance_valid(%ConditionList):
			%ConditionList.undo_redo = undo_redo
var condition_popup_offset := 50

func get_condition() -> Array[Dictionary]:
	return %ConditionList._to_dict()


func set_condition(new_condition: Array[Dictionary]) -> void:
	%ConditionList._from_dict(new_condition)
	update_button_text()


func is_empty() -> bool:
	return %ConditionList.is_empty()


func update_button_text() -> void:
	$ConditionButton.text = 'Set condition'
	var new_condition: Array = %ConditionList._to_dict()
	if new_condition.size() == 0: return
	
	var new_text := ''
	for cond_dict: Dictionary in new_condition:
		if cond_dict.is_empty():
			new_text += 'true '
			continue
		new_text += cond_dict.value1 + ' '
		new_text += operator_texts[cond_dict.operator] + ' '
		new_text += cond_dict.value2 + ' '
		if cond_dict.has('combiner'): new_text += combiner_texts[cond_dict.combiner] + ' '
	$ConditionButton.text = new_text


func _on_condition_button_pressed() -> void:
	var popup_pos : Vector2 = global_position + $ConditionButton.position + Vector2(0, $ConditionButton.size.y + size.y + condition_popup_offset)
	$ConditionPanel.popup(Rect2i(popup_pos, $ConditionPanel.size))


func _on_delete_button_pressed() -> void:
	delete_requested.emit()


func _on_condition_panel_hide() -> void:
	update_button_text()


func _on_modified() -> void:
	$ConditionPanel.size.y = 0
	modified.emit()

func update_variables(variables_list: Array[String]) -> void:
	%ConditionList.update_variables(variables_list)
	
