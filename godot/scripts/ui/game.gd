extends Control

const DiceSet = preload("res://scripts/core/dice_set.gd")
const BoardGenerator = preload("res://scripts/core/board_generator.gd")
const PathValidator = preload("res://scripts/core/path_validator.gd")
const WordValidator = preload("res://scripts/core/word_validator.gd")
const ScoringService = preload("res://scripts/core/scoring_service.gd")

const BOARD_SIZE: int = 5
const DICE_PATH: String = "res://data/dice_set_big_boggle.json"
const ENABLE_DICTIONARY_VALIDATION: bool = false
const DICTIONARY_PATHS: Array[String] = [
	"res://data/dictionary_es_demo.txt",
	"res://data/dictionary_en_demo.txt"
]

@onready var board_grid: GridContainer = $MarginContainer/VBox/BoardGrid
@onready var current_word_label: Label = $MarginContainer/VBox/TopBar/CurrentWordLabel
@onready var score_label: Label = $MarginContainer/VBox/TopBar/ScoreLabel
@onready var feedback_label: Label = $MarginContainer/VBox/FeedbackLabel
@onready var dictionary_info_label: Label = $MarginContainer/VBox/DictionaryInfoLabel
@onready var accepted_list: ItemList = $MarginContainer/VBox/AcceptedList
@onready var send_button: Button = $MarginContainer/VBox/Actions/SendButton
@onready var clear_button: Button = $MarginContainer/VBox/Actions/ClearButton

var board_cells: Dictionary = {}
var button_by_position: Dictionary = {}
var selected_path: Array[Vector2i] = []
var selected_buttons: Array[Button] = []
var validator: WordValidator
var score: int = 0
var loaded_dictionary_paths: PackedStringArray = PackedStringArray()
var accepted_words: Dictionary = {}
var current_board: Array[Array] = []

func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	clear_button.pressed.connect(_clear_selection)

	var dice_set: DiceSet = DiceSet.from_json_file(DICE_PATH)
	if not dice_set.is_valid_for_board(BOARD_SIZE):
		feedback_label.text = "Error: DiceSet inválido para tablero 5x5."
		return

	current_board = BoardGenerator.generate_board(dice_set, BOARD_SIZE)
	_build_board(current_board)
	get_viewport().size_changed.connect(_on_viewport_size_changed)

	if ENABLE_DICTIONARY_VALIDATION:
		var words: PackedStringArray = _load_dictionaries(DICTIONARY_PATHS)
		validator = WordValidator.new(words, 4)
		_update_dictionary_info(words.size())
	else:
		dictionary_info_label.text = "Validación de diccionario: desactivada (modo prototipo)."
	_update_labels()


func _on_viewport_size_changed() -> void:
	if current_board.is_empty():
		return
	_build_board(current_board)

func _calculate_tile_size() -> int:
	var viewport_size: Vector2i = get_viewport_rect().size
	var reserved_height: int = 300
	var available_for_board: int = max(viewport_size.y - reserved_height, 240)
	var tile_size: int = int((available_for_board / float(BOARD_SIZE)) - 6.0)
	return clampi(tile_size, 48, 88)

func _build_board(board: Array[Array]) -> void:
	for child in board_grid.get_children():
		child.queue_free()

	board_cells.clear()
	button_by_position.clear()
	selected_path.clear()
	selected_buttons.clear()
	accepted_words.clear()

	for row in board:
		for cell_variant in row:
			var cell: Dictionary = cell_variant
			var position: Vector2i = cell["position"]
			board_cells[position] = cell

			var tile: Button = Button.new()
			tile.text = ""
			var tile_size: int = _calculate_tile_size()
			tile.custom_minimum_size = Vector2(tile_size, tile_size)
			tile.focus_mode = Control.FOCUS_NONE
			tile.pressed.connect(_on_cell_pressed.bind(position))

			var letter_label: Label = Label.new()
			letter_label.text = str(cell["letter"])
			var letter_font_size: int = max(int(tile_size * 0.8), 24)
			letter_label.add_theme_font_size_override("font_size", letter_font_size)
			letter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			letter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			letter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			letter_label.set_anchors_preset(Control.PRESET_FULL_RECT)
			letter_label.offset_left = 0
			letter_label.offset_top = 0
			letter_label.offset_right = 0
			letter_label.offset_bottom = 0
			letter_label.pivot_offset = tile.custom_minimum_size / 2.0
			letter_label.rotation_degrees = float(cell["rotation_degrees"])
			tile.add_child(letter_label)

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

	var word: String = _current_word().to_upper()
	if word.length() < 4:
		feedback_label.text = "❌ %s (too_short)" % word
		_clear_selection(false)
		_update_labels()
		return

	if accepted_words.has(word):
		feedback_label.text = "❌ %s (duplicate)" % word
		_clear_selection(false)
		_update_labels()
		return

	var is_valid: bool = true
	var invalid_reason: String = ""
	if ENABLE_DICTIONARY_VALIDATION:
		var result: Dictionary = validator.validate_word(word)
		is_valid = bool(result["valid"])
		invalid_reason = String(result["reason"])

	if is_valid:
		accepted_words[word] = true
		var points: int = ScoringService.points_for_word_length(word.length())
		score += points
		accepted_list.add_item("%s (+%d)" % [word, points])
		feedback_label.text = "✅ %s aceptada" % word
	else:
		if invalid_reason == "not_in_dictionary":
			feedback_label.text = "❌ %s no está en el diccionario activo" % word
		else:
			feedback_label.text = "❌ %s (%s)" % [word, invalid_reason]

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
		var cell: Dictionary = board_cells[position]
		chars.append(str(cell["letter"]))
	return "".join(chars)

func _update_labels() -> void:
	current_word_label.text = "Palabra: %s" % _current_word()
	score_label.text = "Puntaje: %d" % score

func _load_dictionaries(paths: Array[String]) -> PackedStringArray:
	var words_set: Dictionary = {}
	loaded_dictionary_paths = PackedStringArray()

	for path in paths:
		var file: FileAccess = FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		loaded_dictionary_paths.append(path)
		while not file.eof_reached():
			var line: String = file.get_line().strip_edges()
			if line.is_empty():
				continue
			words_set[line.to_upper()] = true

	if words_set.is_empty():
		feedback_label.text = "No se encontró diccionario demo (ES/EN)."
		for fallback_word in ["CASA", "PERRO", "GATO", "LUNA", "GAME", "WORD"]:
			words_set[String(fallback_word)] = true

	var words: PackedStringArray = PackedStringArray()
	for word in words_set.keys():
		words.append(String(word))
	return words

func _update_dictionary_info(total_words: int) -> void:
	if loaded_dictionary_paths.is_empty():
		dictionary_info_label.text = "Diccionario: fallback interno (%d palabras)." % total_words
		return
	dictionary_info_label.text = "Diccionario activo: %s (%d palabras)." % [", ".join(loaded_dictionary_paths), total_words]
