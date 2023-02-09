extends Node

func _ready():
	var image: Image = Image.new()
	var tex: ImageTexture = ImageTexture.new()
	image.load("res://assets/img/cat.png")
	tex.create_from_image(image)
	tex.set_size_override(Vector2(255, 255))
	var tex_slices: Array = slice_texture(tex, 3, 3)
	for slice in tex_slices:
		var tex_button: TextureButton = TextureButton.new()
		tex_button.texture_normal = slice
		$GridContainer.add_child(tex_button)
	
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
