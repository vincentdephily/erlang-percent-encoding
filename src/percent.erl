-module(percent).

-export([url_encode/1, uri_encode/1, url_decode/1, uri_decode/1]).

-define(is_alphanum(C), C >= $A, C =< $Z; C >= $a, C =< $z; C >= $0, C =< $9).

%%
%% Percent encoding as defined by the application/x-www-form-urlencoded
%% content type (http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.1).
%%

url_encode(Str) when is_list(Str) ->
  url_encode(lists:reverse(Str, []), []).

url_encode([X | T], Acc) when ?is_alphanum(X); X =:= $-; X =:= $_; X =:= $. ->
  url_encode(T, [X | Acc]);
url_encode([32 | T], Acc) ->
  url_encode(T, [$+ | Acc]);
url_encode([X | T], Acc) ->
  NewAcc = [$%, hexchr_encode(X bsr 4), hexchr_encode(X band 16#0f) | Acc],
  url_encode(T, NewAcc);
url_encode([], Acc) ->
  Acc.

%%
%% Percent encoding as defined by RFC 3986 (http://tools.ietf.org/html/rfc3986).
%%

uri_encode(Str) when is_list(Str) ->
  uri_encode(lists:reverse(Str, []), []).

uri_encode([X | T], Acc) when ?is_alphanum(X); X =:= $-; X =:= $_; X =:= $.; X =:= $~ ->
  uri_encode(T, [X | Acc]);
uri_encode([X | T], Acc) ->
  NewAcc = [$%, hexchr_encode(X bsr 4), hexchr_encode(X band 16#0f) | Acc],
  uri_encode(T, NewAcc);
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
  Char = (hexchr_decode(A) bsl 4) + hexchr_decode(B),
  url_decode(T, [Char | Acc]);
url_decode([X | T], Acc) ->
  url_decode(T, [X | Acc]);
url_decode([], Acc) ->
  lists:reverse(Acc, []).

%%
%% Helper functions.
%%

-compile({inline, [{hexchr_encode, 1}, {hexchr_decode, 1}]}).

hexchr_encode(N) -> element(N+1, {$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E,$F}).

hexchr_decode(C) -> element(C+1, {e00,e01,e02,e03,e04,e05,e06,e07,e08,e09,e0a,e0b,e0c,e0d,e0e,e0f,
                                  e10,e11,e12,e13,e14,e15,e16,e17,e18,e19,e1a,e1b,e1c,e1d,e1e,e1f,
                                  e20,e21,e22,e23,e24,e25,e26,e27,e28,e29,e2a,e2b,e2c,e2d,e2e,e2f,
                                  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  e3a,e3b,e3c,e3d,e3e,e3f,
                                  e40,10, 11, 12, 13, 14, 15, e47,e48,e49,e4a,e4b,e4c,e4d,e4e,e4f,
                                  e50,e51,e52,e53,e54,e55,e56,e57,e58,e59,e5a,e5b,e5c,e5d,e5e,e5f,
                                  e60,10, 11, 12, 13, 14, 15, e67,e68,e69,e6a,e6b,e6c,e6d,e6e,e6f,
                                  e70,e71,e72,e73,e74,e75,e76,e77,e78,e79,e7a,e7b,e7c,e7d,e7e,e7f,
                                  e80,e81,e82,e83,e84,e85,e86,e87,e88,e89,e8a,e8b,e8c,e8d,e8e,e8f,
                                  e90,e91,e92,e93,e94,e95,e96,e97,e98,e99,e9a,e9b,e9c,e9d,e9e,e9f,
                                  ea0,ea1,ea2,ea3,ea4,ea5,ea6,ea7,ea8,ea9,eaa,eab,eac,ead,eae,eaf,
                                  eb0,eb1,eb2,eb3,eb4,eb5,eb6,eb7,eb8,eb9,eba,ebb,ebc,ebd,ebe,ebf,
                                  ec0,ec1,ec2,ec3,ec4,ec5,ec6,ec7,ec8,ec9,eca,ecb,ecc,ecd,ece,ecf,
                                  ed0,ed1,ed2,ed3,ed4,ed5,ed6,ed7,ed8,ed9,eda,edb,edc,edd,ede,edf,
                                  ee0,ee1,ee2,ee3,ee4,ee5,ee6,ee7,ee8,ee9,eea,eeb,eec,eed,eee,eef,
                                  ef0,ef1,ef2,ef3,ef4,ef5,ef6,ef7,ef8,ef9,efa,efb,efc,efd,efe,eff}).
