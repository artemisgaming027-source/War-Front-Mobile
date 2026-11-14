extends Node3D

const HeroRoster = preload("res://scripts/hero_roster.gd")

const TEAM_BLUE := 0
const TEAM_RED := 1
const LANE_Z := [-18.0, 0.0, 18.0]
const HERO_SPEED := 8.0
const ATTACK_RANGE := 12.0
const ATTACK_DAMAGE := 18.0

var player: CharacterBody3D
var units: Array[Node3D] = []
var match_time := 600.0
var blue_score := 0
var red_score := 0
var game_over := false
var hud_label: Label
var message_label: Label
var attack_button: Button
var move_vector := Vector2.ZERO
var selected_hero := "assault"

func _ready() -> void:
	_build_world()
	_build_bases_and_towers()
	_spawn_armies()
	_build_camera()
	_build_hud()
	_update_hud()

func _process(delta: float) -> void:
	if game_over:
		return
	match_time = maxf(0.0, match_time - delta)
	_update_units(delta)
	_update_hud()
	if match_time <= 0.0:
		_finish_match("WAKTU HABIS")

func _build_world() -> void:
	add_child(_make_box("Terrain", Vector3(0, -0.7, 0), Vector3(76, 1, 58), Color(0.20, 0.27, 0.22)))
	for lane_index in range(3):
		var z: float = LANE_Z[lane_index]
		add_child(_make_box("Lane_%d" % lane_index, Vector3(0, -0.12, z), Vector3(68, 0.25, 7.0), Color(0.28, 0.30, 0.29)))
		for x in range(-30, 31, 6):
			add_child(_make_box("RoadMark", Vector3(float(x), 0.02, z), Vector3(2.0, 0.04, 0.16), Color(0.76, 0.72, 0.48)))
	for side in [-1.0, 1.0]:
		for i in range(7):
			var x: float = side * (8.0 + float(i % 3) * 5.0)
			var z: float = float((i % 2) * 2 - 1) * (8.0 + float(i) * 1.2)
			add_child(_make_box("SupplyCrate", Vector3(x, 0.7, z), Vector3(2.0, 1.4, 2.0), Color(0.30, 0.34, 0.25)))
	for x in range(-34, 35, 8):
		for z in [-27.0, 27.0]:
			add_child(_make_box("PerimeterWall", Vector3(float(x), 1.0, z), Vector3(6.0, 2.0, 0.7), Color(0.22, 0.25, 0.24)))

func _build_bases_and_towers() -> void:
	_add_base(TEAM_BLUE, -32.0)
	_add_base(TEAM_RED, 32.0)
	for lane_z in LANE_Z:
		_add_tower(TEAM_BLUE, Vector3(-20, 1.4, lane_z))
		_add_tower(TEAM_BLUE, Vector3(-10, 1.4, lane_z))
		_add_tower(TEAM_RED, Vector3(20, 1.4, lane_z))
		_add_tower(TEAM_RED, Vector3(10, 1.4, lane_z))

func _add_base(team: int, x: float) -> void:
	var color := Color(0.12, 0.35, 0.75) if team == TEAM_BLUE else Color(0.72, 0.16, 0.12)
	add_child(_make_box("Blue_HQ" if team == TEAM_BLUE else "Red_HQ", Vector3(x, 1.2, 0), Vector3(7, 2.4, 13), color))
	add_child(_make_cylinder("HQBeacon", Vector3(x, 3.4, 0), 1.3, 3.0, color.lightened(0.35)))

func _add_tower(team: int, pos: Vector3) -> void:
	var color := Color(0.18, 0.48, 0.9) if team == TEAM_BLUE else Color(0.9, 0.22, 0.16)
	var tower := _make_cylinder("DefenseTower", pos, 1.1, 2.8, color)
	tower.set_meta("team", team)
	tower.set_meta("hp", 320.0)
	add_child(tower)

func _spawn_armies() -> void:
	player = _make_unit("Assault", TEAM_BLUE, Vector3(-27, 0.9, 0), true, selected_hero)
	add_child(player)
	units.append(player)
	for i in range(4):
		var z: float = LANE_Z[i % 3] + (1.8 if i % 2 == 0 else -1.8)
		var ally_hero: String = HeroRoster.HERO_ORDER[i + 1]\n\t\tvar ally := _make_unit(HeroRoster.get_profile(ally_hero).display_name, TEAM_BLUE, Vector3(-25.0 - float(i % 2) * 2.0, 0.9, z), false, ally_hero)
		add_child(ally)
		units.append(ally)
	for i in range(5):
		var z: float = LANE_Z[i % 3] + (1.8 if i % 2 == 0 else -1.8)
		var enemy_hero: String = HeroRoster.HERO_ORDER[i % HeroRoster.HERO_ORDER.size()]\n\t\tvar enemy := _make_unit(HeroRoster.get_profile(enemy_hero).display_name, TEAM_RED, Vector3(25.0 + float(i % 2) * 2.0, 0.9, z), false, enemy_hero)
		add_child(enemy)
		units.append(enemy)

func _make_unit(unit_name: String, team: int, pos: Vector3, is_player: bool, hero_id: String) -> CharacterBody3D:
	var unit := CharacterBody3D.new()
	unit.name = unit_name
	unit.position = pos
	unit.set_meta("team", team)
	unit.set_meta("hp", 220.0 if is_player else 150.0)
	unit.set_meta("max_hp", 220.0 if is_player else 150.0)
	unit.set_meta("is_player", is_player)
	unit.set_meta("cooldown", randf_range(0.0, 0.8))
	var body_color := Color(0.12, 0.36, 0.78) if team == TEAM_BLUE else Color(0.72, 0.16, 0.12)
	unit.add_child(_make_cylinder("Armor", Vector3(0, 0.85, 0), 0.48, 1.45, body_color))
	unit.add_child(_make_sphere("Helmet", Vector3(0, 1.75, 0), 0.34, Color(0.24, 0.29, 0.22)))
	unit.add_child(_make_box("Rifle", Vector3(0.42, 1.12, -0.2), Vector3(0.16, 0.16, 1.0), Color(0.08, 0.09, 0.08)))
	unit.add_child(_make_box("HealthBack", Vector3(0, 2.35, 0), Vector3(1.1, 0.10, 0.08), Color(0.12, 0.12, 0.12)))
	var hp_bar := _make_box("HealthFill", Vector3(0, 2.42, 0), Vector3(1.0, 0.08, 0.09), Color(0.2, 0.9, 0.3) if team == TEAM_BLUE else Color(0.95, 0.25, 0.18))
	unit.add_child(hp_bar)
	unit.set_meta("hp_bar", hp_bar)
	return unit

func _update_units(delta: float) -> void:
	for unit in units:
		if not is_instance_valid(unit) or float(unit.get_meta("hp", 0.0)) <= 0.0:
			continue
		if bool(unit.get_meta("is_player", false)):
			_player_control(unit, delta)
		else:
			_bot_control(unit, delta)
		var cd := maxf(0.0, float(unit.get_meta("cooldown", 0.0)) - delta)
		unit.set_meta("cooldown", cd)

func _player_control(unit: CharacterBody3D, delta: float) -> void:
	var direction := Vector3.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left") + move_vector.x
	direction.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up") + move_vector.y
	if direction.length() > 1.0:
		direction = direction.normalized()
	unit.velocity.x = direction.x * HERO_SPEED
	unit.velocity.z = direction.z * HERO_SPEED
	unit.velocity.y -= 22.0 * delta
	unit.move_and_slide()
	if direction.length() > 0.1:
		unit.rotation.y = atan2(direction.x, direction.z)
	if Input.is_action_pressed("attack") or (attack_button != null and attack_button.button_pressed):
		_try_attack(unit)

func _bot_control(unit: CharacterBody3D, delta: float) -> void:
	var target := _nearest_enemy(unit)
	if target == null:
		return
	var offset: Vector3 = target.global_position - unit.global_position
	var distance := offset.length()
	var unit_range: float = float(unit.get_meta("attack_range", ATTACK_RANGE))\n\tif distance > unit_range * 0.72:
		var direction := Vector3(offset.x, 0, offset.z).normalized()
		unit.velocity.x = direction.x * 4.2
		unit.velocity.z = direction.z * 4.2
		unit.velocity.y -= 22.0 * delta
		unit.move_and_slide()
		unit.rotation.y = atan2(direction.x, direction.z)
	else:
		unit.velocity.x = move_toward(unit.velocity.x, 0.0, 15.0 * delta)
		unit.velocity.z = move_toward(unit.velocity.z, 0.0, 15.0 * delta)
		unit.move_and_slide()
		_try_attack(unit)

func _try_attack(unit: CharacterBody3D) -> void:
	if float(unit.get_meta("cooldown", 0.0)) > 0.0:
		return
	var target := _nearest_enemy(unit)
	if target == null or unit.global_position.distance_to(target.global_position) > ATTACK_RANGE:
		return
	target.set_meta("hp", float(target.get_meta("hp")) - ATTACK_DAMAGE)
	unit.set_meta("cooldown", 0.85)
	var bar: MeshInstance3D = target.get_meta("hp_bar")
	var ratio: float = clampf(float(target.get_meta("hp")) / float(target.get_meta("max_hp")), 0.0, 1.0)
	bar.scale.x = maxf(0.02, ratio)
	if float(target.get_meta("hp")) <= 0.0:
		target.visible = false
		if int(unit.get_meta("team")) == TEAM_BLUE:
			blue_score += 1
		else:
			red_score += 1
		if bool(target.get_meta("is_player", false)):
			_finish_match("KAMU TERELIMINASI")

func _nearest_enemy(unit: Node3D) -> Node3D:
	var best: Node3D = null
	var best_distance: float = float(unit.get_meta("attack_range", ATTACK_RANGE))
	for candidate in units:
		if candidate == unit or not is_instance_valid(candidate) or not candidate.visible:
			continue
		if float(candidate.get_meta("hp", 0.0)) <= 0.0:
			continue
		if int(candidate.get_meta("team")) == int(unit.get_meta("team")):
			continue
		var distance := unit.global_position.distance_to(candidate.global_position)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	return best

func _build_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "BattleCamera"
	camera.position = Vector3(0, 48, 35)
	camera.rotation_degrees = Vector3(-54, 0, 0)
	camera.current = true
	camera.fov = 48.0
	add_child(camera)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.light_energy = 1.15
	add_child(light)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.58, 0.62, 0.60)
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	add_child(environment)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud_label = Label.new()
	hud_label.position = Vector2(20, 14)
	hud_label.add_theme_font_size_override("font_size", 23)
	hud_label.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(hud_label)
	message_label = Label.new()
	message_label.text = "WAR FRONT  |  " + str(player.get_meta("hero_name", "ASSAULT")) + "  |  5V5 TRAINING"
	message_label.position = Vector2(20, 50)
	message_label.add_theme_font_size_override("font_size", 15)
	layer.add_child(message_label)
	var hint := Label.new()
	hint.text = "WASD / tombol arah untuk bergerak"
	hint.position = Vector2(20, 78)
	hint.add_theme_font_size_override("font_size", 14)
	layer.add_child(hint)
	var directions := [
		["▲", Vector2(100, -50), "move_up"],
		["▼", Vector2(100, 130), "move_down"],
		["◀", Vector2(10, 40), "move_left"],
		["▶", Vector2(190, 40), "move_right"]
	]
	for item in directions:
		var button := Button.new()
		button.text = item[0]
		button.position = Vector2(24, 530) + item[1]
		button.size = Vector2(90, 90)
		button.add_theme_font_size_override("font_size", 28)
		layer.add_child(button)
		var action: String = item[2]
		button.button_down.connect(func(): Input.action_press(action))
		button.button_up.connect(func(): Input.action_release(action))
	attack_button = Button.new()
	attack_button.text = "FIRE"
	attack_button.position = Vector2(1080, 540)
	attack_button.size = Vector2(150, 130)
	attack_button.add_theme_font_size_override("font_size", 24)
	layer.add_child(attack_button)

func _update_hud() -> void:
	if hud_label == null:
		return
	var minutes := int(match_time) / 60
	var seconds := int(match_time) % 60
	hud_label.text = "BLUE %02d  |  %02d:%02d  |  RED %02d" % [blue_score, minutes, seconds, red_score]

func _finish_match(reason: String) -> void:
	game_over = true
	if message_label != null:
		message_label.text = reason + "  •  PERTANDINGAN SELESAI"

func _make_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.position = pos
	instance.mesh = mesh
	instance.material_override = _material(color)
	return instance

func _make_cylinder(node_name: String, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.position = pos
	instance.mesh = mesh
	instance.material_override = _material(color)
	return instance

func _make_sphere(node_name: String, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.position = pos
	instance.mesh = mesh
	instance.material_override = _material(color)
	return instance

func _material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	return mat
