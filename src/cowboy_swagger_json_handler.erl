%%% @doc Cowboy Swagger Handler. This handler exposes a GET operation
%%%      to enable `swagger.json' to be retrieved from embedded
%%%      Swagger-UI (located in `priv/swagger' folder).
-module(cowboy_swagger_json_handler).

%% Cowboy callbacks
-export([ init/2
        , content_types_provided/2
        ]).

-behaviour(cowboy_rest).

%% Handlers
-export([handle_get/2]).

-type options() :: #{ server => ranch:ref()
                    , host   => cowboy_swagger_handler:route_match()
                    , _ => _
                    }.
-export_type([options/0]).

-type state() :: options().

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Cowboy Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @hidden
-spec init(cowboy_req:req(), options()) ->
  {cowboy_rest, cowboy_req:req(), state()}.
init(Req, Opts) ->
  State = Opts,
  {cowboy_rest, Req, State}.

%% @hidden
-spec content_types_provided(cowboy_req:req(), state()) ->
  {[{binary(), atom()}], cowboy_req:req(), state()}.
content_types_provided(Req, State) ->
  {[{<<"application/json">>, handle_get}], Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Handlers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @hidden
-spec handle_get(cowboy_req:req(), state()) ->
  {iodata(), cowboy_req:req(), state()}.
handle_get(Req, State) ->
  Server = maps:get(server, State, '_'),
  HostMatch = maps:get(host, State, '_'),
  Trails = trails:all(Server, HostMatch),
  {ok,Root_app} = application:get_env(cowboy_swagger,root_app),
  Path = code:priv_dir(Root_app),
  {ok, Yaml_file} = file:read_file(Path ++ "/swagger.yaml"),
  File = unicode:characters_to_list(Yaml_file),
  {File, Req, State}.
  
%   {cowboy_swagger:to_json(Trails), Req, State}.
