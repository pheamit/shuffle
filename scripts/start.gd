extends Control

onready var label: Label
onready var slider: HSlider

func _ready():
	label = $VBoxContainer/columns
	slider = $VBoxContainer/HSlider
	label.text =  String(slider.value) + " columns"

func _on_HSlider_value_changed(value):
	label.text = String(value) + " columns"

func _on_start_pressed():
	settings.columns = slider.value
	get_tree().change_scene("res://scenes/main.tscn")

func _on_exit_pressed():
	get_tree().quit()
