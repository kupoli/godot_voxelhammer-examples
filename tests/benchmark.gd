tool

extends Spatial

export var do_terrain_bm = false setget _set_do_terrain_bm
export var do_clear = false setget _set_do_clear

export(Resource) var vox_configuration =  preload("res://addons/voxel_hammer/res/benchmark_voxel_configuration.tres")

class BenchmarkSuit:
	var chunks
	var chunk_size
	
	func _init(chunks, chunk_size):
		self.chunks = chunks
		self.chunk_size = chunk_size

var pending_suits = Array()
var running_suit = null

var suit_timer = null

var test_offset = Vector3(0,0,0)


func _set_do_terrain_bm(nv):
	if nv:
		do_terrain_bm = false
		add_terrain_benchmarks()
	else:
		do_terrain_bm = false


func _set_do_clear(nv):
	if nv:
		do_clear = false
		clear_benchmarks()
	else:
		do_clear = false


func _ready():
	if not Engine.editor_hint:
		_set_do_terrain_bm(true)


func _process(delta):
	if not running_suit:
		running_suit = pending_suits.pop_front()
		if running_suit:
				var total_voxels = running_suit.chunks.x*running_suit.chunks.y*running_suit.chunks.z * running_suit.chunk_size.x*running_suit.chunk_size.y*running_suit.chunk_size.z
				var suit_text = "chunks: %s * size: %s: total %s voxels" % [running_suit.chunks, running_suit.chunk_size, total_voxels]
				print("Testing with %s" % suit_text)
				#create terrain
				
				suit_timer = DebugTimer.new("Time of %s" % suit_text)
			
				var terrain = VoxelTerrain.new()
				terrain.configuration = vox_configuration
				terrain.terrain_chunks = running_suit.chunks
				terrain.chunk_voxel_count = running_suit.chunk_size
				
				terrain.do_test_fill = true
				
				add_child(terrain)
				
				terrain.connect("terrain_ready", self, "_on_terrain_ready")
				
				terrain.translation = test_offset
				test_offset.z += 512


func add_terrain_benchmarks():
	print("Adding terrain benchmarks...")
	
	# test suits in format [chunks, chunk_size]
	#pending_suits.append( BenchmarkSuit.new(Vector3(2,2,2), Vector3(16,16,16)))
	pending_suits.append( BenchmarkSuit.new(Vector3(8,4,8), Vector3(32,32,32)))
	pending_suits.append( BenchmarkSuit.new(Vector3(4,2,4), Vector3(64,64,64)))
	pending_suits.append( BenchmarkSuit.new(Vector3(2,1,2), Vector3(128,128,128)))


func clear_benchmarks():
	for child in get_children():
		child.queue_free()


func _on_terrain_ready():
	#print("Terrain ready")
	suit_timer.end()
	running_suit = null
