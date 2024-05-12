extends Node3D

# The game state helps us manage the lifecycle of the game.
# The states here should reflect all the possible nodes in your game lifecycle flowchart.
enum GAME_STATE {Start, Playing, Transition, GameOver, Completed}

var state: GAME_STATE # Current state of the game (see enum above)
var level: int # The level number
var level_node: Node # Our placeholder node where we will put the level scene
var current_level: Level # The currently loaded level scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_node = $Level
	set_state(GAME_STATE.Start)

func _on_start_button_pressed() -> void:
	goto_level(1)
	set_state(GAME_STATE.Playing)
	
func free_level() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null

func goto_level(new_level: int) -> void:
	# Free any previous level
	free_level()

	# Keep track of current level (number)
	level = new_level

	# Load the level and instantiate
	var path: String = "res://Levels/level_" + str(level) + ".tscn"
	current_level = load(path).instantiate()
	
	# Put in inside the level node
	level_node.add_child(current_level)
	
	# Position the player at their starting position
	var player_start_pos = current_level.get_node("PlayerStart").position
	$Player.position = player_start_pos
	
func set_state(new_state: GAME_STATE) -> void:
	state = new_state
	$StartScreen.visible = state == GAME_STATE.Start
	$Level.visible = state != GAME_STATE.Start
	$GameOver.visible = state == GAME_STATE.GameOver
	#$Transition.visible = state == GAME_STATE.Transition
	$Completed.visible = state == GAME_STATE.Completed
	
	$Player.set_physics_process(state == GAME_STATE.Playing)

func _on_player_player_died():
	set_state(GAME_STATE.GameOver)

func _on_player_player_wins():
	if level < 2:
		goto_level(level + 1)
	else:
		set_state(GAME_STATE.Completed)
