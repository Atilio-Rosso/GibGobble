class_name PathValidator
extends RefCounted

static func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx := abs(a.x - b.x)
	var dy := abs(a.y - b.y)
	return (dx <= 1 and dy <= 1) and not (dx == 0 and dy == 0)

static func is_valid_path(path: Array[Vector2i], board_size: int) -> bool:
	if path.is_empty():
		return false

	var visited := {}
	for i in range(path.size()):
		var cell := path[i]
		if cell.x < 0 or cell.y < 0 or cell.x >= board_size or cell.y >= board_size:
			return false
		if visited.has(cell):
			return false
		visited[cell] = true
		if i > 0 and not is_adjacent(path[i - 1], cell):
			return false

	return true
