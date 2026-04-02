extends Node

enum e_tile {
	Null,	#Pas de tile / trou
	Wall,	#Tile mur infranchissable
	Floor,	#Tile de sol classique
	Ally,	#Tile contenant une cible alliée
	Enemy,	#Tile contenant une cible enemie
	Obj,	#Tile contenant un objet interagisable (tonneau, destructible...)
	Cover,	#Tile demi-mur passable
}
