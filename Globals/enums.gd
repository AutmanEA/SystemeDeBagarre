extends Node

enum e_tile {
	Null,	#Pas de tile / trou
	Wall,	#Tile mur infranchissable
	Floor,	#Tile de sol classique
	Cover,	#Tile demi-mur infranchissable mais ne bloquand pas la vision
	Hard,	#Tile de terrain difficile qui double les points de mouvements
}

enum e_pawn {
	Ally,	#Tile contenant une cible alliée
	Enemy,	#Tile contenant une cible enemie
	Obj,	#Tile contenant un objet interagisable (tonneau, destructible...)
}
