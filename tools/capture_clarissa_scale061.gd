extends SceneTree
const App=preload("res://scripts/main.gd")
const Profile=preload("res://scripts/save_manager.gd")
var app
func _initialize():call_deferred("run")
func run():
	root.size=Vector2i(1280,720)
	app=App.new();app.profile=Profile.new("user://clarissa_scale_capture.json");root.add_child(app)
	app.profile.data.settings.fullscreen=false;DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	app.set_process(false);app.set_physics_process(false);app.arena.set_process(false)
	app.begin_mode("versus");app.chosen=[16,0];app.stage=1;app.start_match();app.intro_frames=0
	app.combat.fighters[0].x=440;app.combat.fighters[1].x=820
	app.combat.fighters[0]._frame_name="smash"
	app.combat.fighters[1]._frame_name="idle0"
	app._process(1.0)
	for i in 4:app.arena.queue_redraw();app.ui.queue_redraw();await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/screens/v061/smash-scale-fixed.png")
	await app.sound.shutdown();app.queue_free();await process_frame;quit()
