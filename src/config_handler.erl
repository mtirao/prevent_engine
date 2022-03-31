
-module(config_handler).
-behavior(cowboy_handler).

-export([init/2]).


init(Req0, State) ->
    Method = cowboy_req:method(Req0),
    Id = cowboy_req:binding(record_id, Req0),
    Req = application(Method, Id, Req0),
    {ok, Req, State}.


application(<<"GET">>, _, Req) ->
    cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        <<"Hello world!">>,
        Req);

application(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).