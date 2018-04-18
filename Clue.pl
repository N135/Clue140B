setup(People,Weapons,Rooms,Player_num,I_am) :- setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms), assert(player_num(Player_num)), I_am < Player_num, assert(me(I_am)).

setup_people([H]) :- assert(valid_person(H)).
setup_people([H|T]) :- assert(valid_person(H)), setup_people(T).

setup_weapons([H]) :- assert(valid_weapon(H)).
setup_weapons([H|T]) :- assert(valid_weapon(H)), setup_weapons(T).

setup_rooms([H]) :- assert(valid_room(H)).
setup_rooms([H|T]) :- assert(valid_room(H)), setup_rooms(T).

hand(People,Weapons,Rooms) :- me(X), attach_people(People,X), attach_weapons(Weapons,), attach_rooms(Rooms).

suggestion(Player,Person,Weapon,Room) :- player_num(X), Player < X, valid_person(Person), valid_weapon(Weapon), valid_room(Room).
has_one_of(Player,Person,Weapon,Room) :- player_num(X), Player < X, valid_person(Person), valid_weapon(Weapon), valid_room(Room).
