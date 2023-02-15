extends TextureButton

var number

func _process(delta):
	$index.text = String(get_index())

func set_number(num: int):
	$number.text = String(num)
	number = num
