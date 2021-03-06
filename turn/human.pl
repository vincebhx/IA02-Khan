/****TOUR HUMAIN****/
playTurn(InBoard, Colour, OutBoard) :-
	print('Joueur '), print(Colour), print(', à votre tour !'), nl,
	getCote(Cote, Colour), afficherPlateau(InBoard, Cote),
	influenceKhan(Colour),
	initMove(Colour, (Col1, Lin1, Col2, Lin2)),
	possibleMoves(InBoard,Colour, MoveList),!,
	getIdPion(InBoard, Col1, Lin1, Pion),
	execMove(InBoard, Colour, (Col1, Lin1, Col2, Lin2), Pion, MoveList, OutBoard).


/*DÉTERMINATION DE L'INFLUENCE DU KHAN*/
influenceKhan(_) :-pion(kinit, _, _, khan, _),write('Mouvement Libre'),nl, !.

influenceKhan(Colour):-
	pion(_,_,_,khan,Marqueur),
	etablirEquipeActive(Colour,Marqueur,L),L\=[],
	write('Joueur '), print(Colour), write(', le khan te dit '),print(Marqueur),nl, !.

influenceKhan(Colour):-
	write('Joueur '), print(Colour),write(', le khan te dit '),pion(_,_,_,khan,Marqueur),print(Marqueur),
	write('... mais non !'),nl,write('Desobeissance au khan !'),nl,
	write('Vous pouvez soit bouger n''importe quelle piece de votre equipe, soit faire revenir une ancienne piece.'), nl.


/*SAISIE DU MOUVEMENT*/
initMove(rouge, (Col1, Lin1, Col2, Lin2)) :-
	print('Pion à deplacer (kr, r1..r5) ? '),
	read(Pion),
	testInitMove(rouge, Pion, (Col1, Lin1, Col2, Lin2)).

initMove(ocre, (Col1, Lin1, Col2, Lin2)) :-
	print('Pion à deplacer (ko, o1..o5) ? '),
	read(Pion),
	testInitMove(ocre, Pion, (Col1, Lin1, Col2, Lin2)).

/*Vérification de la saisie du pion et saisie de la position d'arrivée*/
testInitMove(Colour, Pion, (Col1, Lin1, Col2, Lin2)) :-
	findColour(Pion, Colour),
	pion(Pion, Col1, Lin1, 'in', _), !,
	getNewPos(Col2, Lin2).

testInitMove(Colour, Pion, (0, 0, Col2, Lin2)) :-
	findColour(Pion, Colour),
	pion(Pion, 0, 0, 'out', _), !,
	getNewPos(Col2, Lin2).

/*Cas d'erreur 1 : L'utilisateur a effectué une mauvaise saisie*/
testInitMove(Colour, Pion, Move) :-
	\+findColour(Pion, Colour),
	print('Erreur de saisie du pion.'), nl,
	initMove(Colour, Move).

/*Cas d'erreur 2 : Le pion n'est pas en jeu*/
testInitMove(Colour, Pion, Move) :-
	pion(Pion, _, _, 'out', _),
	print('Erreur : le pion choisi n est pas en jeu.'), nl,
	initMove(Colour, Move).

/*Saisie de la position d'arrivée*/
getNewPos(Col, Lin) :-
	print('Position d''arrivee (a1..f6) ? '),
	read(Pos), testPos(Pos, Col, Lin).

/*Test de la saisie de la position d'arrivée (On boucle tant qu'on n'a pas une saisie correcte)*/
testPos(Pos, Col, Lin) :- parse(Pos, Col, Lin), Col \= 0, Lin \= 0, !.
testPos(Pos, Col, Lin) :- parse(Pos, 0, 0), print('Erreur de saisie de la position d''arrivée.'), nl, getNewPos(Col, Lin).


/**VERIFICATION ET EXECUTION DU MOUVEMENT**/

execMove(InBoard,_, Move,Pion, MoveList, OutBoard) :-
	element(Move, MoveList), !,
	transfert(InBoard, Move,Pion, OutBoard),!.

execMove(InBoard, Colour, _, _,_, OutBoard) :-
	print('Erreur : mouvement invalide.'), nl,
	playTurn(InBoard, Colour, OutBoard).
