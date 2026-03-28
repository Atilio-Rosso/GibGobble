class_name BoardGenerator
extends RefCounted

const ROTATIONS: Array[int] = [0, 90, 180, 270]

static func generate_board(dice_set: DiceSet, board_size: int, rng: RandomNumberGenerator = null) -> Array[Array]:
	assert(dice_set.is_valid_for_board(board_size), "DiceSet inválido para el tamaño del tablero")
	var random: RandomNumberGenerator = rng if rng != null else RandomNumberGenerator.new()
	if rng == null:
		random.randomize()

	var shuffled_indices: Array[int] = []
	for i in range(dice_set.dice.size()):
		shuffled_indices.append(i)
	shuffled_indices.shuffle()

	var board: Array[Array] = []
	for row in range(board_size):
		var row_cells: Array = []
		for col in range(board_size):
			var idx: int = row * board_size + col
			var die_id: int = shuffled_indices[idx]
			var die_faces: String = dice_set.dice[die_id]
			var face_index: int = random.randi_range(0, 5)
			var letter: String = die_faces.substr(face_index, 1)
			var rotation_index: int = random.randi_range(0, ROTATIONS.size() - 1)
			var rotation: int = ROTATIONS[rotation_index]
			row_cells.append({
				"die_id": die_id,
				"letter": letter,
				"rotation_degrees": rotation,
				"position": Vector2i(col, row)
			})
		board.append(row_cells)
	return board
