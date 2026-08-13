signature Parser_TOKENS =
sig
type ('a,'b) token
type svalue
val SEMI:  'a * 'a -> (svalue,'a) token
val EOF:  'a * 'a -> (svalue,'a) token
val SERIAL:  'a * 'a -> (svalue,'a) token
val TRANSITIVE:  'a * 'a -> (svalue,'a) token
val REFLEXIVE:  'a * 'a -> (svalue,'a) token
val AST:  'a * 'a -> (svalue,'a) token
val COLON:  'a * 'a -> (svalue,'a) token
val SEP:  'a * 'a -> (svalue,'a) token
val RBRACE:  'a * 'a -> (svalue,'a) token
val LBRACE:  'a * 'a -> (svalue,'a) token
val RCHEVRON:  'a * 'a -> (svalue,'a) token
val LCHEVRON:  'a * 'a -> (svalue,'a) token
val RBRACKET:  'a * 'a -> (svalue,'a) token
val LBRACKET:  'a * 'a -> (svalue,'a) token
val RPAREN:  'a * 'a -> (svalue,'a) token
val LPAREN:  'a * 'a -> (svalue,'a) token
val EQ:  'a * 'a -> (svalue,'a) token
val AT:  'a * 'a -> (svalue,'a) token
val NEGDIFF:  'a * 'a -> (svalue,'a) token
val DIFF:  'a * 'a -> (svalue,'a) token
val EXISTS:  'a * 'a -> (svalue,'a) token
val ALL:  'a * 'a -> (svalue,'a) token
val NOT:  'a * 'a -> (svalue,'a) token
val DIMPL:  'a * 'a -> (svalue,'a) token
val IMPL:  'a * 'a -> (svalue,'a) token
val OR:  'a * 'a -> (svalue,'a) token
val AND:  'a * 'a -> (svalue,'a) token
val FALSE:  'a * 'a -> (svalue,'a) token
val TRUE:  'a * 'a -> (svalue,'a) token
val VAR: (string) *  'a * 'a -> (svalue,'a) token
end
signature Parser_LRVALS=
sig
structure Tokens : Parser_TOKENS
structure ParserData:PARSER_DATA
sharing type ParserData.Token.token = Tokens.token
sharing type ParserData.svalue = Tokens.svalue
end
