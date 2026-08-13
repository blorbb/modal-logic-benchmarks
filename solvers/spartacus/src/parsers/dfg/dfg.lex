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

%header (functor DfgLexFun (structure Tokens : Dfg_TOKENS));

idsymbol=[A-Za-z0-9\_];
digit=[0-9];
ws=[\ \t];

%%

"\n"                   => (pos := (!pos + 1); lex ());
{ws}+                  => (lex ());
"box"                  => (Tokens.BOX (!pos, !pos));
"dia"                  => (Tokens.DIA (!pos, !pos));
"false"                => (Tokens.FALSE (!pos, !pos));
"true"                 => (Tokens.TRUE (!pos, !pos));
"and"                  => (Tokens.AND (!pos, !pos));
"or"                   => (Tokens.OR (!pos, !pos));
"implies"              => (Tokens.IMPL (!pos, !pos));
"not"                  => (Tokens.NOT (!pos, !pos));
"Axioms:"              => (Tokens.AXIOMS (!pos, !pos));
"Conjectures:"         => (Tokens.CONJECTURES (!pos, !pos));
"None."                => (Tokens.NONE (!pos, !pos));
"("                    => (Tokens.LPAREN (!pos, !pos));
")"                    => (Tokens.RPAREN (!pos, !pos));
{idsymbol}+            => (Tokens.VAR (yytext, !pos, !pos));
","                    => (Tokens.SEP (!pos, !pos));
"."                    => (Tokens.END (!pos, !pos));
.                      => (print "WARNING: ignoring invalid character\n"; lex ());
