@tool
extends VBoxContainer

var undo_redo: EditorUndoRedoManager

var last_custom_speaker := ''
var cur_speaker := -1
var cur_sprite := -1

var _character: Character = null

func _ready() -> void:
	%SpriteSelector.item_selected.connect(func(idx: int) -> void:
		if _character == null: return
		%SpriteTextureRect.texture = _character.get_sprite_image(idx)
	)


func get_sprite() -> int:
	if %CustomSpeaker.visible:
		return 0
	else:
		return %SpriteSelector.selected


func get_speaker() -> Variant:
	if %CustomSpeaker.visible:
		return %CustomSpeaker.text
	else:
		return %Speaker.selected


func from_dict(dict: Dictionary) -> void:
	if dict['speaker'] is String:
		%CustomSpeaker.text = dict['speaker']
		last_custom_speaker = %CustomSpeaker.text
	elif dict['speaker'] is int:
		cur_speaker = dict['speaker']
		%Speaker.selected = cur_speaker
		_select_speaker(cur_speaker)

		if dict.has('sprite'):
			cur_sprite = dict['sprite']
		else:
			cur_sprite = 0
		%SpriteSelector.selected = cur_sprite
		_select_sprite(cur_sprite)


		%CharacterToggle.set_pressed_no_signal(true)
		toggle_speaker_input(true)


func set_custom_speaker(new_custom_speaker: String) -> void:
	if %CustomSpeaker.text != new_custom_speaker:
		%CustomSpeaker.text = new_custom_speaker
	last_custom_speaker = %CustomSpeaker.text


func toggle_speaker_input(use_speaker_list: bool) -> void:
	%CustomSpeaker.visible = not use_speaker_list
	%Speaker.visible = use_speaker_list
	%SpriteSelector.visible = use_speaker_list
	%SpriteTextureRect.visible = use_speaker_list


func _on_custom_speaker_changed() -> void:
	if not undo_redo: 
		set_custom_speaker(%CustomSpeaker.text)
		return
	
	undo_redo.create_action('Set custom Speaker')
	undo_redo.add_do_method(self, 'set_custom_speaker', %CustomSpeaker.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'set_custom_speaker', last_custom_speaker)
	undo_redo.commit_action()


func update_characters(character_list: Array[Character]) -> void:
	%Speaker.clear()
	
	for character in character_list:
		%Speaker.add_item(character.name)
	
	if character_list.size() > 0:
		if cur_speaker > character_list.size():
			cur_speaker = 0
		%Speaker.select(cur_speaker)
	else:
		%Speaker.select(-1)


func _on_speaker_selected(idx: int) -> void:
	if not undo_redo: 
		_select_speaker(idx)
		return
	
	undo_redo.create_action('Set Speaker')
	undo_redo.add_do_method(self, '_select_speaker', idx)
	undo_redo.add_do_method(%Speaker, 'select', idx)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_select_speaker', cur_speaker)
	undo_redo.add_undo_method(%Speaker, 'select', cur_speaker)
	undo_redo.commit_action()


func _select_speaker(idx: int) -> void:
	if _character != null:
		_character.sprite_list_updated.disconnect(_on_sprite_list_updated)
	cur_speaker = idx

	_character = StoryEditor.characters[idx]
	_on_sprite_list_updated()

	_character.sprite_list_updated.connect(_on_sprite_list_updated)


func _on_sprite_list_updated() -> void:
	%SpriteSelector.clear()
	for i in _character.get_sprite_count():
		%SpriteSelector.add_item(_character.get_sprite_name(i))
	
	if cur_sprite:
		%SpriteSelector.selected = cur_sprite


func _on_speaker_toggled(toggled_on: bool) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Toggle character list')
	undo_redo.add_do_method(%CharacterToggle, 'set_pressed_no_signal', toggled_on)
	undo_redo.add_do_method(self, 'toggle_speaker_input', toggled_on)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, 'toggle_speaker_input', not toggled_on)
	undo_redo.add_undo_method(%CharacterToggle, 'set_pressed_no_signal', not toggled_on)
	undo_redo.commit_action()


func _on_sprite_selector_item_selected(idx: int) -> void:
	if not undo_redo:
		_select_sprite(idx)
		return

	undo_redo.create_action('Set Sprite')
	undo_redo.add_do_method(self, '_select_sprite', idx)
	undo_redo.add_do_method(%SpriteSelector, 'select', idx)
	undo_redo.add_undo_method(self, '_select_speaker', cur_sprite)
	undo_redo.add_undo_method(%SpriteSelector, 'select', cur_sprite)
	undo_redo.commit_action()
	

func _select_sprite(idx: int) -> void:
	cur_sprite = idx
	%SpriteTextureRect.texture = _character.get_sprite_image(idx)


func _on_custom_speaker_text_changed(new_text: String) -> void:
	$CustomSpeakerTimer.stop()
	$CustomSpeakerTimer.start()
