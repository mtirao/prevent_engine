
-module(config_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Id = cowboy_req:binding(record_id, Req0),
    Req = application(Method, Id, Req0),
    {ok, Req, State}.


application(<<"GET">>, _, Req) ->
    Configs = config_json_handler:list(),
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Configs,
        Req);

application(<<"POST">>, _, Req) ->
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            Config = jsone:decode(Data),
            io:format("~p~n", [Config]),
            {ok, Result} = config_db_handler:create(Config),
                case Result of
                    {{_, _, _}, []} -> 
                        cowboy_req:reply(204, Req);
                    _ -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(<<"PUT">>, _, Req) ->
    HasBody = cowboy_req:has_body(Req),
    case HasBody of
        true ->  Length = cowboy_req:body_length(Req),
            {ok, Data, _} = cowboy_req:read_body(Req, #{length => Length}),
            Config = jsone:decode(Data),
            io:format("~p~n", [Config]),
            {ok, Result} = config_db_handler:update(Config),
                case Result of
                    {{_, _, _}, []} -> 
                        cowboy_req:reply(204, Req);
                    _ -> 
                        cowboy_req:reply(400, Req) 
                end;
        false -> cowboy_req:reply(400, Req)
    end;

application(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).