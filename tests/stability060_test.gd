extends SceneTree
## Sixteen deterministic one-minute training simulations with simultaneous input.
const Combat=preload("res://scripts/combat.gd")
const AI=preload("res://scripts/ai.gd")
var checks:int=0
var failures:int=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("STABILITY FAIL: "+label)
func run():
	var total_ticks:int=0
	for id in 16:
		var c=Combat.new()
		c.setup([id,(id+5)%16],true)
		var a=AI.new(600+id)
		var b=AI.new(900+id)
		var finite:bool=true
		var bounded:bool=true
		var max_projectiles:int=0
		var cinematic_age:int=0
		var maximum_cinematic_age:int=0
		var hits:int=0
		for frame in 3600:
			var inputs:Array=[a.think(c,0,3),b.think(c,1,3)]
			if frame%300==0:
				inputs=[{"block":true,"heavy_pressed":true},{"block":true,"heavy_pressed":true}]
			c.tick(inputs)
			total_ticks+=1
			cinematic_age=cinematic_age+1 if c.cinematic.active else 0
			maximum_cinematic_age=maxi(maximum_cinematic_age,cinematic_age)
			max_projectiles=maxi(max_projectiles,c.projectiles.size())
			for f in c.fighters:
				finite=finite and is_finite(f.x) and is_finite(f.y) and is_finite(f.hp) and f.vel.is_finite()
				bounded=bounded and f.hp>=0 and f.hp<=f.max_hp and f.meter>=0 and f.meter<=100 and f.transform>=0
			for event in c.events:
				if event.type in ["hit","super_hit"]:hits+=1
		check(finite,"finite fighter state id%d"%id)
		check(bounded,"bounded health, meter and transformation id%d"%id)
		check(max_projectiles<50,"bounded devices id%d peak%d"%[id,max_projectiles])
		check(maximum_cinematic_age<600,"no locked ultimate id%d"%id)
		check(hits>0,"both-input simulation produces combat id%d"%id)
		c.reset_round()
		check(c.projectiles.is_empty() and not c.cinematic.active and not c.fighters[0].ultimate_tint and not c.fighters[1].ultimate_tint,"reset clears temporary state id%d"%id)
	print("STABILITY060: %d checks, %d failures, %d ticks (960 simulated seconds)"%[checks,failures,total_ticks])
	quit(1 if failures else 0)
