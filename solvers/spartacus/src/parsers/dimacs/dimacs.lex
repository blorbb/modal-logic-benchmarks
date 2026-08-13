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

%header (functor DimacsLexFun (structure Tokens : Dimacs_TOKENS));

alpha=[a-z];
digit=[0-9];
posdi=[1-9];
ws=[\ \t];

%%

{ws}+                    => (lex ());
"\n"                     => (pos := (!pos + 1); lex ());
("c").*                  => (lex ());
"0"                      => (Tokens.ZERO (!pos, !pos));
{posdi}{digit}*          => (Tokens.VAR (yytext, !pos, !pos));
"-"                      => (Tokens.NOT (!pos, !pos));
"+"                      => (Tokens.OR (!pos, !pos));
"*"                      => (Tokens.AND (!pos, !pos));
"xor"                    => (Tokens.XOR (!pos, !pos));
"="                      => (Tokens.EQUAL (!pos, !pos));
"("                      => (Tokens.LPAREN (!pos, !pos));
")"                      => (Tokens.RPAREN (!pos, !pos));
"p"{ws}+"cnf".*          => (Tokens.CNF (!pos, !pos));
"p"{ws}+"sat".*          => (Tokens.CNF (!pos, !pos));
.                        => (print "WARNING: ignoring invalid character\n"; lex ());
