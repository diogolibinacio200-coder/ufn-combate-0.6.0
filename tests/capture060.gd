extends SceneTree
## Reproducible screenshots from the real Godot renderer, not edited mockups.
const Combat=preload("res://scripts/combat.gd")
const Fighter=preload("res://scripts/fighter.gd")
var arena
var combat
class CaptureArena extends "res://scripts/arena_view.gd":
	var catalog:Array=[]
	func _draw() -> void:
		if catalog.is_empty():super._draw();return
		_frame_meshes.clear()
		draw_stage(0,0)
		draw_rect(Rect2(0,0,1280,720),Color(.015,.04,.07,.85))
		for index in catalog.size():
			var item:Dictionary=catalog[index]
			var origin=Vector2(320*(index%4),355*(index/4))
			for side in 2:
				var actor:Dictionary=item.actor.duplicate(true)
				actor.x=origin.x+85+side*150;actor.y=origin.y+310
				actor.face=1 if side==0 else -1;actor._cinematic=true;actor._visual_scale=.64
				draw_fighter(actor,.3)
			draw_string(ThemeDB.fallback_font,origin+Vector2(20,340),str(item.label),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)

func _initialize() -> void:call_deferred("run")
func snap(name:String) -> void:
	for _frame in 3:
		arena.queue_redraw();await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/screens060/"+name+".png")
	print("CAPTURE060 "+name)

func run() -> void:
	root.size=Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/screens060"))
	arena=CaptureArena.new();root.add_child(arena);arena.set_process(false);arena.paused=true
	combat=Combat.new();arena.combat=combat
	for id in [3,4]:
		combat.setup([id,id])
		for player in 2:
			var f:Dictionary=combat.fighters[player]
			f.x=425 if player==0 else 855;f._frame_name="guard" if id==3 else "idle0"
			f.transform=480 if id==4 else 0
		await snap("diogo_guard_both_sides" if id==3 else "mirkos_new_skin_both_sides")
		var key="diogo" if id==3 else "mirkos_armor"
		var frames:Array=arena.sprite_data[key].frames.keys()
		for start in range(0,frames.size(),8):
			arena.catalog=[]
			for index in range(start,mini(start+8,frames.size())):
				var actor=Fighter.create(id,0)
				actor.transform=480 if id==4 else 0
				actor._frame_name=frames[index]
				arena.catalog.append({"actor":actor,"label":frames[index]})
			await snap(key+"_all_frames_%02d"%(start/8+1))
		arena.catalog=[]
	for attacker in 2:
		combat.setup([1,3] if attacker==0 else [3,1])
		combat.fighters[attacker].ultimate_tint=true
		for frame in [1,49,111]:
			combat.cinematic={"active":true,"frame":frame,"duration":126,"character":1,"attacker":attacker,"defender":1-attacker}
			await snap("vitor_red_player%d_%03d"%[attacker+1,frame])
	combat.setup([4,3])
	for frame in [44,131,143]:
		combat.cinematic={"active":true,"frame":frame,"duration":144,"character":4,"attacker":0,"defender":1}
		await snap("mirkos_sequence_%03d"%frame)
	quit()
