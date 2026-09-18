extends TileMapLayer

# Dimensiones base iniciales
const BASE_WIDTH: int = 11
const BASE_HEIGHT: int = 19

# Dimensiones activas en el nivel actual
var width: int = BASE_WIDTH
var height: int = BASE_HEIGHT
var extraPath: int = 9

# Límite máximo opcional para que no sea inmanejable en móviles
const MAX_WIDTH: int = 33 #33 #11 es el basico
const MAX_HEIGHT: int = 53 #53 #19 es el basico
const MAX_PATH: int = 75

@export var source_id = 0
@export var atlas_coords = Vector2i(0, 0)


func _ready():
	GameManager.level_changed.connect(_on_level_changed)
	generate_maze()


func _on_level_changed(new_level: int):
	print("Generando laberinto para el nivel: ", new_level)
	generate_maze()


# ============================================================
# GENERA CAMINOS EXTRA
# ============================================================

func add_extra_paths(grid):
	for i in range(extraPath):
		var x = randi_range(1, width - 2)
		var y = randi_range(1, height - 2)

		if grid[x][y] == 1:

			# Camino a izquierda y derecha
			var horizontal = (
				grid[x - 1][y] == 0
				and grid[x + 1][y] == 0
			)

			# Camino arriba y abajo
			var vertical = (
				grid[x][y - 1] == 0
				and grid[x][y + 1] == 0
			)

			# Romper la pared para crear un camino alternativo
			if horizontal or vertical:
				grid[x][y] = 0


# ============================================================
# BUSCA LA META Y UNA CASILLA ALEATORIA PARA LA LLAVE
# ============================================================

func find_maze_points(grid, start) -> Dictionary:

	var queue = []
	var distances = {}

	queue.append(start)
	distances[start] = 0

	var directions = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(-1, 0),
		Vector2i(1, 0)
	]

	var farthest = start
	var max_distance = 0
	var head = 0

	# 1. Exploración BFS para calcular distancias
	while head < queue.size():

		var current = queue[head]
		head += 1

		for dir in directions:

			var next = current + dir

			if next.x < 0 or next.x >= width:
				continue

			if next.y < 0 or next.y >= height:
				continue

			if grid[next.x][next.y] != 0:
				continue

			if distances.has(next):
				continue

			distances[next] = distances[current] + 1
			queue.append(next)

			if distances[next] > max_distance:
				max_distance = distances[next]
				farthest = next

	# 2. Filtrar pasillos para colocar la llave
	var min_path_dist = int(max_distance * 0.20)
	var max_path_dist = int(max_distance * 0.85)

	var key_candidates: Array[Vector2i] = []

	for cell in distances.keys():
		var d = distances[cell]

		if d >= min_path_dist and d <= max_path_dist:
			var dist_to_start = Vector2(cell - start).length()
			var dist_to_goal = Vector2(cell - farthest).length()

			# Distancia mínima directa de 4 casillas tanto del inicio como de la meta
			if dist_to_start > 4.0 and dist_to_goal > 4.0:
				key_candidates.append(cell)

	var key_cell: Vector2i
	if key_candidates.size() > 0:
		key_cell = key_candidates.pick_random()
	else:
		key_cell = farthest

	return {
		"goal": farthest,
		"key": key_cell
	}


# ============================================================
# GENERACIÓN COMPLETA DEL LABERINTO
# ============================================================

func generate_maze():

	clear()

	# 1. Ajustar dimensiones según el modo de juego
	if GameManager.current_mode == GameManager.GameMode.CHALLENGE:
		width = MAX_WIDTH
		height = MAX_HEIGHT
		extraPath = MAX_PATH
	else:
		var level = GameManager.current_level
		var growth = int(float(level - 1) / 4) * 2
		width = mini(BASE_WIDTH + growth, MAX_WIDTH)
		height = mini(BASE_HEIGHT + growth, MAX_HEIGHT)

		var growthExtraPath = int(float(level - 1) / 4) * 4
		extraPath = mini(9 + growthExtraPath, MAX_PATH)

	print("Modo: ", GameManager.current_mode, " | Dimensiones: %dx%d | Pasillos: %d" % [width, height, extraPath])

	# ========================================================
	# 1. CREAR MATRIZ
	# ========================================================
	var grid = []

	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(1)


	# ========================================================
	# 2. GENERAR LABERINTO CON DFS
	# ========================================================

	var stack = []
	var start = Vector2i(1, 1)

	grid[start.x][start.y] = 0
	stack.append(start)

	var directions = [
		Vector2i(0, -2),
		Vector2i(0, 2),
		Vector2i(-2, 0),
		Vector2i(2, 0)
	]

	while stack.size() > 0:

		var current = stack[-1]
		var neighbors = []

		for dir in directions:
			var nx = current.x + dir.x
			var ny = current.y + dir.y

			if nx > 0 and nx < width - 1:
				if ny > 0 and ny < height - 1:
					if grid[nx][ny] == 1:
						neighbors.append(Vector2i(nx, ny))

		if neighbors.size() > 0:
			var chosen = neighbors.pick_random()

			var mid_x = current.x + int((chosen.x - current.x) / 2)
			var mid_y = current.y + int((chosen.y - current.y) / 2)

			grid[mid_x][mid_y] = 0
			grid[chosen.x][chosen.y] = 0
			stack.append(chosen)
		else:
			stack.pop_back()


	# ========================================================
	# 3. AGREGAR CAMINOS EXTRA
	# ========================================================

	add_extra_paths(grid)


	# ========================================================
	# 4. BUSCAR PUNTOS CLAVE (META Y LLAVE)
	# ========================================================

	var points = find_maze_points(grid, start)
	var farthest_cell = points.goal
	var key_cell = points.key


	# ========================================================
	# 5. PINTAR LAS PAREDES
	# ========================================================

	for x in range(width):
		for y in range(height):
			if grid[x][y] == 1:
				set_cell(
					Vector2i(x, y),
					source_id,
					atlas_coords
				)


	# ========================================================
	# 6. COLOCAR LA PELOTA
	# ========================================================

	var ball = get_parent().get_node_or_null("Ball")

	if ball:
		var start_pos = to_global(map_to_local(start))

		if ball.has_method("reset_to_start"):
			ball.reset_to_start(start_pos)
		else:
			ball.global_position = start_pos


		# ====================================================
		# 7. CONFIGURAR CÁMARA
		# ====================================================

		var camera = ball.get_node_or_null("Camera2D")

		if camera:
			var tile_size = tile_set.tile_size

			camera.limit_left = global_position.x
			camera.limit_top = global_position.y
			camera.limit_right = global_position.x + width * tile_size.x
			camera.limit_bottom = global_position.y + height * tile_size.y

			camera.enabled = true
			camera.position_smoothing_enabled = true
			camera.position_smoothing_speed = 5.0


	# ========================================================
	# 8. COLOCAR LA META Y LA LLAVE
	# ========================================================

	var goal = get_parent().get_node_or_null("Goal")
	if goal:
		goal.global_position = to_global(map_to_local(farthest_cell))
		if goal.has_method("update_visual_state"):
			goal.update_visual_state()

	var key_node = get_parent().get_node_or_null("Key")
	if key_node:
		if GameManager.current_mode == GameManager.GameMode.CHALLENGE:
			key_node.setup_key(to_global(map_to_local(key_cell)))
		else:
			key_node.hide_key()
