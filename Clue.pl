%User-facing functions!
%All of these functions should be used by the user to allow the program to know the game state.
%
%setup: Takes 3 lists; a list of valid People playing cards, Weapon playing cards, and Room playing cards respectively. Also takes number of players at the table and where the user falls in the turn order. 
%This establishes the game state for the program. 
setup(People,Weapons,Rooms,Player_num,I_am) :- setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms), assert(player_num(Player_num)), I_am < Player_num, assert(me(I_am)).

%hand: takes 3 lists; the People cards, Weapons cards and Room cards that start in the players hand.
%This gives the program all the information the user has at the start of the game
hand(People,Weapons,Rooms) :- me(X), attach_people(People,X), attach_weapons(Weapons,X), attach_rooms(Rooms,X).

%
suggestion(Player,Person,Weapon,Room) :- player_num(X), Player < X, me(Y), Player = me, valid_person(Person), valid_weapon(Weapon), valid_room(Room).

%
has_one_of(Player,Person,Weapon,Room) :- player_num(X), Player < X, valid_person(Person), valid_weapon(Weapon), valid_room(Room).




%Supporting code: Users don't need to look here

%-------------------------------------------------------------------%

%Supporting predicates for setup
setup_people([H]) :- assert(valid_person(H)).
setup_people([H|T]) :- assert(valid_person(H)), setup_people(T).

setup_weapons([H]) :- assert(valid_weapon(H)).
setup_weapons([H|T]) :- assert(valid_weapon(H)), setup_weapons(T).

setup_rooms([H]) :- assert(valid_room(H)).
setup_rooms([H|T]) :- assert(valid_room(H)), setup_rooms(T).

%supporting predicates for hand
attach_people([H],Player) :- valid_person(H), assert(has(H,Player)).
attach_people([H|T],Player) :- valid_person(H), assert(has(H,Player)), attach_people(T).

attach_weapons([H],Player) :- valid_weapon(H), assert(has(H,Player)).
attach_weapons([H|T],Player) :- valid_weapon(H), assert(has(H,Player)), attach_weapons(T).

attach_rooms([H],Player) :- valid_room(H), assert(has(H,Player)).
attach_rooms([H|T],Player) :- valid_room(H), assert(has(H,Player)), attach_rooms(T).
