@tool
extends VBoxContainer

signal delete_requested
signal name_changed(new_name: String)
signal image_changed(new_image: Texture2D)

var file_popup: FileDialog
var undo_redo: EditorUndoRedoManager
var curr_text: String

var _character: Character
var _index: int


func setup(chara: Character, idx: int, popup: FileDialog) -> void:
	_character = chara
	_index = idx

	_character.sprite_removed.connect(_on_sprite_removed)

	$NameInput.text = chara.get_sprite_name(idx)
	$TextureRect.texture = chara.get_sprite_image(idx)
	file_popup = popup


func _on_delete_button_pressed() -> void:
	_character.remove_sprite(_index)
	delete_requested.emit()


func _on_select_button_pressed() -> void:
	file_popup.show()
	await file_popup.visibility_changed
	var path := file_popup.current_path
	if path.is_empty() or path == "res://": return

	var image := ResourceLoader.load(path)
	if image is Texture2D:
		$TextureRect.texture = image
		_character.set_sprite_image(_index, image)
		image_changed.emit(image)


func _on_line_edit_text_changed(new_text: String) -> void:
	$NameTimer.stop()
	$NameTimer.start()


func _on_name_timer_timeout() -> void:
	if not undo_redo:
		_set_name($NameInput.text)
		return

	undo_redo.create_action("Set Sprite Name")
	undo_redo.add_do_method(self, "_set_name", $NameInput.text)
	undo_redo.add_undo_method(self, "_set_name", curr_text)
	undo_redo.commit_action()


func _set_name(new_name: String) -> void:
	curr_text = new_name
	_character.set_sprite_name(_index, new_name)
	name_changed.emit(new_name)


func _on_sprite_removed(idx: int) -> void:
	if idx > _index: return
	_index -= 1
