extends SceneTree
const Motion=preload("res://scripts/fighter_motion.gd")
var failures=0
func check(ok:bool,label:String):
	if not ok:failures+=1;printerr("FAIL: "+label)
func _initialize():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/clarissa/frames.json"))
	var texture=load("res://assets/sprites/clarissa/atlas.png")
	var motion=Motion.new()
	var actual=motion.make_mesh("clarissa","smash",data,texture,{}).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var base=data.duplicate(true);base.erase("frame_scales")
	var original=motion.make_mesh("clarissa","smash",base,texture,{}).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	for i in actual.size():check(actual[i].is_equal_approx(original[i]*.8),"uniform scale around foot anchor")
	var image=texture.get_image()
	var idle=image.get_region(Rect2i(0,0,384,320)).get_used_rect().size.y
	var smash=image.get_region(Rect2i(1152,640,384,320)).get_used_rect().size.y*.8
	check(smash<=idle*1.02 and smash>=idle*.9,"smash body stays within standing height")
	for name in ["guard","idle0","punch0","punch1","upper"]:
		var fixed=motion.make_mesh("clarissa",name,data,texture,{}).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		var prior=motion.make_mesh("clarissa",name,base,texture,{}).surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
		check(fixed==prior,"other poses unchanged: "+name)
	print("CLARISSA SCALE: idle=",idle," smash=",smash," failures=",failures)
	quit(1 if failures else 0)
