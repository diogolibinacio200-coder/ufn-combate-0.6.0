extends SceneTree
## Run with a real renderer; this checks submitted and rasterized fighter frames.
const Arena=preload("res://scripts/arena_view.gd")
const Fighter=preload("res://scripts/fighter.gd")
const Combat=preload("res://scripts/combat.gd")
var checks:int=0
var failures:int=0

class Probe extends Arena:
	var actors:Array=[]
	var submitted:Array=[]
	var observed:Array=[]
	var robots:Array=[]
	var sequence_mode:bool=false
	func _draw() -> void:
		_frame_meshes.clear()
		submitted.clear()
		observed.clear()
		robots.clear()
		if sequence_mode:super._draw();return
		for actor in actors:draw_fighter(actor,time)
	func draw_fighter(actor:Dictionary,t:float,alt:bool=false) -> void:
		observed.append(actor.duplicate(true))
		super.draw_fighter(actor,t,alt)
	func _draw_combat_robot(p:Vector2,face:float,strike:float,t:float,alpha:float=1.0) -> void:
		robots.append({"position":p,"face":face,"strike":strike})
		super._draw_combat_robot(p,face,strike,t,alpha)
	func _draw_motion_frame(skin:String,frame:String,data:Dictionary,movement:Dictionary,tint:Color) -> void:
		submitted.append({"skin":skin,"frame":frame,"alpha":tint.a})
		super._draw_motion_frame(skin,frame,data,movement,tint)

func _initialize() -> void:call_deferred("run")
func check(ok:bool,label:String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+label)

func run() -> void:
	var viewport=SubViewport.new()
	viewport.size=Vector2i(800,380)
	viewport.transparent_bg=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var arena=Probe.new();viewport.add_child(arena);arena.set_process(false)
	for id in 17:
		for variant in (2 if id in [3,4] else 1):
			var a=Fighter.create(id,0);var b=Fighter.create(id,1)
			for actor in [a,b]:
				actor.y=340.0;actor.skin=variant if id==3 else 0
				actor.transform=480 if id==4 and variant==1 else 0
				actor.invuln=60
			a.x=200.0;a.face=1;b.x=600.0;b.face=-1
			arena.actors=[a,b]
			var key=arena.skin_for(a)
			check(arena.sprite_atlas.has(key),"atlas loaded "+key)
			if not arena.sprite_atlas.has(key):continue
			var data:Dictionary=arena.sprite_data[key]
			var image:Image=arena.sprite_atlas[key].get_image()
			if image.is_compressed():image.decompress()
			for animation in data.animations:
				for frame in data.animations[animation]:
					check(data.frames.has(frame),"animation resolves %s/%s/%s"%[key,animation,frame])
			var index=0
			for frame in data.frames:
				var source:Array=data.frames[frame]
				var rect=Rect2i(source[0],source[1],source[2],source[3])
				check(Rect2i(Vector2i.ZERO,image.get_size()).encloses(rect),"source bounds "+key+"/"+frame)
				check(image.get_region(rect).get_used_rect().size.x>25,"nonempty artwork "+key+"/"+frame)
				for actor in [a,b]:
					actor.state=["idle","walk","dash","block","attack","jump","hitstun"][index%7]
					actor._frame_name=frame;actor.vel=Vector2(4.2,-2)
					arena.motion.update(actor,1.0/60.0)
				arena.time=float(index)/60.0
				arena.queue_redraw()
				await process_frame
				await RenderingServer.frame_post_draw
				check(arena.submitted.size()==2,"one complete mesh per actor "+key+"/"+frame)
				for command in arena.submitted:
					check(command.alpha==1.0 and command.frame==frame and command.skin==key,"opaque current pose "+key+"/"+frame)
				var raster=viewport.get_texture().get_image()
				check(raster!=null and raster.get_used_rect().size.x>400,"both orientations rasterized "+key+"/"+frame)
				index+=1
			if id==4:
				a.transform=0
				check(arena.skin_for(a)=="mirkos","normal skin restored on expiry")
	# Preview reveal never mutates the persistent timer or fighter identity.
	var mirkos=Fighter.create(4,0);mirkos._armor_skin=true
	check(arena.skin_for(mirkos)=="mirkos_armor" and mirkos.transform==0 and mirkos.id==4,"cinematic skin preview is presentation only")
	viewport.size=Vector2i(1280,720)
	arena.sequence_mode=true
	arena.combat=Combat.new()
	for attacker in 2:
		arena.combat.setup([1,3] if attacker==0 else [3,1])
		for frame in [1,49,111]:
			arena.combat.cinematic={"active":true,"frame":frame,"duration":126,"character":1,"attacker":attacker,"defender":1-attacker}
			arena.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
			var fighter_actors=arena.observed.filter(func(actor):return not actor.has("_tint"))
			check(fighter_actors.size()==2,"cinematic has two opaque main actors")
			for actor in fighter_actors:
				check(bool(actor.get("ultimate_tint",false))==(int(actor.id)==1),"only Vitor attacker is red")
				if actor.id==1:
					check(actor.face==arena.combat.fighters[attacker].face,"cinema keeps attacker facing")
		arena.combat.setup([4,3] if attacker==0 else [3,4])
		for frame in [10,27,44,61,78,92]:
			arena.combat.cinematic={"active":true,"frame":frame,"duration":144,"character":4,"attacker":attacker,"defender":1-attacker}
			arena.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
			check(arena.robots.size()==2,"exactly two attacking robots")
			var striking=arena.robots.filter(func(robot):return robot.strike==1.0)
			check(striking.size()==1,"one robot punches at each damage beat")
			var victim=arena.observed.filter(func(actor):return actor.id==3)[0]
			if striking.size()==1:
				var fist:Vector2=striking[0].position+Vector2(striking[0].face*108,-111)
				check(Rect2(fist-Vector2(12,10),Vector2(25,21)).intersects(Fighter.hurtbox(victim)),"visible robot fist contacts captured victim")
		for frame in [139,140,143]:
			arena.combat.cinematic={"active":true,"frame":frame,"duration":144,"character":4,"attacker":attacker,"defender":1-attacker}
			arena.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
			var transformed=arena.observed.filter(func(actor):return actor.id==4)
			check(transformed.size()==1 and arena.skin_for(transformed[0])==("mirkos_armor" if frame>=140 else "mirkos"),"armor reveal swaps exact full atlas")
			check(arena.combat.fighters[attacker].transform==0,"render does not mutate transformation mechanics")
	print("RENDER060: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
