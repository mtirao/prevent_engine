-module(notification_db_handler).


-export([configs/0, create/1, query/1]).

connect() ->
    pgsql_connection:open("localhost", "prevent_engine", "mtirao", "").

close(Conn) ->
    pgsql_connection:close(Conn).

configs() ->
    Conn = connect(),
    Result = pgsql_connection:simple_query("select * from notification", Conn),
    close(Conn),
    {ok, Result}.
    
create(ProfileId) when is_integer(ProfileId) ->
    Date = erlang:localtime(),
    Conn = connect(),
    Result = pgsql_connection:extended_query("insert into notification(profile_id, date) values ($1, $2)", [ProfileId, Date], Conn),
    close(Conn),
    {ok, Result}.


query(ProfileId) when is_integer(ProfileId) ->
    Conn = connect(),
    {_, Result} = pgsql_connection:extended_query("select * FROM notification WHERE profile_id = $1 order by date desc", [ProfileId], Conn),
    close(Conn),
    {ok, Result}.
