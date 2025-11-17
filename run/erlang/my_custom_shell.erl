-module(my_custom_shell).
-export([start/2]).

start(Args, UserSwitch) ->
    % 自定义 I/O 处理逻辑
    io:format("Custom shell started!~n"),
    loop().

loop() ->
    receive
        {io_request, From, ReplyAs, Request} ->
            % 处理 I/O 请求
            io:reply(ReplyAs, ok),
            loop();
        _ ->
            loop()
    end.