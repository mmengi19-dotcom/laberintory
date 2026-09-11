extends TileMapLayer

# Dimensiones base iniciales
const BASE_WIDTH: int = 11
const BASE_HEIGHT: int = 19

# Dimensiones activas en el nivel actual
var width: int = BASE_WIDTH
var height: int = BASE_HEIGHT
var extraPath: int = 9

# Límite máximo opcional para que no sea inmanejable en móviles
const MAX_WIDTH: int = 33
const MAX_HEIGHT: int = 53
const MAX_PATH: int = 75

@export var source_id = 0
@export var atlas_coords = Vector2i(0, 0)
@onready var timer = get_parent().get_node("UI/TimerLabel")

func _ready():
	timer.start_timer()
	generate_maze()


# ============================================================
# GENERA CAMINOS EXTRA
# ============================================================

func add_extra_paths(grid):
	for i in range(extraPath):#EN 25 FUNCIONA BIEN
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
# BUSCA LA CASILLA MÁS LEJANA DEL INICIO
# ============================================================

func find_farthest_cell(grid, start):

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

	while head < queue.size():

		var current = queue[head]
		head += 1

		for dir in directions:

			var next = current + dir

			# Comprobar límites
			if next.x < 0 or next.x >= width:
				continue

			if next.y < 0 or next.y >= height:
				continue

			# No atravesar paredes
			if grid[next.x][next.y] != 0:
				continue

			# No visitar dos veces
			if distances.has(next):
				continue

			distances[next] = distances[current] + 1
			queue.append(next)

			# Comprobar si es la casilla más lejana
			if distances[next] > max_distance:
				max_distance = distances[next]
				farthest = next

	return farthest


# ============================================================
# GENERACIÓN COMPLETA DEL LABERINTO
# ============================================================

func generate_maze():

	clear()

	# 1. Obtener nivel actual desde la UI
	var ui = get_parent().get_node_or_null("UI")
	var level = ui.current_level if ui else 1

	# 2. Calcular incremento: +2 cada 4 niveles
	var growth = int((level - 1) / 4) * 2

	width = mini(BASE_WIDTH + growth, MAX_WIDTH)
	height = mini(BASE_HEIGHT + growth, MAX_HEIGHT)
	
	var growthExtraPath = int((level - 1) / 4) * 4
	extraPath=mini(9+growthExtraPath,75)
	print("pasillos %d",extraPath)
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

	# Abrir posición inicial
	grid[start.x][start.y] = 0

	stack.append(start)


	# Movimientos de dos casillas
	var directions = [
		Vector2i(0, -2),
		Vector2i(0, 2),
		Vector2i(-2, 0),
		Vector2i(2, 0)
	]


	while stack.size() > 0:

		var current = stack[-1]
		var neighbors = []


		# --------------------------------------------
		# Buscar vecinos disponibles
		# --------------------------------------------

		for dir in directions:

			var nx = current.x + dir.x
			var ny = current.y + dir.y

			if nx > 0 and nx < width - 1:
				if ny > 0 and ny < height - 1:

					if grid[nx][ny] == 1:
						neighbors.append(Vector2i(nx, ny))


		# --------------------------------------------
		# Si encontramos un vecino
		# --------------------------------------------

		if neighbors.size() > 0:

			var chosen = neighbors.pick_random()


			# ----------------------------------------
			# Romper pared intermedia
			# ----------------------------------------

			var mid_x = current.x + int(
				(chosen.x - current.x) / 2
			)

			var mid_y = current.y + int(
				(chosen.y - current.y) / 2
			)

			grid[mid_x][mid_y] = 0


			# Abrir destino
			grid[chosen.x][chosen.y] = 0

			stack.append(chosen)


		# --------------------------------------------
		# Si no hay vecinos, retroceder
		# --------------------------------------------

		else:

			stack.pop_back()


	# ========================================================
	# 3. AGREGAR CAMINOS EXTRA
	# ========================================================

	add_extra_paths(grid)


	# ========================================================
	# 4. BUSCAR LA CASILLA MÁS LEJANA
	# ========================================================

	var farthest_cell = find_farthest_cell(
		grid,
		start
	)


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

		# Si el script de la bola tiene la función de reinicio, la frena y reubica
		if ball.has_method("reset_to_start"):
			ball.reset_to_start(start_pos)
		else:
			ball.global_position = start_pos


		# ====================================================
		# 7. CONFIGURAR CÁMARA
		# ====================================================

		var camera = ball.get_node_or_null("Camera2D")

		if camera:

			# Obtener tamaño de los tiles
			var tile_size = tile_set.tile_size


			# --------------------------------------------
			# Límites del laberinto
			# --------------------------------------------

			camera.limit_left = global_position.x

			camera.limit_top = global_position.y

			camera.limit_right = (
				global_position.x
				+ width * tile_size.x
			)

			camera.limit_bottom = (
				global_position.y
				+ height * tile_size.y
			)


			# --------------------------------------------
			# Activar cámara
			# --------------------------------------------

			camera.enabled = true


			# --------------------------------------------
			# Suavizado de movimiento
			# --------------------------------------------

			camera.position_smoothing_enabled = true
			camera.position_smoothing_speed = 5.0


	# ========================================================
	# 8. COLOCAR LA META
	# ========================================================

	var goal = get_parent().get_node_or_null("Goal")

	if goal:

		goal.global_position = to_global(
			map_to_local(farthest_cell)
		)
