(*****************************************************************************
 *  Author:
 *    Daniel N. Goetzmann <dngoetzmann@googlemail.com>
 *
 *  Copyright:
 *     Daniel N. Goetzmann, 2009
 *
 *  Last modified:
 *    $Date: 2009-06-22 23:59:07 +0200 (Mon, 22 Jun 2009) $
 *    $Author: goetzmann $
 *    $Revision: 460 $
 *
 *  This file is part of Spartacus,
 *  the tableau prover for hybrid logic
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 *****************************************************************************)


structure Tokens = Tokens

type pos = int
type svalue = Tokens.svalue
type ('a, 'b) token = ('a, 'b) Tokens.token
type lexresult = (svalue, pos) token

val pos = ref 1
val eof = fn () => Tokens.EOF (!pos, !pos)

%%

%header (functor OwlFsLexFun (structure Tokens : OwlFs_TOKENS));

alpha=[A-Za-z];
digit=[0-9];
ws=[\ \t];
anc=[A-Za-z0-9:];


%%


"\n"                       => (pos := (!pos + 1); lex ());
(["](([^"]|"\\"["])*)["])("^^")({anc}+) => (Tokens.T_XSTRING (yytext, !pos, !pos));
"//".*                     => (lex ());
{ws}+                      => (lex ());
"InverseOf"                => (Exn.error "Token \"InverseOf\" not supported");
"IntersectionOf"           => (Tokens.T_INTERSECTION_OF (!pos, !pos));
"UnionOf"                  => (Tokens.T_UNION_OF (!pos, !pos));
"ComplementOf"             => (Tokens.T_COMPLEMENT_OF (!pos, !pos));
"OneOf"                    => (Tokens.T_ONE_OF (!pos, !pos));
"DatatypeRestriction"      => (Exn.error "Token \"DatatypeRestriction\" not supported");
"SomeValuesFrom"           => (Tokens.T_SOME_VALUES_FROM (!pos, !pos));
"AllValuesFrom"            => (Tokens.T_ALL_VALUES_FROM (!pos, !pos));
"HasValue"                 => (Tokens.T_HAS_VALUE (!pos, !pos));
"HasSelf"                  => (Exn.error "Token \"HasSelf\" not supported");
"MinCardinality"           => (Exn.error "Token \"MinCardinality\" not supported");
"MaxCardinality"           => (Exn.error "Token \"MaxCardinality\" not supported");
"ExactCardinality"         => (Exn.error "Token \"ExactCardinality\" not supported");
"SubClassOf"               => (Tokens.T_SUB_CLASS_OF (!pos, !pos));
"EquivalentClasses"        => (Tokens.T_EQUIVALENT_CLASSES (!pos, !pos));
"DisjointClasses"          => (Tokens.T_DISJOINT_CLASSES (!pos, !pos));
"DisjointUnion"            => (Tokens.T_DISJOINT_UNION (!pos, !pos));
"SubPropertyOf"            => (Tokens.T_SUB_PROPERTY_OF (!pos, !pos));
"EquivalentProperties"     => (Exn.error "Token \"EquivalentProperties\" not supported");
"DisjointProperties"       => (Exn.error "Token \"DisjointProperties\" not supported");
"PropertyDomain"           => (Exn.error "Token \"PropertyDomain\" not supported");
"PropertyRange"            => (Exn.error "Token \"PropertyRange\" not supported");
"InverseProperties"        => (Exn.error "Token \"InverseProperties\" not supported");
"FunctionalProperty"       => (Exn.error "Token \"FunctionalProperty\" not supported");
"InverseFunctionalProperty" => (Exn.error "Token \"InverseFunctionalProperty\" not supported");
"ReflexiveProperty"        => (Tokens.T_REFLEXIVE_PROPERTY (!pos, !pos));
"IrreflexiveProperty"      => (Exn.error "Token \"IrreflexiveProperty\" not supported");
"SymmetricProperty"        => (Tokens.T_SYMMETRIC_PROPERTY (!pos, !pos));
"AsymmetricProperty"       => (Exn.error "Token \"AsymmetricProperties\" not supported");
"TransitiveProperty"       => (Tokens.T_TRANSITIVE_PROPERTY (!pos, !pos));
"HasKey"                   => (Exn.error "Token \"HasKey\" not supported");
"SameIndividual"           => (Tokens.T_SAME_INDIVIDUAL (!pos, !pos));
"SameIndividuals"          => (Tokens.T_SAME_INDIVIDUAL (!pos, !pos));
"DifferentIndividuals"     => (Tokens.T_DIFFERENT_INDIVIDUALS (!pos, !pos));
"DifferentIndividual"      => (Tokens.T_DIFFERENT_INDIVIDUALS (!pos, !pos));
"ClassAssertion"           => (Tokens.T_CLASS_ASSERTION (!pos, !pos));
"PropertyAssertion"        => (Tokens.T_PROPERTY_ASSERTION (!pos, !pos));
"NegativePropertyAssertion" => (Tokens.T_NEGATIVE_PROPERTY_ASSERTION (!pos, !pos));
"Namespace"                => (Tokens.T_NAMESPACE (!pos, !pos));
"Ontology"                 => (Tokens.T_ONTOLOGY (!pos, !pos));
"Imports"                  => (Tokens.T_IMPORTS (!pos, !pos));
"Import"                   => (Tokens.T_IMPORTS (!pos, !pos));
"Annotation"               => (Tokens.T_ANNOTATION (!pos, !pos));
"Import"                   => (Exn.error "Token \"Import\" not supported");
"Declaration"              => (Tokens.T_DECLARATION (!pos, !pos));
"Class"                    => (Tokens.T_CLASS (!pos, !pos));
"OWLClass"                 => (Tokens.T_CLASS (!pos, !pos));
"ObjectProperty"           => (Tokens.T_OBJECT_PROPERTY (!pos, !pos));
"AnnotationProperty"       => (Tokens.T_ANNOTATION_PROPERTY (!pos, !pos));
"NamedIndividual"          => (Tokens.T_NAMED_INDIVIDUAL (!pos, !pos));
"EntityAnnotation"         => (Tokens.T_ENTITY_ANNOTATION (!pos, !pos));
"Label"                    => (Tokens.T_LABEL (!pos, !pos));
"Comment"                  => (Tokens.T_COMMENT (!pos, !pos));
"owl:Thing"                => (Tokens.T_TOP (!pos, !pos));
"owl:Nothing"              => (Tokens.T_BOTTOM (!pos, !pos));
{digit}+                   => (Tokens.T_NON_NEGATIVE_INTEGER (yytext, !pos, !pos));
"("                        => (Tokens.T_LPAREN (!pos, !pos));
")"                        => (Tokens.T_RPAREN (!pos, !pos));
"="                        => (Tokens.T_EQS (!pos, !pos));
"ObjectIntersectionOf"     => (Tokens.T_INTERSECTION_OF (!pos, !pos));
"ObjectUnionOf"            => (Tokens.T_UNION_OF (!pos, !pos));
"ObjectComplementOf"       => (Tokens.T_COMPLEMENT_OF (!pos, !pos));
"ObjectOneOf"              => (Tokens.T_ONE_OF (!pos, !pos));
"ObjectSomeValuesFrom"     => (Tokens.T_SOME_VALUES_FROM (!pos, !pos));
"ObjectAllValuesFrom"      => (Tokens.T_ALL_VALUES_FROM (!pos, !pos));
"ObjectHasValue"           => (Tokens.T_HAS_VALUE (!pos, !pos));
"SubObjectPropertyOf"      => (Tokens.T_SUB_PROPERTY_OF (!pos, !pos));
"ReflexiveObjectProperty"  => (Tokens.T_REFLEXIVE_PROPERTY (!pos, !pos));
"IrreflexiveObjectProperty"=> (Exn.error "Token \"IrreflexiveProperty\" not supported");
"SymmetricObjectProperty"  => (Tokens.T_SYMMETRIC_PROPERTY (!pos, !pos));
"AsymmetricObjectProperty" => (Exn.error "Token \"AsymmetricProperties\" not supported");
"TransitiveObjectProperty" => (Tokens.T_TRANSITIVE_PROPERTY (!pos, !pos));
"ObjectPropertyAssertion"  => (Tokens.T_PROPERTY_ASSERTION (!pos, !pos));
"NegativeObjectPropertyAssertion" => (Tokens.T_NEGATIVE_PROPERTY_ASSERTION (!pos, !pos));
[^\n\t\ \b()="]+           => (Tokens.T_STRING (yytext, !pos, !pos));
.                          => (print "WARNING: ignoring invalid character\n"; lex ());
