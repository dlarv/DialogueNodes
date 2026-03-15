@tool
extends Control

signal delete_requested
signal modified
signal image_pressed

var character: Character = Character.new()

func set_character(chara: Character) -> void:
	character = chara
	$Name.text = chara.name
	$TextureRect.texture = chara.image
	$ColorPickerButton.color = chara.color


func _on_name_text_changed(new_text: String) -> void:
	$NameTimer.stop()
	$NameTimer.start()


func _on_name_timer_timeout() -> void:
	character.name = $Name.text
	modified.emit()


func _on_color_changed(color: Color) -> void:
	character.color = color
	modified.emit()


func _on_delete_button_pressed() -> void:
	delete_requested.emit()


func _on_image_button_pressed() -> void:
	image_pressed.emit()


func set_image(tex: Texture2D) -> void:
	character.image = tex
	$TextureRect.texture = tex

