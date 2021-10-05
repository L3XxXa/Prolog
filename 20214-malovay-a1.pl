pet(boutie, cat).
pet(cornie, cat).
pet(mac, cat).
pet(flash, dog).
pet(rover, dog).
pet(spot, dog).

color(butsie, brown).
color(cornie, black).
color(mac, red).
color(rover, red).
color(spot, white).
color(flash, spotted).

homeless(X) :- not(owns(_, X)).
owns(tom, X) :- color(X, brown); color(X, black).
owns(kate, X):- pet(X, dog), not(owns(tom, X)), not(color(X, white)).
owns(alan, mac):- not(owns(kate, butsie)), homeless(spot).

echo([]).
echo([I]) :- format('X = ~w\n', [I]), !.
echo([I|Is]) :- format('X = ~w, ', [I]), echo(Is).

main(_) :-
	writeln('Tom owns: '),
	(findall(T, owns(tom, T), Tp), echo(Tp)),
        write('Kate owns: '),
        (findall(K, owns(kate, K), Kp), echo(Kp)).

:- initialization(main, main).
