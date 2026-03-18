@tool
extends OptionButton

## Really long var names will mess up node sizing
const MAX_CHAR_LENGTH := 20

var undo_redo: EditorUndoRedoManager
var curr_variable: String
var curr_idx := -2


## For when data is loaded from dict. We only know what value was selected, not the other data
## update_variables(...) should be called before the user has a chance to select
func setup(v: String) -> void:
	clear()
	curr_variable = v
	add_item(v)


func update_variables(list: Array[String]) -> void:
	clear()
	for v in list:
		if len(v) > MAX_CHAR_LENGTH:
			add_item(v.substr(0, MAX_CHAR_LENGTH) + "...")
		else:
			add_item(v)


	var index := list.find(curr_variable)
	select(index)
	curr_idx = index


func _on_item_selected(idx: int) -> void:
	undo_redo.create_action('Set Variable')
	undo_redo.add_do_method(self, 'select', idx)
	undo_redo.add_do_method(self, 'set_variable', idx)
	undo_redo.add_undo_method(self, 'select', curr_idx)
	undo_redo.add_undo_method(self, 'set_variable', curr_idx)
	undo_redo.commit_action()


func set_variable(idx: int) -> void:
	curr_idx = idx
	curr_variable = get_item_text(idx)
