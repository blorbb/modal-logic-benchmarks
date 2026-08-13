signature AdvancedTkb_TOKENS =
sig
type ('a,'b) token
type svalue
val EOF:  'a * 'a -> (svalue,'a) token
val IMPLIESR:  'a * 'a -> (svalue,'a) token
val SYMMETRIC:  'a * 'a -> (svalue,'a) token
val SERIAL:  'a * 'a -> (svalue,'a) token
val REFLEXIVE:  'a * 'a -> (svalue,'a) token
val TRANSITIVE:  'a * 'a -> (svalue,'a) token
val ONEOF:  'a * 'a -> (svalue,'a) token
val EQUALC:  'a * 'a -> (svalue,'a) token
val IMPLIESC:  'a * 'a -> (svalue,'a) token
val DI:  'a * 'a -> (svalue,'a) token
val DC:  'a * 'a -> (svalue,'a) token
val DPC:  'a * 'a -> (svalue,'a) token
val DPR:  'a * 'a -> (svalue,'a) token
val RPAREN:  'a * 'a -> (svalue,'a) token
val LPAREN:  'a * 'a -> (svalue,'a) token
val DIA:  'a * 'a -> (svalue,'a) token
val BOX:  'a * 'a -> (svalue,'a) token
val NOT:  'a * 'a -> (svalue,'a) token
val OR:  'a * 'a -> (svalue,'a) token
val AND:  'a * 'a -> (svalue,'a) token
val FALSE:  'a * 'a -> (svalue,'a) token
val TRUE:  'a * 'a -> (svalue,'a) token
val ATOM: (string) *  'a * 'a -> (svalue,'a) token
end
signature AdvancedTkb_LRVALS=
sig
structure Tokens : AdvancedTkb_TOKENS
structure ParserData:PARSER_DATA
sharing type ParserData.Token.token = Tokens.token
sharing type ParserData.svalue = Tokens.svalue
end
