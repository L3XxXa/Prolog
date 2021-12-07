%to run write swipl 20214-MalovAY-A4.pl 
%mod file have to be near to this file

:- use_module('20214-MalovAY-A4-mod1').

:- initialization(init).

init:-
    writeln("Hello!"),
    writeln("I am L3XXXA"),
    writeln("I can emulate communication with a psychotherapist. Please, write in lower case."),
    writeln("Can I help you?"),
    read_string(user_input, "\n", "", _, Resp),
    writeresponse(Resp).
writeresponse(Resp) :- (Resp == "Yes"; Resp == "yes"; Resp == "Help me" ; Resp == "help me"; Resp == "You can"; Resp == "you can")-> listener;
writebye, halt.

writebye:-
writeln("Goodbye. I hope I helped you.").

listener:-
    writeln("Tell me what worries you"), whathappenedlisten.

whathappenedlisten:-
    read_string(user_input, "\n", "", _, X),
    changetxt(X, L, Len),
    rec(L, Len).

changetxt([], []).
changetxt(L, X, Len):-
    string_lower(L, Z),
    split_string(Z, " ", ",!.;?", X),
    length(X, Len).
    
        
    

rec([], _) :- script(10).
rec([W|_], Len) :- word(X, List), member(W, List), startscript(X, W, Len).
rec([_|W], Len):- rec(W, Len).

startscript(X, W, Len):- X == 9 -> (family(X, W), script(X)); (Len == 1, X == 6) -> shortscript(6); script(X).







