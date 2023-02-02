extends Node

func _ready():
	var tex: Texture = load("res://assets/img/cat.png")
	var tex_slices: Array = slice_texture(tex, 3, 3)
	for slice in tex_slices:
		print_debug(slice.region)

func slice_texture(tex: Texture, cols: int, rows: int) -> Array:
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
