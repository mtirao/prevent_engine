-module(db_handler).


-export([configs/0, create/1, update/1, query/1]).

connect() ->
    pgsql_connection:open("localhost", "prevent_engine", "mtirao", "").

close(Conn) ->
    pgsql_connection:close(Conn).

configs() ->
    Conn = connect(),
    Result = pgsql_connection:simple_query("select * from config", Conn),
    close(Conn),
    {ok, Result}.
    
create(Config) when is_map(Config) ->
    io:format("About to insert Config~n"),
    ParameterName = binary_to_list(maps:get(<<"parametername">>,Config)),
    ParameterValue = binary_to_list(maps:get(<<"parametervalue">>,Config)),
    io:format("~s~n", [ParameterName]),
    io:format("~s~n", [ParameterValue]),
    Conn = connect(),
    Result = pgsql_connection:extended_query("insert into config(parameter_name, parameter_value) values ($1, $2)", [ParameterName, ParameterValue], Conn),
    io:format("About to insert Event:~p~n", [Result]),
    close(Conn),
    {ok, Result}.

update(Config) when is_map(Config) ->
    io:format("About to update Config~n"),
    ParameterName = binary_to_list(maps:get(<<"parametername">>,Config)),
    ParameterValue = binary_to_list(maps:get(<<"parametervalue">>,Config)),
    io:format("~s~n", [ParameterName]),
    io:format("~s~n", [ParameterValue]),
    Conn = connect(),
    Result = pgsql_connection:extended_query("update config set parameter_value = $2 WHERE parameter_name = $1", [ParameterName, ParameterValue], Conn),
    io:format("About to update Event:~p~n", [Result]),
    close(Conn),
    {ok, Result}.

query(ParameterName) when is_list(ParameterName) ->
    io:format("Query config ~s~n", [ParameterName]),
    Conn = connect(),
    {_, Result} = pgsql_connection:extended_query("select * FROM config WHERE parameter_name = $1", [ParameterName], Conn),
    close(Conn),
    {ok, Result}.
