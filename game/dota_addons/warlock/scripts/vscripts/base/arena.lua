--- Warlock arena, shrink and damage
-- @author Krzysztof Lis (Adynathos)

Arena = class()
Arena.ARENA_TILE_SIZE 	= 192
Arena.ARENA_TILE_HEIGHT = 32
Arena.ARENA_TILE_Z 		= 42.5 --Height 3, 71.5
Arena.ARENA_MAX_COORD	= 20
Arena.SHRINK_PERIOD 	= 10
Arena.DAMAGE_PERIOD 	= 0.25
Arena.DAMAGE_PER_SECOND = 100
Arena.DAMAGE_KB_POINT_FACTOR = 0.5
Arena.LAYERS = 
{
	{	-- 0->1 / 0->-1
		forward = { add={{x=0,y=0,style=0},},remove={},change={}},
		backward = nil
	},
	{	-- 1->2 / 1->0
		forward = { add={{x=-1,y=0,style=8},{x=0,y=-1,style=9},{x=0,y=1,style=11},{x=1,y=0,style=10},},remove={},change={}},
		backward =  { add={},remove={{x=0,y=0},},change={}}
	},
	{	-- 2->3 / 2->1
		forward = { add={{x=-1,y=-1,style=5},{x=-1,y=1,style=4},{x=1,y=-1,style=6},{x=1,y=1,style=7},},remove={},change={{x=-1,y=0,style=0},{x=0,y=-1,style=0},{x=0,y=1,style=0},{x=1,y=0,style=0},}},
		backward =  { add={},remove={{x=-1,y=0},{x=0,y=-1},{x=0,y=1},{x=1,y=0},},change={}}
	},
	{	-- 3->4 / 3->2
		forward = { add={{x=-2,y=0,style=8},{x=0,y=-2,style=9},{x=0,y=2,style=11},{x=2,y=0,style=10},},remove={},change={}},
		backward =  { add={},remove={{x=-1,y=-1},{x=-1,y=1},{x=1,y=-1},{x=1,y=1},},change={{x=-1,y=0,style=8},{x=0,y=-1,style=9},{x=0,y=1,style=11},{x=1,y=0,style=10},}}
	},
	{	-- 4->5 / 4->3
		forward = { add={{x=-2,y=-1,style=5},{x=-2,y=1,style=4},{x=-1,y=-2,style=5},{x=-1,y=2,style=4},{x=1,y=-2,style=6},{x=1,y=2,style=7},{x=2,y=-1,style=6},{x=2,y=1,style=7},},remove={},change={{x=-2,y=0,style=0},{x=-1,y=-1,style=0},{x=-1,y=1,style=0},{x=0,y=-2,style=0},{x=0,y=2,style=0},{x=1,y=-1,style=0},{x=1,y=1,style=0},{x=2,y=0,style=0},}},
		backward =  { add={},remove={{x=-2,y=0},{x=0,y=-2},{x=0,y=2},{x=2,y=0},},change={}}
	},
	{	-- 5->6 / 5->4
		forward = { add={{x=-3,y=0,style=8},{x=-2,y=-2,style=5},{x=-2,y=2,style=4},{x=0,y=-3,style=9},{x=0,y=3,style=11},{x=2,y=-2,style=6},{x=2,y=2,style=7},{x=3,y=0,style=10},},remove={},change={{x=-2,y=-1,style=0},{x=-2,y=1,style=0},{x=-1,y=-2,style=0},{x=-1,y=2,style=0},{x=1,y=-2,style=0},{x=1,y=2,style=0},{x=2,y=-1,style=0},{x=2,y=1,style=0},}},
		backward =  { add={},remove={{x=-2,y=-1},{x=-2,y=1},{x=-1,y=-2},{x=-1,y=2},{x=1,y=-2},{x=1,y=2},{x=2,y=-1},{x=2,y=1},},change={{x=-2,y=0,style=8},{x=-1,y=-1,style=5},{x=-1,y=1,style=4},{x=0,y=-2,style=9},{x=0,y=2,style=11},{x=1,y=-1,style=6},{x=1,y=1,style=7},{x=2,y=0,style=10},}}
	},
	{	-- 6->7 / 6->5
		forward = { add={{x=-3,y=-2,style=5},{x=-3,y=-1,style=0},{x=-3,y=1,style=0},{x=-3,y=2,style=4},{x=-2,y=-3,style=5},{x=-2,y=3,style=4},{x=-1,y=-3,style=0},{x=-1,y=3,style=0},{x=1,y=-3,style=0},{x=1,y=3,style=0},{x=2,y=-3,style=6},{x=2,y=3,style=7},{x=3,y=-2,style=6},{x=3,y=-1,style=0},{x=3,y=1,style=0},{x=3,y=2,style=7},},remove={},change={{x=-3,y=0,style=0},{x=-2,y=-2,style=0},{x=-2,y=2,style=0},{x=0,y=-3,style=0},{x=0,y=3,style=0},{x=2,y=-2,style=0},{x=2,y=2,style=0},{x=3,y=0,style=0},}},
		backward =  { add={},remove={{x=-3,y=0},{x=-2,y=-2},{x=-2,y=2},{x=0,y=-3},{x=0,y=3},{x=2,y=-2},{x=2,y=2},{x=3,y=0},},change={{x=-2,y=-1,style=5},{x=-2,y=1,style=4},{x=-1,y=-2,style=5},{x=-1,y=2,style=4},{x=1,y=-2,style=6},{x=1,y=2,style=7},{x=2,y=-1,style=6},{x=2,y=1,style=7},}}
	},
	{	-- 7->8 / 7->6
		forward = { add={{x=-4,y=-1,style=5},{x=-4,y=0,style=0},{x=-4,y=1,style=4},{x=-1,y=-4,style=5},{x=-1,y=4,style=4},{x=0,y=-4,style=0},{x=0,y=4,style=0},{x=1,y=-4,style=6},{x=1,y=4,style=7},{x=4,y=-1,style=6},{x=4,y=0,style=0},{x=4,y=1,style=7},},remove={},change={}},
		backward =  { add={},remove={{x=-3,y=-2},{x=-3,y=-1},{x=-3,y=1},{x=-3,y=2},{x=-2,y=-3},{x=-2,y=3},{x=-1,y=-3},{x=-1,y=3},{x=1,y=-3},{x=1,y=3},{x=2,y=-3},{x=2,y=3},{x=3,y=-2},{x=3,y=-1},{x=3,y=1},{x=3,y=2},},change={{x=-3,y=0,style=8},{x=-2,y=-2,style=5},{x=-2,y=2,style=4},{x=0,y=-3,style=9},{x=0,y=3,style=11},{x=2,y=-2,style=6},{x=2,y=2,style=7},{x=3,y=0,style=10},}}
	},
	{	-- 8->9 / 8->7
		forward = { add={{x=-4,y=-2,style=5},{x=-4,y=2,style=4},{x=-3,y=-3,style=5},{x=-3,y=3,style=4},{x=-2,y=-4,style=5},{x=-2,y=4,style=4},{x=2,y=-4,style=6},{x=2,y=4,style=7},{x=3,y=-3,style=6},{x=3,y=3,style=7},{x=4,y=-2,style=6},{x=4,y=2,style=7},},remove={},change={{x=-4,y=-1,style=0},{x=-4,y=1,style=0},{x=-3,y=-2,style=0},{x=-3,y=2,style=0},{x=-2,y=-3,style=0},{x=-2,y=3,style=0},{x=-1,y=-4,style=0},{x=-1,y=4,style=0},{x=1,y=-4,style=0},{x=1,y=4,style=0},{x=2,y=-3,style=0},{x=2,y=3,style=0},{x=3,y=-2,style=0},{x=3,y=2,style=0},{x=4,y=-1,style=0},{x=4,y=1,style=0},}},
		backward =  { add={},remove={{x=-4,y=-1},{x=-4,y=0},{x=-4,y=1},{x=-1,y=-4},{x=-1,y=4},{x=0,y=-4},{x=0,y=4},{x=1,y=-4},{x=1,y=4},{x=4,y=-1},{x=4,y=0},{x=4,y=1},},change={}}
	},
	{	-- 9->10 / 9->8
		forward = { add={{x=-5,y=-1,style=5},{x=-5,y=0,style=0},{x=-5,y=1,style=4},{x=-4,y=-3,style=5},{x=-4,y=3,style=4},{x=-3,y=-4,style=5},{x=-3,y=4,style=4},{x=-1,y=-5,style=5},{x=-1,y=5,style=4},{x=0,y=-5,style=0},{x=0,y=5,style=0},{x=1,y=-5,style=6},{x=1,y=5,style=7},{x=3,y=-4,style=6},{x=3,y=4,style=7},{x=4,y=-3,style=6},{x=4,y=3,style=7},{x=5,y=-1,style=6},{x=5,y=0,style=0},{x=5,y=1,style=7},},remove={},change={{x=-4,y=-2,style=0},{x=-4,y=2,style=0},{x=-3,y=-3,style=0},{x=-3,y=3,style=0},{x=-2,y=-4,style=0},{x=-2,y=4,style=0},{x=2,y=-4,style=0},{x=2,y=4,style=0},{x=3,y=-3,style=0},{x=3,y=3,style=0},{x=4,y=-2,style=0},{x=4,y=2,style=0},}},
		backward =  { add={},remove={{x=-4,y=-2},{x=-4,y=2},{x=-3,y=-3},{x=-3,y=3},{x=-2,y=-4},{x=-2,y=4},{x=2,y=-4},{x=2,y=4},{x=3,y=-3},{x=3,y=3},{x=4,y=-2},{x=4,y=2},},change={{x=-4,y=-1,style=5},{x=-4,y=1,style=4},{x=-3,y=-2,style=5},{x=-3,y=2,style=4},{x=-2,y=-3,style=5},{x=-2,y=3,style=4},{x=-1,y=-4,style=5},{x=-1,y=4,style=4},{x=1,y=-4,style=6},{x=1,y=4,style=7},{x=2,y=-3,style=6},{x=2,y=3,style=7},{x=3,y=-2,style=6},{x=3,y=2,style=7},{x=4,y=-1,style=6},{x=4,y=1,style=7},}}
	},
	{	-- 10->11 / 10->9
		forward = { add={{x=-5,y=-2,style=5},{x=-5,y=2,style=4},{x=-4,y=-4,style=5},{x=-4,y=4,style=4},{x=-2,y=-5,style=5},{x=-2,y=5,style=4},{x=2,y=-5,style=6},{x=2,y=5,style=7},{x=4,y=-4,style=6},{x=4,y=4,style=7},{x=5,y=-2,style=6},{x=5,y=2,style=7},},remove={},change={{x=-5,y=-1,style=0},{x=-5,y=1,style=0},{x=-4,y=-3,style=0},{x=-4,y=3,style=0},{x=-3,y=-4,style=0},{x=-3,y=4,style=0},{x=-1,y=-5,style=0},{x=-1,y=5,style=0},{x=1,y=-5,style=0},{x=1,y=5,style=0},{x=3,y=-4,style=0},{x=3,y=4,style=0},{x=4,y=-3,style=0},{x=4,y=3,style=0},{x=5,y=-1,style=0},{x=5,y=1,style=0},}},
		backward =  { add={},remove={{x=-5,y=-1},{x=-5,y=0},{x=-5,y=1},{x=-4,y=-3},{x=-4,y=3},{x=-3,y=-4},{x=-3,y=4},{x=-1,y=-5},{x=-1,y=5},{x=0,y=-5},{x=0,y=5},{x=1,y=-5},{x=1,y=5},{x=3,y=-4},{x=3,y=4},{x=4,y=-3},{x=4,y=3},{x=5,y=-1},{x=5,y=0},{x=5,y=1},},change={{x=-4,y=-2,style=5},{x=-4,y=2,style=4},{x=-3,y=-3,style=5},{x=-3,y=3,style=4},{x=-2,y=-4,style=5},{x=-2,y=4,style=4},{x=2,y=-4,style=6},{x=2,y=4,style=7},{x=3,y=-3,style=6},{x=3,y=3,style=7},{x=4,y=-2,style=6},{x=4,y=2,style=7},}}
	},
	{	-- 11->12 / 11->10
		forward = { add={{x=-6,y=-1,style=5},{x=-6,y=0,style=0},{x=-6,y=1,style=4},{x=-5,y=-3,style=5},{x=-5,y=3,style=4},{x=-3,y=-5,style=5},{x=-3,y=5,style=4},{x=-1,y=-6,style=5},{x=-1,y=6,style=4},{x=0,y=-6,style=0},{x=0,y=6,style=0},{x=1,y=-6,style=6},{x=1,y=6,style=7},{x=3,y=-5,style=6},{x=3,y=5,style=7},{x=5,y=-3,style=6},{x=5,y=3,style=7},{x=6,y=-1,style=6},{x=6,y=0,style=0},{x=6,y=1,style=7},},remove={},change={{x=-5,y=-2,style=0},{x=-5,y=2,style=0},{x=-2,y=-5,style=0},{x=-2,y=5,style=0},{x=2,y=-5,style=0},{x=2,y=5,style=0},{x=5,y=-2,style=0},{x=5,y=2,style=0},}},
		backward =  { add={},remove={{x=-5,y=-2},{x=-5,y=2},{x=-4,y=-4},{x=-4,y=4},{x=-2,y=-5},{x=-2,y=5},{x=2,y=-5},{x=2,y=5},{x=4,y=-4},{x=4,y=4},{x=5,y=-2},{x=5,y=2},},change={{x=-5,y=-1,style=5},{x=-5,y=1,style=4},{x=-4,y=-3,style=5},{x=-4,y=3,style=4},{x=-3,y=-4,style=5},{x=-3,y=4,style=4},{x=-1,y=-5,style=5},{x=-1,y=5,style=4},{x=1,y=-5,style=6},{x=1,y=5,style=7},{x=3,y=-4,style=6},{x=3,y=4,style=7},{x=4,y=-3,style=6},{x=4,y=3,style=7},{x=5,y=-1,style=6},{x=5,y=1,style=7},}}
	},
	{	-- 12->13 / 12->11
		forward = { add={{x=-6,y=-3,style=5},{x=-6,y=-2,style=0},{x=-6,y=2,style=0},{x=-6,y=3,style=4},{x=-5,y=-4,style=5},{x=-5,y=4,style=4},{x=-4,y=-5,style=5},{x=-4,y=5,style=4},{x=-3,y=-6,style=5},{x=-3,y=6,style=4},{x=-2,y=-6,style=0},{x=-2,y=6,style=0},{x=2,y=-6,style=0},{x=2,y=6,style=0},{x=3,y=-6,style=6},{x=3,y=6,style=7},{x=4,y=-5,style=6},{x=4,y=5,style=7},{x=5,y=-4,style=6},{x=5,y=4,style=7},{x=6,y=-3,style=6},{x=6,y=-2,style=0},{x=6,y=2,style=0},{x=6,y=3,style=7},},remove={},change={{x=-6,y=-1,style=0},{x=-6,y=1,style=0},{x=-5,y=-3,style=0},{x=-5,y=3,style=0},{x=-4,y=-4,style=0},{x=-4,y=4,style=0},{x=-3,y=-5,style=0},{x=-3,y=5,style=0},{x=-1,y=-6,style=0},{x=-1,y=6,style=0},{x=1,y=-6,style=0},{x=1,y=6,style=0},{x=3,y=-5,style=0},{x=3,y=5,style=0},{x=4,y=-4,style=0},{x=4,y=4,style=0},{x=5,y=-3,style=0},{x=5,y=3,style=0},{x=6,y=-1,style=0},{x=6,y=1,style=0},}},
		backward =  { add={},remove={{x=-6,y=-1},{x=-6,y=0},{x=-6,y=1},{x=-5,y=-3},{x=-5,y=3},{x=-3,y=-5},{x=-3,y=5},{x=-1,y=-6},{x=-1,y=6},{x=0,y=-6},{x=0,y=6},{x=1,y=-6},{x=1,y=6},{x=3,y=-5},{x=3,y=5},{x=5,y=-3},{x=5,y=3},{x=6,y=-1},{x=6,y=0},{x=6,y=1},},change={{x=-5,y=-2,style=5},{x=-5,y=2,style=4},{x=-2,y=-5,style=5},{x=-2,y=5,style=4},{x=2,y=-5,style=6},{x=2,y=5,style=7},{x=5,y=-2,style=6},{x=5,y=2,style=7},}}
	},
	{	-- 13->14 / 13->12
		forward = { add={{x=-7,y=-2,style=5},{x=-7,y=-1,style=0},{x=-7,y=0,style=0},{x=-7,y=1,style=0},{x=-7,y=2,style=4},{x=-6,y=-4,style=5},{x=-6,y=4,style=4},{x=-5,y=-5,style=5},{x=-5,y=5,style=4},{x=-4,y=-6,style=5},{x=-4,y=6,style=4},{x=-2,y=-7,style=5},{x=-2,y=7,style=4},{x=-1,y=-7,style=0},{x=-1,y=7,style=0},{x=0,y=-7,style=0},{x=0,y=7,style=0},{x=1,y=-7,style=0},{x=1,y=7,style=0},{x=2,y=-7,style=6},{x=2,y=7,style=7},{x=4,y=-6,style=6},{x=4,y=6,style=7},{x=5,y=-5,style=6},{x=5,y=5,style=7},{x=6,y=-4,style=6},{x=6,y=4,style=7},{x=7,y=-2,style=6},{x=7,y=-1,style=0},{x=7,y=0,style=0},{x=7,y=1,style=0},{x=7,y=2,style=7},},remove={},change={{x=-6,y=-3,style=0},{x=-6,y=3,style=0},{x=-5,y=-4,style=0},{x=-5,y=4,style=0},{x=-4,y=-5,style=0},{x=-4,y=5,style=0},{x=-3,y=-6,style=0},{x=-3,y=6,style=0},{x=3,y=-6,style=0},{x=3,y=6,style=0},{x=4,y=-5,style=0},{x=4,y=5,style=0},{x=5,y=-4,style=0},{x=5,y=4,style=0},{x=6,y=-3,style=0},{x=6,y=3,style=0},}},
		backward =  { add={},remove={{x=-6,y=-3},{x=-6,y=-2},{x=-6,y=2},{x=-6,y=3},{x=-5,y=-4},{x=-5,y=4},{x=-4,y=-5},{x=-4,y=5},{x=-3,y=-6},{x=-3,y=6},{x=-2,y=-6},{x=-2,y=6},{x=2,y=-6},{x=2,y=6},{x=3,y=-6},{x=3,y=6},{x=4,y=-5},{x=4,y=5},{x=5,y=-4},{x=5,y=4},{x=6,y=-3},{x=6,y=-2},{x=6,y=2},{x=6,y=3},},change={{x=-6,y=-1,style=5},{x=-6,y=1,style=4},{x=-5,y=-3,style=5},{x=-5,y=3,style=4},{x=-4,y=-4,style=5},{x=-4,y=4,style=4},{x=-3,y=-5,style=5},{x=-3,y=5,style=4},{x=-1,y=-6,style=5},{x=-1,y=6,style=4},{x=1,y=-6,style=6},{x=1,y=6,style=7},{x=3,y=-5,style=6},{x=3,y=5,style=7},{x=4,y=-4,style=6},{x=4,y=4,style=7},{x=5,y=-3,style=6},{x=5,y=3,style=7},{x=6,y=-1,style=6},{x=6,y=1,style=7},}}
	},
	{	-- 14->15 / 14->13
		forward = { add={{x=-7,y=-3,style=5},{x=-7,y=3,style=4},{x=-6,y=-5,style=5},{x=-6,y=5,style=4},{x=-5,y=-6,style=5},{x=-5,y=6,style=4},{x=-3,y=-7,style=5},{x=-3,y=7,style=4},{x=3,y=-7,style=6},{x=3,y=7,style=7},{x=5,y=-6,style=6},{x=5,y=6,style=7},{x=6,y=-5,style=6},{x=6,y=5,style=7},{x=7,y=-3,style=6},{x=7,y=3,style=7},},remove={},change={{x=-7,y=-2,style=0},{x=-7,y=2,style=0},{x=-6,y=-4,style=0},{x=-6,y=4,style=0},{x=-5,y=-5,style=0},{x=-5,y=5,style=0},{x=-4,y=-6,style=0},{x=-4,y=6,style=0},{x=-2,y=-7,style=0},{x=-2,y=7,style=0},{x=2,y=-7,style=0},{x=2,y=7,style=0},{x=4,y=-6,style=0},{x=4,y=6,style=0},{x=5,y=-5,style=0},{x=5,y=5,style=0},{x=6,y=-4,style=0},{x=6,y=4,style=0},{x=7,y=-2,style=0},{x=7,y=2,style=0},}},
		backward =  { add={},remove={{x=-7,y=-2},{x=-7,y=-1},{x=-7,y=0},{x=-7,y=1},{x=-7,y=2},{x=-6,y=-4},{x=-6,y=4},{x=-5,y=-5},{x=-5,y=5},{x=-4,y=-6},{x=-4,y=6},{x=-2,y=-7},{x=-2,y=7},{x=-1,y=-7},{x=-1,y=7},{x=0,y=-7},{x=0,y=7},{x=1,y=-7},{x=1,y=7},{x=2,y=-7},{x=2,y=7},{x=4,y=-6},{x=4,y=6},{x=5,y=-5},{x=5,y=5},{x=6,y=-4},{x=6,y=4},{x=7,y=-2},{x=7,y=-1},{x=7,y=0},{x=7,y=1},{x=7,y=2},},change={{x=-6,y=-3,style=5},{x=-6,y=3,style=4},{x=-5,y=-4,style=5},{x=-5,y=4,style=4},{x=-4,y=-5,style=5},{x=-4,y=5,style=4},{x=-3,y=-6,style=5},{x=-3,y=6,style=4},{x=3,y=-6,style=6},{x=3,y=6,style=7},{x=4,y=-5,style=6},{x=4,y=5,style=7},{x=5,y=-4,style=6},{x=5,y=4,style=7},{x=6,y=-3,style=6},{x=6,y=3,style=7},}}
	},
	{	-- 15->16 / 15->14
		forward = { add={{x=-8,y=-2,style=5},{x=-8,y=-1,style=0},{x=-8,y=0,style=0},{x=-8,y=1,style=0},{x=-8,y=2,style=4},{x=-7,y=-4,style=5},{x=-7,y=4,style=4},{x=-4,y=-7,style=5},{x=-4,y=7,style=4},{x=-2,y=-8,style=5},{x=-2,y=8,style=4},{x=-1,y=-8,style=0},{x=-1,y=8,style=0},{x=0,y=-8,style=0},{x=0,y=8,style=0},{x=1,y=-8,style=0},{x=1,y=8,style=0},{x=2,y=-8,style=6},{x=2,y=8,style=7},{x=4,y=-7,style=6},{x=4,y=7,style=7},{x=7,y=-4,style=6},{x=7,y=4,style=7},{x=8,y=-2,style=6},{x=8,y=-1,style=0},{x=8,y=0,style=0},{x=8,y=1,style=0},{x=8,y=2,style=7},},remove={},change={{x=-7,y=-3,style=0},{x=-7,y=3,style=0},{x=-3,y=-7,style=0},{x=-3,y=7,style=0},{x=3,y=-7,style=0},{x=3,y=7,style=0},{x=7,y=-3,style=0},{x=7,y=3,style=0},}},
		backward =  { add={},remove={{x=-7,y=-3},{x=-7,y=3},{x=-6,y=-5},{x=-6,y=5},{x=-5,y=-6},{x=-5,y=6},{x=-3,y=-7},{x=-3,y=7},{x=3,y=-7},{x=3,y=7},{x=5,y=-6},{x=5,y=6},{x=6,y=-5},{x=6,y=5},{x=7,y=-3},{x=7,y=3},},change={{x=-7,y=-2,style=5},{x=-7,y=2,style=4},{x=-6,y=-4,style=5},{x=-6,y=4,style=4},{x=-5,y=-5,style=5},{x=-5,y=5,style=4},{x=-4,y=-6,style=5},{x=-4,y=6,style=4},{x=-2,y=-7,style=5},{x=-2,y=7,style=4},{x=2,y=-7,style=6},{x=2,y=7,style=7},{x=4,y=-6,style=6},{x=4,y=6,style=7},{x=5,y=-5,style=6},{x=5,y=5,style=7},{x=6,y=-4,style=6},{x=6,y=4,style=7},{x=7,y=-2,style=6},{x=7,y=2,style=7},}}
	},
	{	-- 16->17 / 16->15
		forward = { add={{x=-8,y=-3,style=5},{x=-8,y=3,style=4},{x=-7,y=-5,style=5},{x=-7,y=5,style=4},{x=-6,y=-6,style=5},{x=-6,y=6,style=4},{x=-5,y=-7,style=5},{x=-5,y=7,style=4},{x=-3,y=-8,style=5},{x=-3,y=8,style=4},{x=3,y=-8,style=6},{x=3,y=8,style=7},{x=5,y=-7,style=6},{x=5,y=7,style=7},{x=6,y=-6,style=6},{x=6,y=6,style=7},{x=7,y=-5,style=6},{x=7,y=5,style=7},{x=8,y=-3,style=6},{x=8,y=3,style=7},},remove={},change={{x=-8,y=-2,style=0},{x=-8,y=2,style=0},{x=-7,y=-4,style=0},{x=-7,y=4,style=0},{x=-6,y=-5,style=0},{x=-6,y=5,style=0},{x=-5,y=-6,style=0},{x=-5,y=6,style=0},{x=-4,y=-7,style=0},{x=-4,y=7,style=0},{x=-2,y=-8,style=0},{x=-2,y=8,style=0},{x=2,y=-8,style=0},{x=2,y=8,style=0},{x=4,y=-7,style=0},{x=4,y=7,style=0},{x=5,y=-6,style=0},{x=5,y=6,style=0},{x=6,y=-5,style=0},{x=6,y=5,style=0},{x=7,y=-4,style=0},{x=7,y=4,style=0},{x=8,y=-2,style=0},{x=8,y=2,style=0},}},
		backward =  { add={},remove={{x=-8,y=-2},{x=-8,y=-1},{x=-8,y=0},{x=-8,y=1},{x=-8,y=2},{x=-7,y=-4},{x=-7,y=4},{x=-4,y=-7},{x=-4,y=7},{x=-2,y=-8},{x=-2,y=8},{x=-1,y=-8},{x=-1,y=8},{x=0,y=-8},{x=0,y=8},{x=1,y=-8},{x=1,y=8},{x=2,y=-8},{x=2,y=8},{x=4,y=-7},{x=4,y=7},{x=7,y=-4},{x=7,y=4},{x=8,y=-2},{x=8,y=-1},{x=8,y=0},{x=8,y=1},{x=8,y=2},},change={{x=-7,y=-3,style=5},{x=-7,y=3,style=4},{x=-3,y=-7,style=5},{x=-3,y=7,style=4},{x=3,y=-7,style=6},{x=3,y=7,style=7},{x=7,y=-3,style=6},{x=7,y=3,style=7},}}
	},
	{	-- 17->18 / 17->16
		forward = { add={{x=-9,y=-2,style=5},{x=-9,y=-1,style=0},{x=-9,y=0,style=0},{x=-9,y=1,style=0},{x=-9,y=2,style=4},{x=-8,y=-4,style=5},{x=-8,y=4,style=4},{x=-7,y=-6,style=5},{x=-7,y=6,style=4},{x=-6,y=-7,style=5},{x=-6,y=7,style=4},{x=-4,y=-8,style=5},{x=-4,y=8,style=4},{x=-2,y=-9,style=5},{x=-2,y=9,style=4},{x=-1,y=-9,style=0},{x=-1,y=9,style=0},{x=0,y=-9,style=0},{x=0,y=9,style=0},{x=1,y=-9,style=0},{x=1,y=9,style=0},{x=2,y=-9,style=6},{x=2,y=9,style=7},{x=4,y=-8,style=6},{x=4,y=8,style=7},{x=6,y=-7,style=6},{x=6,y=7,style=7},{x=7,y=-6,style=6},{x=7,y=6,style=7},{x=8,y=-4,style=6},{x=8,y=4,style=7},{x=9,y=-2,style=6},{x=9,y=-1,style=0},{x=9,y=0,style=0},{x=9,y=1,style=0},{x=9,y=2,style=7},},remove={},change={{x=-8,y=-3,style=0},{x=-8,y=3,style=0},{x=-7,y=-5,style=0},{x=-7,y=5,style=0},{x=-6,y=-6,style=0},{x=-6,y=6,style=0},{x=-5,y=-7,style=0},{x=-5,y=7,style=0},{x=-3,y=-8,style=0},{x=-3,y=8,style=0},{x=3,y=-8,style=0},{x=3,y=8,style=0},{x=5,y=-7,style=0},{x=5,y=7,style=0},{x=6,y=-6,style=0},{x=6,y=6,style=0},{x=7,y=-5,style=0},{x=7,y=5,style=0},{x=8,y=-3,style=0},{x=8,y=3,style=0},}},
		backward =  { add={},remove={{x=-8,y=-3},{x=-8,y=3},{x=-7,y=-5},{x=-7,y=5},{x=-6,y=-6},{x=-6,y=6},{x=-5,y=-7},{x=-5,y=7},{x=-3,y=-8},{x=-3,y=8},{x=3,y=-8},{x=3,y=8},{x=5,y=-7},{x=5,y=7},{x=6,y=-6},{x=6,y=6},{x=7,y=-5},{x=7,y=5},{x=8,y=-3},{x=8,y=3},},change={{x=-8,y=-2,style=5},{x=-8,y=2,style=4},{x=-7,y=-4,style=5},{x=-7,y=4,style=4},{x=-6,y=-5,style=5},{x=-6,y=5,style=4},{x=-5,y=-6,style=5},{x=-5,y=6,style=4},{x=-4,y=-7,style=5},{x=-4,y=7,style=4},{x=-2,y=-8,style=5},{x=-2,y=8,style=4},{x=2,y=-8,style=6},{x=2,y=8,style=7},{x=4,y=-7,style=6},{x=4,y=7,style=7},{x=5,y=-6,style=6},{x=5,y=6,style=7},{x=6,y=-5,style=6},{x=6,y=5,style=7},{x=7,y=-4,style=6},{x=7,y=4,style=7},{x=8,y=-2,style=6},{x=8,y=2,style=7},}}
	},
	{	-- 18->19 / 18->17
		forward = { add={{x=-9,y=-4,style=5},{x=-9,y=-3,style=0},{x=-9,y=3,style=0},{x=-9,y=4,style=4},{x=-8,y=-5,style=5},{x=-8,y=5,style=4},{x=-5,y=-8,style=5},{x=-5,y=8,style=4},{x=-4,y=-9,style=5},{x=-4,y=9,style=4},{x=-3,y=-9,style=0},{x=-3,y=9,style=0},{x=3,y=-9,style=0},{x=3,y=9,style=0},{x=4,y=-9,style=6},{x=4,y=9,style=7},{x=5,y=-8,style=6},{x=5,y=8,style=7},{x=8,y=-5,style=6},{x=8,y=5,style=7},{x=9,y=-4,style=6},{x=9,y=-3,style=0},{x=9,y=3,style=0},{x=9,y=4,style=7},},remove={},change={{x=-9,y=-2,style=0},{x=-9,y=2,style=0},{x=-8,y=-4,style=0},{x=-8,y=4,style=0},{x=-4,y=-8,style=0},{x=-4,y=8,style=0},{x=-2,y=-9,style=0},{x=-2,y=9,style=0},{x=2,y=-9,style=0},{x=2,y=9,style=0},{x=4,y=-8,style=0},{x=4,y=8,style=0},{x=8,y=-4,style=0},{x=8,y=4,style=0},{x=9,y=-2,style=0},{x=9,y=2,style=0},}},
		backward =  { add={},remove={{x=-9,y=-2},{x=-9,y=-1},{x=-9,y=0},{x=-9,y=1},{x=-9,y=2},{x=-8,y=-4},{x=-8,y=4},{x=-7,y=-6},{x=-7,y=6},{x=-6,y=-7},{x=-6,y=7},{x=-4,y=-8},{x=-4,y=8},{x=-2,y=-9},{x=-2,y=9},{x=-1,y=-9},{x=-1,y=9},{x=0,y=-9},{x=0,y=9},{x=1,y=-9},{x=1,y=9},{x=2,y=-9},{x=2,y=9},{x=4,y=-8},{x=4,y=8},{x=6,y=-7},{x=6,y=7},{x=7,y=-6},{x=7,y=6},{x=8,y=-4},{x=8,y=4},{x=9,y=-2},{x=9,y=-1},{x=9,y=0},{x=9,y=1},{x=9,y=2},},change={{x=-8,y=-3,style=5},{x=-8,y=3,style=4},{x=-7,y=-5,style=5},{x=-7,y=5,style=4},{x=-6,y=-6,style=5},{x=-6,y=6,style=4},{x=-5,y=-7,style=5},{x=-5,y=7,style=4},{x=-3,y=-8,style=5},{x=-3,y=8,style=4},{x=3,y=-8,style=6},{x=3,y=8,style=7},{x=5,y=-7,style=6},{x=5,y=7,style=7},{x=6,y=-6,style=6},{x=6,y=6,style=7},{x=7,y=-5,style=6},{x=7,y=5,style=7},{x=8,y=-3,style=6},{x=8,y=3,style=7},}}
	},
	{	-- 19->20 / 19->18
		forward = { add={{x=-10,y=-2,style=5},{x=-10,y=-1,style=0},{x=-10,y=0,style=0},{x=-10,y=1,style=0},{x=-10,y=2,style=4},{x=-9,y=-5,style=5},{x=-9,y=5,style=4},{x=-8,y=-6,style=5},{x=-8,y=6,style=4},{x=-7,y=-7,style=5},{x=-7,y=7,style=4},{x=-6,y=-8,style=5},{x=-6,y=8,style=4},{x=-5,y=-9,style=5},{x=-5,y=9,style=4},{x=-2,y=-10,style=5},{x=-2,y=10,style=4},{x=-1,y=-10,style=0},{x=-1,y=10,style=0},{x=0,y=-10,style=0},{x=0,y=10,style=0},{x=1,y=-10,style=0},{x=1,y=10,style=0},{x=2,y=-10,style=6},{x=2,y=10,style=7},{x=5,y=-9,style=6},{x=5,y=9,style=7},{x=6,y=-8,style=6},{x=6,y=8,style=7},{x=7,y=-7,style=6},{x=7,y=7,style=7},{x=8,y=-6,style=6},{x=8,y=6,style=7},{x=9,y=-5,style=6},{x=9,y=5,style=7},{x=10,y=-2,style=6},{x=10,y=-1,style=0},{x=10,y=0,style=0},{x=10,y=1,style=0},{x=10,y=2,style=7},},remove={},change={{x=-9,y=-4,style=0},{x=-9,y=4,style=0},{x=-8,y=-5,style=0},{x=-8,y=5,style=0},{x=-7,y=-6,style=0},{x=-7,y=6,style=0},{x=-6,y=-7,style=0},{x=-6,y=7,style=0},{x=-5,y=-8,style=0},{x=-5,y=8,style=0},{x=-4,y=-9,style=0},{x=-4,y=9,style=0},{x=4,y=-9,style=0},{x=4,y=9,style=0},{x=5,y=-8,style=0},{x=5,y=8,style=0},{x=6,y=-7,style=0},{x=6,y=7,style=0},{x=7,y=-6,style=0},{x=7,y=6,style=0},{x=8,y=-5,style=0},{x=8,y=5,style=0},{x=9,y=-4,style=0},{x=9,y=4,style=0},}},
		backward =  { add={},remove={{x=-9,y=-4},{x=-9,y=-3},{x=-9,y=3},{x=-9,y=4},{x=-8,y=-5},{x=-8,y=5},{x=-5,y=-8},{x=-5,y=8},{x=-4,y=-9},{x=-4,y=9},{x=-3,y=-9},{x=-3,y=9},{x=3,y=-9},{x=3,y=9},{x=4,y=-9},{x=4,y=9},{x=5,y=-8},{x=5,y=8},{x=8,y=-5},{x=8,y=5},{x=9,y=-4},{x=9,y=-3},{x=9,y=3},{x=9,y=4},},change={{x=-9,y=-2,style=5},{x=-9,y=2,style=4},{x=-8,y=-4,style=5},{x=-8,y=4,style=4},{x=-4,y=-8,style=5},{x=-4,y=8,style=4},{x=-2,y=-9,style=5},{x=-2,y=9,style=4},{x=2,y=-9,style=6},{x=2,y=9,style=7},{x=4,y=-8,style=6},{x=4,y=8,style=7},{x=8,y=-4,style=6},{x=8,y=4,style=7},{x=9,y=-2,style=6},{x=9,y=2,style=7},}}
	},
	{	-- 20->21 / 20->19
		forward = nil,
		backward =  { add={},remove={{x=-10,y=-2},{x=-10,y=-1},{x=-10,y=0},{x=-10,y=1},{x=-10,y=2},{x=-9,y=-5},{x=-9,y=5},{x=-8,y=-6},{x=-8,y=6},{x=-7,y=-7},{x=-7,y=7},{x=-6,y=-8},{x=-6,y=8},{x=-5,y=-9},{x=-5,y=9},{x=-2,y=-10},{x=-2,y=10},{x=-1,y=-10},{x=-1,y=10},{x=0,y=-10},{x=0,y=10},{x=1,y=-10},{x=1,y=10},{x=2,y=-10},{x=2,y=10},{x=5,y=-9},{x=5,y=9},{x=6,y=-8},{x=6,y=8},{x=7,y=-7},{x=7,y=7},{x=8,y=-6},{x=8,y=6},{x=9,y=-5},{x=9,y=5},{x=10,y=-2},{x=10,y=-1},{x=10,y=0},{x=10,y=1},{x=10,y=2},},change={{x=-9,y=-4,style=5},{x=-9,y=4,style=4},{x=-8,y=-5,style=5},{x=-8,y=5,style=4},{x=-7,y=-6,style=5},{x=-7,y=6,style=4},{x=-6,y=-7,style=5},{x=-6,y=7,style=4},{x=-5,y=-8,style=5},{x=-5,y=8,style=4},{x=-4,y=-9,style=5},{x=-4,y=9,style=4},{x=4,y=-9,style=6},{x=4,y=9,style=7},{x=5,y=-8,style=6},{x=5,y=8,style=7},{x=6,y=-7,style=6},{x=6,y=7,style=7},{x=7,y=-6,style=6},{x=7,y=6,style=7},{x=8,y=-5,style=6},{x=8,y=5,style=7},{x=9,y=-4,style=6},{x=9,y=4,style=7},}}
	},
}
Arena.MAX_LAYER 		= #Arena.LAYERS
Arena.TILE_MODELS = {
    -- { 0 round edges, 1 round edge, 2 round edges }
	{ "models/tiles/tile1_0round.vmdl", "models/tiles/tile1_1round.vmdl", "models/tiles/tile1_2round.vmdl" },
    { "models/tiles/tile2_0round.vmdl", "models/tiles/tile2_1round.vmdl", "models/tiles/tile2_2round.vmdl" },
    { "models/tiles/tile3_0round.vmdl", "models/tiles/tile3_1round.vmdl", "models/tiles/tile3_2round.vmdl" },
}
Arena.LAVA_MODIFIER = "modifier_phoenix_icarus_dive_burn"
Arena.tile_model = Arena.TILE_MODELS[1]

function Arena:init()
	-- self.tiles = 2 dimensional array indexed by x and y in the grid
	-- self.tiles[x] = row on that x
	self.tiles = {}

	-- initialize the rows
	for x = -self.ARENA_MAX_COORD, self.ARENA_MAX_COORD do
		self.tiles[x] = {}
	end

	--
	self.current_layer = 1

	GAME:addTask{
		id='arena_damage',
		period=self.DAMAGE_PERIOD,
		func = function()
			local dmg_info = {
				amount = self.DAMAGE_PER_SECOND * self.DAMAGE_PERIOD,
				knockback_vulnerability_factor = self.DAMAGE_KB_POINT_FACTOR,
				is_lava = true
			}

			for pawn, _ in pairs(GAME.pawns) do
				-- Apply or remove a burn effect
				local on_lava = not self:isLocationSafe(pawn.location)
				if(pawn.on_lava and not on_lava) then
					pawn.on_lava = false
					pawn:removeNativeModifier(Arena.LAVA_MODIFIER)
				elseif(not pawn.on_lava and on_lava) then
					pawn.on_lava = true
					pawn:addNativeModifier(Arena.LAVA_MODIFIER)
				end
				
				if pawn.enabled and on_lava then
					pawn:receiveDamage(dmg_info)
				end
			end
		end
	}
end

function Arena:getTileStatus(grid_x, grid_y)
	if math.abs(grid_x) > self.ARENA_MAX_COORD or math.abs(grid_y) > self.ARENA_MAX_COORD then
		return false
	end

	return (self.tiles[grid_x][grid_y] ~= nil)
end

function Arena:setTileStatus(grid_x, grid_y, status)
	local tile = self.tiles[grid_x][grid_y]

	if tile ~= nil and not status then
        local task = GAME:addTask {
            period = 0.05,
            func = function()
                local orig = tile:GetAbsOrigin()
                orig.z = orig.z - 0.5

                tile:SetAbsOrigin(orig)

                local c = 128 + 127 * (orig.z  - 39.5) / 3

                tile:SetRenderColor(255, c, c)

                if orig.z <= 39.5 then
                    tile:Destroy()
                    task:cancel()
                end
            end
        }

		self.tiles[grid_x][grid_y] = nil
	elseif tile == nil and status then
		-- create a new tile
		tile = Entities:CreateByClassname("prop_dynamic")
		tile:SetAbsOrigin(Vector(grid_x*self.ARENA_TILE_SIZE, grid_y*self.ARENA_TILE_SIZE, self.ARENA_TILE_Z))
		self.tiles[grid_x][grid_y] = tile
	end
end

function Arena:setTileStyle(grid_x, grid_y, style)
    -- Get tile from grid
    local tile = self.tiles[grid_x][grid_y]

    if not tile then
        err("Tile not found in setTileStyle")
        return
    end

    -- Calculate yaw and tile type from style
    local yaw = (style % 4) * 90
    local tile_type = math.floor(style / 4) + 1

    -- Apply yaw and tile type
    tile:SetAngles(0, yaw, 0)
    tile:SetModel(Arena.tile_model[tile_type])
end

function Arena:applyDelta(delta)
    for i, tile in pairs(delta.add) do
        self:setTileStatus(tile.x, tile.y, true)
        self:setTileStyle(tile.x, tile.y, tile.style)
    end

    for i, tile in pairs(delta.remove) do
        self:setTileStatus(tile.x, tile.y, false)
    end

    for i, tile in pairs(delta.change) do
        self:setTileStyle(tile.x, tile.y, tile.style)
    end
end

function Arena:setLayer(layer_index)
    -- Clamp between 1 and max layer
	layer_index = math.min(layer_index, self.MAX_LAYER)
	layer_index = math.max(layer_index, 1)

	-- increase the layer -> create tiles
	while layer_index > self.current_layer do
        self:applyDelta(self.LAYERS[self.current_layer].forward)
        self.current_layer = self.current_layer + 1
	end

	-- decrease the layer -> remove tiles
	while layer_index < self.current_layer do
        self:applyDelta(self.LAYERS[self.current_layer].backward)
		self.current_layer = self.current_layer - 1
	end
end

function Arena:setAutoShrink(status)
	if self.task_shrink then
		self.task_shrink:cancel()
		self.task_shrink = nil
	end

	if status then
		self.task_shrink = GAME:addTask{id='arena_shrink', period=self.SHRINK_PERIOD, func=function()
			self:setLayer(self.current_layer - 1)
		end}
	end
end

function Arena:isLocationSafe(location)
	local grid_x = math.floor( location.x / self.ARENA_TILE_SIZE + 0.5 )
	local grid_y = math.floor( location.y / self.ARENA_TILE_SIZE + 0.5 )

	return self:getTileStatus(grid_x, grid_y)
end

function Arena:setPlatformType(platform)
	Arena.tile_model = Arena.TILE_MODELS[platform]
end

function Game:initArena()
	self.arena = Arena:new()
end

