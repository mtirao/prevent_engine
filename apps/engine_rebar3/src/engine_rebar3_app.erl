%%%-------------------------------------------------------------------
%% @doc engine_rebar3 public API
%% @end
%%%-------------------------------------------------------------------

-module(engine_rebar3_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    %%Dispatch = cowboy_router:compile([
		%%{'_', [ {"/api/prevent/config", config_handler, []} ] } 
    %%]),
    %%{ok, _} = cowboy:start_clear(my_http_listener,
     %%   [{port, 8081}],
     %%   #{env => #{dispatch => Dispatch}}
	%%),
	engine_rebar3_sup:start_link().

stop(_State) ->
	ok.


%% internal functions
