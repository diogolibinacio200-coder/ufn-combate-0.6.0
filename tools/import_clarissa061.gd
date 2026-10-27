extends SceneTree
## Pack generated whole poses into the engine's 384x320 atlas contract.
const REGIONS = [
 [70,5,260,290],[420,5,235,290],[785,5,260,290],[1145,5,270,290],
 [80,335,220,207],[390,298,275,245],[780,305,270,235],[1090,292,350,245],
 [45,542,315,278],[390,545,337,277],[795,540,272,296],[1135,540,272,277],
 [5,850,325,232],[395,830,320,252],[720,968,410,118],[1165,765,253,317]
]
const NAMES=["idle0","guard","walk0","walk1","crouch","dash","jump0","jump1","punch0","punch1","upper","smash","serve","hurt","down","victory"]
func _initialize() -> void:
	var source=Image.load_from_file("res://assets/references/061/clarissa-paddle-source.png")
	var extra=Image.load_from_file("res://assets/references/061/clarissa-smash-victory.png")
	var atlas=Image.create(384*4,320*4,false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var frames={}
	for i in 16:
		var r=REGIONS[i]
		var pose=source.get_region(Rect2i(r[0],r[1],r[2],r[3]))
		if i in [11,15]:
			pose=extra.get_region(Rect2i(0 if i==11 else 1086,0,1086,724))
		# Ignore sub-10% alpha fringe when finding the complete silhouette.
		for yy in pose.get_height():
			for xx in pose.get_width():
				if pose.get_pixel(xx,yy).a<.1:pose.set_pixel(xx,yy,Color.TRANSPARENT)
		if i in [11,15]:pose=pose.get_region(pose.get_used_rect())
		var scale_factor=minf(.90, minf(365.0/pose.get_width(),294.0/pose.get_height()))
		pose.resize(roundi(pose.get_width()*scale_factor),roundi(pose.get_height()*scale_factor),Image.INTERPOLATE_LANCZOS)
		var origin=Vector2i((i%4)*384,(i/4)*320)
		atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),origin+Vector2i((384-pose.get_width())/2,304-pose.get_height()))
		frames[NAMES[i]]=[origin.x,origin.y,384,320]
	frames.idle1=frames.idle0;frames.idle2=frames.guard
	var anim={"idle":["idle0","guard","idle0"],"guard":["guard"],"lowguard":["crouch"],"crouch":["crouch"],"walk":["walk0","idle0","walk1","guard"],"backwalk":["walk1","guard","walk0","idle0"],"dash":["walk0","dash","walk1"],"jump":["jump0","jump1"],"fall":["jump1","crouch"],"light":["punch0","punch1","guard"],"heavy":["upper","smash","guard"],"specialA":["serve","punch1","guard"],"specialB":["upper","serve","guard"],"specialC":["guard"],"uppercut":["upper","smash"],"kick":["jump0","jump1","guard"],"hurt":["hurt"],"down":["down"],"recover":["down","crouch","guard"],"land":["crouch","guard"],"victory":["victory"],"intro":["guard","idle0"],"ultimate":["serve","punch1","upper","smash","victory"]}
	for pair in [["lowlight","light"],["lowheavy","heavy"],["lowkick","crouch"],["airlight","light"],["airheavy","heavy"],["airkick","kick"],["grab","light"],["block","guard"],["defeat","down"],["backdash","dash"]]:anim[pair[0]]=anim[pair[1]]
	atlas.save_png("res://assets/sprites/clarissa/atlas.png")
	atlas.get_region(Rect2i(0,0,384,320)).save_png("res://assets/sprites/clarissa/portrait.png")
	var f=FileAccess.open("res://assets/sprites/clarissa/frames.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"frames":frames,"animations":anim,"anchor":[192,304],"frame_scales":{"smash":0.8}},"\t"))
	print("Clarissa atlas packed; original generated alpha preserved")
	quit()
