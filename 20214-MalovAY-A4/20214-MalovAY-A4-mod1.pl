:- module('20214-MalovAY-A4-mod1', [word/2, script/1, family/2, shortscript/1]).
:- dynamic db_family/1.
word(1, ["bye", "goodbye"]).

word(2, ["feel"]).

word(3, ["love", "feelings"]).

word(4, ["sex", "shreks", "jagajaga"]).

word(5, ["furious", "raging", "annoyed", "angry", "irritated", "enraged"]).

word(6, ["yes"]).
word(6, ["no"]).

word(7, ["complex"]).
word(7, ["fixation"]).

word(8, ["always", "ever"]).

word(9, ["mother", "mom", "mama", "mamma"]).
word(9, ["brother", "bro", "bruvver", "bruv"]).
word(9, ["sister", "sis"]).
word(9, ["son"]).
word(9, ["daughter"]).
word(9, ["father", "dad", "papa"]).
word(9, ["wife"]).
word(9, ["husband"]).
word(12, ["thank"]).

family(9, W) :- asserta(db_family(W)).
family(_,_).

shortscript(6):- writeln("Can you say something more about that?"),whathappenedlisten.

script(1):-  writebye, halt.

script(2):- writeln("For how long have you felt that?"),whathappenedlisten.

script(3):- writeln("Are you afraid of that feeling?"),whathappenedlisten.

script(4):- writeln("Do you understand that it will affect personal. If you want to talk about that, please, continue"),whathappenedlisten.

script(5):- writeln("What do you feel right now?"),whathappenedlisten.



script(7):- writeln("Do not get stuck on your problems. Try to let them go."),whathappenedlisten.

script(8):- writeln("Can you give me an example?"),whathappenedlisten.

script(9):- writeln("Maybe you want to talk about your family? If so continue please"),whathappenedlisten.

script(10):- retract(db_family(X)), format("You mentioned your family member earlier. Tell me more about your ~w?\n", X),whathappenedlisten.
script(10):- writeln("Please, continue."),whathappenedlisten.

script(12):- writeln("You are welcome. I hope I helped you. Do you want to continue?"),whathappenedlisten.






