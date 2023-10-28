extends Node2D


# The size of the grid
var grid_width
var grid_height

# The size of the sprite
var sprite_scale = 0.5
var sprite_spacing = 80

# The arrays we keep bools in, we have two of these
# so we're able to switch between them.
var grid_one = []
var grid_two = []

# This is where we're keeping the sprites
var sprite_grid = []

# We need to swap between grid one and two- and can keep references to active and background grid
var active_grid
var background_grid

# Do we want to start with glider or random?
const use_glider = false

# Our random number generator
var rng = RandomNumberGenerator.new()

# Loads a grid with random data,
# allowing you to optionally specify how
# likely cells should be alive
func randomise_grid(true_chance = 0.5):
	for x in grid_width:
		for y in grid_height:
			var value = rng.randf() < true_chance
			active_grid[x][y] =value

# Create an empty grid
func create_empty_grid():
	var new_grid = []
	for x in grid_width:
		new_grid.append([])
		for y in grid_height:
			new_grid[x].append(false)
	return new_grid

# Create a 2d grid of sprites which we can hide/show as needed
func create_sprite_grid():
	var new_grid = []
	for x in grid_width:
		new_grid.append([])
		for y in grid_height:
			var sprite = Sprite2D.new()
			sprite.texture = load("res://icon.svg")
			sprite.scale.x = sprite_scale
			sprite.scale.y = sprite_scale
			sprite.position.x = x * sprite_spacing
			sprite.position.y = y * sprite_spacing
			self.add_child(sprite)
			new_grid[x].append(sprite)
	return new_grid

# Switch between active and background grid
func switch_active_grid():
	if active_grid == grid_one:
		active_grid = grid_two
		background_grid = grid_one
	else:
		active_grid = grid_one
		background_grid = grid_two

# Update sprites, hiding and showing as needed
func update_sprites():
	for x in grid_width:
		for y in grid_height:
			sprite_grid[x][y].visible = active_grid[x][y]

# Does all of the calculations to update the grid
func update_grid():
	print("Updating grid")

	# Toggle active grid before we start..
	switch_active_grid()

	# Iterate over the grid
	for x in grid_width:
		# Check for left/right edges
		var not_at_left = x != 0
		var not_at_right = x != (grid_width -1)

		for y in grid_height:

			# Check for top/bottom edges
			var not_at_top = y != 0
			var not_at_bottom = y != (grid_height -1)

			# Count the number of neighbours
			var neighbours = 0
			# Top left
			neighbours += int(not_at_left && not_at_top && background_grid[x-1][y-1])
			# Top
			neighbours += int(not_at_top && background_grid[x][y-1])
			# Top right
			neighbours += int(not_at_right && not_at_top && background_grid[x+1][y-1])
			# Left
			neighbours += int(not_at_left && background_grid[x-1][y])
			# Right
			neighbours += int(not_at_right && background_grid[x+1][y])
			# Bottom left
			neighbours += int(not_at_left && not_at_bottom && background_grid[x-1][y+1])
			# Bottom
			neighbours += int(not_at_bottom && background_grid[x][y+1])
			# Bottom right
			neighbours += int (not_at_right && not_at_bottom && background_grid[x+1][y+1])

			# Is the cell currently alive?
			if (background_grid[x][y]):
				# Live cells need two or three neighbours to survive
				active_grid[x][y] = neighbours == 2 || neighbours == 3
			else:
				# Dead cells become alive with three neighbourds
				active_grid[x][y] = neighbours == 3

# Draws the grid to the console
func dump_grid_to_console():
	for x in grid_width:
		var line = ""
		for y in grid_height:
			var value = active_grid[x][y]
			if (value):
				line = line+"X"
			else:
				line = line+"."
		print(line)
	print("---------------")

func setup_glider_grid():
	grid_width = 8
	grid_height = 8

	# Some starter data - a glider on an 8x8 grid..
	var glider = [
		[false, false, false, false, false, false, false, false],
		[false, false, true,  false, false, false, false, false],
		[true, false, true,  false, false, false, false, false],
		[false, true,  true,  false, false, false, false, false],
		[false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false],
		[false, false, false, false, false, false, false, false],
	]

	# Create our grid, we'll use the glider for testing
	grid_one = glider
	grid_two = create_empty_grid()
	active_grid = grid_one
	background_grid = grid_two


func setup_random():
	grid_width = 16
	grid_height = 16
	sprite_spacing = 512 / grid_width
	sprite_scale = 0.1

	grid_one = create_empty_grid()
	grid_two = create_empty_grid()
	active_grid = grid_one
	background_grid = grid_two
	randomise_grid()

# Called when the node enters the scene tree for the first time.
func _ready():
	if use_glider:
		setup_glider_grid()
	else:
		setup_random()

	# Create our sprite grid
	sprite_grid = create_sprite_grid()

	active_grid = grid_one
	background_grid = grid_two

	#randomise_grid()
	update_sprites()
	#dump_grid_to_console()

# Called when our timer ticks
func _on_update_timer_timeout():
	#print("Timer ticked")

	var time_before = Time.get_ticks_msec()
	update_grid()
	update_sprites()
	var total_time = Time.get_ticks_msec() - time_before
	print("Updtae time "+str(total_time)+"ms")
	#dump_grid_to_console()
