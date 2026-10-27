extends SceneTree
const App=preload("res://scripts/main.gd")
const Profile=preload("res://scripts/save_manager.gd")
var app
func _initialize():call_deferred("run")
func snap(n:String):
	app._process(1.0)
	for i in 4:app.arena.queue_redraw();app.ui.queue_redraw();await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/screens/v061/"+n+".png")
func run():
	root.size=Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/screens/v061"))
	app=App.new();app.profile=Profile.new("user://clarissa_capture.json");root.add_child(app)
	app.profile.data.settings.fullscreen=false;DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	app.set_process(false);app.set_physics_process(false);app.arena.set_process(false)
	app.begin_mode("versus");app.cursors=[16,3];await snap("selection")
	app.chosen=[16,3];app.stage=4;app.start_match();app.intro_frames=0;app.combat.fighters[0].meter=100;await snap("fight")
	app.combat._start_move(app.combat.fighters[0],app.combat.move_db.super_move(16))
	for i in 90:app.combat.tick([{},{}])
	await snap("ultimate")
	app.set_screen("kart");app.kart.start([16,3],[0,0],0,1)
	for i in 10:await process_frame
	await snap("kart")
	app.kart.stop();await app.sound.shutdown();app.queue_free();await process_frame;quit()
