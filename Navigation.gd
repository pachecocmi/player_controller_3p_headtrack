extends Navigation

const SPEED = 4.0

var camrot = 0.0

var begin = Vector3()
var end = Vector3()
var m = SpatialMaterial.new()

var path = []
var draw_path = true

func _ready():
	set_process_input(true)
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.white
	
	begin = get_closest_point(get_node("AI").get_translation())
	end = get_closest_point(get_node("Player").get_translation())
	_update_path()
	print(begin, end)
	


func _process(delta):
	if path.size() > 1:
		var to_walk = delta * SPEED
		var to_watch = Vector3.UP
		while to_walk > 0 and path.size() >= 2:
			var pfrom = path[path.size() - 1]
			var pto = path[path.size() - 2]
			to_watch = (pto - pfrom).normalized()
			var d = pfrom.distance_to(pto)
			if d <= to_walk:
				path.remove(path.size() - 1)
				to_walk -= d
			else:
				path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk / d)
				to_walk = 0
		
		var atpos = path[path.size() - 1]
		var atdir = to_watch
		atdir.y = 0
		
		var t = Transform()
		t.origin = atpos
		t = t.looking_at(atpos + atdir, Vector3.UP)
		get_node("AI").set_transform(t)
		
		if path.size() < 2:
			path = []
			set_process(false)
	else:
		set_process(false)

func _update_path():
	var p = get_simple_path(begin, end, true)
	path = Array(p) # Vector3 array too complex to use, convert to regular array.
	path.invert()
	set_process(true)
