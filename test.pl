

fact(1, purse).
fact(2, purse).
fact(1, hat).

num(SoFar, Object, 0) :- not(fact_and_not_member(Object, SoFar)).
num(SoFar, Object, Num) :- fact(Object), not(member(Object, SoFar)), append(SoFar, Object, Res), num(Res, Object, Num - 1).


fact_and_not_member(Object, SoFar) :- fact(Object), not(member(Object, SoFar)).
