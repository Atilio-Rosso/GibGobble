class_name WordValidator
extends RefCounted

var min_length: int = 3
var dictionary := {}
var already_found := {}

func _init(words: PackedStringArray = PackedStringArray(), p_min_length: int = 3) -> void:
	min_length = p_min_length
	for word in words:
		dictionary[String(word).to_upper()] = true

func validate_word(raw_word: String) -> Dictionary:
	var word := raw_word.strip_edges().to_upper()
	if word.length() < min_length:
		return {"valid": false, "reason": "too_short", "word": word}
	if not dictionary.has(word):
		return {"valid": false, "reason": "not_in_dictionary", "word": word}
	if already_found.has(word):
		return {"valid": false, "reason": "duplicate", "word": word}

	already_found[word] = true
	return {"valid": true, "reason": "ok", "word": word}
