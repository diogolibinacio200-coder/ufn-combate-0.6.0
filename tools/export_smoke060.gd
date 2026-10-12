extends SceneTree
var app
var failures:int=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
	print("EXPORT ","PASS: " if ok else "FAIL: ",label)
	if not ok:failures+=1
func run():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS,true)
	DisplayServer.window_set_position(Vector2i(-30000,-30000))
	check(ProjectSettings.get_setting("application/config/version")=="0.6.0","pack version0.6.0")
	app=load("res://scripts/main.gd").new()
	app.profile=load("res://scripts/save_manager.gd").new("user://export060_test_"+str(OS.get_process_id())+".json")
	root.add_child(app)
	app.profile.data.settings.fullscreen=false
	app.profile.data.settings.resolution=0
	app.apply_settings()
	DisplayServer.window_set_position(Vector2i(-30000,-30000))
	app.set_process_input(false)
	app.set_physics_process(false)
	check(app.arena.sprite_atlas.has("mirkos_armor"),"armored atlas present in exported pack")
	check(app.arena.sprite_data.has("mirkos_armor"),"armor animation metadata present")
	app.mode="versus";app.chosen=[1,4];app.start_match();app.intro_frames=0
	app.combat.fighters[0].meter=100
	app.combat.fighters[0].x=100;app.combat.fighters[1].x=1180
	app.combat.tick([{"block":true,"heavy_pressed":true},{}])
	for frame in 420:app.combat.tick([{},{}])
	check(app.combat.fighters[1].hp==720,"exported Vitor distant ultimate deals280")
	check(not app.combat.cinematic.active and not app.combat.fighters[0].ultimate_tint,"exported ultimate releases states")
	app.combat.setup([4,3]);app.combat.fighters[0].x=400;app.combat.fighters[1].x=550
	app.combat.fighters[0].meter=100
	app.combat.tick([{"block":true,"heavy_pressed":true},{}])
	for frame in 280:app.combat.tick([{},{}])
	check(app.combat.fighters[0].transform>0 and app.combat.fighters[1].hp==800,"exported robots damage and transform")
	for frame in 15:
		app.arena.queue_redraw()
		await process_frame
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_executable_path().get_base_dir()+"/export-smoke060.png")
	await app.sound.shutdown()
	app.queue_free()
	await process_frame
	print("EXPORT060: 6 checks, ",failures," failures")
	quit(1 if failures else 0)
