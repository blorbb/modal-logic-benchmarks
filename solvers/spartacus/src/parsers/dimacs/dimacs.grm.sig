signature Dimacs_TOKENS =
sig
type ('a,'b) token
type svalue
val P:  'a * 'a -> (svalue,'a) token
val CNF:  'a * 'a -> (svalue,'a) token
val SAT:  'a * 'a -> (svalue,'a) token
val END:  'a * 'a -> (svalue,'a) token
val EOF:  'a * 'a -> (svalue,'a) token
val ZERO:  'a * 'a -> (svalue,'a) token
val RPAREN:  'a * 'a -> (svalue,'a) token
val LPAREN:  'a * 'a -> (svalue,'a) token
val EQUAL:  'a * 'a -> (svalue,'a) token
val XOR:  'a * 'a -> (svalue,'a) token
val NOT:  'a * 'a -> (svalue,'a) token
val OR:  'a * 'a -> (svalue,'a) token
val AND:  'a * 'a -> (svalue,'a) token
val VAR: (string) *  'a * 'a -> (svalue,'a) token
end
signature Dimacs_LRVALS=
sig
structure Tokens : Dimacs_TOKENS
structure ParserData:PARSER_DATA
sharing type ParserData.Token.token = Tokens.token
sharing type ParserData.svalue = Tokens.svalue
end
