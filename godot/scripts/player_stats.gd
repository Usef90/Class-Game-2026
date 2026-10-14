extends Node

var player_hitpoint: float = 100
var player_max_energy: float = 50



var player_recovery: float = 10
var player_defalt_def: int = 0
var player_aoe_damage: float = 1
var player_single_damage: float = 1
var player_damage: float = 1
var player_hitpoint_recovery: float = 0

var attacks: Array =[]
var upgrades: Array = []

var luck: int = 20 #percentage wise
# Global player wallet 
var player_gold: int = 20
