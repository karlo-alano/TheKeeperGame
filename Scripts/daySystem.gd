extends Node

var dayInfo := {
	1: {"label": "June 31",
		"tasks": [
			{"name": "Pack lunch for Penny", "done": false},
			{"name": "Deliver letters", "done": false},
			{"name": "Sweep litter", "done": false}
		],
		"counter": "2 days to go"
	},
	2: {"label": "July 1",
		"tasks": [
			{"name": "Collect rent", "done": false},
			{"name": "Water plants", "done": false},
			{"name": "Accompany cat", "done": false}
		],
		"counter": "1 day to go"
	},
	3: {"label": "July 2",
		"tasks": [
			{"name": "Ask Mrs. Valenciano about paluto for Penny's birthday", "done": false}
		],
		"counter": "Day 3"
	},
}

var journal_entries := {
	1: "",
	2: "June 31. Made packed lunch. Delivered the letters. Penny came home safe. That's the day.\n\nI mentioned him at the gate. I shouldn't have.",
	3: ""
}
