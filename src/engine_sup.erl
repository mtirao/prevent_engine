-module(engine_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Child =#{id => patient_monitor,
			start => {patient_monitor, start_link, []}},
	Procs = [Child],
	{ok, {{one_for_one, 1, 5}, Procs}}.


