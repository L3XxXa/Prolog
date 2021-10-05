item(name, studio, genre, year).
item("The Last of Us 2", "Naughty Dog", "Survival horror", 2020).
item("The Last of Us", "Naughty Dog", "Survival horror", 2013).
item("Cotrol", "Remedy Entertainment", "Action Adventure", 2019).
item("Metro Exodus", "4A Games", "First-person shooter", 2019).
item("Metro Last Light", "4A Games", "First-person shooter", 2013).
item("Metro 2033", "4A Games", "First-person shooter", 2010).
item("Death Stranding", "Kojima Production", "Action Adventure", 2019).
item("The Witcher 3: Wild Hunt", "CD Projekt Red", "Action RPG", 2015).
item("Cyberpunk 2077", "CD Projekt Red", "Action RPG", 2020).
item("Red Dead Redemption 2", "Rockstar Studio", "Action Adventure", 2019).
item("Grand Theft Auto 5", "Rockstar Studio", "Action Adventure", 2013).
item("Detroit: Become Human", "Quantic Dream", "Interactive game", 2018).
item("Beyond: Two Souls", "Quantic Dream", "Interactive game", 2013).
item("Heavy Rain", "Quantic Dream", "Interactive game", 2010).
item("Valiant Hearts: The Great War", "Ubisoft", "Puzzle", 2014).
item("Sekiro: Shadows Die Twice", "FromSoftware", "Action Adventure", 2019).
item("Ghost of Tsushima", "Sucker Punch Production", "Action Adventure", 2020).
item("Days Gone", "Bend Studio", "Action Adventure", 2019).
item("Minecraft", "Mojang", "Survival", 2011).
item("Horizon Zero Dawn", "Guerilla Games", "Action RPG", 2017).
item("Fallout 4", "Bethesda Game Studio", "Action RPG", 2015).
item("God of War", "Santa Monica Studio", "Action Adventure", 2018).
item("Half-Life 2", "Valve", "First-person shooter", 2004).
item("Half-Life", "Valve", "First-person shooter", 1998).
item("Half-Life Alyx", "Valve", "First-person shooter", 2020).
item("Firewatch", "Campo Santo", "Adventure", 2016).
item("Little Nightmares 2", "Tarsier studio", "Horror Puzzle", 2021).
item("Little Nightmares", "Tarsier studio", "Horror Puzzle", 2017).

searchinit:-
    writeln("Welcome!"),
    writeln("This is list of must-played games. This list is made by L3XxXA. Do you want to continue ((y)es/(n)o)?"),
    read_string(user_input, "\n", "", _, Response),
    writeresponse(Response).

writeresponse(Response) :- Response == "yes"; Response == "y" -> chooseparameter; Response == "no"; Response == "n" -> writeln("Bye, thanks for executing me)"); writeln("Wha?"), searchinit.

chooseparameter:-
    writeln("Choose one of the parameter to search by:"),
    writeln("1 - Name of the game"),
    writeln("2 - Game studio"),
    writeln("3 - Genre of the game"),
    writeln("4 - Year of release"),
    writeln("5 - List of all games"),
    writeln("6 - Exit"),
    read_string(user_input, "\n", "", _, Val),
    atom_number(Val, Num),
    searchbyparameter(Num), nl.

searchbyparameter(1):-
    writeln("You have chosen to search game by the name."),
    write("Write full name of the game: "),
    read_string(user_input, "\n", "", _, Name),
    searchwithname(Name), nl.

searchbyparameter(2):-
    writeln("You have chosen to search game by the game studio."),
    write("Write full name of the stduio: "),
    read_string(user_input, "\n", "", _, Studio),
    searchwithstudio(Studio), nl.

searchbyparameter(3):-
    writeln("You have chosen to search game by the genre."),
    writeln("I know only:"),
    writeln("*Action adventure"),
    writeln("*Action RPG"),
    writeln("*Survival horror"),
    writeln("*Puzzle"),
    writeln("*Puzzle horror"),
    writeln("*First-person shooter"),
    writeln("*Survival"),
    writeln("*Adventure"),
    writeln("*Interactive game"),
    write("Write genre of the game: "),
    read_string(user_input, "\n", "", _, Genre),
    searchwithgenre(Genre), nl.

searchbyparameter(4):-
    writeln("You have chosen to search game by the year (from 1998 to 2021)"),
    write("Write the lower bound: "),
    nl,
    read_string(user_input, "\n", "", _, LYear),
    write("Write the upper bound: "),
    read_string(user_input, "\n", "", _, RYear),
    findyear(LYear, RYear), nl.
searchbyparameter(5):-
    writeln("There is a list of all games in the Data Base: "),
    printallgames.
searchbyparameter(6):-
    writeln("Goodbye, have a nice day"),
    halt.
searchbyparameter(_):- chooseparameter.

searchwithname(Name) :- \+ item(Name, _, _, _), !, writeln("Nothing found!"), chooseparameter.
searchwithname(Name):-
    item(Name, Par1, Par2, Par3),
    writeln("======================="),
    write("Name: "), writeln(Name),
    write("Studio: "), writeln(Par1),
    write("Genre: "), writeln(Par2),
    write("Year: "), writeln(Par3),
    writeln("======================="),
    fail.

searchwithstudio(Studio) :- \+ item(_, Studio, _, _), !, writeln("Nothing found!"), chooseparameter.
searchwithstudio(Studio):-
    item(Par1, Studio, Par2, Par3),
    writeln("======================="),
    write("Name: "), writeln(Par1),
    write("Studio: "), writeln(Studio),
    write("Genre: "), writeln(Par2),
    write("Year: "), writeln(Par3),
    writeln("======================="),
    fail.

searchwithgenre(Genre) :- \+ item(_, _, Genre, _), !, writeln("Nothing found!"), chooseparameter.
searchwithgenre(Genre):-
    item(Par1, Par2, Genre, Par3),
    writeln("======================="),
    write("Name: "), writeln(Par1),
    write("Studio: "), writeln(Par2),
    write("Genre: "), writeln(Genre),
    write("Year: "), writeln(Par3),
    writeln("======================="),
    fail.

printallgames:-
    item(Par1, Par2, Par3, Par4),
    writeln("======================="),
    write("Name: "), writeln(Par1),
    write("Studio: "), writeln(Par2),
    write("Genre: "), writeln(Par3),
    write("Year: "), writeln(Par4),
    writeln("======================="),
    fail.

findyear(LYear, RYear):-
    atom_number(LYear, NumL),
    atom_number(RYear, NumR),
    searchwithyear(NumL, NumR).
findyear(LYear, RYear):-
    \+atom_number(LYear, _),
    atom_number(RYear, NumR),
    searchwithyear(1998, NumR).
findyear(LYear, RYear):-
    atom_number(LYear, NumL),
    \+atom_number(RYear, _),
    searchwithyear(NumL, 2021).
findyear(LYear, RYear):-
    \+atom_number(LYear, _),
    \+atom_number(RYear, _),
    searchwithyear(1998, 2021).

searchwithyear(LYear, RYear):-
    between(LYear, RYear, Val),
    item(Par1, Par2, Par3, Val),
    writeln("======================="),
    write("Name: "), writeln(Par1),
    write("Studio: "), writeln(Par2),
    write("Genre: "), writeln(Par3),
    write("Year: "), writeln(Val),
    writeln("======================="),
    fail.

:- initialization(searchinit, main).









