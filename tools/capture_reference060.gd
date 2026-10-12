extends SceneTree
## Flat game-asset contact sheets on a dark stage color, without deformation.
func _initialize() -> void:
	var armor = Image.load_from_file("res://assets/sprites/mirkos_armor/atlas.png")
	var diogo = Image.load_from_file("res://assets/sprites/diogo/atlas.png")
	var sheet = Image.create(2304,1920,false,Image.FORMAT_RGBA8)
	sheet.fill(Color("162b3c"))
	for n in 35:
		var source = Rect2i((n%8)*384,(n/8)*320,384,320)
		var pose = armor.get_region(source)
		sheet.blend_rect(pose,Rect2i(0,0,384,320),Vector2i((n%6)*384,(n/6)*320))
	# Dedicated guard proof at native scale, both orientations, on dark pixels.
	var guard = diogo.get_region(Rect2i(1152,0,384,320))
	var proof = Image.create(768,320,false,Image.FORMAT_RGBA8)
	proof.fill(Color("16384a"))
	proof.blend_rect(guard,Rect2i(0,0,384,320),Vector2i.ZERO)
	guard.flip_x()
	proof.blend_rect(guard,Rect2i(0,0,384,320),Vector2i(384,0))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/screens"))
	sheet.save_png("res://docs/screens/060_armor_source_poses.png")
	proof.save_png("res://docs/screens/060_diogo_guard_source_both_sides.png")
	quit()
