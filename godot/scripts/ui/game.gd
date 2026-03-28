extends Control

const DiceSet = preload("res://scripts/core/dice_set.gd")
const BoardGenerator = preload("res://scripts/core/board_generator.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const WordValidator = preload("res://scripts/core/word_validator.gd")
const ScoringService = preload("res://scripts/core/scoring_service.gd")

const BOARD_SIZE: int = 5
const DEFAULT_DICTIONARY_PATH: String = "res://data/dictionary_es_demo.txt"
const DICE_PATH: String = "res://data/dice_set_big_boggle.json"

@onready var board_grid: GridContainer = $MarginContainer/VBox/BoardGrid
@onready var current_word_label: Label = $MarginContainer/VBox/TopBar/CurrentWordLabel
@onready var score_label: Label = $MarginContainer/VBox/TopBar/ScoreLabel
@onready var feedback_label: Label = $MarginContainer/VBox/FeedbackLabel
@onready var accepted_list: ItemList = $MarginContainer/VBox/AcceptedList
@onready var send_button: Button = $MarginContainer/VBox/Actions/SendButton
@onready var clear_button: Button = $MarginContainer/VBox/Actions/ClearButton

var board_cells: Dictionary = {}
var button_by_position: Dictionary = {}
var selected_path: Array[Vector2i] = []
var selected_buttons: Array[Button] = []
var validator: WordValidator
var score: int = 0

func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	clear_button.pressed.connect(_clear_selection)

	var dice_set: DiceSet = DiceSet.from_json_file(DICE_PATH)
	if not dice_set.is_valid_for_board(BOARD_SIZE):
		feedback_label.text = "Error: DiceSet inválido para tablero 5x5."
		return

	var board: Array[Array] = BoardGenerator.generate_board(dice_set, BOARD_SIZE)
	_build_board(board)

	var words: PackedStringArray = _load_dictionary(DEFAULT_DICTIONARY_PATH)
	validator = WordValidator.new(words, 3)
	_update_labels()

func _build_board(board: Array[Array]) -> void:
	for child in board_grid.get_children():
		child.queue_free()

	board_cells.clear()
	button_by_position.clear()
	selected_path.clear()
	selected_buttons.clear()

	for row in board:
		for cell in row:
			var position: Vector2i = cell["position"]
			board_cells[position] = cell

			var tile: Button = Button.new()
			tile.text = str(cell["letter"])
			tile.custom_minimum_size = Vector2(96, 96)
			tile.pivot_offset = tile.custom_minimum_size / 2.0
			tile.rotation_degrees = float(cell["rotation_degrees"])
			tile.focus_mode = Control.FOCUS_NONE
			tile.pressed.connect(_on_cell_pressed.bind(position))
			board_grid.add_child(tile)
			button_by_position[position] = tile

func _on_cell_pressed(position: Vector2i) -> void:
	if selected_path.has(position):
		feedback_label.text = "No puedes repetir una celda en la misma palabra."
		return

	if not selected_path.is_empty():
		var previous: Vector2i = selected_path[selected_path.size() - 1]
		if not PathValidator.is_adjacent(previous, position):
			feedback_label.text = "La letra seleccionada debe ser adyacente."
			return

	selected_path.append(position)
	var button: Button = button_by_position[position]
	selected_buttons.append(button)
	button.modulate = Color(0.70, 0.90, 1.0)
	_update_labels()

func _on_send_pressed() -> void:
	if selected_path.is_empty():
		feedback_label.text = "Selecciona al menos una letra."
		return

	if not PathValidator.is_valid_path(selected_path, BOARD_SIZE):
		feedback_label.text = "Ruta inválida. Revisa adyacencia y repeticiones."
		_clear_selection(false)
		return

	var word: String = _current_word()
	var result: Dictionary = validator.validate_word(word)
	if result["valid"]:
		var points: int = ScoringService.points_for_word_length(word.length())
		score += points
		accepted_list.add_item("%s (+%d)" % [word, points])
		feedback_label.text = "✅ %s aceptada" % word
	else:
		feedback_label.text = "❌ %s (%s)" % [word, str(result["reason"])]

	_clear_selection(false)
	_update_labels()

func _clear_selection(update_feedback: bool = true) -> void:
	for button in selected_buttons:
		button.modulate = Color(1, 1, 1)
	selected_buttons.clear()
	selected_path.clear()
	if update_feedback:
		feedback_label.text = "Selección limpiada."
	_update_labels()

func _current_word() -> String:
	var chars: Array[String] = []
	for position in selected_path:
		chars.append(str(board_cells[position]["letter"]))
	return "".join(chars)

func _update_labels() -> void:
	current_word_label.text = "Palabra: %s" % _current_word()
	score_label.text = "Puntaje: %d" % score

func _load_dictionary(path: String) -> PackedStringArray:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		feedback_label.text = "No se encontró diccionario demo, usando lista mínima."
		return PackedStringArray(["CASA", "PERRO", "GATO", "SOL", "LUNA", "JUEGO", "DADO"])

	var words: PackedStringArray = PackedStringArray()
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line.is_empty():
			continue
		words.append(line.to_upper())
	return words
