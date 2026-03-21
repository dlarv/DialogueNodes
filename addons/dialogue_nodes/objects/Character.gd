@tool
@icon('res://addons/dialogue_nodes/icons/Character.svg')
## The data for a speaker in a dialogue.
class_name Character
extends Resource

signal sprite_removed(idx: int)
signal sprite_list_updated()

const MAX_SIZE := Vector2i(32, 32)

@export var name: String = ''
@export var _sprite_images: Array[Texture2D]
@export var _sprite_names: Array[String]
@export var color: Color = Color.WHITE

# Here to provide backwards compatibility
@export var image: Texture2D
var active_sprite := -1

func add_sprite(n: String, tex: Texture2D) -> void:
	_sprite_images.append(tex)
	_sprite_names.append(n)
	sprite_list_updated.emit()


func set_sprite_name(idx: int, n: String) -> void:
	if idx >= len(_sprite_images):
		push_error("Could not rename image %d in %s sprite list, list too short." % [idx, n])
		return
	_sprite_names[idx] = n
	sprite_list_updated.emit()


func set_sprite_image(idx: int, tex: Texture2D) -> void:
	if idx >= len(_sprite_images):
		_sprite_images.append(tex)
		return
	_sprite_images[idx] = tex
	sprite_list_updated.emit()


func get_sprite_image(idx: int) -> Texture2D:
	if idx >= len(_sprite_images) or idx == -1: return null
	return _sprite_images[idx]


func get_sprite_name(idx: int) -> String:
	if idx >= len(_sprite_images): return "null"
	return _sprite_names[idx]


func get_sprite_count() -> int:
	return len(_sprite_images)


func remove_sprite(idx: int) -> void:
	_sprite_images.remove_at(idx)
	_sprite_names.remove_at(idx)
	sprite_removed.emit(idx)
	sprite_list_updated.emit()


func get_active_sprite() -> Texture2D:
	if active_sprite == -1: return null
	return _sprite_images[active_sprite]
