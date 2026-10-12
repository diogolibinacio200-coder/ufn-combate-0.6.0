extends SceneTree
## Deterministic regression scenarios for the actual 0.6 activation/collision path.
const Combat=preload("res://scripts/combat.gd")
const Fighter=preload("res://scripts/fighter.gd")
var checks:int=0
var failures:int=0

func _initialize() -> void:call_deferred("run")

func check(ok:bool,label:String) -> void:
	checks+=1
	if not ok:
		failures+=1
		printerr("FALHOU: "+label)

func fresh(id:int=1,side:int=0,face:int=1,distance:float=100.0,opponent:int=0):
	var c=Combat.new()
	var ids:Array=[opponent,opponent]
	ids[side]=id
	c.setup(ids)
	var a:Dictionary=c.fighters[side]
	var d:Dictionary=c.fighters[1-side]
	a.x=90.0 if face==1 else 1190.0
	d.x=a.x+face*distance
	a.face=face
	d.face=-face
	return c

func activate(c,side:int=0) -> void:
	c.fighters[side].meter=100.0
	var inputs:Array=[{},{}]
	inputs[side]={"block":true,"heavy":true,"heavy_pressed":true}
	c.tick(inputs)

func frames(c,n:int,inputs:Array=[{},{}]) -> Array:
	var events:Array=[]
	for _i in n:
		c.tick(inputs)
		events.append_array(c.events.duplicate(true))
	return events

func pursuit_matrix() -> void:
	for opponent in 16:
		for side in 2:
			for face in [-1,1]:
				for distance in [95.0,540.0,1100.0]:
					var c=fresh(1,side,face,distance,opponent)
					var a:Dictionary=c.fighters[side]
					var d:Dictionary=c.fighters[1-side]
					var hp:float=d.hp
					activate(c,side)
					check(a.move.kind=="rush_red" and a.ultimate_tint and not d.ultimate_tint,"Proactive self transformation %d/%d/%d/%d"%[opponent,side,face,int(distance)])
					check(a.meter==0.0,"Activation spends exactly the full meter")
					var count:int=0
					var finals:int=0
					var captured:bool=false
					var clock_at_capture:int=0
					var clock_stable:bool=true
					var tint_stable:bool=true
					var collisions:bool=true
					var step_bounded:bool=true
					for _i in 400:
						var previous_x:float=a.x
						c.tick([{},{}])
						if not captured and not c.cinematic.active:step_bounded=step_bounded and absf(a.x-previous_x)<=11.001
						for event in c.events:
							if event.type=="super_hit":
								count+=1
								finals+=int(event.final)
								collisions=collisions and event.hitbox.intersects(Fighter.hurtbox(d))
						if c.cinematic.active:
							if not captured:clock_at_capture=c.time_frames
							captured=true
							clock_stable=clock_stable and clock_at_capture==c.time_frames
							tint_stable=tint_stable and a.ultimate_tint and not d.ultimate_tint
						elif captured:break
					check(captured and not c.cinematic.active,"Near/far contact completes without opponent attacking")
					check(count==15 and finals==1 and is_equal_approx(hp-d.hp,280.0),"Exactly fifteen strikes and280 total damage")
					check(collisions and step_bounded,"World-space hitboxes and bounded pursuit")
					check(clock_stable and tint_stable,"Frozen match clock and attacker-only tint")
					check(a.state=="idle" and d.state=="knockdown" and not a.ultimate_tint and not d.ultimate_tint,"Sequence restores control and clears visual state")
					check(a.x>=90.0 and a.x<=1190.0 and d.x>=90.0 and d.x<=1190.0 and absf(a.x-d.x)>=66.0,"Corner-safe separation")
					frames(c,80)
					check(c._free(a) and c._free(d),"Both actors recover after ultimate")

func moving_targets() -> void:
	for side in 2:
		for face in [-1,1]:
			var c=fresh(1,side,face,800.0)
			activate(c,side)
			var inputs:Array=[{},{}]
			inputs[1-side]={"right":face==1,"left":face==-1}
			var log:Array=frames(c,400,inputs)
			check(log.filter(func(e):return e.type=="super_hit").size()==15,"Pursuit catches a retreating opponent")
			c=fresh(1,side,face,600.0)
			activate(c,side)
			frames(c,42)
			var a:Dictionary=c.fighters[side]
			var d:Dictionary=c.fighters[1-side]
			d.x=a.x-face*90.0
			log=frames(c,300)
			check(log.filter(func(e):return e.type=="super_hit").size()==15 and a.face==-face,"Live target is reacquired after crossing sides")
			for state in ["jump","knockdown","attack"]:
				c=fresh(1,side,face,300.0)
				d=c.fighters[1-side]
				d.state=state
				if state=="jump":d.y=460.0;d.vel.y=-6.0
				if state=="knockdown":d.stun=35;d.invuln=28
				if state=="attack":
					d.move=c.move_db.normals()[0]
					d.move.startup=100
				activate(c,side)
				log=frames(c,400)
				check(log.filter(func(e):return e.type=="super_hit").size()==15,"Target animation remains compatible: "+state)

func defenses_and_interruptions() -> void:
	for side in 2:
		var c=fresh(1,side)
		var inputs:Array=[{},{}]
		inputs[1-side]={"block":true}
		activate(c,side)
		var log:Array=frames(c,240,inputs)
		check(not log.any(func(e):return e.type=="cinematic_start") and log.any(func(e):return e.type=="block"),"Ordinary blocking defeats proactive capture")
		check(is_equal_approx(c.fighters[1-side].hp,988.8) and c._free(c.fighters[side]) and not c.fighters[side].ultimate_tint,"Block applies only chip and bounded recovery")
		c=fresh(1,side)
		activate(c,side)
		c.fighters[1-side].invuln=220
		log=frames(c,230)
		check(not log.any(func(e):return e.type=="cinematic_start") and c.fighters[1-side].hp==1000.0 and not c.fighters[side].ultimate_tint,"Prolonged invulnerability produces a clean whiff")
		c=fresh(1,side)
		activate(c,side)
		c.fighters[1-side].invuln=40
		log=frames(c,300)
		check(log.filter(func(e):return e.type=="super_hit").size()==15,"Temporary invulnerability does not consume the pending hit")
		for id in [1,4]:
			for delay in [0,44]:
				c=fresh(id,side,1,600.0 if id==1 else 300.0)
				activate(c,side)
				frames(c,delay)
				var a:Dictionary=c.fighters[side]
				var d:Dictionary=c.fighters[1-side]
				c.hitstop=0
				c._apply_hit(d,a,c.move_db.normals()[0],c.EMPTY,false)
				log=frames(c,350)
				check(not log.any(func(e):return e.type=="super_hit") and d.hp==1000.0,"Startup/approach interruption prevents delayed hits")
				check(a.transform==0 and not a.ultimate_tint and c.projectiles.is_empty() and c._free(a),"Interruption clears red state, robots and armor reward")
			c=fresh(id,side)
			activate(c,side)
			for _i in 150:
				c.tick([{},{}])
				if c.cinematic.active:break
			frames(c,40)
			var hp:float=c.fighters[1-side].hp
			c.cancel_cinematic()
			log=frames(c,300)
			check(c.fighters[1-side].hp==hp and c.fighters[side].transform==0 and c.fighters.all(func(f):return not f.ultimate_tint and c._free(f)),"Cinematic cancellation stops later damage and releases actors")
			c.reset_round()
			check(not c.cinematic.active and c.projectiles.is_empty() and c.fighters.all(func(f):return not f.ultimate_tint and f.transform==0),"Round reset fully clears ultimate state")

func robot_contacts_and_transformation() -> void:
	for side in 2:
		for face in [-1,1]:
			var c=fresh(4,side,face,300.0)
			var a:Dictionary=c.fighters[side]
			var d:Dictionary=c.fighters[1-side]
			activate(c,side)
			var robot_seen:bool=false
			var robots_travelled:bool=false
			var no_early_damage:bool=true
			var no_early_armor:bool=true
			var log:Array=[]
			var previous:float=-1.0
			var captured:bool=false
			for _i in 300:
				c.tick([{},{}])
				log.append_array(c.events.duplicate(true))
				if c.cinematic.active:captured=true
				if not captured:
					no_early_damage=no_early_damage and d.hp==1000.0
					for p in c.projectiles:
						if p.kind=="robot_strike" and p.lane==0:
							robot_seen=true
							if previous!=-1.0:robots_travelled=robots_travelled or is_equal_approx((p.x-previous)*face,9.0)
							previous=p.x
				if c.cinematic.active:no_early_armor=no_early_armor and a.transform==0
				elif captured:break
			check(robot_seen and robots_travelled and no_early_damage,"Robots exist, travel and cannot damage before collision")
			check(captured and log.filter(func(e):return e.type=="super_hit").size()==6 and d.hp==800.0,"Robot contact confirms six real damaging impacts")
			var phases:Array=log.filter(func(e):return e.type=="ultimate_phase").map(func(e):return e.phase)
			check(phases.has("robots") and phases.find("recall")<phases.find("assembly") and phases.has("assembly"),"Robot attack precedes recall and transformation")
			check(no_early_armor and a.transform==480 and c.projectiles.is_empty(),"Completed sequence grants exact eight-second transformation")
			frames(c,479)
			check(a.transform==1,"Armor persists through its last active frame")
			frames(c,1)
			check(a.transform==0,"Armor expires exactly on frame480")
			c=fresh(4,side,face,600.0)
			activate(c,side)
			log=frames(c,180)
			check(c.fighters[1-side].hp==1000.0 and not log.any(func(e):return e.type=="super_hit"),"Robots respect finite range and cannot deal offscreen damage")
			check(c.fighters[side].transform>0,"An uninterrupted whiff retains the existing armor reward")

func consecutive_and_long_running() -> void:
	var c=fresh(1)
	c.training=true
	c.training_options.infinite_health=false
	c.training_options.infinite_meter=false
	var total:int=0
	for _repeat in 12:
		c.fighters[0].x=120.0
		c.fighters[1].x=1110.0
		c.fighters[1].hp=1000.0
		activate(c)
		var log:Array=frames(c,500)
		total+=log.filter(func(e):return e.type=="super_hit").size()
		check(c._free(c.fighters[0]) and c._free(c.fighters[1]) and c.projectiles.is_empty() and not c.fighters[0].ultimate_tint,"Consecutive ultimates leave no stale state")
	check(total==180,"Twelve permitted ultimates over6000 ticks retain exact hit counts")

func run() -> void:
	pursuit_matrix()
	moving_targets()
	defenses_and_interruptions()
	robot_contacts_and_transformation()
	consecutive_and_long_running()
	print("ULTIMATES 0.6.0: %d checks, %d failures"%[checks,failures])
	quit(0 if failures==0 else 1)
