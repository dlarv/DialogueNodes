@tool
extends PanelContainer

const PATH := "res://addons/dialogue_nodes/objects/StoryManager.tscn"
const StoryManagerScene := preload(PATH)
const CharacterItem := preload("CharacterItem.tscn")

func _enter_tree():
	for child in %GridContainer.get_children(): %GridContainer.remove_child(child)
	for character in StoryManager.characters:
		_create_entry(character)


func _on_new_character_button_pressed() -> void:
	var character := _create_entry()
	StoryManager.add_character(character)
	save()


func _on_reload_button_pressed(refresh:=true) -> void:
	var story_manager = ResourceLoader.load(PATH, "", ResourceLoader.CacheMode.CACHE_MODE_IGNORE).instantiate()
	StoryManager.characters = story_manager.characters

	for child in %GridContainer.get_children(): %GridContainer.remove_child(child)
	for character in StoryManager.characters:
		_create_entry(character)


func _on_delete_requested(character_item: Control) -> void:
	StoryManager.remove_character(character_item.character)
	%GridContainer.remove_child(character_item)
	save()


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


func _create_entry(character: Character=null) -> Character:
	if character == null:
		character = Character.new()
	var item := CharacterItem.instantiate()
	item.set_character(character)
	item.delete_requested.connect(_on_delete_requested.bind(item))
	item.image_pressed.connect(_on_character_image_pressed.bind(item))
	%GridContainer.add_child(item)
	item.modified.connect(_on_item_modified)

	return character


func _on_item_modified() -> void:
	save()
	StoryManager.character_list_updated.emit()


func _on_character_image_pressed(character_item: Control) -> void:
	$FileDialog.show()
	var path: String = await $FileDialog.file_selected
	var image := ResourceLoader.load(path)
	if image is Texture2D:
		character_item.set_image(image)
		save()

