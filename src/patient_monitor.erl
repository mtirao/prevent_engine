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
            {ok, Values} = config_db_handler:query("notification_count"),
            NotificationCount = notification_count(Values),
            notified_patient(NotificationCount, 0, Patients),
            no_data;
        {error, _} ->
            io:format("Patient server unreachable.~n"),
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
        length(Values) > 0 ->
            if 
                Count > Index ->
                    {ok, Status} = notify(hd(Values)),
                    if 
                        Status == sent -> notified_patient(Count, Index + 1, tl(Values));
                        true -> notified_patient(Count, Index, tl(Values))
                    end;
                true -> 
                    io:format("No more profile to notified~n")
            end;
        true ->
            io:format("No more profile to notified~n")
    end.


notify(Profile) ->
    ProfileId = maps:get(<<"profileid">>, Profile),
    PatientId = maps:get(<<"patientid">>, Profile),
    {ok, Values} = notification_db_handler:query(ProfileId),
    if
        length(Values) > 0 -> 
            {_, Date} = lists:nth(1, Values),
            DateSec = calendar:datetime_to_gregorian_seconds(Date),
            DateSecCurrent = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
            TimeDifSec = (DateSecCurrent - DateSec) / 86400,
            send_notification_with_frequency(TimeDifSec, ProfileId, PatientId);
        true -> 
            send_notification(ProfileId, PatientId),
            {ok, sent}
    end.
    
send_notification_with_frequency(TimeDiff, ProfileId, PatientId) ->
    {ok, Values} = config_db_handler:query("notification_frequency"),
    {_, _, ParameterValue} = lists:nth(1, Values),
    ValueText = binary_to_list(ParameterValue),
    Frequency = list_to_integer(ValueText),
    if 
        TimeDiff > Frequency -> 
            send_notification(ProfileId, PatientId),
            {ok, sent};
        true -> {ok, notsent}
    end.

send_notification(ProfileId, PatientId) ->
    {ok, ClinicPid} = gun:open("localhost", 4100),
    RequestBody = jsone:encode(#{<<"sent">> => #{<<"profileid">> => ProfileId, <<"patientid">> => PatientId}}),
    StreamRef = gun:post(ClinicPid, "/api/prevent/notified", [{<<"content-type">>, <<"application/json">>}], RequestBody),
    case gun:await(ClinicPid, StreamRef) of
        {response, fin, _, _} ->
                no_data;
        {response, nofin, ResponseCode, _} ->
            if 
                (ResponseCode >= 200) and (ResponseCode =< 299) ->
                    {ok, Body} = gun:await_body(ClinicPid, StreamRef),
                    Notification = jsone:decode(Body),
                    io:format("Server response: ~p~n", [Notification]),
                    notification_db_handler:create(ProfileId),
                    no_data;
                true ->
                    io:format("Not valid server response~n"),
                    no_data
            end;
        {error, _} ->
            io:format("Patient server unreachable.~n"),
            no_data
    end.