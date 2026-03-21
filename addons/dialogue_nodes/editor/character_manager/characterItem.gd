@tool
extends Control

signal delete_requested
signal modified
signal image_pressed

var character: Character = Character.new()

func set_character(chara: Character, file_dialog: FileDialog) -> void:
	character = chara
	$Name.text = chara.name
	$TextureRect.texture = chara.get_sprite_image(0)
	$ColorPickerButton.color = chara.color

	%Popup.setup(chara, file_dialog)
	%Popup.icon_updated.connect(func() -> void:
		$TextureRect.texture = chara.get_sprite_image(0)
	)


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
	%Popup.show()


# func set_image(tex: Texture2D) -> void:
# 	character.set_sprite_image(0, tex)
# 	$TextureRect.texture = tex
#
