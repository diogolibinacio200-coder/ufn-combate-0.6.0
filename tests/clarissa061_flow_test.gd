extends SceneTree
const App=preload("res://scripts/main.gd")
const Profile=preload("res://scripts/save_manager.gd")
var failures=0
var checks=0
var app
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+label)
func _initialize():call_deferred("run")
func run():
	app=App.new();app.profile=Profile.new("user://clarissa_flow_%d.json"%OS.get_process_id());root.add_child(app)
	app.set_process(false);app.set_physics_process(false)
	for mode in ["arcade","versus","training","survival","tower"]:
		app.begin_mode(mode);app.cursors=[16,3]
		app.tick_select([{"attack_pressed":true},{"attack_pressed":true}])
		check(app.chosen[0]==16,"selection "+mode)
		if mode=="tower":
			check(app.arcade_order[-2]==14 and app.arcade_order[-1]==15,"bosses unchanged")
			check(app.profile.valid_tower(app.profile.data.progress.tower) if app.profile.has_method("valid_tower") else app.profile.data.progress.tower.character==16,"Clarissa tower saved")
		app.start_match()
		check(app.combat.fighters[0].id==16,"fighter in "+mode)
		app.set_screen("menu")
	app.begin_mode("versus");app.cursors=[3,16];app.tick_select([{"attack_pressed":true},{"attack_pressed":true}]);app.start_match()
	check(app.combat.fighters[1].id==16,"player two selection")
	app.combat.setup([16,16],false,[3,0]);check(app.combat.tag(0,true),"Clarissa can tag out");check(app.combat.tag(0,true) and app.combat.fighters[0].id==16,"Clarissa can tag in")
	app.kart.start([16,3],[0,0],0,2)
	check(app.kart.racers[0].character==14 and app.kart.NAMES[14]=="CLARISSA","combat ID maps to kart index")
	app.kart.signature_item(app.kart.racers[0],Vector2(0,1))
	check(app.kart.projectiles.size()>0 and app.kart.projectiles[-1].homing,"kart homing beach ball")
	app.kart.stop()
	check(app.arena.sprite_data.has("clarissa"),"sprite atlas loaded")
	for pose in app.arena.sprite_data.clarissa.animations:
		for frame in app.arena.sprite_data.clarissa.animations[pose]:check(app.arena.sprite_data.clarissa.frames.has(frame),"frame exists")
	print("CLARISSA FLOW: ",checks," checks, ",failures," failures")
	app.queue_free();await process_frame;quit(1 if failures else 0)
