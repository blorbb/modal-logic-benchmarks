signature Intohylo_TOKENS =
sig
type ('a,'b) token
type svalue
val END:  'a * 'a -> (svalue,'a) token
val EOF:  'a * 'a -> (svalue,'a) token
val SEMI:  'a * 'a -> (svalue,'a) token
val AT:  'a * 'a -> (svalue,'a) token
val COLON:  'a * 'a -> (svalue,'a) token
val NEGDIFF:  'a * 'a -> (svalue,'a) token
val DIFF:  'a * 'a -> (svalue,'a) token
val EXISTS:  'a * 'a -> (svalue,'a) token
val ALL:  'a * 'a -> (svalue,'a) token
val DIMPL:  'a * 'a -> (svalue,'a) token
val IMPL:  'a * 'a -> (svalue,'a) token
val RCHEVRON:  'a * 'a -> (svalue,'a) token
val LCHEVRON:  'a * 'a -> (svalue,'a) token
val RBRACKET:  'a * 'a -> (svalue,'a) token
val LBRACKET:  'a * 'a -> (svalue,'a) token
val RPAREN:  'a * 'a -> (svalue,'a) token
val LPAREN:  'a * 'a -> (svalue,'a) token
val DIA:  'a * 'a -> (svalue,'a) token
val BOX:  'a * 'a -> (svalue,'a) token
val NOT:  'a * 'a -> (svalue,'a) token
val OR:  'a * 'a -> (svalue,'a) token
val AND:  'a * 'a -> (svalue,'a) token
val FALSE:  'a * 'a -> (svalue,'a) token
val TRUE:  'a * 'a -> (svalue,'a) token
val RELATION: (string) *  'a * 'a -> (svalue,'a) token
val NOMINAL: (string) *  'a * 'a -> (svalue,'a) token
val PROPOSITION: (string) *  'a * 'a -> (svalue,'a) token
end
signature Intohylo_LRVALS=
sig
structure Tokens : Intohylo_TOKENS
structure ParserData:PARSER_DATA
sharing type ParserData.Token.token = Tokens.token
sharing type ParserData.svalue = Tokens.svalue
end
