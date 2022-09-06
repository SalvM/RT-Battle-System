extends Node

const inputKeys = "KI"
const moveKeys = "WASD"

const fightCombos = {
	"IKI": {
		"name": "Slashing",
		"cost": 4,
		"hits": 2,
		"delta": 1.2
	}
}

# Looking for one of the combos inside a string
func _wordInString(word, string):
	if word.length() > string.length(): return [];
	var stringIndex = 0
	var indexes = []
	while (stringIndex <= string.length() - word.length()):
		var i = string.find(word, stringIndex);
		if i < 0:
			stringIndex = string.length();
		else:
			indexes.push_back(i);
			stringIndex = i + word.length() - 1;
	return indexes;

# Given the last inputs, it will find and return a combo
func checkForWords(comboAttempt):
	var comboToExecute = []
	comboToExecute.resize(comboAttempt.length())
	for word in fightCombos.keys():
		for index in _wordInString(word, comboAttempt):
			return word
