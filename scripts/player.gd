extends RigidBody

# defs
const SPEED = 5.0;
const ACCELERATION = 8.0;
const JUMP_FORCE = 10.0;

# refs
onready var camera = $camera;
onready var body = $body;

# vars
var velocity = Vector3.ZERO;
var has_jump = false;
var lock_body = false;

func _ready() -> void:
	mode = RigidBody.MODE_CHARACTER;
	can_sleep = false;
	gravity_scale = 2.0;

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	var dir = Vector3.ZERO;
	var basis = camera.global_transform.basis;
	
	if (Input.is_key_pressed(KEY_W)):
		dir -= basis.z;
	if (Input.is_key_pressed(KEY_S)):
		dir += basis.z;
	if (Input.is_key_pressed(KEY_A)):
		dir -= basis.x;
	if (Input.is_key_pressed(KEY_D)):
		dir += basis.x;
	
	dir.y = 0.0;
	dir = dir.normalized();
	
	# set speed
	dir = dir * SPEED;
	
	# get velocity
	velocity = state.linear_velocity;
	
	# set velocity
	dir.y = velocity.y;
	velocity = velocity.linear_interpolate(dir, ACCELERATION * state.step);
	
	# jump
	if (Input.is_key_pressed(KEY_SPACE)):
		if (!has_jump):
			velocity.y = JUMP_FORCE;
		has_jump = true;
	else:
		has_jump = false;
	
	# move object
	state.linear_velocity = velocity;

func _process(delta: float) -> void:
	# look direction
	var look_dir = Vector3.FORWARD;
	
	# horizontal velocity
	var hvel = Vector3(velocity.x, 0.0, velocity.z);
	if (hvel.length() > 0.1 && !lock_body):
		look_dir = hvel.normalized();
	
	if (lock_body):
		look_dir = camera.get_forward();
		look_dir.y = 0.0;
		look_dir = look_dir.normalized();
	
	# rotate body node
	var rot_a = Quat(body.transform.basis);
	var rot_b = Quat(body.transform.looking_at(look_dir, Vector3.UP).basis);
	body.transform.basis = Basis(rot_a.slerp(rot_b, 10.0 * delta));

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && event.pressed):
		var instance = preload("res://test.tscn").instance();
		var origin = global_transform.origin + Vector3(0, 1.0, 0);
		instance.transform = instance.transform.looking_at(camera.get_shoot_direction(origin), Vector3.UP);
		instance.transform.origin = origin;
		get_parent().add_child(instance);
