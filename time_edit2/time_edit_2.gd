extends HBoxContainer

var updownarrow = preload("res://time_edit2/updownarrow.png")

func _ready() -> void:
	$HourSpinBox.get_line_edit().context_menu_enabled = false
	$MinuteSpinBox.get_line_edit().context_menu_enabled = false
	$SecondSpinBox.get_line_edit().context_menu_enabled = false
	$HourSpinBox.theme.set_icon("theme_override_icons/updown","", updownarrow)
