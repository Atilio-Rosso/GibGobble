extends SceneTree

const DiceSet = preload("res://scripts/core/dice_set.gd")
const BoardGenerator = preload("res://scripts/core/board_generator.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const ScoringService = preload("res://scripts/core/scoring_service.gd")
const WordValidator = preload("res://scripts/core/word_validator.gd")

var failed := 0

func _init() -> void:
	test_dice_set_validation()
	test_board_generation_uses_25_unique_dice()
	test_path_validator()
	test_scoring()
	test_word_validator()

	if failed == 0:
		print("OK: todos los tests pasaron")
		quit(0)
	else:
		push_error("Fallaron %d tests" % failed)
		quit(1)

func expect(condition: bool, message: String) -> void:
	if not condition:
		failed += 1
		push_error("[FAIL] %s" % message)

func test_dice_set_validation() -> void:
	var valid_dice: Array[String] = []
	for _i in range(25):
		valid_dice.append("ABCDEF")
	var ds := DiceSet.new(valid_dice)
	expect(ds.is_valid_for_board(5), "DiceSet válido para 5x5")

	valid_dice.pop_back()
	var invalid := DiceSet.new(valid_dice)
	expect(not invalid.is_valid_for_board(5), "DiceSet inválido si no tiene 25 dados")

	var repeated_faces: Array[String] = []
	for _j in range(25):
		repeated_faces.append("AABCDE")
	var invalid_repeated := DiceSet.new(repeated_faces)
	expect(not invalid_repeated.is_valid_for_board(5), "DiceSet inválido si un dado repite letras")

func test_board_generation_uses_25_unique_dice() -> void:
	var dice: Array[String] = []
	for i in range(25):
		dice.append("ABCDEF")
	var ds := DiceSet.new(dice)
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var board := BoardGenerator.generate_board(ds, 5, rng)

	var seen := {}
	for row in board:
		for cell in row:
			seen[cell.die_id] = true
			expect([0, 90, 180, 270].has(cell.rotation_degrees), "Rotación válida")
	expect(seen.size() == 25, "Cada tablero debe usar los 25 dados exactamente una vez")

func test_path_validator() -> void:
	var ok_path: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(1, 2)]
	expect(PathValidator.is_valid_path(ok_path, 5), "Ruta adyacente válida")

	var repeated: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 1), Vector2i(0, 0)]
	expect(not PathValidator.is_valid_path(repeated, 5), "Ruta inválida con celda repetida")

	var jump: Array[Vector2i] = [Vector2i(0, 0), Vector2i(2, 2)]
	expect(not PathValidator.is_valid_path(jump, 5), "Ruta inválida por salto no adyacente")

func test_scoring() -> void:
	expect(ScoringService.points_for_word_length(2) == 0, "2 letras = 0")
	expect(ScoringService.points_for_word_length(4) == 1, "4 letras = 1")
	expect(ScoringService.points_for_word_length(5) == 2, "5 letras = 2")
	expect(ScoringService.points_for_word_length(8) == 11, "8 letras = 11")

func test_word_validator() -> void:
	var validator := WordValidator.new(PackedStringArray(["CASA", "PERRO"]), 4)
	var first := validator.validate_word("casa")
	expect(first.valid, "CASA debe ser válida")

	var dup := validator.validate_word("CASA")
	expect(not dup.valid and dup.reason == "duplicate", "CASA duplicada inválida")

	var short := validator.validate_word("sol")
	expect(not short.valid and short.reason == "too_short", "Palabra corta inválida")
