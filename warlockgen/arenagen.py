from collections import OrderedDict

class GridDelta:
	def __init__(self):
		self.added_tiles = []
		self.removed_tiles = []
		self.changed_tiles = []

class Tile:
	def __init__(self, x, y, is_set):
		self.is_set = is_set
		self.x = x
		self.y = y
		self.style = None #Yaw = (rotation % 4) * 90deg, Round Edges = int(rotation / 4)
		
class Grid:
	def __init__(self, extent_x, extent_y):
		self.range_x = range(-extent_x, extent_x + 1)
		self.range_y = range(-extent_y, extent_y + 1)
		self.tiles = { }
		for x in range(-extent_x - 1, extent_x + 2):
			self.tiles[x] = { }
			for y in range(-extent_y - 1, extent_y + 2):
				self.tiles[x][y] = Tile(x, y, False)
			
		# Create an ordered dict with patterns to check, first ones have priority
		self.patterns = OrderedDict()
		
		# Set: Right; Not Set: Top, Left, Bottom; Yaw: 0deg, Round Edges: 2
		self.patterns["8"] = { "set": [ (1, 0) ], "not_set": [ (-1, 0), (0, 1), (0, -1) ] }
		# Set: Bottom; Not Set: Top, Left, Right; Yaw: 90deg, Round Edges: 2
		self.patterns["9"] = { "set": [ (0, 1) ], "not_set": [ (-1, 0), (0, -1), (1, 0) ] }
		# Set: Left; Not Set: Top, Right, Bottom; Yaw: 180deg, Round Edges: 2
		self.patterns["10"] = { "set": [ (-1, 0) ], "not_set": [ (1, 0), (0, 1), (0, -1) ] }
		# Set: Top; Not Set: Right, Left, Bottom; Yaw: 270deg, Round Edges: 2
		self.patterns["11"] = { "set": [ (0, -1) ], "not_set": [ (-1, 0), (0, 1), (1, 0) ] }
		
		# Set: Right, Bottom; Not Set: Left, Top; Yaw: 0deg, Round Edges: 1
		self.patterns["4"] = { "set": [ (1, 0), (0, -1) ], "not_set": [ (-1, 0), (0, 1) ] }
		# Set: Left, Bottom; Not Set: Right, Top; Yaw: 90deg, Round Edges: 1
		self.patterns["5"] = { "set": [ (0, 1), (1, 0) ], "not_set": [ (0, -1), (-1, 0) ] }
		# Set: Top, Left; Not Set: Right, Bottom; Yaw: 180deg, Round Edges: 1
		self.patterns["6"] = { "set": [ (-1, 0), (0, 1) ], "not_set": [ (1, 0), (0, -1) ] }
		# Set: Right, Top; Not Set: Left, Bottom; Yaw: 270deg, Round Edges: 1
		self.patterns["7"] = { "set": [ (0, -1), (-1, 0) ], "not_set": [ (0, 1), (1, 0) ] }

		# Default
		self.patterns["0"] = { "set": [ ], "not_set": [ ] }
		
				
	def generate_tiles(self, radius, tile_size):
		for x in self.range_x:
			for y in self.range_y:
				x_coord = x * tile_size
				y_coord = y * tile_size
				self.tiles[x][y].is_set = x_coord * x_coord + y_coord * y_coord < radius * radius

	def get_tile(self, x, y):
		return self.tiles[x][y]
		
	def _calculate_tile_style(self, x, y):
		if self.tiles[x][y].is_set:
			
			for style_str, pattern in self.patterns.items():
				match = True
				
				for s in pattern["set"]:
					if not self.tiles[x + s[0]][y + s[1]].is_set:
						match = False
						break
					
				for ns in pattern["not_set"]:
					if self.tiles[x + ns[0]][y + ns[1]].is_set:
						match = False
						break
						
				if match:
					self.tiles[x][y].style = int(style_str)
					break

	def calculate_tile_styles(self):
		for x in self.range_x:
			for y in self.range_y:
				self._calculate_tile_style(x, y)

def generate_grid_delta(from_grid, to_grid):
	delta = GridDelta()
	
	for x in from_grid.range_x:
		for y in from_grid.range_y:
			from_tile = from_grid.get_tile(x, y)
			to_tile = to_grid.get_tile(x, y)
		
			if not from_tile.is_set and to_tile.is_set: # Added
				delta.added_tiles.append((x, y, to_tile.style))
			elif from_tile.is_set and not to_tile.is_set: # Removed
				delta.removed_tiles.append((x, y))
			elif to_tile.is_set and from_tile.style != to_tile.style: # Changed
				delta.changed_tiles.append((x, y, to_tile.style))
				
	return delta
				
def get_delta_string(delta):
	s = ""

	s += "add = {"
	for tile in delta.added_tiles:
		s += "{ x = %s, y = %s, style = %s}, " % tile
		
	s += "}, remove = { "
	for tile in delta.removed_tiles:
		s += "{ x = %s, y = %s }, " % tile
	
	s += "}, change = { "
	for tile in delta.changed_tiles:
		s += "{ x = %s, y = %s, style = %s}, " % tile

	s += "} "
	
	return s

def main():
	tile_size = 192
	max_radius = 2000
	radius_step = 100
	radius = 0

	grids = []

	while radius <= max_radius:
		grid = Grid(20, 20)
		grid.generate_tiles(radius, tile_size)
		grid.calculate_tile_styles()
		grids.append(grid)
		radius += radius_step
		
	forward_deltas = []
	backward_deltas = []
	
	for i, grid in enumerate(grids):
		if i != len(grids) - 1:
			forward_deltas.append(generate_grid_delta(grids[i], grids[i+1]))
		else:
			forward_deltas.append(GridDelta())
			
		if i != 0:
			backward_deltas.append(generate_grid_delta(grids[i], grids[i-1]))
		else:
			backward_deltas.append(GridDelta())
			
	arena_str = "Arena.LAYERS = \n{"
	for i in range(0, len(forward_deltas)):
		arena_str += "\n\t{\t-- %s->%s / %s->%s\n" % (i, i+1, i, i-1)
		arena_str += "\t\tforward = "
		
		if i != len(forward_deltas) - 1:
			arena_str += "{ "
			arena_str += get_delta_string(forward_deltas[i]).replace(" ", "")
			arena_str += "},\n"
		else:
			arena_str += "nil,\n"
			
		arena_str += "\t\tbackward = "
		
		if i != 0:
			arena_str += " { "
			arena_str += get_delta_string(backward_deltas[i]).replace(" ", "")
			arena_str += "}"
		else:
			arena_str += "nil"
			
		arena_str += "\n\t},"
		
	arena_str += "\n}"
	
	with open("tile_code.lua", "w") as f:
		f.write(arena_str)
		
if __name__ == "__main__":
	main()
	