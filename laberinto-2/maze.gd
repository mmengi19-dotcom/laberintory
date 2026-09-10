extends TileMapLayer

const WIDTH = 11
const HEIGHT = 19

@export var source_id = 0
@export var atlas_coords = Vector2i(0, 0)

func _ready():
	generate_maze()

func generate_maze():
	clear()
	
	# 1. Matriz de paredes (1 = pared, 0 = camino)
	var grid = []
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(1)
	
	# 2. Algoritmo DFS (Backtracking)
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
		
		# Buscar vecinos libres a 2 baldosas
		for dir in directions:
			var nx = current.x + dir.x
			var ny = current.y + dir.y
			if nx > 0 and nx < WIDTH - 1 and ny > 0 and ny < HEIGHT - 1:
				if grid[nx][ny] == 1:
					neighbors.append(Vector2i(nx, ny))
		
		if neighbors.size() > 0:
			var chosen = neighbors.pick_random()
			# Romper pared del medio
			var mid_x = current.x + int((chosen.x - current.x) / 2)
			var mid_y = current.y + int((chosen.y - current.y) / 2)
			grid[mid_x][mid_y] = 0
			# Abrir destino
			grid[chosen.x][chosen.y] = 0
			stack.append(chosen)
		else:
			stack.pop_back()
			
	# 3. Pintar paredes en el TileMapLayer
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y] == 1:
				set_cell(Vector2i(x, y), source_id, atlas_coords)
	
	# 4. Ubicar la pelota en el inicio (1, 1)
	var ball = get_parent().get_node_or_null("Ball")
	if ball:
		ball.global_position = to_global(map_to_local(start))
	
	# 5. Ubicar la meta en un callejón sin salida aleatorio lejos del inicio
	var goal = get_parent().get_node_or_null("Goal")
	if goal:
		var possible_goals = []
		
		for x in range(1, WIDTH - 1):
			for y in range(1, HEIGHT - 1):
				# Si es camino y no es la posición inicial de la pelota
				if grid[x][y] == 0 and Vector2i(x, y) != start:
					# Contamos cuántas salidas tiene la casilla
					var exits = 0
					if grid[x + 1][y] == 0: exits += 1
					if grid[x - 1][y] == 0: exits += 1
					if grid[x][y + 1] == 0: exits += 1
					if grid[x][y - 1] == 0: exits += 1
					
					# Distancia Manhattan al punto de inicio para que no esté pegada a la pelota
					var distance = abs(x - start.x) + abs(y - start.y)
					
					# Si solo tiene 1 salida (es un callejón sin salida) y está a más de 6 baldosas
					if exits == 1 and distance >= 6:
						possible_goals.append(Vector2i(x, y))
		
		# Si encontramos callejones lejanos, elegimos uno al azar
		if possible_goals.size() > 0:
			var random_goal = possible_goals.pick_random()
			goal.global_position = to_global(map_to_local(random_goal))
		else:
			# Respaldo por seguridad: esquina inferior derecha
			goal.global_position = to_global(map_to_local(Vector2i(WIDTH - 2, HEIGHT - 2)))
