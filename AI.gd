extends KinematicBody

export var speed = 100
var target
var space_state

func _ready():
	space_state = get_world().direct_space_state

func _physics_process(delta):
	if target:
		var result = space_state.intersect_ray(global_transform.origin, target.global_transform.origin)
		if result.collider.is_in_group("Player"):
			#look at player
			look_at(target.global_transform.origin, Vector3.UP)
			# add this so the ai looks at the player
			self.rotate_object_local(Vector3(0,1,0), 3.14)
			move_to_target(delta)
	else:
		AI_IDLE()

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		print(body.name+"entered")

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null
		print(body.name+"exit")

func move_to_target(delta):
	var direction = (target.transform.origin - transform.origin).normalized()
	move_and_slide(direction*speed*delta)

func random():
	return randi()%2

func AI_IDLE():
	var atpos = Vector3(Vector3(random(),0,random()))
	atpos = atpos.normalized() * 2 
	move_and_slide(atpos)
