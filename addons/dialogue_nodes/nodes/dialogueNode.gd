@tool
extends BaseDialogueNode

signal character_list_requested(dialogue_node: GraphNode)

@export var max_options := 4

var last_size := size
var last_custom_speaker := ''
var cur_speaker := -1
var cur_sprite := -1
var last_dialogue := ''
var OptionScene := preload('res://addons/dialogue_nodes/nodes/sub_nodes/DialogueNodeOption.tscn')
var options: Array = []
var empty_option: BoxContainer
var first_option_index := -1
var base_color: Color = Color.WHITE

var _character: Character = null


func _ready() -> void:
	_register_timer(%Dialogue, "text_changed", _on_dialogue_text_changed)
	_register_timer(%CustomSpeaker, "text_changed", _on_custom_speaker_changed)

	options.clear()
	for idx in range(get_child_count() - 1, -1, -1):
		var child = get_child(idx)
		if child.is_in_group('dialogue_node_options'):
			add_option(child)
			first_option_index = child.get_index()
			break
	update_slots()
	reset_size()

	%SpriteSelector.item_selected.connect(func(idx: int) -> void:
		if _character == null: return
		%SpriteTextureRect.texture = _character.get_sprite_image(idx)
	)


func _to_dict(graph: GraphEdit) -> Dictionary:
	var dict := {}
	var empty_condition: Array[Dictionary] = []
	
	if %CustomSpeaker.visible:
		%CustomSpeaker.text = %CustomSpeaker.text.replace('{', '').replace('}', '')
		dict['speaker'] = %CustomSpeaker.text
	elif %Speaker.visible:
		var speaker_idx: int = %Speaker.selected
		dict['speaker'] = speaker_idx
		dict['sprite'] = %SpriteSelector.selected
	
	dict['dialogue'] = %Dialogue.text
	dict['size'] = size

	# get options connected to other nodes
	var options_dict := {}
	for connection in graph.get_connections(name):
		# this returns index starting from 0
		var idx: int = connection['from_port']
		
		options_dict[idx] = {}
		options_dict[idx]['text'] = options[idx].text
		options_dict[idx]['link'] = connection['to_node']
		options_dict[idx]['condition'] = options[idx].get_condition()
	
	# get options not connected
	for i in range(options.size()):
		if not options_dict.has(i) and options[i].text != '':
			options_dict[i] = {}
			options_dict[i]['text'] = options[i].text
			options_dict[i]['link'] = 'END'
			options_dict[i]['condition'] = options[i].get_condition()
	
	# single empty disconnected option
	if options_dict.is_empty():
		options_dict[0] = {}
		options_dict[0]['text'] = ''
		options_dict[0]['link'] = 'END'
		options_dict[0]['condition'] = empty_condition
	
	# store options info in dict
	dict['options'] = options_dict
	
	return dict


func _from_dict(dict: Dictionary) -> Array[String]:
	var next_nodes: Array[String] = []
	
	# set values
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
	%Dialogue.text = dict['dialogue']
	%DialogueExpanded.text = %Dialogue.text
	last_dialogue = %Dialogue.text
	
	# remove any existing options (if any)
	for option in options:
		option.queue_free()
	options.clear()
	
	# add new options
	for idx in dict['options']:
		var condition: Array[Dictionary] = []
		if dict['options'][idx].has('condition'):
			var cur_condition = dict['options'][idx]['condition']
			# For pre v1.3
			if cur_condition is Dictionary:
				condition = [cur_condition]
			else:
				condition = cur_condition
		var new_option := OptionScene.instantiate()
		add_option(new_option, first_option_index + int(idx))
		new_option.set_text(dict['options'][idx]['text'])
		new_option.set_condition(condition)
		next_nodes.append(dict['options'][idx]['link'])
	# add empty option if any space left
	if options.size() < max_options and options[-1].text != '':
		var new_option := OptionScene.instantiate()
		add_option(new_option)
	update_slots()
	
	# set size of node
	if dict.has('size'):
		var new_size: Vector2
		if dict['size'] is Vector2:
			new_size = dict['size']
		else: # for Dialogue files created before v1.0.2
			new_size = Vector2( float(dict['size']['x']), float(dict['size']['y']) )
		size = new_size
		last_size = size
	
	return next_nodes


func set_custom_speaker(new_custom_speaker: String) -> void:
	if %CustomSpeaker.text != new_custom_speaker:
		%CustomSpeaker.text = new_custom_speaker
	last_custom_speaker = %CustomSpeaker.text


func toggle_speaker_input(use_speaker_list: bool) -> void:
	%CustomSpeaker.visible = not use_speaker_list
	%Speaker.visible = use_speaker_list
	%SpriteSelector.visible = use_speaker_list
	%SpriteTextureRect.visible = use_speaker_list


func set_dialogue_text(new_text: String) -> void:
	if %Dialogue.text != new_text:
		%Dialogue.text = new_text
	if %DialogueExpanded.text != new_text:
		%DialogueExpanded.text = %Dialogue.text
	last_dialogue = %Dialogue.text


func add_option(option: BoxContainer, to_idx := -1) -> void:
	if option.get_parent() != self: add_child(option, true)
	if to_idx > -1: move_child(option, to_idx)
	
	option.undo_redo = undo_redo
	option.modified.connect(_on_modified)
	option.text_changed.connect(_on_option_text_changed.bind(option))
	option.focus_exited.connect(_on_option_focus_exited.bind(option))
	options.append(option)
	
	# sort options in the array
	options.sort_custom(func (op1, op2):
		return op1.get_index() < op2.get_index()
		)
	
	# shift slot connections
	var index := options.find(option)
	for i in range(options.size() - 1, index, -1):
		if options[i].text != '':
			connection_shift_request.emit(name, i - 1, i)


func remove_option(option: BoxContainer) -> void:
	# shift slot connections
	var index := options.find(option)
	for i in range(index, options.size() - 1):
		if options[i + 1].text != '':
			connection_shift_request.emit(name, i + 1, i)
	
	options.erase(option)
	option.modified.disconnect(_on_modified)
	option.text_changed.disconnect(_on_option_text_changed.bind(option))
	option.focus_exited.disconnect(_on_option_focus_exited.bind(option))
	
	if option.get_parent() == self: remove_child(option)


func update_slots() -> void:
	if options.size() == 1:
		set_slot(options[0].get_index(), false, 0, base_color, true, 0, base_color)
		return
	
	for option in options:
		var enabled: bool = option.text != ''
		set_slot(option.get_index(), false, 0, base_color, enabled, 0, base_color)


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


func _on_characters_updated() -> void:
	%Speaker.clear()
	var character_list := StoryManager.characters
	
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
	cur_speaker = idx

	%SpriteSelector.clear()
	var character = StoryManager.characters[idx]
	_character = character
	for i in character.get_sprite_count():
		%SpriteSelector.add_item(character.get_sprite_name(i))


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
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_select_speaker', cur_sprite)
	undo_redo.add_undo_method(%SpriteSelector, 'select', cur_sprite)
	undo_redo.commit_action()
	

func _select_sprite(idx: int) -> void:
	cur_sprite = idx
	%SpriteTextureRect.texture = _character.get_sprite_image(idx)


func _on_dialogue_text_changed() -> void:
	if not undo_redo: 
		set_dialogue_text(%Dialogue.text)
		return

	undo_redo.create_action('Set Dialogue text')
	if %DialoguePanel.visible:
		undo_redo.add_do_method(self, 'set_dialogue_text', %DialogueExpanded.text)
	else:
		undo_redo.add_do_method(self, 'set_dialogue_text', %Dialogue.text)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(%DialogueExpanded, 'release_focus')
	undo_redo.add_undo_method(self, 'set_dialogue_text', last_dialogue)
	undo_redo.commit_action()


func _on_expand_button_pressed() -> void:
	%DialoguePanel.popup_centered()
	%DialogueExpanded.grab_focus()


func _on_close_button_pressed() -> void:
	%DialoguePanel.hide()


func _on_option_text_changed(new_text: String, option: BoxContainer) -> void:
	if not undo_redo: return
	
	var idx := option.get_index()
	
	# case 0: option was queued for deletion but changed from '' to 'something'
	if option == empty_option:
		if new_text == '': return
		undo_redo.create_action('Set option text')
		undo_redo.add_do_method(option, 'set_text', new_text)
		undo_redo.add_do_method(self, 'update_slots')
		undo_redo.add_do_method(self, '_on_modified')
		undo_redo.add_undo_method(self, '_on_modified')
		undo_redo.add_undo_method(option, 'set_text', option.text)
		undo_redo.add_undo_method(self, 'update_slots')
		undo_redo.commit_action()
		empty_option = null
		return
	
	if new_text == option.text: return
	
	# case 1: option changed from '' to 'something'
	if option.text == '':
		if idx == (get_child_count() - 1) and options.size() < max_options:
			var new_option = OptionScene.instantiate()
			
			undo_redo.create_action('Set option text')
			undo_redo.add_do_method(option, 'set_text', new_text)
			undo_redo.add_do_method(self, 'add_option', new_option)
			undo_redo.add_do_method(self, 'update_slots')
			undo_redo.add_do_reference(new_option)
			undo_redo.add_do_method(self, '_on_modified')
			undo_redo.add_undo_method(self, '_on_modified')
			undo_redo.add_undo_method(option, 'set_text', option.text)
			undo_redo.add_undo_method(self, 'remove_option', new_option)
			undo_redo.add_undo_method(self, 'update_slots')
			undo_redo.add_undo_method(self, 'set_size', size)
			undo_redo.commit_action()
			return
	
	# case 2: option changed from 'something' to ''
	elif new_text == '':
		if idx != (get_child_count() - 1):
			empty_option = option
			return
		disconnection_from_request.emit(name, idx - first_option_index)
	
	# case 3: text changed from something to something else (neither are '')
	undo_redo.create_action('Set option text')
	undo_redo.add_do_method(option, 'set_text', new_text)
	undo_redo.add_do_method(self, 'update_slots')
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_method(option, 'set_text', option.text)
	undo_redo.add_undo_method(self, 'update_slots')
	undo_redo.commit_action()


func _on_option_focus_exited(option: BoxContainer) -> void:
	if not undo_redo: return
	
	# case 2: remove option when focus exits
	if option == empty_option:
		var idx := option.get_index()
		
		disconnection_from_request.emit(name, idx - first_option_index)
		
		undo_redo.create_action('Remove option')
		undo_redo.add_do_method(self, 'remove_option', option)
		# if the last option has some text, then create a new empty option
		if options[-1].text != '':
			var new_option = OptionScene.instantiate()
			undo_redo.add_do_method(self, 'add_option', new_option)
			undo_redo.add_do_reference(new_option)
			undo_redo.add_undo_method(self, 'remove_option', new_option)
		undo_redo.add_do_method(self, 'update_slots')
		undo_redo.add_do_method(self, '_on_modified')
		undo_redo.add_undo_method(self, '_on_modified')
		undo_redo.add_undo_method(self, 'add_option', option, idx)
		undo_redo.add_undo_method(option, 'set_text', option.text)
		undo_redo.add_undo_method(self, 'update_slots')
		undo_redo.commit_action()
		empty_option = null


func _on_variables_updated(variables_list: Array[String]) -> void:
	for option in options:
		option.update_variables(variables_list)


func _on_resize_end(new_size: Vector2) -> void:
	if not undo_redo: return
	
	undo_redo.create_action('Set node size')
	undo_redo.add_do_method(self, 'set_size', size)
	undo_redo.add_do_property(self, 'last_size', size)
	undo_redo.add_do_method(self, '_on_modified')
	undo_redo.add_undo_method(self, '_on_modified')
	undo_redo.add_undo_property(self, 'last_size', last_size)
	undo_redo.add_undo_method(self, 'set_size', last_size)
	undo_redo.commit_action()

