extends Node

var swap = []
var buttons = []
var textures = []
export var columns = 3

func _ready():
	$GridContainer.columns = columns
	randomize()
	load_images("res://assets/img/")
	textures.shuffle()
	var button_scene = preload("res://scenes/button.tscn")
	
#	tex.set_size_override(Vector2(255, 255))
	var tex_slices: Array = slice_texture(textures[0], columns, columns)
	
	for i in tex_slices.size():
		var button_instance = button_scene.instance()
		button_instance.texture_normal = tex_slices[i]
		button_instance.set_number(i)
		button_instance.connect("pressed", self, "button_pressed", [button_instance])
		buttons.append(button_instance)
	
	# Randomize the slices
	buttons.shuffle()
	
	for button in buttons:
		$GridContainer.add_child(button)

func button_pressed(button):
	if swap.size() > 0:
		var idx_a = swap[0].get_index()
		var idx_b = button.get_index()
		$GridContainer.move_child(swap[0], idx_b)
#		print("move ", swap[0].number, " to index ", idx_b)
		$GridContainer.move_child(button, idx_a)
#		print("move ", button.number, " to index ", idx_a)
		swap.clear()
		if is_solved():
			victory()
	else:
#		print("append ", button.number, " to swap array")
		swap.append(button)
	
func mediator(value, property):
	$GridContainer.add_constant_override(property, value)

func slice_texture(tex: ImageTexture, cols: int, rows: int) -> Array:
	var result: Array = []
	var region: Rect2 = Rect2(Vector2(0, 0), Vector2(tex.get_width() / cols, tex.get_height() / rows))
	var offset_x: bool = false
	var offset_y: bool = false
	for i in rows:
		region.position.x = 0
		for j in cols:
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.set_atlas(tex)
			atlas.set_region(region)
			result.append(atlas)
			if not offset_x:
				region.position.x += region.size.x + 1
				offset_x = true
			else:
				region.position.x += region.size.x
		if not offset_y:
			region.position.y += region.size.y + 1
			offset_y = true
		else:
			region.position.y += region.size.y
		offset_x = false
	return result

func is_solved() -> bool:
	for button in $GridContainer.get_children():
		if button.number != button.get_index():
			return false
	return true

func victory():
	var tween = get_tree().create_tween()
	var trans = Tween.TRANS_CIRC
	tween.tween_method(self, "mediator", 8.0, 0.0, 1, ["vseparation"]).set_trans(trans)
	tween.parallel().tween_method(self, "mediator", 8.0, 0.0, 1, ["hseparation"]).set_trans(trans)

func load_images(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && !file_name.ends_with("import"):
#				print("Found file: " + path + file_name)
				var image: Image = Image.new()
				var tex: ImageTexture = ImageTexture.new()
				image.load(path + file_name)
				tex.create_from_image(image)
				textures.append(tex)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
