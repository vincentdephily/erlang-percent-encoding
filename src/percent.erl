-module(percent).

-compile(export_all).

%%
%% Percent encoding as defined by the application/x-www-form-urlencoded
%% content type (http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.1).
%%

url_encode(Str) when list(Str) ->
  url_encode(lists:reverse(Str), []).

url_encode([X | T], Acc) when X >= $0, X =< $9 ->
  url_encode(T, [X | Acc]);
url_encode([X | T], Acc) when X >= $a, X =< $z ->
  url_encode(T, [X | Acc]);
url_encode([X | T], Acc) when X >= $A, X =< $Z ->
  url_encode(T, [X | Acc]);
url_encode([X | T], Acc) when X == $-; X == $_; X == $. ->
  url_encode(T, [X | Acc]);
url_encode([32 | T], Acc) ->
  url_encode(T, [$+ | Acc]);
url_encode([X | T], Acc) ->
  url_encode(T, [$%, hexchr(X bsr 4), hexchr(X band 16#0f) | Acc]);
url_encode([], Acc) ->
  Acc.

%%
%% Percent encoding as defined by RFC 3986 (http://tools.ietf.org/html/rfc3986).
%%

uri_encode(Str) when list(Str) ->
  uri_encode(lists:reverse(Str), []).

uri_encode([X | T], Acc) when X >= $0, X =< $9 ->
  uri_encode(T, [X | Acc]);
uri_encode([X | T], Acc) when X >= $a, X =< $z ->
  uri_encode(T, [X | Acc]);
uri_encode([X | T], Acc) when X >= $A, X =< $Z ->
  uri_encode(T, [X | Acc]);
uri_encode([X | T], Acc) when X == $-; X == $_; X == $.; X == $~ ->
  uri_encode(T, [X | Acc]);
uri_encode([X | T], Acc) ->
  uri_encode(T, [$%, hexchr(X bsr 4), hexchr(X band 16#0f) | Acc]);
uri_encode([], Acc) ->
  Acc.

%%
%% Percent decoding.
%%

url_decode(Str) when is_list(Str) ->
  url_decode(Str, []).

uri_decode(Str) when is_list(Str) ->
  url_decode(Str, []).

url_decode([$%, A, B | T], Acc) ->
  url_decode(T, [(hexchr_decode(A) * 16) + hexchr_decode(B) | Acc]);
url_decode([X | T], Acc) ->
  url_decode(T, [X | Acc]);
url_decode([], Acc) ->
  lists:reverse(Acc).

%%
%% Helper functions.
%%

hexchr(N) when N < 10 ->
  N + $0;
hexchr(N) -> 
  N + $A - 10.

hexchr_decode(C) when C >= $a ->
  C - $a + 10;
hexchr_decode(C) when C >= $A ->
  C - $A + 10;
hexchr_decode(C) ->
  C - $0.