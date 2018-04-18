setup(People,Weapons,Rooms,Players) :- setup_people(People), setup_weapons(Weapons), setup_rooms(Rooms), assert(player_num(Players)).

setup_people([H]) :- assert(valid_person(H)).
setup_people([H|T]) :- assert(valid_person(H)), setup_people(T).

setup_weapons([H]) :- assert(valid_weapon(H)).
setup_weapons([H|T]) :- assert(valid_weapon(H)), setup_weapons(T).

setup_rooms([H]) :- assert(valid_room(H)).
setup_rooms([H|T]) :- assert(valid_room(H))), setup_rooms(T).

hand(People,Weapons,Rooms) :- attach_people(People), attach_weapons(Weapons), attach_rooms(Rooms).

attach_people([H]) :- assert(my_person(H)).
attach_people([H|T]) :- assert(my_person(H)), attach_people(T).

attach_weapons([H]) :- assert(my_weapon(H)).
attach_weapons([H|T]) :- assert(my_weapon(H)), attach_weapons(T).

attach_rooms([H]) :- assert(my_room(H)),
attach_rooms([H|T]) :- assert(my_room(H)), attach_rooms(T).
