extends Spatial

# defs
const DISTANCE = 5.0;
const SENSITIVITY = 0.2;
const INTERP = 10.0;

# refs
onready var player = get_parent();
onready var pitch = $pitch;
onready var camera = $pitch/pivot/cam;
onready var pivot = $pitch/pivot;
onready var aim = $pitch/aim;
onready var space_state = get_world().direct_space_state;

# vars
var origin_pos = Vector3.ZERO;
var offset = Vector3.ZERO;
var cam_position = Vector3.ZERO;
var is_colliding = false;
var collide_pos = Vector3.ZERO;

func _ready():
	origin_pos = player.global_transform.origin;
	offset = transform.origin;
	capture_mouse();

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		_rotate_cam(event.relative * SENSITIVITY);

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

func _rotate_cam(rel: Vector2) -> void:
	pitch.rotation_degrees.x = clamp(pitch.rotation_degrees.x - rel.y, -68.0, 60.0);
	rotation_degrees.y = fmod(rotation_degrees.y - rel.x, 360.0);

func _physics_process(delta: float) -> void:
	var from = aim.global_transform.origin;
	cam_position = pivot.global_transform.origin;
	var ray_test = space_state.intersect_ray(from, cam_position, [player]);
	
	if (ray_test && ray_test.size() && ray_test.has("position")):
		is_colliding = true;
		collide_pos = ray_test.position;
	else:
		is_colliding = false;
		collide_pos = Vector3.ZERO;

func _process(delta: float) -> void:
	# intepolate base camera
	origin_pos = origin_pos.linear_interpolate(player.global_transform.origin, INTERP * delta);
	global_transform.origin = origin_pos + offset;
	
	# set camera position
	if (is_colliding && collide_pos.length() > 0.0):
		camera.global_transform.origin = collide_pos;
	else:
		camera.transform.origin = Vector3.ZERO;
	
	# look at aim position
	var aim_position = aim.global_transform.origin;
	camera.global_transform.basis = camera.global_transform.looking_at(aim_position, Vector3.UP).basis;

func get_forward() -> Vector3:
	return -camera.global_transform.basis.z;

func get_shoot_direction(from: Vector3) -> Vector3:
	var f = camera.global_transform.origin + (get_forward() * 100.0);
	return (f - from).normalized();
	
