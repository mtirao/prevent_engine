-module(patient_monitor).

-export([start_link/0]).


start_link() ->
    %%application:ensure_all_started(gun),
    {ok, ClinicPid} = gun:open("localhost", 3200),
    server(ClinicPid).

server(ClinicPid) ->
    StreamRef = gun:get(ClinicPid, "/api/prevent/new/patients"),
    case gun:await(ClinicPid, StreamRef) of
        {response, fin, _, _} ->
                no_data;
        {response, nofin, _, _} ->
            {ok, Body} = gun:await_body(ClinicPid, StreamRef),
            Patients = jsone:decode(Body),
            {ok, Values} = db_handler:query("notification_count"),
            NotificationCount = notification_count(Values),
            io:format("Notification count: ~p~n", [NotificationCount]),
            io:format("Patients: ~p~n", [Patients]),
            notified_patient(NotificationCount, 0, Patients),
            no_data;
        {error, _} ->
            no_data
    end,
    timer:sleep(600000),
    server(ClinicPid).

notification_count(Values) ->
    NotificationCountTuple = lists:nth(1, Values),
    Value = lists:nth(3,tuple_to_list(NotificationCountTuple)),
    ValueText = binary_to_list(Value),
    list_to_integer(ValueText).

notified_patient(Count, Index, Values) ->
  
    if 
        Count > Index ->
            notify(hd(Values)),
            notified_patient(Count, Index + 1, tl(Values));
        true -> 
            io:format("No more profile to notified")
    end.


notify(Profile) ->
    io:format("Notified profile: ~p~n", [maps:get(<<"profileid">>, Profile)]).