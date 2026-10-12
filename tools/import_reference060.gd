extends SceneTree
## Deterministic game-asset import of the two user-supplied 1536x1024 sheets.
## Runs with: godot --headless --path . --script tools/import_reference060.gd
## No generated artwork or segmented/reconstructed body parts are used.

const BASE = "res://assets/sprites/"
const REFERENCES = "res://assets/references/060/"
const CELL = Vector2i(384,320)
const REGIONS = {
	"idle0":[15,20,178,255], "idle1":[194,20,158,255],
	"idle2":[353,20,141,255], "guard":[495,20,143,255],
	"crouch":[639,75,147,204], "lowguard":[789,90,147,190],
	"walk0":[953,20,153,258], "walk1":[1110,20,143,258],
	"dash":[1272,20,237,258],
	"jump0":[17,330,129,209], "jump1":[178,287,141,211],
	"jump2":[334,282,126,232], "jump3":[477,322,126,218],
	"punch0":[632,330,221,228], "punch1":[819,330,219,228],
	"punch2":[985,340,205,219], "upper":[1175,300,163,260],
	"kick":[1328,329,192,231],
	"axe":[18,548,164,239], "sweep":[181,610,253,166],
	"airkick":[429,547,208,209], "backkick":[643,567,140,217],
	"land":[20,830,162,165], "down":[239,879,249,115],
	"recover":[503,839,176,159], "victory":[731,764,154,239],
	"intro":[947,765,145,236],
}
## The supplied armor sheet has no dedicated hurt, knockback or low/air-punch
## artwork. Explicit whole-pose aliases preserve every existing state and timer.
const ALIASES = {
	"hurt":"guard", "knockback":"land",
	"lowpunch0":"punch0", "lowpunch1":"punch1", "lowpunch2":"punch2",
	"airpunch0":"punch0", "airpunch1":"punch1", "airpunch2":"punch2",
}

func _initialize() -> void:
	var armor = Image.load_from_file(REFERENCES+"mirkos-armor-source.jpeg")
	var diogo = Image.load_from_file(REFERENCES+"diogo-main-source.jpeg")
	if armor == null or diogo == null or armor.get_size() != Vector2i(1536,1024) or diogo.get_size() != Vector2i(1536,1024):
		printerr("Reference sheets must be the original 1536x1024 user attachments")
		quit(1)
		return
	build_armor(armor)
	fix_diogo_guard(diogo)
	print("REFERENCE IMPORT 0.6.0: complete armor skin and intact Diogo guard")
	quit()

static func rect(values: Array) -> Rect2i:
	return Rect2i(int(values[0]),int(values[1]),int(values[2]),int(values[3]))

static func background_pixel(c: Color) -> bool:
	# JPEG compression produces off-white background. Only connected exterior
	# near-white pixels are keyed: enclosed white shirt/armor details survive.
	return minf(c.r,minf(c.g,c.b)) > .89 and maxf(c.r,maxf(c.g,c.b))-minf(c.r,minf(c.g,c.b)) < .10

static func extract_pose(sheet: Image, area: Rect2i) -> Image:
	var img = sheet.get_region(area)
	img.convert(Image.FORMAT_RGBA8)
	var w = img.get_width()
	var h = img.get_height()
	var exterior = PackedByteArray()
	exterior.resize(w*h)
	var queue = PackedInt32Array()
	# Edge-connected flood fill does not indiscriminately erase white costume.
	for y in h:
		for x in w:
			if (x == 0 or y == 0 or x == w-1 or y == h-1) and background_pixel(img.get_pixel(x,y)):
				exterior[y*w+x] = 1
				queue.append(y*w+x)
	var cursor = 0
	while cursor < queue.size():
		var n = queue[cursor]
		cursor += 1
		var x = n%w
		var y = n/w
		for neighbor in [Vector2i(x-1,y),Vector2i(x+1,y),Vector2i(x,y-1),Vector2i(x,y+1)]:
			if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= w or neighbor.y >= h:
				continue
			var index = neighbor.y*w+neighbor.x
			if exterior[index] == 0 and background_pixel(img.get_pixelv(neighbor)):
				exterior[index] = 1
				queue.append(index)
	for y in h:
		for x in w:
			if exterior[y*w+x] == 1:
				img.set_pixel(x,y,Color.TRANSPARENT)
	# Neighboring reference poses overlap in X but are disconnected in 2D.
	# Keep the largest connected silhouette, discarding adjacent feet/noise.
	var seen = exterior.duplicate()
	var largest = PackedInt32Array()
	for y in h:
		for x in w:
			var first = y*w+x
			if seen[first] != 0:
				continue
			queue = PackedInt32Array([first])
			seen[first] = 1
			cursor = 0
			while cursor < queue.size():
				var n = queue[cursor]
				cursor += 1
				for dy in range(-1,2):
					for dx in range(-1,2):
						var nx = n%w+dx
						var ny = n/w+dy
						if nx < 0 or ny < 0 or nx >= w or ny >= h:
							continue
						var index = ny*w+nx
						if seen[index] == 0:
							seen[index] = 1
							queue.append(index)
			if queue.size() > largest.size():
				largest = queue
	var result = Image.create(w,h,false,Image.FORMAT_RGBA8)
	result.fill(Color.TRANSPARENT)
	for n in largest:
		result.set_pixel(n%w,n/w,img.get_pixel(n%w,n/w))
	return result.get_region(result.get_used_rect())

static func armor_pose(sheet: Image, area: Rect2i) -> Image:
	var img = extract_pose(sheet,area)
	# The dark armor has closed background pockets between bent arms/legs.
	# These are whole near-white regions, unlike its tiny specular highlights.
	# Do not apply this to Diogo: his white shirt is part of the character.
	var seen: Dictionary = {}
	for y in img.get_height():
		for x in img.get_width():
			var first = Vector2i(x,y)
			if seen.has(first) or img.get_pixelv(first).a < .9 or not background_pixel(img.get_pixelv(first)):
				continue
			var queue: Array[Vector2i] = [first]
			seen[first] = true
			var cursor = 0
			while cursor < queue.size():
				var p = queue[cursor]
				cursor += 1
				for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
					var v = p+direction
					if v.x < 0 or v.y < 0 or v.x >= img.get_width() or v.y >= img.get_height() or seen.has(v):
						continue
					var c = img.get_pixelv(v)
					if c.a > .9 and background_pixel(c):
						seen[v] = true
						queue.append(v)
			if queue.size() > 10:
				for pixel in queue:
					img.set_pixelv(pixel,Color.TRANSPARENT)
	return img

func build_armor(sheet: Image) -> void:
	var normal: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"mirkos/frames.json"))
	var original = Image.load_from_file(BASE+"mirkos/atlas.png")
	var atlas = Image.create(original.get_width(),original.get_height(),false,Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	var placements: Dictionary = {}
	var poses: Dictionary = {}
	for name in REGIONS:
		poses[name] = armor_pose(sheet,rect(REGIONS[name]))
	for name in normal.frames:
		var source_name: String = ALIASES.get(name,name)
		var pose: Image = poses[source_name]
		var cell = rect(normal.frames[name])
		# Match the center and foot height of the original whole source pose.
		# A single native source scale avoids breathing/resizing across frames.
		var old_bounds = original.get_region(rect(normal.frames[source_name])).get_used_rect()
		var bottom = old_bounds.end.y
		var center = old_bounds.position.x+old_bounds.size.x/2
		if name.begins_with("airpunch"):
			bottom = 248
		var place = Vector2i(center-pose.get_width()/2,bottom-pose.get_height())
		assert(place.x >= 2 and place.y >= 2 and place.x+pose.get_width() < CELL.x-2 and place.y+pose.get_height() < CELL.y-2,"Armor pose escapes cell: "+name)
		atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),cell.position+place)
		placements[name] = {"source_pose":source_name,"source_rect":REGIONS[source_name],"destination":[place.x,place.y],"size":[pose.get_width(),pose.get_height()],"whole_pose_alias":ALIASES.has(name)}
	var output = BASE+"mirkos_armor/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	atlas.save_png(output+"atlas.png")
	var data: Dictionary = {"frames":normal.frames.duplicate(true),"animations":normal.animations.duplicate(true),"anchor":[192,304],"source":"res://assets/references/060/mirkos-armor-source.jpeg","imported_poses":placements,"whole_pose_aliases":ALIASES}
	FileAccess.open(output+"frames.json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t")+"\n")
	# Portrait remains the same character, using the supplied armored idle pose.
	var portrait: Image = poses.idle0.duplicate()
	portrait.save_png(output+"portrait.png")
	print("ARMOR: ",normal.frames.size()," complete frames from ",poses.size()," supplied poses")

func fix_diogo_guard(sheet: Image) -> void:
	var atlas = Image.load_from_file(BASE+"diogo/atlas.png")
	atlas.convert(Image.FORMAT_RGBA8)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"diogo/frames.json"))
	var guard_rect = rect(data.frames.guard)
	var pose = extract_pose(sheet,Rect2i(500,22,136,253))
	var place = Vector2i(192-pose.get_width()/2,304-pose.get_height())
	atlas.fill_rect(guard_rect,Color.TRANSPARENT)
	atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),guard_rect.position+place)
	atlas.save_png(BASE+"diogo/atlas.png")
	var metadata = {"source":REFERENCES+"diogo-main-source.jpeg","source_rect":[500,22,136,253],"frame":"guard","destination":[place.x,place.y],"size":[pose.get_width(),pose.get_height()],"anchor":[192,304],"method":"Whole supplied pose; connected exterior background only; no body segmentation"}
	FileAccess.open(REFERENCES+"diogo-guard-import.json",FileAccess.WRITE).store_string(JSON.stringify(metadata,"\t")+"\n")
