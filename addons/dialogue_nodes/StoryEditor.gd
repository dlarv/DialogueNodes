@tool
extends TabContainer
class_name StoryEditor

static var story_state: StoryState

static var characters: Array[Character]:
	get:
		if not story_state:
			load_data()
		return story_state.characters
static var variables: Dictionary[String, Dictionary]:
	get:
		if not story_state:
			load_data()
		return story_state.variables


@onready var files = $Editor.files
var undo_redo: EditorUndoRedoManager:
	set(val):
		undo_redo = val
		$Editor.undo_redo = val


func _enter_tree() -> void:
	$Editor.undo_redo = undo_redo
	$SetupMenu.undo_redo = undo_redo


func _ready():
	if story_state == null:
		load_data()
	$SetupMenu.load_data(story_state.custom_dialog_nodes, story_state.custom_text_effects)
	story_state.custom_node_list_updated.emit(story_state.custom_dialog_nodes)


func save_all_files() -> void:
	$Editor.files.save_all()


static func save_data() -> void:
	ResourceSaver.save(story_state, "res://story_state.tres")
	story_state.character_list_updated.emit()
	story_state.variable_list_updated.emit(story_state.variables.keys())


static func load_data() -> void:
	story_state = ResourceLoader.load("res://story_state.tres", "StoryState")
	story_state.character_list_updated.emit()
	story_state.variable_list_updated.emit(story_state.variables.keys())


static func add_character(character: Character) -> void:
	story_state.characters.append(character)
	story_state.character_list_updated.emit()


static func remove_character(character: Character) -> void:
	var idx: int = story_state.characters.find(character)
	story_state.characters.remove_at(idx)
	story_state.character_list_updated.emit()


static func new_variable(key: String) -> void:
	if story_state.variables.has(key):
		push_error("Could not add var. '%s' already exists" % key)
		return
	story_state.variables[key] = {}
	story_state.variable_list_updated.emit(get_variable_list())


static func remove_variable(key: String) -> void:
	if not story_state.variables.has(key):
		push_error("Could not remove var. '%s' not found" % key)
		return
	story_state.variables.erase(key)
	story_state.variable_list_updated.emit(get_variable_list())


static func rename_variable(old_name: String, new_name: String) -> void:
	if not story_state.variables.has(old_name):
		push_error("Could not rename var. '%s' not found" % old_name)
		return

	var data := story_state.variables.get(old_name)
	story_state.variables.erase(old_name)
	story_state.variables[new_name] = data

	story_state.variable_list_updated.emit(get_variable_list())


static func update_variables(dict: Dictionary[String, Dictionary]) -> void:
	story_state.variables = dict


static func get_variable_list() -> Array[String]:
	return story_state.variables.keys()


static func subscribe_to_variables(fn: Callable) -> void:
	story_state.variable_list_updated.connect(fn)


static func subscribe_to_characters(fn: Callable) -> void:
	story_state.character_list_updated.connect(fn)


static func unsubscribe_to_variables(fn: Callable) -> void:
	story_state.variable_list_updated.connect(fn)


static func unsubscribe_to_characters(fn: Callable) -> void:
	story_state.character_list_updated.disconnect(fn)


static func subscribe_to_custom_nodes(fn: Callable) -> void:
	story_state.custom_node_list_updated.connect(fn)


static func add_custom_node(path:="") -> void:
	story_state.custom_dialog_nodes.append(path)


static func remove_custom_node(idx: int) -> void:
	story_state.custom_dialog_nodes.remove_at(idx)
	story_state.custom_node_list_updated.emit(story_state.custom_dialog_nodes)


static func set_custom_node_path(idx: int, path: String) -> void:
	story_state.custom_dialog_nodes[idx] = path
	story_state.custom_node_list_updated.emit(story_state.custom_dialog_nodes)
