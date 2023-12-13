%%%-------------------------------------------------------------------
%% @doc engine_rebar3 top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(engine_rebar3_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
	Procs = [],
	{ok, {{one_for_one, 1, 5}, Procs}}.
   %% Child =#{id => patient_monitor,
	%		start => {patient_monitor, start_link, []}},
	%%Procs = [Child],
	%%{ok, {{one_for_one, 1, 5}, Procs}}.



%% internal functions
