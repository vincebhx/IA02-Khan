generateMove(BoardInit, Player, BestMove) :-

									/*On crée une copie temporaire des prédicats pion sous le nom de miniMaxPion
									L'objectif pour nous était d'implémenter un minimax*/
									
									findall((IdPion,Col,Lin,Etat,Marq),pion(IdPion,Col,Lin,Etat,Marq),ListePionsMinimax),
									recopiagePions(ListePionsMinimax),
									/*On récupère la liste de tous les mouvements possibles*/
									possibleMovesMiniMax(BoardInit,Player,List),
									sort(List,PossibleMoveList),
									testHeuristique(PossibleMoveList,Player,BoardInit,ListePionsMinimax,[],Lmoves),
									/*On récupère BestMove dans la liste triée des (Heuristiques,BestMove)*/
									sort(Lmoves,L2),reverse(L2,L3),element((_,BestMove),L3),!,
									/*Ces copies sont désormais supprimées*/
									retractall(miniMaxPion(_,_,_,_,_)).
									
						
                                   
/*Ce test permet de simuler le plateau de jeu associé à chaque mouvement et donc les heuristiques associées*/
testHeuristique([(Col1,Lin1,Col2,Lin2)|L],Player,InBoard,ListePionsMinimax,L1,L3):- 
																		miniMaxPion(Pion,Col1,Lin1,_,_),
																		/* OutBoard est le plateau sur lequel on va tester l'heuristique*/
																		transfertMiniMax(InBoard,(Col1,Lin1,Col2,Lin2),Pion,OutBoard),
																		/*Voir dans heuristic.pl*/
																		heuristic(OutBoard, Player, H),
																		append([(H,(Col1,Lin1,Col2,Lin2))],L1,L2),
																		/*On vient réinitialiser l'ensemble des prédicats miniMaxPion pour pouvoir calculer les heuristiques du prochain mouvement*/
																		retractall(miniMaxPion(_,_,_,_,_)),
																		recopiagePions(ListePionsMinimax),
																		testHeuristique(L,Player,InBoard,ListePionsMinimax,L2,L3).
testHeuristique([],_,_,_,L,L).
/*On aboutit à la liste Lmoves

Permet d'assert toute la liste ListePionsMinimax*/
  recopiagePions([(IdPion,Col,Lin,Etat,Marq)|Q]) :- asserta(miniMaxPion(IdPion,Col,Lin,Etat,Marq)),recopiagePions(Q).
  recopiagePions([]).




