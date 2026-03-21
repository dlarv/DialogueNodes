@tool
extends PopupPanel

signal icon_updated

const PATH := "res://addons/dialogue_nodes/objects/StoryManager.tscn"
const StoryManagerScene := preload(PATH)
const SpriteItem := preload("SpriteItem.tscn")

var file_dialog: FileDialog

var _character: Character

func setup(character: Character, file_dialog: FileDialog) -> void:
	_character = character
	self.file_dialog = file_dialog

	%Label.text = character.name

	for child in %GridContainer.get_children(): %GridContainer.remove_child(child)

	for i in character.get_sprite_count():
		var item := SpriteItem.instantiate()
		item.setup(character, i, file_dialog)
		_add_entry(item, i)


func _on_add_button_pressed() -> void:
	var item := SpriteItem.instantiate()
	var idx := _character.get_sprite_count()
	item.setup(_character, idx, file_dialog)
	_add_entry(item, idx)
	_character.add_sprite("", null)


func _add_entry(item: Control, idx: int) -> void:
	%GridContainer.add_child(item)

	item.name_changed.connect(func(new_name: String) -> void:
		save()
	)
	item.image_changed.connect(func(image: Texture2D) -> void:
		icon_updated.emit()
		save()
	)
	item.delete_requested.connect(func() -> void:
		%GridContainer.remove_child(item)
		save()
	)


func save() -> void:
	# Determines whether scene should be opened or closed after saving sequence
	var _already_opened := PATH in EditorInterface.get_open_scenes()

	var scene := PackedScene.new()
	scene.pack(StoryManager)
	ResourceSaver.save(scene, PATH)

	# even though we know if it was open, we don't know if its active, hence this line
	EditorInterface.open_scene_from_path(PATH)
	# Scene will not officially save until it is closed and opened again.
	EditorInterface.close_scene()
	if _already_opened:
		EditorInterface.open_scene_from_path(PATH)

