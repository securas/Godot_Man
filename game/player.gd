extends Node2D

const CELLSIZE : Vector2 = Vector2( 8, 8 )
const VEL : float = 5

var dir : Vector2i = Vector2i( 1, 0 )
var target_dir : Vector2i = Vector2i.ZERO
var dir_idx : int = 1
var not_started : bool
var score : int = 0

@onready var colmap : TileMap = $"../collisions_tilemap"
@onready var carmap : TileMap = $"../carrots_tilemap"
@onready var anim: AnimationPlayer = $anim


var poscell : Vector2i
var posdelta : Vector2
var lst_position : Vector2

func _ready() -> void:
	set_physics_process( false )
	var curcell = Vector2i( ( position - CELLSIZE * 0.5 ) / CELLSIZE )
	poscell = curcell
	posdelta = ( position - Vector2( poscell ) * CELLSIZE ) / CELLSIZE
	#print( "CURCELL: ", curcell )


func start() -> void:
	set_physics_process( true )
	anim.play( "move" )
	

func _physics_process( delta : float ) -> void:
	posdelta += dir * delta * VEL
	var is_moving : int = 0
	if _has_collision( poscell + Vector2i( 1, 0 ) ) and posdelta.x >= 0.5:
		posdelta.x = 0.5
	else:
		is_moving += 1
	if posdelta.x > 1:
		poscell.x += 1
		posdelta.x -= 1
	if _has_collision( poscell + Vector2i( -1, 0 ) ) and posdelta.x <= 0.5:
		posdelta.x = 0.5
	else:
		is_moving += 1
	if posdelta.x < 0:
		poscell.x -= 1
		posdelta.x += 1
	if poscell.x > 27: poscell.x -= 28
	if poscell.x < 0: poscell.x += 28
	
	if _has_collision( poscell + Vector2i( 0, 1 ) ) and posdelta.y >= 0.5:
		posdelta.y = 0.5
	else:
		is_moving += 1
	if posdelta.y > 1:
		poscell.y += 1
		posdelta.y -= 1
	if _has_collision( poscell + Vector2i( 0, -1 ) ) and posdelta.y <= 0.5:
		posdelta.y = 0.5
	else:
		is_moving += 1
	if posdelta.y < 0:
		poscell.y -= 1
		posdelta.y += 1
	
	_update_position()
	var pos_var = ( position - lst_position ).abs()
	if pos_var.x > 0.1 or pos_var.y > 0.1:
		if not anim.is_playing():
			anim.play()
	else:
		anim.pause()
	
	print( "movement: ", position - lst_position )
	#if is_moving:
		#anim.pause()
	#else:
		#if not anim.is_playing():
			#print( "plaling")
			#anim.play()
	
	if Input.is_action_just_pressed( "btn_left" ):
		target_dir = Vector2i.LEFT
	if Input.is_action_just_pressed( "btn_right" ):
		target_dir = Vector2i.RIGHT
	if Input.is_action_just_pressed( "btn_up" ):
		target_dir = Vector2i.UP
	if Input.is_action_just_pressed( "btn_down" ):
		target_dir = Vector2i.DOWN
	
	if target_dir != Vector2i.ZERO:
		if not _has_collision( poscell + target_dir ) and \
			posdelta.x >= 0.45 and posdelta.x <= 0.55 and \
			posdelta.y >= 0.45 and posdelta.y <= 0.55:
				dir = target_dir
				target_dir = Vector2i.ZERO
	
	if posdelta.x >= 0.45 and posdelta.x <= 0.55 and \
		posdelta.y >= 0.45 and posdelta.y <= 0.55:
			if carmap.get_cell_source_id( 0, poscell ) >= 0:
				var atlaspos : Vector2i = carmap.get_cell_atlas_coords( 0, poscell )
				#print( "celldata: ",atlaspos )
				if atlaspos == Vector2i( 0, 1 ):
					score += 1
					print( "SCORE: ", score )
					carmap.set_cell( 0, poscell, -1 )
			# get_cell_atlas_coords


func _has_collision( at_cell : Vector2i ) -> bool:
	if not colmap: return false
	return colmap.get_cell_source_id( 0, at_cell ) >= 0

func _update_position() -> void:
	lst_position = position
	position = ( Vector2( poscell ) + posdelta ) * 8
	#print( "player position: ", position )
