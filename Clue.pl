%User-facing functions!
%All of these functions should be used by the user to allow the program to know the game state.

/*
setup:
Takes 3 lists; a list of valid People playing cards, Weapon playing cards,
and Room playing cards respectively. Also takes number of players at the table and
where the user falls in the turn order. 
The assumption that a higher numbered player will always be to the left, barring position player_num.
*/
setup_game(People,Weapons,Rooms,Player_num,I_am) :- assert(player_num(Player_num)),
		assert(people(People)), assert(weapons(Weapons)), assert(rooms(Rooms)),
		setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms),
		I_am =< Player_num, assert(me(I_am)).
/*
setup_hand:
takes 3 lists; the People cards, Weapons cards and Room cards that start in the players hand.
*/
setup_hand(People,Weapons,Rooms) :- me(X), setup_people(People,X), setup_weapons(Weapons,X), setup_rooms(Rooms,X),
		people(Plist), weapons(Wlist), rooms(Rlist),
		dont_have_except(Plist, People, X), dont_have_except(Wlist, Weapons, X), dont_have_except(Rlist, Rooms, X).

/*
make_accusation:
This returns true if for every category, nobody has X AND for every card other than X, somebody has it.

Might be useful to build in write() statements eventually, so that it can be called from inside other functions (notepad could suggest accusation at end.)
*/
make_accusation(Person, Weapon, Room) :- know(Person), know(Weapon), know(Room).

/*
my_suggestion:
Entered when the user makes a suggestion.
Takes a person, weapon and room card. Also takes whatever player responded and with what card they responded, optionally.
If no player and card is given, its assumed no one at the table (barring the user) had any of the 3 cards.
*/
my_suggestion(Person, Weapon, Room, []) :- me(M), succ(M,X), add_dont_have(X, M, Person, Weapon, Room), resolve(), notepad().
my_suggestion(Person, Weapon, Room, [Player, Card]) :- shown(Player, Card), me(M), succ(M,X), add_dont_have(X, Player, Person, Weapon, Room), resolve(), notepad().

/*
other_suggestion:
Entered in response to another players suggestion. 
*/
other_suggestion(Person, Weapon, Room, [Player, Responder]) :- succ(Player,X),
		add_dont_have(X, Responder, Person, Weapon, Room), check_others(Person, Weapon, Room, Responder), resolve(), notepad().
other_suggestion(Person, Weapon, Room, [Player]) :- succ(Player,X),
		add_dont_have(X, Player, Person, Weapon, Room), resolve(), notepad(). 

/*
get_suggestion:
Takes a list of rooms availible, and returns 

get_suggestion(Possible_Rooms) :- rooms(Rooms), weapons(Weapons), people(People), is_best_room(Rooms, Rooms, Room, false),
		is_best_room(Possible_Rooms, Possible_Rooms, Possible_Room, false) is_best_person(People, People, Person, false), is_best_weapon(Weapons, Weapons, Weapon, false),
		write(Room), write(Possible_Room), write(Person), write(Weapon).
*/

/*
notepad:
Prints an easy to read graphic display of everything known so far.
*/

notepad() :- player_num(P), output_players(P), people(People), output(P,People), weapons(Weapons), output(P,Weapons), rooms(Rooms), output(P,Rooms).

%Supporting code: Users dont need to look here

%-------------------------------------------------------------------

%Supporting predicates for setup
%Establishes valid people cards
setup_people([H]) :- assert(valid_person(H)), setup_have(H).
setup_people([H|T]) :- assert(valid_person(H)), setup_have(H), setup_people(T).

%Establishes valid weapon cards
setup_weapons([H]) :- assert(valid_weapon(H)), setup_have(H).
setup_weapons([H|T]) :- assert(valid_weapon(H)), setup_have(H), setup_weapons(T).

%Establishes valid room cards
setup_rooms([H]) :- assert(valid_room(H)), setup_have(H).
setup_rooms([H|T]) :- assert(valid_room(H)), setup_have(H), setup_rooms(T).

%Makes it so that everyone could_have all the cards.
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
dont_have_except([H], Passed, Me) :-  member(H, Passed).

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

%make all players between start and end not have any of the 3.

add_dont_have(X, X, _, _, _).
add_dont_have(Start, End, Person, Weapon, Room) :- player_num(P), Start > P, 
	       	add_dont_have(1, End, Person, Weapon, Room).
add_dont_have(Start, End, Person, Weapon, Room) :- succ(Start,S0), player_num(P), S0 > P,
		assert(doesnt_have(Start, Person)), assert(doesnt_have(Start, Weapon)), assert(doesnt_have(Start,Room)),
	       	add_dont_have(1, End, Person, Weapon, Room).
add_dont_have(Start, End, Person, Weapon, Room) :- succ(Start,S0),
		assert(doesnt_have(Start, Person)), assert(doesnt_have(Start, Weapon)), assert(doesnt_have(Start,Room)),
		add_dont_have(S0, End, Person, Weapon, Room).

%indicates that player has been shown a card.
shown(Player,H) :- player_num(Y), set(Player,H,Y), clean_up(Player,H).

%clears has_at_least_one() if card from set is shown
clean_up(Player,H) :- has_at_least_one(Player,Y), member(H,Y), retract(has_at_least_one(Player,Y)), clean_up(Player,H).
clean_up(_,_).

%nonsense has_at_least_one to prevent errors (defines has_at_least_one in the event that something referencing has_at_least_one() calls it before has_at_least_one is asserted.)
has_at_least_one(0,[]).

%helpers for other_suggestion:

check_others(Person,Weapon,Room,Player) :- has(X,Person), has(Y,Weapon), X \== Player, Y \== Player, assert(has(Player,Room)).
check_others(Person,Weapon,Room,Player) :- has(X,Person), has(Y,Room), X \== Player, Y \== Player, assert(has(Player,Weapon)).
check_others(Person,Weapon,Room,Player) :- has(X,Room), has(Y,Weapon), X \== Player, Y \== Player, assert(has(Player,Person)).
check_others(Person,Weapon,Room,Player) :- has(X,Person), X \== Player, assert(has_at_least_one(Player,[Weapon, Room])).
check_others(Person,Weapon,Room,Player) :- has(X,Weapon), X \== Player, assert(has_at_least_one(Player,[Person, Room])).
check_others(Person,Weapon,Room,Player) :- has(X,Room), X \== Player, assert(has_at_least_one(Player,[Weapon, Person])).
check_others(Person,Weapon,Room,Player) :- assert(has_at_least_one(Player,[Person,Weapon,Room])).

resolve() :- has_at_least_one(Player, [X,Y]), doesnt_have(Player, X), retract(has_at_least_one(Player,[X,Y])), shown(Player,Y), resolve().
resolve() :- has_at_least_one(Player, [X,Y]), doesnt_have(Player, Y), retract(has_at_least_one(Player, [X,Y])), shown(Player,Y), resolve().
resolve() :- has_at_least_one(Player, [X,Y,Z]), doesnt_have(Player,X), retract(has_at_least_one(Player,[X,Y,Z])), assert(has_at_least_one(Player,[Y,Z])), resolve().
resolve() :- has_at_least_one(Player, [X,Y,Z]), doesnt_have(Player,Y), retract(has_at_least_one(Player,[X,Y,Z])), assert(has_at_least_one(Player,[X,Z])), resolve().
resolve() :- has_at_least_one(Player, [X,Y,Z]), doesnt_have(Player,Z),  retract(has_at_least_one(Player,[X,Y,Z])), assert(has_at_least_one(Player,[Y,X])), resolve().
resolve().

%helpers for notepad
output_players(P) :- tab(20), op_helper(P,1).
op_helper(P,X) :- X =< P, write(X), tab(2), succ(X,X0), op_helper(P,X0).
op_helper(P,X) :- X > P, nl. 

output(Players,[H]) :- write(H), write_length(H,I,[]), Z is 20 - I,  tab(Z), line(Players, H, 1), nl.
output(Players,[H | T]) :- write(H), write_length(H,I,[]), Z is 20 - I,  tab(Z), line(Players, H, 1),  nl, output(Players,T).

line(P, H, X) :- X =< P, has(X,H), write(o), tab(2), succ(X,X0), line(P, H, X0).
line(P, H, X) :- X =< P, doesnt_have(X,H), write(x), tab(2), succ(X,X0), line(P, H, X0).
line(P, H, X) :- X =< P, could_have(X,H), write(?), tab(2), succ(X,X0), line(P, H, X0).
line(P, H, X) :- X > P.




%get_suggestion helpers
is_best_room([RH], Room) :- Room = RH.
is_best_room([RH | RT], Room) :- is_best_room(RT, X), player_num(P), num_dont_have(RH, P, Num1), num_dont_have(X, P, Num2), Num1 >= Num2, Room = RH.
is_best_room([RH | RT], Room) :- is_best_room(RT, X), player_num(P), num_dont_have(RH, P, Num1), num_dont_have(X, P, Num2), Num2 > Num1, Room = X.

is_best_weapon([WH], Weapon) :- Weapon = WH.
is_best_weapon([WH | WT], Weapon) :- is_best_weapon(WT, X), player_num(P), num_dont_have(WH, P, Num1), num_dont_have(X, P, Num2), Num1 >= Num2, Room = WH.
is_best_weapon([WH | WT], Weapon) :- is_best_weapon(WT, X), player_num(P), num_dont_have(WH, P, Num1), num_dont_have(X, P, Num2), Num2 > Num1, Room = X.

is_best_person([PH], Person) :- Person = PH.
is_best_person([PH | PT], Person) :- is_best_person(PT, X), player_num(P), num_dont_have(PH, P, Num1), num_dont_have(X, P, Num2), Num1 >= Num2, Room = PH.
is_best_person([PH | PT], Person) :- is_best_person(PT, X), player_num(P), num_dont_have(PH, P, Num1), num_dont_have(X, P, Num2), Num2 > Num1, Room = X.

%num_dont_have: Takes card were looking for, and the total number of players initially, returns the number of players who dont have that card in result.
num_dont_have(Card, 1, Result) :- doesnt_have(1,Card), Result = 1.  
num_dont_have(Card, 1, Result) :- Result = 0.  
num_dont_have(Card, Player, Result) :- succ(P,Player), num_dont_have(Card,P,X), doesnt_have(Player,Card), succ(X,Result).
num_dont_have(Card, Player, Result) :- succ(P,Player), num_dont_have(Card,P,X), Result = X.

%halo = has at least one
is_best_room_via_halo(Rooms, Room).


