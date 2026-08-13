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

val pos = ref 0
val eof = fn () => Tokens.EOF (!pos, !pos)

%%

%header (functor AdvancedTkbLexFun (structure Tokens : AdvancedTkb_TOKENS));

header=[A-Za-z0-9\.\_\ ];
alpha=[A-Za-z];
digit=[0-9];
ws=[\ \t];

%%

"\n"                       => (pos := (!pos + 1); lex ());
";;;".*                    => (lex ());
{ws}+                      => (lex ());
"DEFINE-PRIMITIVE-ROLE"    => (Tokens.DPR (!pos, !pos));
"define-primitive-role"    => (Tokens.DPR (!pos, !pos));
"defprimrole"              => (Tokens.DPR (!pos, !pos));
"DEFPRIMROLE"              => (Tokens.DPR (!pos, !pos));
"DEFINE-PRIMITIVE-CONCEPT" => (Tokens.DPC (!pos, !pos));
"define-primitive-concept" => (Tokens.DPC (!pos, !pos));
"defprimconcept"           => (Tokens.DPC (!pos, !pos));
"DEFPRIMCONCEPT"           => (Tokens.DPC (!pos, !pos));
"DEFINE-CONCEPT"           => (Tokens.DC (!pos, !pos));
"define-concept"           => (Tokens.DC (!pos, !pos));
"defconcept"               => (Tokens.DC (!pos, !pos));
"DEFCONCEPT"               => (Tokens.DC (!pos, !pos));
"DEFINE-INDIVIDUAL"        => (Tokens.DI (!pos, !pos));
"define-individual"        => (Tokens.DI (!pos, !pos));
"defindividual"            => (Tokens.DI (!pos, !pos));
"DEFINDIVIDUAL"            => (Tokens.DI (!pos, !pos));
"IMPLIES_C"                => (Tokens.IMPLIESC (!pos, !pos));
"implies_c"                => (Tokens.IMPLIESC (!pos, !pos));
"implies"                  => (Tokens.IMPLIESC (!pos, !pos));
"IMPLIES"                  => (Tokens.IMPLIESC (!pos, !pos));
"EQUAL_C"                  => (Tokens.EQUALC (!pos, !pos));
"equal_c"                  => (Tokens.EQUALC (!pos, !pos));
"ONE-OF"                   => (Tokens.ONEOF (!pos, !pos));
"one-of"                   => (Tokens.ONEOF (!pos, !pos));
"TRANSITIVE"               => (Tokens.TRANSITIVE (!pos, !pos));
"transitive"               => (Tokens.TRANSITIVE (!pos, !pos));
"REFLEXIVE"                => (Tokens.REFLEXIVE (!pos, !pos));
"reflexive"                => (Tokens.REFLEXIVE (!pos, !pos));
"SYMMETRIC"                => (Tokens.SYMMETRIC (!pos, !pos));
"symmetric"                => (Tokens.SYMMETRIC (!pos, !pos));
"SERIAL"                   => (Tokens.SERIAL (!pos, !pos));
"serial"                   => (Tokens.SERIAL (!pos, !pos));
"IMPLIES_R"                => (Tokens.IMPLIESR (!pos, !pos));
"implies_r"                => (Tokens.IMPLIESR (!pos, !pos));
"TOP"                      => (Tokens.TRUE (!pos, !pos));
"top"                      => (Tokens.TRUE (!pos, !pos));
"*TOP*"                    => (Tokens.TRUE (!pos, !pos));
"*top*"                    => (Tokens.TRUE (!pos, !pos));
"BOTTOM"                   => (Tokens.FALSE (!pos, !pos));
"bottom"                   => (Tokens.FALSE (!pos, !pos));
"*BOTTOM*"                 => (Tokens.FALSE (!pos, !pos));
"*bottom*"                 => (Tokens.FALSE (!pos, !pos));
"NOT"                      => (Tokens.NOT (!pos, !pos));
"not"                      => (Tokens.NOT (!pos, !pos));
"AND"                      => (Tokens.AND (!pos, !pos));
"and"                      => (Tokens.AND (!pos, !pos));
"OR"                       => (Tokens.OR (!pos, !pos));
"or"                       => (Tokens.OR (!pos, !pos));
"ALL"                      => (Tokens.BOX (!pos, !pos));
"all"                      => (Tokens.BOX (!pos, !pos));
"SOME"                     => (Tokens.DIA (!pos, !pos));
"some"                     => (Tokens.DIA (!pos, !pos));
{alpha}+{digit}*           => (Tokens.ATOM (yytext, !pos, !pos));
"("                        => (Tokens.LPAREN (!pos, !pos));
")"                        => (Tokens.RPAREN (!pos, !pos));
.                          => (print "WARNING: ignoring invalid character\n"; lex ());
