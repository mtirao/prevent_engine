-module(config_json_handler).

-export([list/0]).

%convert_date_to_string(Datetime) ->
%    L = qdate:to_string("Y-m-d h:ia", Datetime),
%    lists:flatten([io_lib:format("~c", [V]) || V <- L]).

list() -> 
    {ok, {{_, Count}, Columns}} = config_db_handler:configs(),
    Function = fun({Id, Parameter_Name, Parameter_Value}, Acc) ->  [#{id => Id, parametername => Parameter_Name, parametervalue => Parameter_Value} | Acc] end,
    Values = lists:foldl(Function, [], Columns),
    binary_to_list(jsone:encode(#{count => Count, configs => Values})).
