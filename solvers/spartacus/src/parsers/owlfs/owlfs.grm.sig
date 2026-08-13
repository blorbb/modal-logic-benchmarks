signature OwlFs_TOKENS =
sig
type ('a,'b) token
type svalue
val EOF:  'a * 'a -> (svalue,'a) token
val T_STRING: (string) *  'a * 'a -> (svalue,'a) token
val T_EQS:  'a * 'a -> (svalue,'a) token
val T_RPAREN:  'a * 'a -> (svalue,'a) token
val T_LPAREN:  'a * 'a -> (svalue,'a) token
val T_COMMENT:  'a * 'a -> (svalue,'a) token
val T_LABEL:  'a * 'a -> (svalue,'a) token
val T_ENTITY_ANNOTATION:  'a * 'a -> (svalue,'a) token
val T_NON_NEGATIVE_INTEGER: (string) *  'a * 'a -> (svalue,'a) token
val T_BOTTOM:  'a * 'a -> (svalue,'a) token
val T_TOP:  'a * 'a -> (svalue,'a) token
val T_NAMED_INDIVIDUAL:  'a * 'a -> (svalue,'a) token
val T_ANNOTATION_PROPERTY:  'a * 'a -> (svalue,'a) token
val T_OBJECT_PROPERTY:  'a * 'a -> (svalue,'a) token
val T_CLASS:  'a * 'a -> (svalue,'a) token
val T_DECLARATION:  'a * 'a -> (svalue,'a) token
val T_ANNOTATION:  'a * 'a -> (svalue,'a) token
val T_IMPORTS:  'a * 'a -> (svalue,'a) token
val T_ONTOLOGY:  'a * 'a -> (svalue,'a) token
val T_NAMESPACE:  'a * 'a -> (svalue,'a) token
val T_NEGATIVE_PROPERTY_ASSERTION:  'a * 'a -> (svalue,'a) token
val T_PROPERTY_ASSERTION:  'a * 'a -> (svalue,'a) token
val T_CLASS_ASSERTION:  'a * 'a -> (svalue,'a) token
val T_DIFFERENT_INDIVIDUALS:  'a * 'a -> (svalue,'a) token
val T_SAME_INDIVIDUAL:  'a * 'a -> (svalue,'a) token
val T_TRANSITIVE_PROPERTY:  'a * 'a -> (svalue,'a) token
val T_SYMMETRIC_PROPERTY:  'a * 'a -> (svalue,'a) token
val T_REFLEXIVE_PROPERTY:  'a * 'a -> (svalue,'a) token
val T_SUB_PROPERTY_OF:  'a * 'a -> (svalue,'a) token
val T_DISJOINT_UNION:  'a * 'a -> (svalue,'a) token
val T_DISJOINT_CLASSES:  'a * 'a -> (svalue,'a) token
val T_EQUIVALENT_CLASSES:  'a * 'a -> (svalue,'a) token
val T_SUB_CLASS_OF:  'a * 'a -> (svalue,'a) token
val T_HAS_VALUE:  'a * 'a -> (svalue,'a) token
val T_ALL_VALUES_FROM:  'a * 'a -> (svalue,'a) token
val T_SOME_VALUES_FROM:  'a * 'a -> (svalue,'a) token
val T_ONE_OF:  'a * 'a -> (svalue,'a) token
val T_COMPLEMENT_OF:  'a * 'a -> (svalue,'a) token
val T_UNION_OF:  'a * 'a -> (svalue,'a) token
val T_INTERSECTION_OF:  'a * 'a -> (svalue,'a) token
val T_XSTRING: (string) *  'a * 'a -> (svalue,'a) token
end
signature OwlFs_LRVALS=
sig
structure Tokens : OwlFs_TOKENS
structure ParserData:PARSER_DATA
sharing type ParserData.Token.token = Tokens.token
sharing type ParserData.svalue = Tokens.svalue
end
