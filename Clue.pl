setup(People,Weapons,Rooms,Players) :- setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms), assert(player_num(Players)).

setup_people([H]) :- assert(valid_person(H)).
setup_people([H|T]) :- assert(valid_person(H)), setup_people(T).

setup_weapons([H]) :- assert(valid_weapon(H)).
setup_weapons([H|T]) :- assert(valid_weapon(H)), setup_weapons(T).

setup_rooms([H]) :- assert(valid_room(H)).
setup_rooms([H|T]) :- assert(valid_room(H))), setup_rooms(T).

hand(People,Weapons,Rooms) :- attach_people(People), clear_weapons(Weapons), clear_rooms(Rooms).
