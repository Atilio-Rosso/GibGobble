class_name ScoringService
extends RefCounted

static func points_for_word_length(length: int) -> int:
	if length <= 2:
		return 0
	if length <= 4:
		return 1
	if length == 5:
		return 2
	if length == 6:
		return 3
	if length == 7:
		return 5
	return 11
