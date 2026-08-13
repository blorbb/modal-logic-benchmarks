signature Dfg_TOKENS =
sig
type ('a,'b) token
type svalue
val END:  'a * 'a -> (svalue,'a) token
val EOF:  'a * 'a -> (svalue,'a) token
val NONE:  'a * 'a -> (svalue,'a) token
val CONJECTURES:  'a * 'a -> (svalue,'a) token
val AXIOMS:  'a * 'a -> (svalue,'a) token
val SEP:  'a * 'a -> (svalue,'a) token
val RPAREN:  'a * 'a -> (svalue,'a) token
val LPAREN:  'a * 'a -> (svalue,'a) token
val BOX:  'a * 'a -> (svalue,'a) token
val DIA:  'a * 'a -> (svalue,'a) token
val NOT:  'a * 'a -> (svalue,'a) token
val IMPL:  'a * 'a -> (svalue,'a) token
val OR:  'a * 'a -> (svalue,'a) token
val AND:  'a * 'a -> (svalue,'a) token
val FALSE:  'a * 'a -> (svalue,'a) token
val TRUE:  'a * 'a -> (svalue,'a) token
val VAR: (string) *  'a * 'a -> (svalue,'a) token
end
signature Dfg_LRVALS=
sig
structure Tokens : Dfg_TOKENS
structure ParserData:PARSER_DATA
sharing type ParserData.Token.token = Tokens.token
sharing type ParserData.svalue = Tokens.svalue
end
