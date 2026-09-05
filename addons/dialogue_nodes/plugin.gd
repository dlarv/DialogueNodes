@tool
extends EditorPlugin


const EditorScene := preload('res://addons/dialogue_nodes/StoryEditor.tscn')
const DialogueBoxScene := preload('res://addons/dialogue_nodes/objects/DialogueBox.gd')
const DialogueBubbleScene := preload('res://addons/dialogue_nodes/objects/DialogueBubble.gd')
const DialogueBoxIcon := preload('res://addons/dialogue_nodes/icons/DialogueBox.svg')
const DialogueBubbleIcon := preload('res://addons/dialogue_nodes/icons/DialogueBubble.svg')
const BaseDialogueNodeScene := preload("res://addons/dialogue_nodes/nodes/baseDialogueNode.gd")
const SETTING_PATH_ROOT := "application/story_manager"

var editor: Control


func _enter_tree() -> void:
	editor = EditorScene.instantiate()
	
	# add editor to main viewport
	get_editor_interface().get_editor_main_screen().add_child(editor)
	
	# get undo redo manager
	editor.undo_redo = get_undo_redo()
	
	_make_visible(false)
	
	# add dialogue box and bubble nodes
	add_custom_type(
		'DialogueBox',
		'Panel',
		DialogueBoxScene,
		DialogueBoxIcon)
	add_custom_type(
		'DialogueBubble',
		'RichTextLabel',
		DialogueBubbleScene,
		DialogueBubbleIcon
	)
	add_custom_type(
		'BaseDialogueNode',
		'GraphNode',
		BaseDialogueNodeScene,
		DialogueBoxIcon
	)

	
	if not ProjectSettings.has_setting("autoload/StoryManager"):
		add_autoload_singleton("StoryManager", "res://addons/dialogue_nodes/objects/StoryManager.tscn")
		print_debug("Added default StoryManager singleton")
	_init_settings_menu()

	print_debug('Plugin Enabled')


func _exit_tree() -> void:
	# remove from main viewport
	if is_instance_valid(editor):
		editor.queue_free()
	
	remove_custom_type('DialogueBox')
	
	# remove_autoload_singleton("StoryManager")
	print_debug('Plugin Disabled')


func _has_main_screen() -> bool:
	return true


func _make_visible(visible) -> void:
	if is_instance_valid(editor):
		editor.visible = visible


func _get_plugin_name() -> String:
	return 'Dialogue'


func _get_plugin_icon() -> Texture2D:
	return preload('res://addons/dialogue_nodes/icons/Dialogue.svg')


func _handles(object) -> bool:
	return object is DialogueData


func _edit(object) -> void:
	if object is DialogueData and is_instance_valid(editor):
		editor.files.open_file(object.resource_path)


func _save_external_data() -> void:
	if is_instance_valid(editor):
		editor.files.save_all()


func _init_settings_menu() -> void:
	# Get StoryState path
	var story_state_path := "%s/story_state_path" % SETTING_PATH_ROOT
	var initial_state_path := &"res://story_state.tres"

	if not ProjectSettings.has_setting(story_state_path):
		ProjectSettings.set_setting(story_state_path, initial_state_path)

	ProjectSettings.set_initial_value(story_state_path, initial_state_path)

	ProjectSettings.add_property_info({
		"name": story_state_path,
		"type": TYPE_STRING,
		"hint": PropertyHint.PROPERTY_HINT_FILE,
	})

	# Get Custom Nodes
	var custom_node_path := "%s/custom_nodes" % SETTING_PATH_ROOT

	if not ProjectSettings.has_setting(custom_node_path):
		ProjectSettings.set_setting(custom_node_path, [])

	ProjectSettings.add_property_info({
		"name": custom_node_path,
		"type": TYPE_ARRAY,
		"hint": PropertyHint.PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d/%d:" % [ TYPE_STRING, PropertyHint.PROPERTY_HINT_FILE ]
	})

	ProjectSettings.set_restart_if_changed(custom_node_path, true)

	# Get Custom Text Effects
	var custom_effect_path := "%s/custom_text_effects" % SETTING_PATH_ROOT

	var path := "res://addons/dialogue_nodes/objects"
	var initial_value := [
			"%s/bbcodeWait.gd" % path,
			"%s/bbcodeGhost.gd" % path,
			"%s/bbcodeMatrix.gd" % path,
		]
	if not ProjectSettings.has_setting(custom_effect_path):
		ProjectSettings.set_setting(custom_effect_path, initial_value)

	ProjectSettings.set_initial_value(custom_effect_path, initial_value)

	ProjectSettings.add_property_info({
		"name": custom_effect_path,
		"type": TYPE_ARRAY,
		"hint": PropertyHint.PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d/%d:" % [ TYPE_STRING, PropertyHint.PROPERTY_HINT_FILE ]
	})

	ProjectSettings.set_restart_if_changed(custom_effect_path, true)


