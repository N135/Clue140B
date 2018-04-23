%User-facing functions!
%All of these functions should be used by the user to allow the program to know the game state.

%setup: Takes 3 lists; a list of valid People playing cards, Weapon playing cards, and Room playing cards respectively. Also takes number of players at the table and where the user falls in the turn order. 

setup(People,Weapons,Rooms,Player_num,I_am) :- assert(player_num(Player_num)), assert(people(People)), assert(weapons(Weapons)), assert(rooms(Rooms)), setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms),  I_am < Player_num, assert(me(I_am)).

%hand: takes 3 lists; the People cards, Weapons cards and Room cards that start in the players hand.

hand(People,Weapons,Rooms) :- me(X), attach_people(People,X), attach_weapons(Weapons,X), attach_rooms(Rooms,X).

%Note! hand still needs to set all other cards to doesnt_have for player 

%shown: Takes a player and a card, tells the program that the user was shown that card by the player number given
%This returns false if a not_any is played before it for the same card on any other player. This is OK, as the intended purpose still happens.

shown(Player,H) :- player_num(Y), set(Player,H,Y).

%not_any: Takes 3 cards and a player, and then lets the game know that the player has none of the 3 objects 

not_any(Player,Person,Weapon,Room) :- player_num(X), Player < X, valid_person(Person), valid_weapon(Weapon), valid_room(Room), set_not(Player,Person,Weapon,Room).

% not sure if well need any of this
suggestion(Player,Person,Weapon,Room) :- player_num(X), Player < X, me(Y), Player = me, valid_person(Person), valid_weapon(Weapon), valid_room(Room).

%
%has_one_of(Player,Person,Weapon,Room) :- player_num(X), Player < X, valid_person(Person), valid_weapon(Weapon), valid_room(Room).


%This returns true if for every category, nobody has X AND for every card other than X, somebody has it.
make_accusation(Person, Weapon, Room) :- know(Person), know(Weapon), know(Room).

% Person, Weapon, and Room are the suggested objects and Responses is a List of at most 3 elements, each of which is a 2 element list containing the
%player number who showed me the card and the card that they showed me.
% The predicate adds the information given to the knowledgebase.
%later stages should do something with Person, Weapon, and Room

my_suggestion(Person, Weapon, Room, Responses) :- add_responses(Responses).

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

attach_people([], Player).
attach_people([H],Player) :- valid_person(H), shown(Player,H).
attach_people([H|T],Player) :- valid_person(H), shown(Player,H), attach_people(T, Player).

attach_weapons([], Player).
attach_weapons([H],Player) :- valid_weapon(H), shown(Player,H).
attach_weapons([H|T],Player) :- valid_weapon(H), shown(Player,H), attach_weapons(T, Player).

attach_rooms([], Player).
attach_rooms([H],Player) :- valid_room(H), shown(Player,H).
attach_rooms([H|T],Player) :- valid_room(H), shown(Player,H), attach_rooms(T, Player).

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


%my_suggestion helpers
add_responses([[Player | Card]]) :- shown(Player, Card).
add_responses([[Player | Card] | Tail]) :- shown(Player, Card), add_responses(Tail).

