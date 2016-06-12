/**********************************************/
/*Détermination du meilleur mouvement possible*/
/**********************************************/

/*On appelle possibleMoves pour récupérer la liste des mouvements possibles.
MoveList est sous la forme [[(X1, Y1, X2, Y2)],...] où X est la colonne, Y est la ligne, (X1,Y1) est la position de départ et (X2, Y2) la position d'arrivée*/

generateMove(Board, Player, Move) :-
  retractall(playerState(_,_)),
  oppPlayer(Player, Player2),
  asserta(playerState(Player, max)),
  asserta(playerState(Player2, min)),
  miniMax(Player, 3, Board, Move, _).

/**Algorithme Minimax**/
/*miniMax(Player, Frontier, Board, Move, Value)*/
/*minimax(p) = f(p) si p est une feuille de l’arbre où f est une fonction d’évaluation de la position du jeu
minimax(p) = MAX(minimax(O1), …, minimax(On)) si p est un nœud Joueur avec fils O1, …, On
minimax(p) = MIN(minimax(O1), …, minimax(On)) si p est un nœud Opposant avec fils O1, …, On*/
miniMax(Player, 0, Board, BestMove, Value) :-
  print('MINIMAX TERMINAL - Frontiere:0  Valeur:'),
  transfertAI(Board, BestMove, OutBoard),
  heuristic(OutBoard, Player, 0, Value),
  print(Value), nl, !.

miniMax(Player, Frontier, Board, BestMove, Value) :-
  print('MINIMAX - Frontiere:'), print(Frontier), print('  Joueur:'), print(Player), nl,
  possibleMoves(Board, Player, MoveList),
  best(Player, Frontier, Board, MoveList, BestMove, Value).
% BoardList : liste de tuples (Move, Board) pour retrouver un mouvement correspondant à un état du plateau plus facilement


%On trouve le meilleur mouvement
best(Player, Frontier, Board, [Move], Move, Value) :-
  print('Mouvement:'), print(Move), nl,
  NFrontier is Frontier - 1,
  oppPlayer(Player, Player2),
  transfertAI(Board, Move, Board2),
  miniMax(Player2, NFrontier, Board2,  _, Value), !.

best(Player, Frontier, Board, [Move1|MoveList], BestMove, BestValue) :-
  print('Mouvement:'), print(Move1), nl,
  NFrontier is Frontier - 1,
  oppPlayer(Player, Player2),
  transfertAI(Board, Move1, Board2),
  miniMax(Player2, NFrontier, Board2, _, Value1),
  best(Player, Frontier, Board, MoveList, Move2, Value2),
  betterOf(Player, Move1, Value1, Move2, Value2, BestMove, BestValue),
  print('Best move : '), print(BestMove), print(' - Best value : '), print(BestValue), nl.


betterOf(Player, Move1, Value1, _, Value2, Move1, Value1) :-
    playerState(Player, min),
    Value1 > Value2, !.

betterOf(Player, Move1, Value1, _, Value2, Move1, Value1) :-
    playerState(Player, max),
    Value1 < Value2, !.

betterOf(_, _, _, Move2, Value2, Move2, Value2).

/**Algorithme Alpha-Beta**/
/*alphaBeta(Player, Frontier, Board, Alpha, Beta, Move, Value) où Value est l'heuristique*/

/*Cas 1 : si la frontière est à 0, on arrête l'exploration et on calcule l'heuristique*/
alphaBeta(Colour, 0, Board, _, _, Move, Value) :-
  heuristic(Board, Colour, 0, Value).

%Cas 2 : On récupère les mouvements possibles pour le joueur, puis on évalue les mouvements possibles
alphaBeta(Player, Frontier, Board, Alpha, Beta, Move, Value) :-
  print('ALPHABETA - Frontiere '), print(Frontier), print(' - a:'), print(Alpha), print(' b:'), print(Beta), nl,
  Frontier > 0, % On vérifie que la frontière est bien positive !
  possibleMoves(Board, Player, MoveList), % On récupère les mouvements possibles
  NAlpha is -Beta, % On change de joueur; on passe donc de MAX à MIN ou vice-versa.
  NBeta is -Alpha,
  NFrontier is Frontier - 1, % On décrémente la frontière car on traite des cas plus profonds de l'arbre
  evaluerEtChoisir(Player, MoveList, Board, NFrontier, NAlpha, NBeta, nil, Move, Value). %On récupère le meilleur mouvement


%Evaluation des différents mouvements possibles, et choix du meilleur
evaluerEtChoisir(Player, [Move|MoveList], Board, Frontier, Alpha, Beta, Record, BestMove, BestValue) :-
  nl, print('EVALUERCHOISIR\n'),
  transfertAI(Board, Move, OutBoard), % On récupère un Board avec le mouvement de l'arbre à tester
  oppPlayer(Player, OtherPlayer), % On change de joueur (pour minimiser les chances de l'adversaire / maximiser celles de l'IA)
  alphaBeta(OtherPlayer, Frontier, OutBoard, Alpha, Beta, _, Value), % On rappelle alphaBeta à la profondeur suivante. _ : OtherMove
  NValue is -Value,
  coupure(Player, Move, NValue, Frontier, Alpha, Beta, MoveList, Board, Record, BestMove, BestValue).

evaluerEtChoisir(_, [], _, _, Alpha, _, Move, Move, Alpha):- print('EVALUERCHOISIR TERMINAL\n'). %Si on n'a plus de mouvement à traiter dans la liste, on renvoie la valeur de Alpha ainsi que le mouvement.


%Traitement selon la valeur de Value par rapport à Alpha et Beta
coupure(_, Move, Value, _, _, Beta, _, _, _, Move, Value) :-
  Beta =< Value, !,
  print('      CUTOFF - Beta <= Val\n'), !.

coupure(Player, Move, Value, Frontier, Alpha, Beta, Moves, Board, _, BestMove, BestValue) :-
  Alpha < Value, Value < Beta, !,
  print('      CUTOFF - Alpha < Val < Beta\n'),
  evaluerEtChoisir(Player, Moves, Board, Frontier, Value, Beta, Move, BestMove, BestValue), !.

coupure(Player, _, Value, Frontier, Alpha, Beta, Moves, Board, Record, BestMove, BestValue) :-
  Value =< Alpha, !,
  print('      CUTOFF - Val <= Alpha\n'),
  evaluerEtChoisir(Player, Moves, Board, Frontier, Alpha, Beta, Record, BestMove, BestValue).


/*Petit prédicat pour trouver le joueur adverse*/
oppPlayer(rouge, ocre).
oppPlayer(ocre, rouge).


/**Transfert d'un pion sur le plateau sans passer par les prédicats externes**/
transfertAI(InBoard, (Col1, Lin1, Col2, Lin2), OutBoard) :-
  getIdPion(InBoard, Col1, Lin1, IdPion),
  miseAJourMove(IdPion, Col1, Lin1, Col2, Lin2, 'in', InBoard, OutBoard).

/*On trouve IdPion*/
/*On trouve la ligne*/
getIdPion([T|_], Col, 1, IdPion) :- getIdInLine(T, Col, IdPion).
getIdPion([_|Q], Col, Lin, IdPion) :- Lin > 0, NLin is Lin-1, getIdPion(Q, Col, NLin, IdPion).
/*On trouve la colonne*/
getIdInLine([(_, IdPion)|_], 1, IdPion).
getIdInLine([_|Q], Col, IdPion) :- Col > 0, NCol is Col-1, getIdInLine(Q, NCol, IdPion).


/**Calcul de la fonction heuristique**/
/*On maximise pour l'IA; on minimise pour son adversaire*/


								
heuristic(Board,Colour) :- listingPionsEquipe(Board,Colour,1,1,[],Lequipe),
								oppPlayer(Colour,Ennemi),
								listingPionsEquipe(Board,Ennemi,1,1,[],Lennemie),
								listingKalistas(Board,Colour,1,1, ((0,0),(0,0)),(KA,KE)),
								nbSbiresAlliesEnJeu(0.2,Lequipe,0,V2),print(V2),nl,
								nbSbiresEnnemisEnJeu(0.2,Lennemie,V2,V3),print(V3), nl,
								distanceSbiresKalista(0.2,KE,Lequipe,V3,V5),print(V5),nl,
								defenseKalistaAlliee(0.2,Lequipe,KA,V5,V6),print(V6),nl,
								defenseKalistaEnnemie(0.2,Lennemie,KE,V6,V7),print(V7),nl,
								gagne(Lennemie,Colour,V7,V8),
								perdu(Lequipe,Colour,V8,V9),write('Heuristique de '), print(V9),
								
								print(Ennemi),nl,
								print(Lequipe),nl,
								print(Lennemie),nl,
								print(KA),nl,
								print(KE),nl.

/* Ce coup passe à 100 si le joueur a gagné*/
gagne(L,rouge,_,Vb):- \+ element((_,_,ko),L),Vb is 100,!.
gagne(L,ocre,_,Vb):- \+ element((_,_,kr),L),Vb is 100,!.

gagne(_,_,V,V).
/*Ce coup passeà -100 si le joueur a perdu*/
perdu(L,rouge,_,Vb):- \+element((_,_,kr),L),Vb is 0,!.
perdu(L,ocre,_,Vb):- \+element((_,_,ko),L),Vb is 0,!.
perdu(_,_,V,V).


/* Cette heuristique cherche à laisser le plus souvent possible 4 pièces à l'ennemi, kalista comprise*/
nbSbiresEnnemisEnJeu(Coeff,L,Va,Vb):-longueur(V,L),
									 calculNbSbiresEnnemis(Coeff,Va,Vb,V).

nbSbiresAlliesEnJeu(Coeff,L,Va,Vb):- longueur(V,L),
									 calculNbSbiresAllies(Coeff,Va,Vb,V).
/* Determine le nombre de pions dans l'équipe adverse*/
listingPionsEquipe([T|Q],Colour,Col,Lin, V1,V3) :- Lin<7,NLin is Lin+1, listingPionsEquipeDansLigne(T,Colour,Col,Lin,V1,V2),
												 listingPionsEquipe(Q,Colour,Col,NLin,V2,V3),!.
listingPionsEquipe(_,_,_,7,V,V).

listingPionsEquipeDansLigne([(_, Pion)|Q], Colour,Col,Lin,V1,V3) :- Col<7, NCol is Col+1,findColour(Pion,Colour),append([(Col,Lin,Pion)],V1,V2),!, listingPionsEquipeDansLigne(Q, Colour,NCol,Lin,V2,V3).
listingPionsEquipeDansLigne([_|Q], Colour,Col,Lin,V1,V2) :- Col <7,NCol is Col+1,!, listingPionsEquipeDansLigne(Q,Colour,NCol,Lin,V1,V2),!.
listingPionsEquipeDansLigne([],_,7,_,V,V).
listingPionsEquipeDansLigne(_,_,7,_,V,V).

/*Determine le nombre de mouvements possibles susceptibles de supprimer des pièces adverses*/

nbPositionAttaque(Coeff,Colour,Board,Lennemi,V1,V2) :- possibleMoves(Board,Colour,PossibleMoveList),
															  findall((Col1,Lin1,Col2,Lin2),menacePion((Col1,Lin1,Col2,Lin2),PossibleMoveList,Lennemi),ListeMenaces),
															  longueur(L,ListeMenaces),
															  calculNbPositionAttaque(Coeff,V1,V2,L).

menacePion((Col1,Lin1,Col2,Lin2),PossibleMoveList,Lennemi) :- element((Col1,Lin1,Col2,Lin2),PossibleMoveList),element((Col2,Lin2,_),Lennemi).
/* Determine le nombre de mouvements adverses susceptibles de supprimer ses pièces*/
nbPositionVictime(Coeff,Colour,Board,Lequipe,V1,V2) :- possibleMoves(Board,Colour,PossibleMoveList),
															  findall((Col1,Lin1,Col2,Lin2),menacePion((Col1,Lin1,Col2,Lin2),PossibleMoveList,Lequipe),ListeMenaces),
															  longueur(L,ListeMenaces),
															  calculNbPositionVictime(Coeff,V1,V2,L).
															  
/*Recherche de la position des kalistas
listingKalistas(Board,Colour,1,1, ((0,0),(0,0)),(KA,KE)).*/
listingKalistas([T|Q],Colour,Col,Lin,(KAin,KEin),(KAout,KEout)) :- Lin<7,NLin is Lin+1, listingKalistasDansLigne(T,Colour,Col,Lin,(KAin,KEin),(KA2,KE2)),
												 listingKalistas(Q,Colour,Col,NLin,(KA2,KE2),(KAout,KEout)),!.
listingKalistas(_,_,_,7,(K1,K2),(K1,K2)):- print(K1),nl,print(K2).

listingKalistasDansLigne([(_, ko)|Q], ocre,Col,Lin,(_,KalistaEnnemie),(KA,KE)) :- Col<7, NCol is Col+1,!, listingKalistasDansLigne(Q, ocre,NCol,Lin,((Col,Lin),KalistaEnnemie),(KA,KE)),!.
listingKalistasDansLigne([(_, kr)|Q], rouge,Col,Lin,(_,KalistaEnnemie),(KA,KE)) :- Col<7, NCol is Col+1,!, listingKalistasDansLigne(Q, rouge,NCol,Lin,((Col,Lin),KalistaEnnemie),(KA,KE)),!.
listingKalistasDansLigne([(_, ko)|Q], rouge,Col,Lin,(KalistaAlliee,_),(KA,KE)) :- Col<7, NCol is Col+1,!, listingKalistasDansLigne(Q, rouge,NCol,Lin,(KalistaAlliee,(Col,Lin)),(KA,KE)),!.
listingKalistasDansLigne([(_, kr)|Q], ocre,Col,Lin,(KalistaAlliee,_),(KA,KE)) :- Col<7, NCol is Col+1,!, listingKalistasDansLigne(Q, ocre,NCol,Lin,(KalistaAlliee,(Col,Lin)),(KA,KE)),!.
listingKalistasDansLigne([_|Q], Colour,Col,Lin,(K1,K2),(K3,K4)) :- Col <7,NCol is Col+1,!, listingKalistasDansLigne(Q,Colour,NCol,Lin,(K1,K2),(K3,K4)),!.
listingKalistasDansLigne(_,_,7,_,(K1,K2),(K1,K2)).
															  
/*Recherche du nombre de sbires autour de la Kalista*/

defenseKalistaAlliee(Coeff,ListePion,(Col,Lin),Va,Vb) :- defenseur((Col+1,Lin),ListePion,0,V2),
												 defenseur((Col-1,Lin),ListePion,V2,V3),
												 defenseur((Col,Lin+1),ListePion,V3,V4),
												 defenseur((Col,Lin-1),ListePion,V4,V5),
												 calculDefenseKalistaAlliee(Coeff,Va,Vb,V5).
												 
defenseKalistaEnnemie(Coeff,ListePion,(Col,Lin),Va,Vb) :- defenseur((Col+1,Lin),ListePion,0,V2),
												 defenseur((Col-1,Lin),ListePion,V2,V3),
												 defenseur((Col,Lin+1),ListePion,V3,V4),
												 defenseur((Col,Lin-1),ListePion,V4,V5),
												 calculDefenseKalistaEnnemie(Coeff,Va,Vb,V5).
												 
defenseur((Col,Lin),ListePion,Va,Vb) :- element((Col,Lin,_),ListePion), Vb is Va+1,!.
defenseur(_,_,V,V).

distanceSbiresKalista(Coeff,(ColK,LinK),Lequipe,Va,Vb):- findall((Col,Lin),distanceDeuxCases(Lequipe,Col,Lin,ColK,LinK),ListePionsACote),
														 longueur(L,ListePionsACote),
														 calculDistanceSbireKalista(Coeff,Va,Vb,L).
														 
distanceDeuxCases(Lequipe,Col,Lin,ColK,LinK):- element((Col,Lin,_),Lequipe),Col=<ColK+2,Col>=ColK-2,
												Lin>=LinK-2,Lin=<LinK+2,!.
/*Listing des calculs d'heuristiques*/

calculDefenseKalistaAlliee(Coeff,Va,Vb,NbDefenseurs):- Vb is Va+Coeff*NbDefenseurs*100*0.25.
														 
calculDefenseKalistaEnnemie(Coeff,Va,Vb,NbDefenseurs):-Vb is Va+Coeff*(4-NbDefenseurs)*100*0.25.

calculDistanceSbireKalista(Coeff,Va,Vb,L):- Vb is Va+Coeff*L*100/6.

calculNbSbiresEnnemis(Coeff,Va,Vb,1):- Vb is Va+Coeff*(0),!.
calculNbSbiresEnnemis(Coeff,Va,Vb,2):- Vb is Va+Coeff*(33),!.
calculNbSbiresEnnemis(Coeff,Va,Vb,3):- Vb is Va+Coeff*(66),!.
calculNbSbiresEnnemis(Coeff,Va,Vb,4):- Vb is Va+Coeff*(100),!.
calculNbSbiresEnnemis(Coeff,Va,Vb,5):- Vb is Va+Coeff*(50),!.
calculNbSbiresEnnemis(Coeff,Va,Vb,6):- Vb is Va+Coeff*(0),!.

calculNbSbiresAllies(Coeff,Va,Vb,V):- Vb is Va+Coeff*V.

calculNbPositionAttaque(Coeff,Va,Vb,L) :- Vb is Va+Coeff*L*100/15,Vb < Va+Coeff*100,!.
calculNbPositionAttaque(Coeff,Va,Vb,_) :- Vb is Va+Coeff*100.

calculNbPositionVictime(Coeff,Va,Vb,L) :-Vb is Va+Coeff*(15-L)*100/15,Vb>Va+Coeff*100,!.
calculNbPositionVictime(Coeff,Va,Vb,_) :- Vb is Va+Coeff*100.


