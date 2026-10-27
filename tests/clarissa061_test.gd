extends SceneTree
const Combat=preload("res://scripts/combat.gd")
const DB=preload("res://scripts/move_db.gd")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL: "+label)
func fresh(side:int=0,distance:float=350.0):
	var c=Combat.new()
	c.setup([16,0] if side==0 else [0,16])
	c.fighters[side].x=200.0 if side==0 else 1080.0
	c.fighters[1-side].x=c.fighters[side].x+distance*(1 if side==0 else -1)
	c.fighters[side].meter=100
	return c
func ticks(c,n:int,inputs:Array=[{},{}]) -> void:
	for i in n:c.tick(inputs)
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var db=DB.new()
	check(db.character(16).playable and not db.character(14).playable and not db.character(15).playable,"boss IDs preserved")
	for side in 2:
		for distance in [100.0,350.0,700.0]:
			var c=fresh(side,distance)
			check(c.fighters[side].hp==1000,"equal base health")
			var input=[{},{}];input[side]={"block":true,"heavy_pressed":true,"heavy":true}
			c.tick(input);ticks(c,260)
			check(c.fighters[1-side].hp==720,"super exact damage side %d distance %s"%[side,distance])
			check(not c.cinematic.active and c.fighters[side].state!="super","super releases actors")
			check(c.projectiles.is_empty(),"super projectile cleanup")
		var miss=fresh(side,1000)
		miss._start_move(miss.fighters[side],db.super_move(16));ticks(miss,220)
		check(miss.fighters[1-side].hp==1000,"missed opener no cinematic damage")
		for slot in 3:
			var c=fresh(side,350)
			c._start_move(c.fighters[side],db.specials(16)[slot]);ticks(c,180)
			check(c.projectiles.is_empty(),"special lifetime %d"%slot)
			if slot<2:check(c.fighters[1-side].hp<1000,"projectiles hit %d side %d"%[slot,side])
			if slot==1:check(c.fighters[1-side].hp>=916,"rain bounded damage")
		var blocked=fresh(side,350)
		blocked._start_move(blocked.fighters[side],db.super_move(16))
		var guard=[{},{}];guard[1-side]={"block":true}
		ticks(blocked,220,guard)
		check(blocked.fighters[1-side].hp>950 and not blocked.cinematic.active,"blocked super no capture")
		var volley=fresh(side,100)
		var inp=[{},{}];inp[side]={"right":side==0,"left":side==1,"attack":true,"attack_pressed":true}
		volley.tick(inp);ticks(volley,100)
		check(volley.fighters[1-side].hp<960 and volley.fighters[1-side].hp>=922,"volley bounded damage")
	var priority=fresh(0,350)
	priority.tick([{"right":true,"attack_pressed":true,"special_slot":0},{}])
	check(priority.fighters[0].move.name=="BOLA TELEGUIADA","AI explicit slot has priority over volley")
	var legacy=fresh(0,350)
	legacy.fighters[0].motion=[{"dir":"down","tick":0},{"dir":"right","tick":0}]
	legacy.tick([{"right":true,"attack_pressed":true},{}])
	check(legacy.fighters[0].move.name=="BOLA TELEGUIADA","legacy motion has priority over volley")
	var net=fresh(0,400)
	net._start_move(net.fighters[0],db.specials(16)[2]);ticks(net,25)
	check(net.projectiles.size()==1 and net.projectiles[0].hp==2,"net two projectile durability")
	var shot=db.move("TEST","projectile",60,1,1,1,30,0,{"speed":10.0,"duration":80})
	for i in 2:
		net._spawn(net.fighters[1],shot,"projectile",350,478)
		net.projectiles[-1].vel=Vector2(-10,0)
		ticks(net,7)
	check(net.projectiles.is_empty(),"net destroyed after two balls")
	check(net.fighters[0].hp==1000,"net absorbs balls")
	print("CLARISSA 0.6.1: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
