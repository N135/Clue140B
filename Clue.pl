%User-facing functions!
%All of these functions should be used by the user to allow the program to know the game state.

/*

setup: Takes 3 lists; a list of valid People playing cards, Weapon playing cards,
and Room playing cards respectively. Also takes number of players at the table and
where the user falls in the turn order. 

*/

setup_game(People,Weapons,Rooms,Player_num,I_am) :- assert(player_num(Player_num)),
		assert(people(People)), assert(weapons(Weapons)), assert(rooms(Rooms)),
		setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms),
		I_am < Player_num, assert(me(I_am)).
/*
takes 3 lists; the People cards, Weapons cards and Room cards that start in the players hand.
*/
setup_hand(People,Weapons,Rooms) :- me(X), setup_people(People,X), setup_weapons(Weapons,X), setup_rooms(Rooms,X),
people(Plist), weapons(Wlist), rooms(Rlist),
dont_have_except(Plist, People, X), dont_have_except(Wlist, Weapons, X), dont_have_except(Rlist, Rooms, X).

%This returns true if for every category, nobody has X AND for every card other than X, somebody has it.
make_accusation(Person, Weapon, Room) :- know(Person), know(Weapon), know(Room).

% Person, Weapon, and Room are the suggested objects and Responses is a List of at most 3 elements, each of which is a 2 element list containing the
%player number who showed me the card and the card that they showed me.
% The predicate adds the information given to the knowledgebase.
%later stages should do something with Person, Weapon, and Room

my_suggestion(Person, Weapon, Room, []).
my_suggestion(Person, Weapon, Room, [PlayerShowing, CardShowed]) :- shown(PlayerShowing, CardShowed), player_num(P), add_dont_have(PlayerShowing, CardShowed, P).

notepad() :- player_num(P), output_players(P), people(People), output(P,People), weapons(Weapons), output(P,Weapons), rooms(Rooms), output(P,Rooms).

%Supporting code: Users dont need to look here

%-------------------------------------------------------------------

%Supporting predicates for setup
setup_people([H]) :- assert(valid_person(H)), setup_have(H).
setup_people([H|T]) :- assert(valid_person(H)), setup_have(H), setup_people(T).

setup_weapons([H]) :- assert(valid_weapon(H)), setup_have(H).
setup_weapons([H|T]) :- assert(valid_weapon(H)), setup_have(H), setup_weapons(T).

setup_rooms([H]) :- assert(valid_room(H)), setup_have(H).
setup_rooms([H|T]) :- assert(valid_room(H)), setup_have(H), setup_rooms(T).

setup_have(H) :- player_num(Y), setup_have(Y,H).
setup_have(1,H) :- assert(could_have(1,H)).
setup_have(X,H) :- assert(could_have(X,H)), succ(X0, X), setup_have(X0,H).

%supporting predicates for setup_hand

setup_people([], Me).
setup_people([H],Me) :- valid_person(H), shown(Me,H).
setup_people([H|T],Me) :- valid_person(H), shown(Me,H), setup_people(T, Me).

setup_weapons([], Me).
setup_weapons([H],Me) :- valid_weapon(H), shown(Me,H).
setup_weapons([H|T],Me) :- valid_weapon(H), shown(Me,H), setup_weapons(T, Me).

setup_rooms([], Me).
setup_rooms([H],Me) :- valid_room(H), shown(Me,H).
setup_rooms([H|T],Me) :- valid_room(H), shown(Me,H), setup_rooms(T, Me).

dont_have_except([H|T], Passed, Me) :- not(member(H, Passed)), assert(doesnt_have(Me, H)), dont_have_except(T, Passed, Me).
dont_have_except([H|T], Passed, Me) :- member(H, Passed), dont_have_except(T, Passed, Me).
dont_have_except([H], Passed, Me) :-  not(member(H, Passed)), assert(doesnt_have(Me, H)).
dont_have_except([H], Passed, Me) :-  member(H, Passed)).

%establishes who has what, and then removes could_have from all players, sets has for the passed player and could

set(1,H,1) :- retract(could_have(1,H)), assert(has(1,H)).
set(Player,H,1) :- Player \== 1, retract(could_have(1,H)), assert(doesnt_have(1,H)).
set(Player,H,X) :- Player == X, retract(could_have(X,H)), assert(has(X,H)), succ(X0,X), set(Player,H,X0).
set(Player,H,X) :- Player \== X, retract(could_have(X,H)), assert(doesnt_have(X,H)), succ(X0,X), set(Player,H,X0).

%sets all the passed cards for the passed player to doesnt_have()
set_not(Player,Person,Weapon,Room) :- retract(could_have(Player,Person)), assert(doesnt_have(Player,Person)), retract(could_have(Player,Weapon)), assert(doesnt_have(Player,Weapon)), retract(could_have(Player,Room)), assert(doesnt_have(Player,Room)). 

%Supporting code for make_accusation

know(Person) :- player_num(NumPlayers), people(PeopleList), valid_person(Person), not(somebody_has(NumPlayers, Person)), last_standing(Person, PeopleList), !.
know(Weapon) :- player_num(NumPlayers), weapons(WeaponsList), valid_weapon(Weapon), not(somebody_has(NumPlayers, Weapon)), last_standing(Weapon, WeaponsList).
know(Room) :- 	player_num(NumPlayers), rooms(RoomsList), valid_room(Room), not(somebody_has(NumPlayers, Room)), last_standing(Room, RoomsList).

somebody_has(1, Card) :- has(1, Card).
somebody_has(Player, Card) :- has(Player, Card).
somebody_has(Player, Card) :- succ(PrevPlayer, Player), somebody_has(PrevPlayer, Card).

% true if all People except for Person is known to be held by some Player.
last_standing(Card, [Cards_Head]) :- Card == Cards_Head.
last_standing(Card, [Cards_Head]) :- player_num(NumPlayers), somebody_has(NumPlayers, Cards_Head).
last_standing(Card, [Cards_Head | Cards_Tail]) :- Card == Cards_Head, last_standing(Card, Cards_Tail).
last_standing(Card, [Cards_Head | Cards_Tail]) :- Card \== Cards_Head, player_num(NumPlayers), somebody_has(NumPlayers, Cards_Head), last_standing(Card, Cards_Tail).

add_dont_have(PlayerShowing, CardShowed, Player) :- not(Player = PlayerShowing), assert(doesnt_have(Player, CardShowed)), succ(Prev, Player), add_dont_have(PlayerShowing, CardShowed, Prev).

shown(Player,H) :- player_num(Y), set(Player,H,Y).

%helper for notepad, outputs the list of players
output_players(P) :- tab(20), op_helper(P,1).
op_helper(P,X) :- X =< P, write(X), tab(2), plus(X,1,X0), op_helper(P,X0).
op_helper(P,X) :- X > P, nl. 

output(Players,[H]) :- write(H), write_length(H,I,[]), Z is 20 - I,  tab(Z), line(Players, H, 1), nl.
output(Players,[H | T]) :- write(H), write_length(H,I,[]), Z is 20 - I,  tab(Z), line(Players, H, 1),  nl, output(Players,T).

line(P, H, X) :- X =< P, has(X,H), write(o), tab(2), plus(X,1,X0), line(P, H, X0).
line(P, H, X) :- X =< P, doesnt_have(X,H), write(x), tab(2), plus(X,1,X0), line(P, H, X0).
line(P, H, X) :- X =< P, could_have(X,H), write(?), tab(2), plus(X,1,X0), line(P, H, X0).
line(P, H, X) :- X > P.
