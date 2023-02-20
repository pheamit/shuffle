extends Node

var swap = []
var button_scene
var buttons = []
var textures = []
var sliced_textures = []
export var separation = 20

func _ready():
	randomize()
	setup_container()
	textures = load_textures("res://assets/img/")
	sliced_textures = prep_sliced_textures(textures)
	sliced_textures.shuffle()
	button_scene = preload("res://scenes/button.tscn")
	new_puzzle()

func setup_container():
	$GridContainer.columns = settings.columns
	$GridContainer.add_constant_override("hseparation", separation)
	$GridContainer.add_constant_override("vseparation", separation)

func new_puzzle():
	if sliced_textures.empty():
		get_tree().change_scene("res://scenes/start.tscn")
		return
		
	var tex_slices: Array = sliced_textures.pop_back()
	
	for i in tex_slices.size():
		var button_instance = button_scene.instance()
		button_instance.texture_normal = tex_slices[i]
		button_instance.set_number(i)
		button_instance.connect("pressed", self, "button_pressed", [button_instance])
		buttons.append(button_instance)
	
	# Randomize buttons
	buttons.shuffle()
	setup_container()
	for button in buttons:
		$GridContainer.add_child(button)
	is_solved()

func button_pressed(button):
	if swap.size() > 0:
		var idx_a = swap[0].get_index()
		var idx_b = button.get_index()
		$GridContainer.move_child(swap[0], idx_b)
		$GridContainer.move_child(button, idx_a)
		swap.clear()
		is_solved()
	else:
		swap.append(button)
	
func mediator(value, property):
	$GridContainer.add_constant_override(property, value)

func slice_texture(tex: ImageTexture, cols: float, rows: float) -> Array:
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

func is_solved():
	for button in $GridContainer.get_children():
		if button.number != button.get_index():
			return false
	victory()

func victory():
	var tween = get_tree().create_tween()
	var trans = Tween.TRANS_BACK
	tween.tween_method(self, "mediator", 20.0, 0.0, 1, ["vseparation"]).set_trans(trans)
	yield(tween.parallel().tween_method(self, "mediator", 20.0, 0.0, 1, ["hseparation"]).set_trans(trans), "finished")
	delete_puzzle()
	new_puzzle()

func load_textures(path: String) -> Array:
	var result = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Very IMPORTANT to load the .import files!
			if !dir.current_is_dir() && file_name.ends_with(".import"):
				file_name = file_name.trim_suffix(".import")
				result.append(prep_tex(path + file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return result

func prep_tex(path: String) -> ImageTexture:
	var stream_tex: StreamTexture = load(path)
	var tex: ImageTexture = ImageTexture.new()
	tex.create_from_image(stream_tex.get_data())
	return tex

func prep_sliced_textures(tex_arr: Array) -> Array:
	var result = []
	for tex in tex_arr:
		result.append(slice_texture(tex, settings.columns, settings.columns))
	return result

func delete_puzzle():
	for child in $GridContainer.get_children():
		$GridContainer.remove_child(child)
		child.queue_free()
	buttons.clear()
