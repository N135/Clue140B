%User-facing functions!
%All of these functions should be used by the user to allow the program to know the game state.
%
%setup: Takes 3 lists; a list of valid People playing cards, Weapon playing cards, and Room playing cards respectively. Also takes number of players at the table and where the user falls in the turn order. 

setup(People,Weapons,Rooms,Player_num,I_am) :- assert(player_num(Player_num)), setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms),  I_am < Player_num, assert(me(I_am)).

%hand: takes 3 lists; the People cards, Weapons cards and Room cards that start in the players hand.

hand(People,Weapons,Rooms) :- me(X), attach_people(People,X), attach_weapons(Weapons,X), attach_rooms(Rooms,X).

%Note! hand still needs to set all other cards to doesnt_have for player 


%shown: Takes a player and a card, tells the program that the user was shown that card by the player number given

shown(Player,H) :- player_num(Y), set(Player,H,Y).

%
suggestion(Player,Person,Weapon,Room) :- player_num(X), Player < X, me(Y), Player = me, valid_person(Person), valid_weapon(Weapon), valid_room(Room).

%
%has_one_of(Player,Person,Weapon,Room) :- player_num(X), Player < X, valid_person(Person), valid_weapon(Weapon), valid_room(Room).




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

%supporting predicates for hand
attach_people([H],Player) :- valid_person(H), shown(Player,H).
attach_people([H|T],Player) :- valid_person(H), shown(Player,H), attach_people(T).

attach_weapons([H],Player) :- valid_weapon(H), shown(Player,H).
attach_weapons([H|T],Player) :- valid_weapon(H), shown(Player,H), attach_weapons(T).

attach_rooms([H],Player) :- valid_room(H), shown(Player,H).
attach_rooms([H|T],Player) :- valid_room(H), shown(Player,H), attach_rooms(T).

%establishes who has what, and then removes could_have from all players, sets has for the passed player and could 

set(1,H,1) :- retract(could_have(1,H)), assert(has(1,H)).
set(Player,H,1) :- Player \== 1, retract(could_have(1,H)), assert(doesnt_have(1,H)).
set(Player,H,X) :- Player == X, retract(could_have(X,H)), assert(has(1,H)), succ(X0,X), set(Player,H,X0).
set(Player,H,X) :- Player \== X, retract(could_have(X,H)), assert(doesnt_have(1,H)), succ(X0,X), set(Player,H,X0).
