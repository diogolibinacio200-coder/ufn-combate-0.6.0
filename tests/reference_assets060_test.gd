extends SceneTree
## Asset regressions are checked independently of the game renderer.
const Importer = preload("res://tools/import_reference060.gd")
var checks = 0
var failures = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FALHOU: "+label)

func _initialize() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/mirkos_armor/frames.json"))
	var normal: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/mirkos/frames.json"))
	var source = Image.load_from_file("res://assets/references/060/mirkos-armor-source.jpeg")
	var atlas = Image.load_from_file("res://assets/sprites/mirkos_armor/atlas.png")
	check(data.frames == normal.frames,"Armor supplies every original frame and rectangle")
	check(data.animations == normal.animations,"Armor preserves every animation and its timing")
	check(Vector2(float(data.anchor[0]),float(data.anchor[1])) == Vector2(192,304),"Armor retains canonical foot anchor")
	check(atlas.get_size() == Vector2i(3072,1600),"Armor atlas retains existing layout")
	check(atlas.get_pixel(0,0).a == 0.0,"Armor exterior is transparent")
	var rebuilt_poses: Dictionary = {}
	for frame in data.frames:
		var info: Dictionary = data.imported_poses[frame]
		var key: String = info.source_pose
		if not rebuilt_poses.has(key):
			rebuilt_poses[key] = Importer.armor_pose(source,Importer.rect(info.source_rect))
		var expected: Image = rebuilt_poses[key]
		var img = atlas.get_region(Importer.rect(data.frames[frame]))
		var used = img.get_used_rect()
		check(used.has_area() and used.size.x > 75 and used.size.y > 65,"Nonempty full armor pose: "+frame)
		check(used.position.x >= 2 and used.position.y >= 2 and used.end.x < 382 and used.end.y < 318,"No atlas-edge clipping: "+frame)
		var actual = img.get_region(Rect2i(int(info.destination[0]),int(info.destination[1]),int(info.size[0]),int(info.size[1])))
		check(actual.get_data() == expected.get_data(),"Exact supplied whole-pose pixels: "+frame)
		var mirrored = img.duplicate()
		mirrored.flip_x()
		mirrored.flip_x()
		check(mirrored.get_data() == img.get_data(),"Both facing orientations preserve alpha/pixels: "+frame)
	for animation in data.animations:
		for frame in data.animations[animation]:
			check(data.frames.has(frame),"Animation references real armor frame: "+animation+"/"+frame)
	var diogo = Image.load_from_file("res://assets/sprites/diogo/atlas.png")
	var diogo_source = Image.load_from_file("res://assets/references/060/diogo-main-source.jpeg")
	var metadata: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/references/060/diogo-guard-import.json"))
	var expected = Importer.extract_pose(diogo_source,Importer.rect(metadata.source_rect))
	var guard = diogo.get_region(Rect2i(1152,0,384,320))
	var actual = guard.get_region(Rect2i(int(metadata.destination[0]),int(metadata.destination[1]),int(metadata.size[0]),int(metadata.size[1])))
	check(actual.get_data() == expected.get_data(),"Diogo guard exactly preserves complete arms from supplied reference")
	check(guard.get_pixel(0,0).a == 0.0,"Diogo guard exterior is transparent")
	check(expected.get_width() == 129 and expected.get_height() == 233,"Diogo pose includes both hands and shoes")
	var bright = 0
	for y in range(95,145):
		for x in range(140,190):
			var p = guard.get_pixel(x,y)
			if p.a > .9 and p.r > .8 and p.g > .8 and p.b > .8:
				bright += 1
	check(bright > 30,"White Diogo shirt details survive background extraction")
	print("REFERENCE ASSETS 0.6.0: %d checks, %d failures"%[checks,failures])
	quit(0 if failures == 0 else 1)
