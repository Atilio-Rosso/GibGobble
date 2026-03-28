class_name DiceSet
extends RefCounted

var dice: Array[String] = []

func _init(raw_dice: Array[String] = []) -> void:
	dice = raw_dice.duplicate()

static func from_json_file(path: String) -> DiceSet:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir el archivo de dados: %s" % path)
		return DiceSet.new([])

	var parsed := JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON inválido para dados: %s" % path)
		return DiceSet.new([])

	var raw := parsed.get("dice", [])
	var normalized: Array[String] = []
	for die in raw:
		normalized.append(String(die).to_upper())

	return DiceSet.new(normalized)

func is_valid_for_board(board_size: int) -> bool:
	if board_size <= 0:
		return false
	if dice.size() != board_size * board_size:
		return false
	for die in dice:
		if die.length() != 6:
			return false
		if not _has_unique_faces(die):
			return false
	return true

func _has_unique_faces(die: String) -> bool:
	var seen := {}
	for i in range(die.length()):
		var letter := die.substr(i, 1)
		if seen.has(letter):
			return false
		seen[letter] = true
	return true
