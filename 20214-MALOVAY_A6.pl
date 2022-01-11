:- use_module(utils).
:- use_module(cost).
:- use_module(large_data).

% How to start?
% To start the program write swipl 20214-MalovAY_A6.pl
% All modules have to be in the same directory with this file

:- initialization (main).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init func
% Prepare environment for making schedule
% Start main_work
main:-
    writeln("TASK #6"),
    writeln("EXAM SCHEDULE"),
    clean,
    findall(ExamID, exam(ExamID, _), ExamIDs), % get all exams 
    prepare_env(ExamIDs), % prepare environment for work
    length(ExamIDs, N), % get number of all exams
    main_work(([], 0, 0), N), %start working
    writeln("POSSIBLE SCHEDULE WAS MADE"),
    writeln("BYE"),
    halt.

% Main cycle 
% @param S - current schedule
% @param L - length of the schedule
% @param H - value of priority func
% @param N - Curr node
main_work((S, L, H), N) :-
    L == N, % we can get the node
    print_data(S, H), % print data
    !.
main_work((S, L, H), N) :- 
    L < N, % we can't get to the node, process the queue
    get_neighbours((S, L, H), Neighbours), % get neighbours of the node and start call stack of predicates
    sort(2, =<, Neighbours, NeighboursSorted), % sort with cost
    get_head(NeighboursSorted, Cheapest), % get elem with cheapest cost
    main_work(Cheapest, N), !. % go to the next iteration of the cycle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WORKS WITH GRAPH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Making all event combinatons
% @param State - current exam schedule
% @param ExamIDS - identificators of exams
% @param Rooms - classrooms
% @param Result - there we store all event combinations
events_combinations((State, _, _), ExamIDS, Rooms, Result) :-
    !,
    cycle_exams(State, ExamIDS, Rooms, [], Result).

% Get node's neighbours
% @param CurNode - current node
% @param Neighbours - neighbours of the current node
get_neighbours(CurNode, Neigbours):-
    findall(ExamID, is_vacant_exam(ExamID, CurNode), ExamIDS), % get vacant exam
    findall(Room, is_vacant_room(Room), Rooms), % get vacant classroom
    events_combinations(CurNode, ExamIDS, Rooms, Events), % get all event combinations
    to_nodes(Events, CurNode, [], Nodes), % make them from events to nodes
    Neigbours = Nodes,
    !.

% Convert events to nodes
% @param first list - list of events
% @param second cortege - current schedule, length of schedule, value of priority func
% @param Helper - container
% @param Result - there we store result of work of this predicate
to_nodes([], _, Helper, Helper).
to_nodes([Event|Others], (S, L, H), Helper, Result) :-
    append(S, [Event], State),
    NewL is L + 1,
    cost(schedule(State), NewCost),
    append(Helper, [(State, NewL, NewCost)], Nodes),
    !,
    to_nodes(Others, (S, L, H), Nodes, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK SCHEDULE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Is this exam in the schedule
% @param State - current schedule
% @param ExamID - identificator of exam
is_in_schedule((State, _, _), ExamID) :-
    member(event(ExamID, _, _, _), State).

% Is there no such exam in the schedule
% @param ExamId - identificator of exam
% @param CurNode - current node (we need to check, do we already have node with this exam)
is_vacant_exam(ExamID, CurNode) :-
    exam(ExamID, _),
    not(is_in_schedule(CurNode, ExamID)).

% Is this room available
% @param RoomNum - number of the classrom
% @param Day - current date
% @param From - from what time it is avaliable
% @param Ending - till whaat time is it avaliable
is_vacant_room((RoomNum, Day, From, Ending)) :-
    classroom_available(RoomNum, Day, From, Ending).

% Is exam fits in the schedule of this classroom, and can all students sit in the classroom
% @param ExamID - identificator of the exam
% @param RoomNum - number of the classroom
% @param Day - day of the exam
% @param Start - starting time of the exam
is_in_time(ExamID, RoomNum, Day, Start) :-
    classroom_available(RoomNum, Day, From, Ending), 
    exam_duration(ExamID, Duration),
    Start > From,
    End is Start + Duration,
    End =< Ending,
    st_group(ExamID, Students),
    length(Students, Ammount),
    classroom_capacity(RoomNum, RoomCapacity),
    Ammount =< RoomCapacity.


% Is there time collision
% @param ExamID1 - identificator of the first exam to check for collision
% @param ExamID2 - identificator of the second exam to check for collision
% @param From1 - starting time of the first exam
% @param From2 - starting time of the second exam
time_collision(ExamID1, ExamID2, From1, From2):-
    exam_duration(ExamID1, Duration1),
    exam_duration(ExamID2, Duration2),
    Ending1 is From1 + Duration1,
    Ending2 is From2 + Duration2,
    (between(From1, Ending1, From2); 
    between(From2, Ending2, From1)).

% Check for collisions: 2 exams for one student, teacher, classroom
% @param first four parameters - parameters of the exam to check collision
% @param list - there stored all events
collision(ExamID1, _, Day1, From1, [event(ExamID2, _, Day2, From2)|_]):-
    Day1 == Day2,
    teacher_teaches_both_classes(ExamID1, ExamID2), % Check for teachers who has 2 exams in one day
    student_follows_both_classes(ExamID1, ExamID2), % Check for student who has 2 exams in one day
    time_collision(ExamID1, ExamID2, From1, From2).

collision(ExamID1, RoomNum1, Day1, From1, [event(ExamID2, RoomNum2, Day2, From2)|_]):-
    Day1 == Day2,
    RoomNum1 == RoomNum2, % Check for 2 exams in one auditory at the same time
    time_collision(ExamID1, ExamID2, From1, From2).

% No collision, go next iteration
% @param first four parameters - parameters of the exam to check collision
% @param list - there stored all events
collision(ExamID, RoomNum, Day, From, [_| OtherExams]) :-
    collision(ExamID, RoomNum, Day, From, OtherExams).


% It is an event, if there is no collisions and all aspects
% make exam possible in this day and room 
% @param CurState - current schedule
% @param last four - parameters of the exam
can_be_event(CurState, ExamID, RoomNum, Day, From) :-
    session(Day),
    is_in_time(ExamID, RoomNum, Day, From),
    not(collision(ExamID, RoomNum, Day, From, CurState)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CYCLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trying to find room for exam
% @param CurState - current schedule
% @param ExamID - identificator of the exam
% @param list - list with rooms, where stored date and avaliable time
% @param Helper - container
% @param Result - there is stored result of predicate's work
cycle_rooms(_, _, [], Helper, Helper).
cycle_rooms(CurState, ExamID, [(RoomNum, Day, From, Ending) | Others], Helper, Result) :-
    exam_duration(ExamID, Duration), % get exam duration
    Start is Ending - Duration, % get starting time
    cycle_exam_start(CurState, ExamID, RoomNum, Day, From, Start, [], Events), % trying to find room with starting time
    append(Helper, Events, NewHelper), % add to container
    !,
    cycle_rooms(CurState, ExamID, Others, NewHelper, Result). % recursively start new iteration

% trying to find room with starting time
% @param CurState - current schedule
% @param ExamID - identificator of the exam
% @param RoomNum - number of the classroom
% @param Day - date 
% @param CurStartTime - iterator for cycle
% @param Ending - ending of the exam
% @param Helper - container
% @param Result - there is stored predicate's work
cycle_exam_start(_, _, _ , _, From, Ending, Helper, Helper) :-
    From > Ending + 1.
cycle_exam_start(CurState, ExamID, RoomNum, Day, CurStartTime, Ending, Helper, Result):- 
    not(can_be_event(CurState, ExamID, RoomNum, Day, CurStartTime)), % can't be an event for this room with this current time
    !,
    NewStartTime is CurStartTime + 1, % inc start time
    cycle_exam_start(CurState, ExamID, RoomNum, Day, NewStartTime, Ending, Helper, Result). % recursively start new iteration for this room with new time
cycle_exam_start(CurState, ExamID, RoomNum, Day, CurStartTime, Ending, Helper, Result):-
    can_be_event(CurState, ExamID, RoomNum, Day, CurStartTime), % can be an event for this room with this current time
    append(Helper, [event(ExamID, RoomNum, Day, CurStartTime)], NewHelper), % add to the container
    !,
    NewStartTime is CurStartTime + 1, % inc start time
    cycle_exam_start(CurState, ExamID, RoomNum, Day, NewStartTime, Ending, NewHelper, Result). % recursively start new iteration for tthis room with new time


% Trying to find new exam for schedule
% @param CurState - current schedule
% @param list - list of exams
% @param Rooms - classrooms
% @param Helper - container
% @param Result - there is stored predicate's work
cycle_exams(_, [], _, Helper, Helper).
cycle_exams(CurState, [ExamID|Others], Rooms, Helper, Result):-
    !,
    cycle_rooms(CurState, ExamID, Rooms, [], Events), % trying to find a room for exam
    append(Helper, Events, NewHelper), % add to container event
    cycle_exams(CurState, Others, Rooms, NewHelper, Result). % recursively start new iteration


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%printing each exam
% @param list - list of events
print_exam([]).
print_exam([event(ExamID, RoomNum, Day, Beginnig)|Tail]) :-
    exam(ExamID, EName),
    writeln("----------------------------"),
    write("EXAM: "), writeln(EName),
    write("DATE: "), write(Day), writeln(".01"),
    write("BEGINNIG AT: "), writeln(Beginnig),
    exam_duration(ExamID, Duration),
    write("Duration: "), writeln(Duration),
    Ending is Beginnig + Duration,
    write("ENDING AT: "), writeln(Ending),
    write("ROOM: "), writeln(RoomNum),
    writeln("----------------------------"),
    !,
    print_exam(Tail).
% start printing results
% @param State - current schedule
% @param H - value of priority func
print_data(State, H) :-
    print_exam(State),
    nl,
    write("PENALTIES: "), writeln(H).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HELPERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print elements of the list
print_elems([]).
print_elems([H| T]) :-
    writeln(H),
    print_elems(T).
% Get head elem of the list
get_head([H|_], Head) :-
    Head = H,
    !.

% during that session
session(Day):-
    ex_season_starts(StartDay),
    ex_season_ends(EndDay),
    between(StartDay, EndDay, Day).
