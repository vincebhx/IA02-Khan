/****TOUR HUMAIN****/
playTurn(InBoard, Colour, OutBoard) :- initMove(Colour, Move),
                                       %possibleMoves(InBoard, Colour, MoveList),
                                       checkMove(InBoard, Colour, Move, MoveList, OutBoard).


/**SAISIE DU MOUVEMENT**/
initMove(rouge, (Col1, Lin1, Col2, Lin2)) :- print('Joueur rouge, à votre tour !'), nl,
                                             print('Pion à déplacer (kr, r1..r5) ? '),
                                             read(Pion),
                                             testInitMove(rouge, Pion, (Col1, Lin1, Col2, Lin2)).

initMove(ocre, (Col1, Lin1, Col2, Lin2)) :- print('Joueur ocre, à votre tour !'), nl,
                                            print('Pion à déplacer (ko, o1..o5) ? '),
                                            read(Pion),
                                            testInitMove(ocre, Pion, (Col1, Lin1, Col2, Lin2)).

/*Vérification de la saisie du pion et saisie de la position d'arrivée*/
testInitMove(Colour, Pion, (Col1, Lin1, Col2, Lin2)) :- findColour(Pion, Colour),
                                                        \+pion(Pion, Col1, Lin1, out, _), !,
                                                        getNewPos(Lin2, Col2).
/*Cas d'erreur 1 : L'utilisateur a effectué une mauvaise saisie*/
testInitMove(Colour, Pion, Move) :- \+findColour(Pion, Colour),
                                    print('Erreur de saisie du pion.'), nl,
                                    initMove(Colour, Move).
/*Cas d'erreur 2 : Le pion n'est pas en jeu*/
testInitMove(Colour, Pion, Move) :- pion(Pion, _, _, out, _),
                                    print('Erreur : le pion choisi n est pas en jeu.'), nl,
                                    initMove(Colour, Move).

/*Saisie de la position d'arrivée*/
getNewPos(Lin, Col) :-  print('Position d''arrivee (Ex. ''A1'') ? '), nl,
                        read(Pos), parse(Pos, Col, Lin).


/**VERIFICATION DU MOUVEMENT**/
checkMove(InBoard, _, Move, MoveList, OutBoard) :- %element(Move, MoveList), !,
                                                   transfert(InBoard, Move, OutBoard).

checkMove(InBoard, Colour, Move, MoveList, OutBoard) :- \+element(Move, MoveList),
                                                        print('Erreur : mouvement invalide.'), nl,
                                                        playTurn(InBoard, Colour, OutBoard).