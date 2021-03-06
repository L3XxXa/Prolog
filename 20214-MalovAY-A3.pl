%to start write 'swipl 20214-malovay-a3.pl' in terminal
rule(1, "Anorexia", [1, 5, 15]).
rule(2, "Bulimia", [1, 6, 14]).
rule(3, "BED", [1, 7, 14]).
rule(4, "Autism", [4, 24, 8]).
rule(5, "Dyslexia", [4, 23]).
rule(6, "Asperger syndrome", [4, 8, 16]).
rule(7, "ADHD", [4, 28]).
rule(8, "Rett syndrome", [4, 20, 8]).
rule(9, "Tourette syndrome", [4, 17]).
rule(10, "Shizophrenia", [2, 9]).
rule(11, "Bipolar disorder", [2, 10]).
rule(12, "Demetia", [2, 11]).
rule(13, "Depression", [2, 12]).
rule(14, "Down syndrome", [3, 19, 13, 20, 22]).
rule(15, "Fragile X syndrome", [3, 20, 21]).
rule(16, "Cri du chat syndrome", [3, 20]).
rule(17, "Mania", [2, 27]).
rule(18, "Hypochondriasis", [2, 26]).
rule(19, "Panic disorder", [2, 18]).
rule(20, "Post-traumatic stress disorder", [2, 25]).
properties(1, "Eating disorder").
properties(2, "Psychotic disorder").
properties(3, "Genetic disorder").
properties(4, "Neurodevelopment disorder").
properties(5, "Low weight").
properties(6, "Stomach problems").
properties(7, "High weight").
properties(8, "Low social skills").
properties(9, "Hallucinations").
properties(10, "Elevated moods").
properties(11, "Cognitive problems").
properties(12, "Oppression").
properties(13, "Delayed physical growth").
properties(14, "Binge eating").
properties(15, "Starving").
properties(16, "Repetetive interests").
properties(17, "Motor tics").
properties(18, "Pannic attacks").
properties(19, "Intellectual disability").
properties(20, "Development problems").
properties(21, "Long and narrow face").
properties(22, "Small chin and slanted eyes").
properties(23, "Reading and writing problems").
properties(24, "Problems with communication").
properties(25, "Flashbacks").
properties(26, "Excessive concern about health").
properties(27, "Hyperbulia").
properties(28, "Hyperactivity").


yes(X) :- db_yes(X), !.
yes(X) :- not(no(X)), !, check_if(X).
no(X) :- db_no(X), !.
check_if(X) :- write("Symptom - "), write(X), writeln("?"),
   read_string(user_input, "\n", "", _, Reply),
   remember(Reply, X).

remember("yes", X):- asserta(db_yes(X)), !.
remember("no", X):-asserta(db_no(X)), fail.


:-dynamic db_yes/1, db_no/1.

init:-
    writeln("Welcome!"),
    writeln("This is an expert system about different mental disorders."),
    writeln("I will ask you some symptoms to define disorder. Use only 'yes' and 'no', as I can't work with other answers now"),
    writeln("Do you want to start?"),
    read_string(user_input, "\n", "", _, Resp),
    writeresponse(Resp).
writeresponse(Resp) :- Resp == "yes" -> searchinit; writeln("Bye, thanks for executing me"), halt.

searchinit:-
    writeln("What do you want to do?"),
    writeln("1 - Find disorder by symptoms"),
    writeln("2 - Find symptoms by disorder"),
    writeln("3 - list of all disorders"),
    writeln("4 - exit"),
    read_string(user_input, "\n", "", _, Resp),
    atom_number(Resp, Num),
    searchparameter(Num), nl.

searchparameter(1) :-
    systeminit, nl.
searchparameter(2) :-
    symptomsinit, nl.
searchparameter(3):-
    list, nl.
searchparameter(4):-
    exit, nl.

searchparameter(_) :- searchinit.



systeminit:- retractall(db_yes(_)), retractall(db_no(_)),
    disorder(X), write("Disorder is "), writeln(X), returnans(X).
systeminit:- writeln("Sorry, IDK what it is").

returnans(X):-
    writeln("I can define the disorder. Do you want?"),
    read_string(user_input, "\n", "", _, Resp),
    writeresponser(X, Resp).
writeresponser(X, Resp) :- Resp == "yes" -> showsymptoms(X); restart.

symptomsinit:-
    writeln("Write a disorder"),
    read_string(user_input, "\n", "", _, Resp),
    showsymptoms(Resp), fail.

list:-rule(_, N, _),
    writeln(N),
    fail.

exit:- writeln("Goodbye! Have a nice day"), halt.

showsymptoms(X):- rule(_, X, Property), showproperty(Property).
showproperty(([N|Property])):- properties(N, A),
    writeln(A),
    showproperty(Property).
showproperty([]) :- restart.

restart:- writeln("Do you want to restart?"),
    read_string(user_input, "\n", "", _, Resp),
    writeresponse(Resp).

disorder(X) :- rule(_, X, Property), check_property(Property).
check_property([N|Property]):- properties(N, A),
    yes(A),
    check_property(Property).
check_property([]).
:-initialization(init).





