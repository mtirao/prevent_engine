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
            lists:foreach(fun(N) ->
                        maps:foreach(fun(Key, Value) -> io:format("Key:~s Encrypted: ~w",[binary_to_list(Key),Value]) end, N )
              end, Patients),
            io:format("~s~n", [Body]),
            no_data;
        {error, _} ->
            no_data
    end,
    timer:sleep(600000),
    server(ClinicPid).