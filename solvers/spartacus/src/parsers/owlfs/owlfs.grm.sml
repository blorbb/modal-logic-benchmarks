functor OwlFsLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : OwlFs_TOKENS
   end
 = 
struct
structure ParserData=
struct
structure Header = 
struct
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


fun disjointClasses (x::y::nil) = Parsetree.disj (Parsetree.neg x) (Parsetree.neg y)
  | disjointClasses (x::xr) =
		Parsetree.conj
			(Parsetree.disj (Parsetree.neg x) (Parsetree.mconj (map Parsetree.neg xr)))
			(disjointClasses xr)
  | disjointClasses _ = Exn.unexpArg "OwlFs.grm.disjointClasses"

fun disjointUnion c xr =
	Parsetree.conj
		(Parsetree.dimpl c (Parsetree.mdisj xr))
		(disjointClasses xr)

fun sameIndividual (x::xr) = Parsetree.AT (x, Parsetree.mconj (map Parsetree.NOMINAL xr))
  | sameIndividual nil = Exn.unexpArg "OwlFs.grm.sameIndividual"

fun differentIndividuals xs =
	let
		fun f x y = if x = y then NONE else SOME (Parsetree.NEG (Parsetree.NOMINAL y))
		
		fun g x = Parsetree.AT (x, Parsetree.mconj (List.mapPartial (f x) xs))
	in
		Parsetree.mconj (map g xs)
	end


end
structure LrTable = Token.LrTable
structure Token = Token
local open LrTable in 
val table=let val actionRows =
"\
\\001\000\001\000\014\000\039\000\013\000\040\000\012\000\000\000\
\\001\000\001\000\027\000\002\000\167\000\003\000\166\000\004\000\165\000\
\\005\000\164\000\006\000\163\000\007\000\162\000\008\000\161\000\
\\031\000\151\000\032\000\150\000\038\000\228\000\040\000\022\000\000\000\
\\001\000\001\000\027\000\002\000\167\000\003\000\166\000\004\000\165\000\
\\005\000\164\000\006\000\163\000\007\000\162\000\008\000\161\000\
\\031\000\151\000\032\000\150\000\040\000\022\000\000\000\
\\001\000\001\000\027\000\027\000\131\000\028\000\130\000\030\000\129\000\
\\040\000\022\000\000\000\
\\001\000\001\000\027\000\031\000\151\000\032\000\150\000\040\000\022\000\000\000\
\\001\000\001\000\027\000\040\000\022\000\000\000\
\\001\000\001\000\031\000\040\000\030\000\000\000\
\\001\000\023\000\007\000\000\000\
\\001\000\027\000\131\000\028\000\130\000\030\000\129\000\000\000\
\\001\000\037\000\009\000\000\000\
\\001\000\037\000\010\000\000\000\
\\001\000\037\000\072\000\000\000\
\\001\000\037\000\073\000\000\000\
\\001\000\037\000\074\000\000\000\
\\001\000\037\000\075\000\000\000\
\\001\000\037\000\080\000\000\000\
\\001\000\037\000\081\000\000\000\
\\001\000\037\000\082\000\000\000\
\\001\000\037\000\083\000\000\000\
\\001\000\037\000\084\000\000\000\
\\001\000\037\000\085\000\000\000\
\\001\000\037\000\086\000\000\000\
\\001\000\037\000\087\000\000\000\
\\001\000\037\000\088\000\000\000\
\\001\000\037\000\089\000\000\000\
\\001\000\037\000\090\000\000\000\
\\001\000\037\000\091\000\000\000\
\\001\000\037\000\092\000\000\000\
\\001\000\037\000\093\000\000\000\
\\001\000\037\000\094\000\000\000\
\\001\000\037\000\174\000\000\000\
\\001\000\037\000\175\000\000\000\
\\001\000\037\000\176\000\000\000\
\\001\000\037\000\194\000\000\000\
\\001\000\037\000\195\000\000\000\
\\001\000\037\000\196\000\000\000\
\\001\000\037\000\197\000\000\000\
\\001\000\037\000\198\000\000\000\
\\001\000\037\000\199\000\000\000\
\\001\000\037\000\200\000\000\000\
\\001\000\038\000\077\000\000\000\
\\001\000\038\000\079\000\000\000\
\\001\000\038\000\102\000\000\000\
\\001\000\038\000\123\000\000\000\
\\001\000\038\000\125\000\000\000\
\\001\000\038\000\126\000\000\000\
\\001\000\038\000\132\000\000\000\
\\001\000\038\000\171\000\000\000\
\\001\000\038\000\172\000\000\000\
\\001\000\038\000\173\000\000\000\
\\001\000\038\000\179\000\000\000\
\\001\000\038\000\187\000\000\000\
\\001\000\038\000\188\000\000\000\
\\001\000\038\000\189\000\000\000\
\\001\000\038\000\207\000\000\000\
\\001\000\038\000\211\000\000\000\
\\001\000\038\000\212\000\000\000\
\\001\000\038\000\214\000\000\000\
\\001\000\038\000\215\000\000\000\
\\001\000\038\000\216\000\000\000\
\\001\000\038\000\229\000\000\000\
\\001\000\038\000\230\000\000\000\
\\001\000\038\000\231\000\000\000\
\\001\000\038\000\232\000\000\000\
\\001\000\038\000\233\000\000\000\
\\001\000\038\000\234\000\000\000\
\\001\000\038\000\236\000\000\000\
\\001\000\038\000\242\000\000\000\
\\001\000\038\000\246\000\000\000\
\\001\000\038\000\247\000\000\000\
\\001\000\038\000\248\000\000\000\
\\001\000\038\000\249\000\000\000\
\\001\000\038\000\252\000\000\000\
\\001\000\038\000\253\000\000\000\
\\001\000\038\000\254\000\000\000\
\\001\000\039\000\028\000\000\000\
\\001\000\041\000\000\000\000\000\
\\000\001\000\000\
\\001\001\000\000\
\\002\001\000\000\
\\003\001\000\000\
\\004\001\000\000\
\\005\001\000\000\
\\006\001\000\000\
\\007\001\000\000\
\\008\001\000\000\
\\009\001\000\000\
\\010\001\000\000\
\\011\001\000\000\
\\012\001\000\000\
\\013\001\000\000\
\\014\001\000\000\
\\015\001\009\000\066\000\010\000\065\000\011\000\064\000\012\000\063\000\
\\013\000\062\000\014\000\061\000\015\000\060\000\016\000\059\000\
\\017\000\058\000\018\000\057\000\019\000\056\000\020\000\055\000\
\\021\000\054\000\026\000\053\000\034\000\052\000\000\000\
\\016\001\000\000\
\\017\001\000\000\
\\018\001\000\000\
\\019\001\000\000\
\\020\001\000\000\
\\021\001\000\000\
\\022\001\000\000\
\\023\001\000\000\
\\024\001\000\000\
\\025\001\000\000\
\\026\001\000\000\
\\027\001\000\000\
\\028\001\000\000\
\\029\001\000\000\
\\030\001\000\000\
\\031\001\000\000\
\\032\001\000\000\
\\033\001\000\000\
\\034\001\000\000\
\\035\001\000\000\
\\036\001\000\000\
\\037\001\000\000\
\\038\001\000\000\
\\039\001\000\000\
\\040\001\000\000\
\\041\001\000\000\
\\042\001\000\000\
\\043\001\000\000\
\\044\001\000\000\
\\045\001\000\000\
\\046\001\000\000\
\\047\001\000\000\
\\048\001\000\000\
\\049\001\000\000\
\\050\001\000\000\
\\051\001\000\000\
\\052\001\000\000\
\\053\001\000\000\
\\054\001\000\000\
\\055\001\000\000\
\\056\001\000\000\
\\057\001\000\000\
\\058\001\000\000\
\\059\001\000\000\
\\060\001\000\000\
\\061\001\000\000\
\\062\001\000\000\
\\063\001\000\000\
\\064\001\000\000\
\\065\001\000\000\
\\066\001\000\000\
\\067\001\000\000\
\\068\001\000\000\
\\069\001\000\000\
\\070\001\000\000\
\\071\001\000\000\
\\072\001\000\000\
\\073\001\000\000\
\\074\001\000\000\
\\075\001\000\000\
\\076\001\000\000\
\\077\001\000\000\
\\078\001\000\000\
\\079\001\000\000\
\\080\001\000\000\
\\081\001\000\000\
\\082\001\000\000\
\\083\001\000\000\
\\084\001\001\000\027\000\002\000\167\000\003\000\166\000\004\000\165\000\
\\005\000\164\000\006\000\163\000\007\000\162\000\008\000\161\000\
\\031\000\151\000\032\000\150\000\040\000\022\000\000\000\
\\085\001\000\000\
\\086\001\001\000\027\000\040\000\022\000\000\000\
\\087\001\000\000\
\\088\001\025\000\025\000\035\000\024\000\036\000\023\000\000\000\
\\089\001\000\000\
\\090\001\022\000\005\000\000\000\
\\091\001\000\000\
\\092\001\001\000\027\000\024\000\026\000\025\000\025\000\035\000\024\000\
\\036\000\023\000\040\000\022\000\000\000\
\\092\001\024\000\026\000\025\000\025\000\035\000\024\000\036\000\023\000\000\000\
\\093\001\000\000\
\\094\001\000\000\
\\095\001\000\000\
\\096\001\000\000\
\\097\001\000\000\
\\098\001\000\000\
\\099\001\000\000\
\\100\001\000\000\
\\101\001\000\000\
\\102\001\000\000\
\"
val actionRowNumbers =
"\167\000\007\000\167\000\009\000\
\\083\000\010\000\168\000\000\000\
\\169\000\075\000\079\000\006\000\
\\080\000\100\000\099\000\092\000\
\\170\000\170\000\169\000\089\000\
\\081\000\011\000\012\000\013\000\
\\014\000\082\000\006\000\040\000\
\\077\000\078\000\127\000\153\000\
\\152\000\151\000\150\000\149\000\
\\126\000\143\000\142\000\141\000\
\\140\000\125\000\131\000\130\000\
\\129\000\128\000\124\000\092\000\
\\123\000\041\000\015\000\016\000\
\\017\000\018\000\019\000\020\000\
\\021\000\022\000\023\000\024\000\
\\025\000\026\000\027\000\028\000\
\\029\000\172\000\171\000\092\000\
\\170\000\090\000\005\000\005\000\
\\005\000\005\000\042\000\084\000\
\\093\000\086\000\165\000\165\000\
\\165\000\165\000\165\000\005\000\
\\005\000\165\000\165\000\165\000\
\\165\000\165\000\165\000\165\000\
\\165\000\043\000\092\000\044\000\
\\180\000\045\000\003\000\046\000\
\\085\000\008\000\173\000\165\000\
\\098\000\008\000\005\000\005\000\
\\005\000\105\000\005\000\106\000\
\\005\000\005\000\005\000\005\000\
\\005\000\004\000\002\000\002\000\
\\002\000\087\000\047\000\178\000\
\\177\000\048\000\049\000\030\000\
\\031\000\032\000\091\000\165\000\
\\166\000\050\000\005\000\107\000\
\\104\000\005\000\002\000\163\000\
\\163\000\051\000\052\000\053\000\
\\005\000\144\000\002\000\103\000\
\\102\000\101\000\115\000\114\000\
\\113\000\112\000\111\000\110\000\
\\109\000\002\000\108\000\033\000\
\\034\000\035\000\036\000\037\000\
\\038\000\039\000\002\000\002\000\
\\133\000\088\000\176\000\179\000\
\\005\000\005\000\004\000\054\000\
\\174\000\094\000\005\000\154\000\
\\005\000\055\000\056\000\163\000\
\\057\000\148\000\147\000\146\000\
\\058\000\059\000\002\000\161\000\
\\005\000\005\000\005\000\005\000\
\\002\000\002\000\002\000\001\000\
\\060\000\134\000\061\000\062\000\
\\063\000\175\000\064\000\155\000\
\\065\000\158\000\157\000\164\000\
\\156\000\145\000\138\000\161\000\
\\066\000\161\000\005\000\002\000\
\\002\000\163\000\067\000\002\000\
\\002\000\161\000\135\000\132\000\
\\097\000\096\000\095\000\160\000\
\\159\000\139\000\137\000\162\000\
\\068\000\069\000\070\000\071\000\
\\118\000\161\000\161\000\072\000\
\\122\000\121\000\120\000\119\000\
\\073\000\074\000\136\000\117\000\
\\116\000\076\000"
val gotoT =
"\
\\004\000\253\000\005\000\002\000\054\000\001\000\000\000\
\\006\000\004\000\000\000\
\\005\000\002\000\054\000\006\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\002\000\009\000\000\000\
\\003\000\019\000\007\000\018\000\009\000\017\000\028\000\016\000\
\\055\000\015\000\059\000\014\000\060\000\013\000\000\000\
\\000\000\
\\000\000\
\\001\000\027\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\010\000\049\000\011\000\048\000\026\000\047\000\029\000\046\000\
\\030\000\045\000\033\000\044\000\034\000\043\000\035\000\042\000\
\\037\000\041\000\039\000\040\000\040\000\039\000\041\000\038\000\
\\042\000\037\000\043\000\036\000\046\000\035\000\047\000\034\000\
\\048\000\033\000\049\000\032\000\050\000\031\000\058\000\030\000\000\000\
\\009\000\017\000\028\000\016\000\055\000\065\000\059\000\014\000\
\\060\000\013\000\000\000\
\\009\000\017\000\028\000\016\000\055\000\066\000\059\000\014\000\
\\060\000\013\000\000\000\
\\003\000\069\000\008\000\068\000\009\000\017\000\028\000\016\000\
\\055\000\067\000\059\000\014\000\060\000\013\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\001\000\074\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\010\000\076\000\011\000\048\000\026\000\047\000\029\000\046\000\
\\030\000\045\000\033\000\044\000\034\000\043\000\035\000\042\000\
\\037\000\041\000\039\000\040\000\040\000\039\000\041\000\038\000\
\\042\000\037\000\043\000\036\000\046\000\035\000\047\000\034\000\
\\048\000\033\000\049\000\032\000\050\000\031\000\058\000\030\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\010\000\093\000\011\000\048\000\026\000\047\000\029\000\046\000\
\\030\000\045\000\033\000\044\000\034\000\043\000\035\000\042\000\
\\037\000\041\000\039\000\040\000\040\000\039\000\041\000\038\000\
\\042\000\037\000\043\000\036\000\046\000\035\000\047\000\034\000\
\\048\000\033\000\049\000\032\000\050\000\031\000\058\000\030\000\000\000\
\\009\000\017\000\028\000\016\000\055\000\094\000\059\000\014\000\
\\060\000\013\000\000\000\
\\000\000\
\\003\000\096\000\061\000\095\000\000\000\
\\003\000\096\000\061\000\097\000\000\000\
\\003\000\098\000\000\000\
\\003\000\099\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\028\000\103\000\053\000\102\000\056\000\101\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\105\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\106\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\107\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\108\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\003\000\111\000\015\000\110\000\016\000\109\000\000\000\
\\003\000\111\000\015\000\112\000\016\000\109\000\000\000\
\\027\000\113\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\114\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\115\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\116\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\117\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\118\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\119\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\027\000\120\000\028\000\103\000\053\000\104\000\059\000\014\000\
\\060\000\013\000\000\000\
\\000\000\
\\010\000\122\000\011\000\048\000\026\000\047\000\029\000\046\000\
\\030\000\045\000\033\000\044\000\034\000\043\000\035\000\042\000\
\\037\000\041\000\039\000\040\000\040\000\039\000\041\000\038\000\
\\042\000\037\000\043\000\036\000\046\000\035\000\047\000\034\000\
\\048\000\033\000\049\000\032\000\050\000\031\000\058\000\030\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\096\000\012\000\126\000\061\000\125\000\000\000\
\\000\000\
\\000\000\
\\012\000\131\000\000\000\
\\000\000\
\\028\000\103\000\053\000\132\000\059\000\014\000\060\000\013\000\000\000\
\\000\000\
\\012\000\133\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\134\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\137\000\000\000\
\\003\000\111\000\015\000\138\000\016\000\109\000\000\000\
\\000\000\
\\003\000\111\000\015\000\139\000\016\000\109\000\000\000\
\\000\000\
\\003\000\111\000\015\000\140\000\016\000\109\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\141\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\142\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\143\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\145\000\038\000\144\000\000\000\
\\003\000\147\000\013\000\146\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\157\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\166\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\168\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\031\000\167\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\028\000\103\000\053\000\176\000\057\000\175\000\059\000\014\000\
\\060\000\013\000\000\000\
\\000\000\
\\000\000\
\\003\000\111\000\015\000\179\000\016\000\109\000\044\000\178\000\000\000\
\\000\000\
\\000\000\
\\003\000\111\000\015\000\179\000\016\000\109\000\044\000\180\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\181\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\111\000\015\000\183\000\016\000\109\000\052\000\182\000\000\000\
\\003\000\111\000\015\000\183\000\016\000\109\000\052\000\184\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\136\000\014\000\135\000\017\000\188\000\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\190\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\036\000\189\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\191\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\199\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\201\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\032\000\200\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\111\000\016\000\202\000\000\000\
\\003\000\136\000\014\000\203\000\000\000\
\\003\000\147\000\013\000\204\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\111\000\015\000\207\000\016\000\109\000\045\000\206\000\000\000\
\\000\000\
\\003\000\111\000\015\000\207\000\016\000\109\000\045\000\208\000\000\000\
\\000\000\
\\000\000\
\\003\000\111\000\015\000\183\000\016\000\109\000\052\000\211\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\215\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\217\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\051\000\216\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\218\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\219\000\000\000\
\\003\000\136\000\014\000\135\000\017\000\220\000\000\000\
\\003\000\111\000\015\000\221\000\016\000\109\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\222\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\223\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\224\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\225\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\217\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\051\000\233\000\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\217\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\051\000\235\000\000\000\
\\003\000\111\000\015\000\236\000\016\000\109\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\237\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\238\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\111\000\015\000\183\000\016\000\109\000\052\000\239\000\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\241\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\242\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\217\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\051\000\243\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\147\000\013\000\158\000\018\000\217\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\051\000\248\000\000\000\
\\003\000\147\000\013\000\158\000\018\000\217\000\019\000\156\000\
\\020\000\155\000\021\000\154\000\022\000\153\000\023\000\152\000\
\\024\000\151\000\025\000\150\000\051\000\249\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\"
val numstates = 254
val numrules = 103
val s = ref "" and index = ref 0
val string_to_int = fn () => 
let val i = !index
in index := i+2; Char.ord(String.sub(!s,i)) + Char.ord(String.sub(!s,i+1)) * 256
end
val string_to_list = fn s' =>
    let val len = String.size s'
        fun f () =
           if !index < len then string_to_int() :: f()
           else nil
   in index := 0; s := s'; f ()
   end
val string_to_pairlist = fn (conv_key,conv_entry) =>
     let fun f () =
         case string_to_int()
         of 0 => EMPTY
          | n => PAIR(conv_key (n-1),conv_entry (string_to_int()),f())
     in f
     end
val string_to_pairlist_default = fn (conv_key,conv_entry) =>
    let val conv_row = string_to_pairlist(conv_key,conv_entry)
    in fn () =>
       let val default = conv_entry(string_to_int())
           val row = conv_row()
       in (row,default)
       end
   end
val string_to_table = fn (convert_row,s') =>
    let val len = String.size s'
        fun f ()=
           if !index < len then convert_row() :: f()
           else nil
     in (s := s'; index := 0; f ())
     end
local
  val memo = Array.array(numstates+numrules,ERROR)
  val _ =let fun g i=(Array.update(memo,i,REDUCE(i-numstates)); g(i+1))
       fun f i =
            if i=numstates then g i
            else (Array.update(memo,i,SHIFT (STATE i)); f (i+1))
          in f 0 handle Subscript => ()
          end
in
val entry_to_action = fn 0 => ACCEPT | 1 => ERROR | j => Array.sub(memo,(j-2))
end
val gotoT=Array.fromList(string_to_table(string_to_pairlist(NT,STATE),gotoT))
val actionRows=string_to_table(string_to_pairlist_default(T,entry_to_action),actionRows)
val actionRowNumbers = string_to_list actionRowNumbers
val actionT = let val actionRowLookUp=
let val a=Array.fromList(actionRows) in fn i=>Array.sub(a,i) end
in Array.fromList(map actionRowLookUp actionRowNumbers)
end
in LrTable.mkLrTable {actions=actionT,gotos=gotoT,numRules=numrules,
numStates=numstates,initialState=STATE 0}
end
end
local open Header in
type pos = int
type arg = unit
structure MlyValue = 
struct
datatype svalue = VOID | ntVOID of unit ->  unit
 | T_STRING of unit ->  (string)
 | T_NON_NEGATIVE_INTEGER of unit ->  (string)
 | T_XSTRING of unit ->  (string) | CONSTANT of unit ->  (string)
 | DIDOA of unit ->  (string list)
 | INDIVIDUALS of unit ->  (string list)
 | CLASS_EXPRESSIONS of unit ->  (Parsetree.parsetree list)
 | NEGATIVE_OBJECT_PROPERTY_ASSERTION of unit ->  (Parsetree.parsetree)
 | OBJECT_PROPERTY_ASSERTION of unit ->  (Parsetree.parsetree)
 | CLASS_ASSERTION of unit ->  (Parsetree.parsetree)
 | DIFFERENT_INDIVIDUALS of unit ->  (Parsetree.parsetree)
 | SAME_INDIVIDUAL of unit ->  (Parsetree.parsetree)
 | TARGET_INDIVIDUAL of unit ->  (string)
 | SOURCE_INDIVIDUAL of unit ->  (string)
 | ASSERTION of unit ->  (Parsetree.parsetree)
 | SUB_OBJECT_PROPERTY_EXPRESSION of unit ->  (string)
 | DISJOINT_CLASS_EXPRESSIONS of unit ->  (Parsetree.parsetree list)
 | DISJOINT_UNION of unit ->  (Parsetree.parsetree)
 | DISJOINT_CLASSES of unit ->  (Parsetree.parsetree)
 | EQUIVALENT_CLASSES of unit ->  (Parsetree.parsetree)
 | SUPER_CLASS_EXPRESSION of unit ->  (Parsetree.parsetree)
 | SUB_CLASS_EXPRESSION of unit ->  (Parsetree.parsetree)
 | SUB_CLASS_OF of unit ->  (Parsetree.parsetree)
 | CLASS_AXIOM of unit ->  (Parsetree.parsetree)
 | AXIOM of unit ->  (Parsetree.parsetree option)
 | OBJECT_HAS_VALUE of unit ->  (Parsetree.parsetree)
 | OBJECT_ALL_VALUES_FROM of unit ->  (Parsetree.parsetree)
 | OBJECT_SOME_VALUES_FROM of unit ->  (Parsetree.parsetree)
 | OBJECT_ONE_OF of unit ->  (Parsetree.parsetree)
 | OBJECT_COMPLEMENT_OF of unit ->  (Parsetree.parsetree)
 | OBJECT_UNION_OF of unit ->  (Parsetree.parsetree)
 | OBJECT_INTERSECTION_OF of unit ->  (Parsetree.parsetree)
 | CLASS_EXPRESSION of unit ->  (Parsetree.parsetree)
 | OBJECT_PROPERTY_EXPRESSION of unit ->  (string)
 | NAMED_INDIVIDUAL of unit ->  (string)
 | INDIVIDUAL of unit ->  (string)
 | OBJECT_PROPERTY of unit ->  (string)
 | CLASS of unit ->  (Parsetree.parsetree)
 | AXIOMS of unit ->  (Parsetree.parsetree)
 | DIRECTLY_IMPORTS_DOCUMENT of unit ->  (string)
 | VERSION_IRI of unit ->  (string)
 | ONTOLOGY_IRI of unit ->  (string)
 | ONTOLOGY of unit ->  (string list*Parsetree.parsetree)
 | ONTOLOGY_DOCUMENT of unit ->  (string list*Parsetree.parsetree)
 | IRI of unit ->  (string) | PREFIX of unit ->  (string)
 | NAMESPACE of unit ->  (string)
end
type svalue = MlyValue.svalue
type result = string list*Parsetree.parsetree
end
structure EC=
struct
open LrTable
infix 5 $$
fun x $$ y = y::x
val is_keyword =
fn _ => false
val preferred_change : (term list * term list) list = 
nil
val noShift = 
fn (T 40) => true | _ => false
val showTerminal =
fn (T 0) => "T_XSTRING"
  | (T 1) => "T_INTERSECTION_OF"
  | (T 2) => "T_UNION_OF"
  | (T 3) => "T_COMPLEMENT_OF"
  | (T 4) => "T_ONE_OF"
  | (T 5) => "T_SOME_VALUES_FROM"
  | (T 6) => "T_ALL_VALUES_FROM"
  | (T 7) => "T_HAS_VALUE"
  | (T 8) => "T_SUB_CLASS_OF"
  | (T 9) => "T_EQUIVALENT_CLASSES"
  | (T 10) => "T_DISJOINT_CLASSES"
  | (T 11) => "T_DISJOINT_UNION"
  | (T 12) => "T_SUB_PROPERTY_OF"
  | (T 13) => "T_REFLEXIVE_PROPERTY"
  | (T 14) => "T_SYMMETRIC_PROPERTY"
  | (T 15) => "T_TRANSITIVE_PROPERTY"
  | (T 16) => "T_SAME_INDIVIDUAL"
  | (T 17) => "T_DIFFERENT_INDIVIDUALS"
  | (T 18) => "T_CLASS_ASSERTION"
  | (T 19) => "T_PROPERTY_ASSERTION"
  | (T 20) => "T_NEGATIVE_PROPERTY_ASSERTION"
  | (T 21) => "T_NAMESPACE"
  | (T 22) => "T_ONTOLOGY"
  | (T 23) => "T_IMPORTS"
  | (T 24) => "T_ANNOTATION"
  | (T 25) => "T_DECLARATION"
  | (T 26) => "T_CLASS"
  | (T 27) => "T_OBJECT_PROPERTY"
  | (T 28) => "T_ANNOTATION_PROPERTY"
  | (T 29) => "T_NAMED_INDIVIDUAL"
  | (T 30) => "T_TOP"
  | (T 31) => "T_BOTTOM"
  | (T 32) => "T_NON_NEGATIVE_INTEGER"
  | (T 33) => "T_ENTITY_ANNOTATION"
  | (T 34) => "T_LABEL"
  | (T 35) => "T_COMMENT"
  | (T 36) => "T_LPAREN"
  | (T 37) => "T_RPAREN"
  | (T 38) => "T_EQS"
  | (T 39) => "T_STRING"
  | (T 40) => "EOF"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 40) $$ (T 38) $$ (T 37) $$ (T 36) $$ (T 35) $$ (T 34) $$ (T 33)
 $$ (T 31) $$ (T 30) $$ (T 29) $$ (T 28) $$ (T 27) $$ (T 26) $$ (T 25)
 $$ (T 24) $$ (T 23) $$ (T 22) $$ (T 21) $$ (T 20) $$ (T 19) $$ (T 18)
 $$ (T 17) $$ (T 16) $$ (T 15) $$ (T 14) $$ (T 13) $$ (T 12) $$ (T 11)
 $$ (T 10) $$ (T 9) $$ (T 8) $$ (T 7) $$ (T 6) $$ (T 5) $$ (T 4) $$ 
(T 3) $$ (T 2) $$ (T 1)end
structure Actions =
struct 
type int = Int.int
exception mlyAction of int
local open Header in
val actions = 
fn (i392:int,defaultPos,stack,
    (()):arg) =>
case (i392,stack)
of  ( 0, ( ( _, ( MlyValue.T_STRING T_STRING1, T_STRING1left, 
T_STRING1right)) :: rest671)) => let val  result = MlyValue.NAMESPACE
 (fn _ => let val  (T_STRING as T_STRING1) = T_STRING1 ()
 in (T_STRING)
end)
 in ( LrTable.NT 0, ( result, T_STRING1left, T_STRING1right), rest671)

end
|  ( 1, ( ( _, ( MlyValue.T_XSTRING T_XSTRING1, T_XSTRING1left, 
T_XSTRING1right)) :: rest671)) => let val  result = MlyValue.NAMESPACE
 (fn _ => let val  (T_XSTRING as T_XSTRING1) = T_XSTRING1 ()
 in (T_XSTRING)
end)
 in ( LrTable.NT 0, ( result, T_XSTRING1left, T_XSTRING1right), 
rest671)
end
|  ( 2, ( ( _, ( MlyValue.T_STRING T_STRING1, T_STRING1left, 
T_STRING1right)) :: rest671)) => let val  result = MlyValue.PREFIX (fn
 _ => let val  (T_STRING as T_STRING1) = T_STRING1 ()
 in (T_STRING)
end)
 in ( LrTable.NT 1, ( result, T_STRING1left, T_STRING1right), rest671)

end
|  ( 3, ( ( _, ( MlyValue.T_XSTRING T_XSTRING1, T_XSTRING1left, 
T_XSTRING1right)) :: rest671)) => let val  result = MlyValue.PREFIX
 (fn _ => let val  (T_XSTRING as T_XSTRING1) = T_XSTRING1 ()
 in (T_XSTRING)
end)
 in ( LrTable.NT 1, ( result, T_XSTRING1left, T_XSTRING1right), 
rest671)
end
|  ( 4, ( ( _, ( MlyValue.T_STRING T_STRING1, T_STRING1left, 
T_STRING1right)) :: rest671)) => let val  result = MlyValue.IRI (fn _
 => let val  (T_STRING as T_STRING1) = T_STRING1 ()
 in (T_STRING)
end)
 in ( LrTable.NT 2, ( result, T_STRING1left, T_STRING1right), rest671)

end
|  ( 5, ( ( _, ( MlyValue.T_XSTRING T_XSTRING1, T_XSTRING1left, 
T_XSTRING1right)) :: rest671)) => let val  result = MlyValue.IRI (fn _
 => let val  (T_XSTRING as T_XSTRING1) = T_XSTRING1 ()
 in (T_XSTRING)
end)
 in ( LrTable.NT 2, ( result, T_XSTRING1left, T_XSTRING1right), 
rest671)
end
|  ( 6, ( ( _, ( MlyValue.ONTOLOGY ONTOLOGY1, _, ONTOLOGY1right)) :: (
 _, ( MlyValue.ntVOID PREFIX_DEFINITIONS1, PREFIX_DEFINITIONS1left, _)
) :: rest671)) => let val  result = MlyValue.ONTOLOGY_DOCUMENT (fn _
 => let val  PREFIX_DEFINITIONS1 = PREFIX_DEFINITIONS1 ()
 val  (ONTOLOGY as ONTOLOGY1) = ONTOLOGY1 ()
 in (ONTOLOGY)
end)
 in ( LrTable.NT 3, ( result, PREFIX_DEFINITIONS1left, ONTOLOGY1right)
, rest671)
end
|  ( 7, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.NAMESPACE 
NAMESPACE1, _, _)) :: _ :: _ :: ( _, ( _, T_NAMESPACE1left, _)) :: 
rest671)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
NAMESPACE1 = NAMESPACE1 ()
 in (())
end; ()))
 in ( LrTable.NT 4, ( result, T_NAMESPACE1left, T_RPAREN1right), 
rest671)
end
|  ( 8, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.NAMESPACE 
NAMESPACE1, _, _)) :: _ :: ( _, ( MlyValue.PREFIX PREFIX1, _, _)) :: _
 :: ( _, ( _, T_NAMESPACE1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  PREFIX1 = PREFIX1 ()
 val  NAMESPACE1 = NAMESPACE1 ()
 in (())
end; ()))
 in ( LrTable.NT 4, ( result, T_NAMESPACE1left, T_RPAREN1right), 
rest671)
end
|  ( 9, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.AXIOMS 
AXIOMS1, _, _)) :: ( _, ( MlyValue.DIDOA DIDOA1, _, _)) :: _ :: ( _, (
 _, T_ONTOLOGY1left, _)) :: rest671)) => let val  result = 
MlyValue.ONTOLOGY (fn _ => let val  (DIDOA as DIDOA1) = DIDOA1 ()
 val  (AXIOMS as AXIOMS1) = AXIOMS1 ()
 in (DIDOA, AXIOMS)
end)
 in ( LrTable.NT 5, ( result, T_ONTOLOGY1left, T_RPAREN1right), 
rest671)
end
|  ( 10, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.AXIOMS 
AXIOMS1, _, _)) :: ( _, ( MlyValue.DIDOA DIDOA1, _, _)) :: ( _, ( 
MlyValue.ONTOLOGY_IRI ONTOLOGY_IRI1, _, _)) :: _ :: ( _, ( _, 
T_ONTOLOGY1left, _)) :: rest671)) => let val  result = 
MlyValue.ONTOLOGY (fn _ => let val  ONTOLOGY_IRI1 = ONTOLOGY_IRI1 ()
 val  (DIDOA as DIDOA1) = DIDOA1 ()
 val  (AXIOMS as AXIOMS1) = AXIOMS1 ()
 in (DIDOA, AXIOMS)
end)
 in ( LrTable.NT 5, ( result, T_ONTOLOGY1left, T_RPAREN1right), 
rest671)
end
|  ( 11, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.AXIOMS 
AXIOMS1, _, _)) :: ( _, ( MlyValue.DIDOA DIDOA1, _, _)) :: ( _, ( 
MlyValue.VERSION_IRI VERSION_IRI1, _, _)) :: ( _, ( 
MlyValue.ONTOLOGY_IRI ONTOLOGY_IRI1, _, _)) :: _ :: ( _, ( _, 
T_ONTOLOGY1left, _)) :: rest671)) => let val  result = 
MlyValue.ONTOLOGY (fn _ => let val  ONTOLOGY_IRI1 = ONTOLOGY_IRI1 ()
 val  VERSION_IRI1 = VERSION_IRI1 ()
 val  (DIDOA as DIDOA1) = DIDOA1 ()
 val  (AXIOMS as AXIOMS1) = AXIOMS1 ()
 in (DIDOA, AXIOMS)
end)
 in ( LrTable.NT 5, ( result, T_ONTOLOGY1left, T_RPAREN1right), 
rest671)
end
|  ( 12, ( ( _, ( MlyValue.IRI IRI1, IRI1left, IRI1right)) :: rest671)
) => let val  result = MlyValue.ONTOLOGY_IRI (fn _ => let val  (IRI
 as IRI1) = IRI1 ()
 in ((IRI))
end)
 in ( LrTable.NT 6, ( result, IRI1left, IRI1right), rest671)
end
|  ( 13, ( ( _, ( MlyValue.IRI IRI1, IRI1left, IRI1right)) :: rest671)
) => let val  result = MlyValue.VERSION_IRI (fn _ => let val  (IRI as 
IRI1) = IRI1 ()
 in ((IRI))
end)
 in ( LrTable.NT 7, ( result, IRI1left, IRI1right), rest671)
end
|  ( 14, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.IRI IRI1,
 _, _)) :: _ :: ( _, ( _, T_IMPORTS1left, _)) :: rest671)) => let val 
 result = MlyValue.DIRECTLY_IMPORTS_DOCUMENT (fn _ => let val  (IRI
 as IRI1) = IRI1 ()
 in (IRI)
end)
 in ( LrTable.NT 8, ( result, T_IMPORTS1left, T_RPAREN1right), rest671
)
end
|  ( 15, ( rest671)) => let val  result = MlyValue.AXIOMS (fn _ => (
Parsetree.mconj nil))
 in ( LrTable.NT 9, ( result, defaultPos, defaultPos), rest671)
end
|  ( 16, ( ( _, ( MlyValue.AXIOMS AXIOMS1, _, AXIOMS1right)) :: ( _, (
 MlyValue.AXIOM AXIOM1, AXIOM1left, _)) :: rest671)) => let val  
result = MlyValue.AXIOMS (fn _ => let val  (AXIOM as AXIOM1) = AXIOM1
 ()
 val  (AXIOMS as AXIOMS1) = AXIOMS1 ()
 in (
Parsetree.conj (Option.getOpt (AXIOM, Parsetree.mconj nil)) AXIOMS)

end)
 in ( LrTable.NT 9, ( result, AXIOM1left, AXIOMS1right), rest671)
end
|  ( 17, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.ntVOID 
ENTITY1, _, _)) :: ( _, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _))
 :: _ :: ( _, ( _, T_DECLARATION1left, _)) :: rest671)) => let val  
result = MlyValue.ntVOID (fn _ => ( let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  ENTITY1 = ENTITY1 ()
 in (())
end; ()))
 in ( LrTable.NT 10, ( result, T_DECLARATION1left, T_RPAREN1right), 
rest671)
end
|  ( 18, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.CLASS 
CLASS1, _, _)) :: _ :: ( _, ( _, T_CLASS1left, _)) :: rest671)) => let
 val  result = MlyValue.ntVOID (fn _ => ( let val  CLASS1 = CLASS1 ()
 in (())
end; ()))
 in ( LrTable.NT 11, ( result, T_CLASS1left, T_RPAREN1right), rest671)

end
|  ( 19, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY OBJECT_PROPERTY1, _, _)) :: _ :: ( _, ( _, 
T_OBJECT_PROPERTY1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  OBJECT_PROPERTY1 = 
OBJECT_PROPERTY1 ()
 in (())
end; ()))
 in ( LrTable.NT 11, ( result, T_OBJECT_PROPERTY1left, T_RPAREN1right)
, rest671)
end
|  ( 20, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.NAMED_INDIVIDUAL NAMED_INDIVIDUAL1, _, _)) :: _ :: ( _, ( _, 
T_NAMED_INDIVIDUAL1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  NAMED_INDIVIDUAL1 = 
NAMED_INDIVIDUAL1 ()
 in (())
end; ()))
 in ( LrTable.NT 11, ( result, T_NAMED_INDIVIDUAL1left, T_RPAREN1right
), rest671)
end
|  ( 21, ( ( _, ( MlyValue.ntVOID ANNOTATIONS1, ANNOTATIONS1left, 
ANNOTATIONS1right)) :: rest671)) => let val  result = MlyValue.ntVOID
 (fn _ => ( let val  ANNOTATIONS1 = ANNOTATIONS1 ()
 in (())
end; ()))
 in ( LrTable.NT 26, ( result, ANNOTATIONS1left, ANNOTATIONS1right), 
rest671)
end
|  ( 22, ( ( _, ( MlyValue.ntVOID ANNOTATION_BY_CONSTANT1, 
ANNOTATION_BY_CONSTANT1left, ANNOTATION_BY_CONSTANT1right)) :: rest671
)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
ANNOTATION_BY_CONSTANT1 = ANNOTATION_BY_CONSTANT1 ()
 in (())
end; ()))
 in ( LrTable.NT 27, ( result, ANNOTATION_BY_CONSTANT1left, 
ANNOTATION_BY_CONSTANT1right), rest671)
end
|  ( 23, ( ( _, ( MlyValue.ntVOID ANNOTATION_BY_ENTITY1, 
ANNOTATION_BY_ENTITY1left, ANNOTATION_BY_ENTITY1right)) :: rest671))
 => let val  result = MlyValue.ntVOID (fn _ => ( let val  
ANNOTATION_BY_ENTITY1 = ANNOTATION_BY_ENTITY1 ()
 in (())
end; ()))
 in ( LrTable.NT 27, ( result, ANNOTATION_BY_ENTITY1left, 
ANNOTATION_BY_ENTITY1right), rest671)
end
|  ( 24, ( ( _, ( _, T_TOP1left, T_TOP1right)) :: rest671)) => let
 val  result = MlyValue.CLASS (fn _ => (Parsetree.mconj nil))
 in ( LrTable.NT 12, ( result, T_TOP1left, T_TOP1right), rest671)
end
|  ( 25, ( ( _, ( _, T_BOTTOM1left, T_BOTTOM1right)) :: rest671)) =>
 let val  result = MlyValue.CLASS (fn _ => (Parsetree.mdisj nil))
 in ( LrTable.NT 12, ( result, T_BOTTOM1left, T_BOTTOM1right), rest671
)
end
|  ( 26, ( ( _, ( MlyValue.IRI IRI1, IRI1left, IRI1right)) :: rest671)
) => let val  result = MlyValue.CLASS (fn _ => let val  (IRI as IRI1)
 = IRI1 ()
 in (Parsetree.PROPVAR IRI)
end)
 in ( LrTable.NT 12, ( result, IRI1left, IRI1right), rest671)
end
|  ( 27, ( ( _, ( MlyValue.IRI IRI1, IRI1left, IRI1right)) :: rest671)
) => let val  result = MlyValue.OBJECT_PROPERTY (fn _ => let val  (IRI
 as IRI1) = IRI1 ()
 in (IRI)
end)
 in ( LrTable.NT 13, ( result, IRI1left, IRI1right), rest671)
end
|  ( 28, ( ( _, ( MlyValue.NAMED_INDIVIDUAL NAMED_INDIVIDUAL1, 
NAMED_INDIVIDUAL1left, NAMED_INDIVIDUAL1right)) :: rest671)) => let
 val  result = MlyValue.INDIVIDUAL (fn _ => let val  (NAMED_INDIVIDUAL
 as NAMED_INDIVIDUAL1) = NAMED_INDIVIDUAL1 ()
 in (NAMED_INDIVIDUAL)
end)
 in ( LrTable.NT 14, ( result, NAMED_INDIVIDUAL1left, 
NAMED_INDIVIDUAL1right), rest671)
end
|  ( 29, ( ( _, ( MlyValue.IRI IRI1, IRI1left, IRI1right)) :: rest671)
) => let val  result = MlyValue.NAMED_INDIVIDUAL (fn _ => let val  (
IRI as IRI1) = IRI1 ()
 in (IRI)
end)
 in ( LrTable.NT 15, ( result, IRI1left, IRI1right), rest671)
end
|  ( 30, ( ( _, ( MlyValue.OBJECT_PROPERTY OBJECT_PROPERTY1, 
OBJECT_PROPERTY1left, OBJECT_PROPERTY1right)) :: rest671)) => let val 
 result = MlyValue.OBJECT_PROPERTY_EXPRESSION (fn _ => let val  (
OBJECT_PROPERTY as OBJECT_PROPERTY1) = OBJECT_PROPERTY1 ()
 in (OBJECT_PROPERTY)
end)
 in ( LrTable.NT 16, ( result, OBJECT_PROPERTY1left, 
OBJECT_PROPERTY1right), rest671)
end
|  ( 31, ( ( _, ( MlyValue.CLASS CLASS1, CLASS1left, CLASS1right)) :: 
rest671)) => let val  result = MlyValue.CLASS_EXPRESSION (fn _ => let
 val  (CLASS as CLASS1) = CLASS1 ()
 in (CLASS)
end)
 in ( LrTable.NT 17, ( result, CLASS1left, CLASS1right), rest671)
end
|  ( 32, ( ( _, ( MlyValue.OBJECT_INTERSECTION_OF 
OBJECT_INTERSECTION_OF1, OBJECT_INTERSECTION_OF1left, 
OBJECT_INTERSECTION_OF1right)) :: rest671)) => let val  result = 
MlyValue.CLASS_EXPRESSION (fn _ => let val  (OBJECT_INTERSECTION_OF
 as OBJECT_INTERSECTION_OF1) = OBJECT_INTERSECTION_OF1 ()
 in (OBJECT_INTERSECTION_OF)
end)
 in ( LrTable.NT 17, ( result, OBJECT_INTERSECTION_OF1left, 
OBJECT_INTERSECTION_OF1right), rest671)
end
|  ( 33, ( ( _, ( MlyValue.OBJECT_UNION_OF OBJECT_UNION_OF1, 
OBJECT_UNION_OF1left, OBJECT_UNION_OF1right)) :: rest671)) => let val 
 result = MlyValue.CLASS_EXPRESSION (fn _ => let val  (OBJECT_UNION_OF
 as OBJECT_UNION_OF1) = OBJECT_UNION_OF1 ()
 in (OBJECT_UNION_OF)
end)
 in ( LrTable.NT 17, ( result, OBJECT_UNION_OF1left, 
OBJECT_UNION_OF1right), rest671)
end
|  ( 34, ( ( _, ( MlyValue.OBJECT_COMPLEMENT_OF OBJECT_COMPLEMENT_OF1,
 OBJECT_COMPLEMENT_OF1left, OBJECT_COMPLEMENT_OF1right)) :: rest671))
 => let val  result = MlyValue.CLASS_EXPRESSION (fn _ => let val  (
OBJECT_COMPLEMENT_OF as OBJECT_COMPLEMENT_OF1) = OBJECT_COMPLEMENT_OF1
 ()
 in (OBJECT_COMPLEMENT_OF)
end)
 in ( LrTable.NT 17, ( result, OBJECT_COMPLEMENT_OF1left, 
OBJECT_COMPLEMENT_OF1right), rest671)
end
|  ( 35, ( ( _, ( MlyValue.OBJECT_ONE_OF OBJECT_ONE_OF1, 
OBJECT_ONE_OF1left, OBJECT_ONE_OF1right)) :: rest671)) => let val  
result = MlyValue.CLASS_EXPRESSION (fn _ => let val  (OBJECT_ONE_OF
 as OBJECT_ONE_OF1) = OBJECT_ONE_OF1 ()
 in (OBJECT_ONE_OF)
end)
 in ( LrTable.NT 17, ( result, OBJECT_ONE_OF1left, OBJECT_ONE_OF1right
), rest671)
end
|  ( 36, ( ( _, ( MlyValue.OBJECT_SOME_VALUES_FROM 
OBJECT_SOME_VALUES_FROM1, OBJECT_SOME_VALUES_FROM1left, 
OBJECT_SOME_VALUES_FROM1right)) :: rest671)) => let val  result = 
MlyValue.CLASS_EXPRESSION (fn _ => let val  (OBJECT_SOME_VALUES_FROM
 as OBJECT_SOME_VALUES_FROM1) = OBJECT_SOME_VALUES_FROM1 ()
 in (OBJECT_SOME_VALUES_FROM)
end)
 in ( LrTable.NT 17, ( result, OBJECT_SOME_VALUES_FROM1left, 
OBJECT_SOME_VALUES_FROM1right), rest671)
end
|  ( 37, ( ( _, ( MlyValue.OBJECT_ALL_VALUES_FROM 
OBJECT_ALL_VALUES_FROM1, OBJECT_ALL_VALUES_FROM1left, 
OBJECT_ALL_VALUES_FROM1right)) :: rest671)) => let val  result = 
MlyValue.CLASS_EXPRESSION (fn _ => let val  (OBJECT_ALL_VALUES_FROM
 as OBJECT_ALL_VALUES_FROM1) = OBJECT_ALL_VALUES_FROM1 ()
 in (OBJECT_ALL_VALUES_FROM)
end)
 in ( LrTable.NT 17, ( result, OBJECT_ALL_VALUES_FROM1left, 
OBJECT_ALL_VALUES_FROM1right), rest671)
end
|  ( 38, ( ( _, ( MlyValue.OBJECT_HAS_VALUE OBJECT_HAS_VALUE1, 
OBJECT_HAS_VALUE1left, OBJECT_HAS_VALUE1right)) :: rest671)) => let
 val  result = MlyValue.CLASS_EXPRESSION (fn _ => let val  (
OBJECT_HAS_VALUE as OBJECT_HAS_VALUE1) = OBJECT_HAS_VALUE1 ()
 in (OBJECT_HAS_VALUE)
end)
 in ( LrTable.NT 17, ( result, OBJECT_HAS_VALUE1left, 
OBJECT_HAS_VALUE1right), rest671)
end
|  ( 39, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSIONS CLASS_EXPRESSIONS1, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION2, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: _ :: ( _, ( _, 
T_INTERSECTION_OF1left, _)) :: rest671)) => let val  result = 
MlyValue.OBJECT_INTERSECTION_OF (fn _ => let val  CLASS_EXPRESSION1 = 
CLASS_EXPRESSION1 ()
 val  CLASS_EXPRESSION2 = CLASS_EXPRESSION2 ()
 val  (CLASS_EXPRESSIONS as CLASS_EXPRESSIONS1) = CLASS_EXPRESSIONS1
 ()
 in (
Parsetree.mconj (CLASS_EXPRESSION1::CLASS_EXPRESSION2::CLASS_EXPRESSIONS)
)
end)
 in ( LrTable.NT 18, ( result, T_INTERSECTION_OF1left, T_RPAREN1right)
, rest671)
end
|  ( 40, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSIONS CLASS_EXPRESSIONS1, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION2, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: _ :: ( _, ( _, 
T_UNION_OF1left, _)) :: rest671)) => let val  result = 
MlyValue.OBJECT_UNION_OF (fn _ => let val  CLASS_EXPRESSION1 = 
CLASS_EXPRESSION1 ()
 val  CLASS_EXPRESSION2 = CLASS_EXPRESSION2 ()
 val  (CLASS_EXPRESSIONS as CLASS_EXPRESSIONS1) = CLASS_EXPRESSIONS1
 ()
 in (
Parsetree.mdisj (CLASS_EXPRESSION1::CLASS_EXPRESSION2::CLASS_EXPRESSIONS)
)
end)
 in ( LrTable.NT 19, ( result, T_UNION_OF1left, T_RPAREN1right), 
rest671)
end
|  ( 41, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: _ :: ( _, ( _, 
T_COMPLEMENT_OF1left, _)) :: rest671)) => let val  result = 
MlyValue.OBJECT_COMPLEMENT_OF (fn _ => let val  (CLASS_EXPRESSION as 
CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 in (Parsetree.neg CLASS_EXPRESSION)
end)
 in ( LrTable.NT 20, ( result, T_COMPLEMENT_OF1left, T_RPAREN1right), 
rest671)
end
|  ( 42, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.INDIVIDUALS INDIVIDUALS1, _, _)) :: ( _, ( 
MlyValue.INDIVIDUAL INDIVIDUAL1, _, _)) :: _ :: ( _, ( _, 
T_ONE_OF1left, _)) :: rest671)) => let val  result = 
MlyValue.OBJECT_ONE_OF (fn _ => let val  (INDIVIDUAL as INDIVIDUAL1) =
 INDIVIDUAL1 ()
 val  (INDIVIDUALS as INDIVIDUALS1) = INDIVIDUALS1 ()
 in (Parsetree.mdisj (map Parsetree.NOMINAL (INDIVIDUAL::INDIVIDUALS))
)
end)
 in ( LrTable.NT 21, ( result, T_ONE_OF1left, T_RPAREN1right), rest671
)
end
|  ( 43, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: _ :: ( _, ( _, T_SOME_VALUES_FROM1left, _)) :: rest671)) => let
 val  result = MlyValue.OBJECT_SOME_VALUES_FROM (fn _ => let val  (
OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 val  (CLASS_EXPRESSION as CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 in (Parsetree.DIAMOND (OBJECT_PROPERTY_EXPRESSION, CLASS_EXPRESSION))

end)
 in ( LrTable.NT 22, ( result, T_SOME_VALUES_FROM1left, T_RPAREN1right
), rest671)
end
|  ( 44, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: _ :: ( _, ( _, T_ALL_VALUES_FROM1left, _)) :: rest671)) => let
 val  result = MlyValue.OBJECT_ALL_VALUES_FROM (fn _ => let val  (
OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 val  (CLASS_EXPRESSION as CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 in (Parsetree.BOX (OBJECT_PROPERTY_EXPRESSION, CLASS_EXPRESSION))
end
)
 in ( LrTable.NT 23, ( result, T_ALL_VALUES_FROM1left, T_RPAREN1right)
, rest671)
end
|  ( 45, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.INDIVIDUAL
 INDIVIDUAL1, _, _)) :: ( _, ( MlyValue.OBJECT_PROPERTY_EXPRESSION 
OBJECT_PROPERTY_EXPRESSION1, _, _)) :: _ :: ( _, ( _, T_HAS_VALUE1left
, _)) :: rest671)) => let val  result = MlyValue.OBJECT_HAS_VALUE (fn
 _ => let val  (OBJECT_PROPERTY_EXPRESSION as 
OBJECT_PROPERTY_EXPRESSION1) = OBJECT_PROPERTY_EXPRESSION1 ()
 val  (INDIVIDUAL as INDIVIDUAL1) = INDIVIDUAL1 ()
 in (
Parsetree.DIAMOND (OBJECT_PROPERTY_EXPRESSION, Parsetree.NOMINAL INDIVIDUAL)
)
end)
 in ( LrTable.NT 24, ( result, T_HAS_VALUE1left, T_RPAREN1right), 
rest671)
end
|  ( 46, ( ( _, ( MlyValue.ntVOID DECLARATION1, DECLARATION1left, 
DECLARATION1right)) :: rest671)) => let val  result = MlyValue.AXIOM
 (fn _ => let val  DECLARATION1 = DECLARATION1 ()
 in (NONE)
end)
 in ( LrTable.NT 25, ( result, DECLARATION1left, DECLARATION1right), 
rest671)
end
|  ( 47, ( ( _, ( MlyValue.CLASS_AXIOM CLASS_AXIOM1, CLASS_AXIOM1left,
 CLASS_AXIOM1right)) :: rest671)) => let val  result = MlyValue.AXIOM
 (fn _ => let val  (CLASS_AXIOM as CLASS_AXIOM1) = CLASS_AXIOM1 ()
 in (SOME (Parsetree.ALL (CLASS_AXIOM)))
end)
 in ( LrTable.NT 25, ( result, CLASS_AXIOM1left, CLASS_AXIOM1right), 
rest671)
end
|  ( 48, ( ( _, ( MlyValue.ntVOID OBJECT_PROPERTY_AXIOM1, 
OBJECT_PROPERTY_AXIOM1left, OBJECT_PROPERTY_AXIOM1right)) :: rest671))
 => let val  result = MlyValue.AXIOM (fn _ => let val  
OBJECT_PROPERTY_AXIOM1 = OBJECT_PROPERTY_AXIOM1 ()
 in (NONE)
end)
 in ( LrTable.NT 25, ( result, OBJECT_PROPERTY_AXIOM1left, 
OBJECT_PROPERTY_AXIOM1right), rest671)
end
|  ( 49, ( ( _, ( MlyValue.ASSERTION ASSERTION1, ASSERTION1left, 
ASSERTION1right)) :: rest671)) => let val  result = MlyValue.AXIOM (fn
 _ => let val  (ASSERTION as ASSERTION1) = ASSERTION1 ()
 in (SOME ASSERTION)
end)
 in ( LrTable.NT 25, ( result, ASSERTION1left, ASSERTION1right), 
rest671)
end
|  ( 50, ( ( _, ( MlyValue.ntVOID ENTITY_ANNOTATION1, 
ENTITY_ANNOTATION1left, ENTITY_ANNOTATION1right)) :: rest671)) => let
 val  result = MlyValue.AXIOM (fn _ => let val  ENTITY_ANNOTATION1 = 
ENTITY_ANNOTATION1 ()
 in (NONE)
end)
 in ( LrTable.NT 25, ( result, ENTITY_ANNOTATION1left, 
ENTITY_ANNOTATION1right), rest671)
end
|  ( 51, ( ( _, ( MlyValue.SUB_CLASS_OF SUB_CLASS_OF1, 
SUB_CLASS_OF1left, SUB_CLASS_OF1right)) :: rest671)) => let val  
result = MlyValue.CLASS_AXIOM (fn _ => let val  (SUB_CLASS_OF as 
SUB_CLASS_OF1) = SUB_CLASS_OF1 ()
 in (SUB_CLASS_OF)
end)
 in ( LrTable.NT 28, ( result, SUB_CLASS_OF1left, SUB_CLASS_OF1right),
 rest671)
end
|  ( 52, ( ( _, ( MlyValue.EQUIVALENT_CLASSES EQUIVALENT_CLASSES1, 
EQUIVALENT_CLASSES1left, EQUIVALENT_CLASSES1right)) :: rest671)) =>
 let val  result = MlyValue.CLASS_AXIOM (fn _ => let val  (
EQUIVALENT_CLASSES as EQUIVALENT_CLASSES1) = EQUIVALENT_CLASSES1 ()
 in (EQUIVALENT_CLASSES)
end)
 in ( LrTable.NT 28, ( result, EQUIVALENT_CLASSES1left, 
EQUIVALENT_CLASSES1right), rest671)
end
|  ( 53, ( ( _, ( MlyValue.DISJOINT_CLASSES DISJOINT_CLASSES1, 
DISJOINT_CLASSES1left, DISJOINT_CLASSES1right)) :: rest671)) => let
 val  result = MlyValue.CLASS_AXIOM (fn _ => let val  (
DISJOINT_CLASSES as DISJOINT_CLASSES1) = DISJOINT_CLASSES1 ()
 in (DISJOINT_CLASSES)
end)
 in ( LrTable.NT 28, ( result, DISJOINT_CLASSES1left, 
DISJOINT_CLASSES1right), rest671)
end
|  ( 54, ( ( _, ( MlyValue.DISJOINT_UNION DISJOINT_UNION1, 
DISJOINT_UNION1left, DISJOINT_UNION1right)) :: rest671)) => let val  
result = MlyValue.CLASS_AXIOM (fn _ => let val  (DISJOINT_UNION as 
DISJOINT_UNION1) = DISJOINT_UNION1 ()
 in (DISJOINT_UNION)
end)
 in ( LrTable.NT 28, ( result, DISJOINT_UNION1left, 
DISJOINT_UNION1right), rest671)
end
|  ( 55, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.SUPER_CLASS_EXPRESSION SUPER_CLASS_EXPRESSION1, _, _)) :: ( _
, ( MlyValue.SUB_CLASS_EXPRESSION SUB_CLASS_EXPRESSION1, _, _)) :: ( _
, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, 
T_SUB_CLASS_OF1left, _)) :: rest671)) => let val  result = 
MlyValue.SUB_CLASS_OF (fn _ => let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  (SUB_CLASS_EXPRESSION as SUB_CLASS_EXPRESSION1) = 
SUB_CLASS_EXPRESSION1 ()
 val  (SUPER_CLASS_EXPRESSION as SUPER_CLASS_EXPRESSION1) = 
SUPER_CLASS_EXPRESSION1 ()
 in (Parsetree.impl SUB_CLASS_EXPRESSION SUPER_CLASS_EXPRESSION)
end)
 in ( LrTable.NT 29, ( result, T_SUB_CLASS_OF1left, T_RPAREN1right), 
rest671)
end
|  ( 56, ( ( _, ( MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, 
CLASS_EXPRESSION1left, CLASS_EXPRESSION1right)) :: rest671)) => let
 val  result = MlyValue.SUB_CLASS_EXPRESSION (fn _ => let val  (
CLASS_EXPRESSION as CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 in (CLASS_EXPRESSION)
end)
 in ( LrTable.NT 30, ( result, CLASS_EXPRESSION1left, 
CLASS_EXPRESSION1right), rest671)
end
|  ( 57, ( ( _, ( MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, 
CLASS_EXPRESSION1left, CLASS_EXPRESSION1right)) :: rest671)) => let
 val  result = MlyValue.SUPER_CLASS_EXPRESSION (fn _ => let val  (
CLASS_EXPRESSION as CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 in (CLASS_EXPRESSION)
end)
 in ( LrTable.NT 31, ( result, CLASS_EXPRESSION1left, 
CLASS_EXPRESSION1right), rest671)
end
|  ( 58, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION2, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: ( _, ( 
MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, 
T_EQUIVALENT_CLASSES1left, _)) :: rest671)) => let val  result = 
MlyValue.EQUIVALENT_CLASSES (fn _ => let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  CLASS_EXPRESSION1 = CLASS_EXPRESSION1 ()
 val  CLASS_EXPRESSION2 = CLASS_EXPRESSION2 ()
 in (Parsetree.dimpl CLASS_EXPRESSION1 CLASS_EXPRESSION2)
end)
 in ( LrTable.NT 32, ( result, T_EQUIVALENT_CLASSES1left, 
T_RPAREN1right), rest671)
end
|  ( 59, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSIONS CLASS_EXPRESSIONS1, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION3, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION2, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: ( _, ( 
MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, 
T_EQUIVALENT_CLASSES1left, _)) :: rest671)) => let val  result = 
MlyValue.EQUIVALENT_CLASSES (fn _ => let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  CLASS_EXPRESSION1 = CLASS_EXPRESSION1 ()
 val  CLASS_EXPRESSION2 = CLASS_EXPRESSION2 ()
 val  CLASS_EXPRESSION3 = CLASS_EXPRESSION3 ()
 val  (CLASS_EXPRESSIONS as CLASS_EXPRESSIONS1) = CLASS_EXPRESSIONS1
 ()
 in (
Parsetree.disj
			(Parsetree.mconj (CLASS_EXPRESSION1::CLASS_EXPRESSION2::CLASS_EXPRESSION3::CLASS_EXPRESSIONS))
			(Parsetree.mconj (map Parsetree.neg
				(CLASS_EXPRESSION1::CLASS_EXPRESSION2::CLASS_EXPRESSION3::CLASS_EXPRESSIONS)))
		
)
end)
 in ( LrTable.NT 32, ( result, T_EQUIVALENT_CLASSES1left, 
T_RPAREN1right), rest671)
end
|  ( 60, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSIONS CLASS_EXPRESSIONS1, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION2, _, _)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: ( _, ( 
MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, 
T_DISJOINT_CLASSES1left, _)) :: rest671)) => let val  result = 
MlyValue.DISJOINT_CLASSES (fn _ => let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  CLASS_EXPRESSION1 = CLASS_EXPRESSION1 ()
 val  CLASS_EXPRESSION2 = CLASS_EXPRESSION2 ()
 val  (CLASS_EXPRESSIONS as CLASS_EXPRESSIONS1) = CLASS_EXPRESSIONS1
 ()
 in (
disjointClasses (CLASS_EXPRESSION1::CLASS_EXPRESSION2::CLASS_EXPRESSIONS)
)
end)
 in ( LrTable.NT 33, ( result, T_DISJOINT_CLASSES1left, T_RPAREN1right
), rest671)
end
|  ( 61, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.DISJOINT_CLASS_EXPRESSIONS DISJOINT_CLASS_EXPRESSIONS1, _, _)
) :: ( _, ( MlyValue.CLASS CLASS1, _, _)) :: ( _, ( MlyValue.ntVOID 
AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, T_DISJOINT_UNION1left, _)
) :: rest671)) => let val  result = MlyValue.DISJOINT_UNION (fn _ =>
 let val  AXIOM_ANNOTATIONS1 = AXIOM_ANNOTATIONS1 ()
 val  (CLASS as CLASS1) = CLASS1 ()
 val  (DISJOINT_CLASS_EXPRESSIONS as DISJOINT_CLASS_EXPRESSIONS1) = 
DISJOINT_CLASS_EXPRESSIONS1 ()
 in (disjointUnion CLASS DISJOINT_CLASS_EXPRESSIONS)
end)
 in ( LrTable.NT 34, ( result, T_DISJOINT_UNION1left, T_RPAREN1right),
 rest671)
end
|  ( 62, ( ( _, ( MlyValue.CLASS_EXPRESSIONS CLASS_EXPRESSIONS1, _, 
CLASS_EXPRESSIONS1right)) :: ( _, ( MlyValue.CLASS_EXPRESSION 
CLASS_EXPRESSION2, _, _)) :: ( _, ( MlyValue.CLASS_EXPRESSION 
CLASS_EXPRESSION1, CLASS_EXPRESSION1left, _)) :: rest671)) => let val 
 result = MlyValue.DISJOINT_CLASS_EXPRESSIONS (fn _ => let val  
CLASS_EXPRESSION1 = CLASS_EXPRESSION1 ()
 val  CLASS_EXPRESSION2 = CLASS_EXPRESSION2 ()
 val  (CLASS_EXPRESSIONS as CLASS_EXPRESSIONS1) = CLASS_EXPRESSIONS1
 ()
 in (CLASS_EXPRESSION1::CLASS_EXPRESSION2::CLASS_EXPRESSIONS)
end)
 in ( LrTable.NT 35, ( result, CLASS_EXPRESSION1left, 
CLASS_EXPRESSIONS1right), rest671)
end
|  ( 63, ( ( _, ( MlyValue.ntVOID SUB_OBJECT_PROPERTY_OF1, 
SUB_OBJECT_PROPERTY_OF1left, SUB_OBJECT_PROPERTY_OF1right)) :: rest671
)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
SUB_OBJECT_PROPERTY_OF1 = SUB_OBJECT_PROPERTY_OF1 ()
 in (())
end; ()))
 in ( LrTable.NT 36, ( result, SUB_OBJECT_PROPERTY_OF1left, 
SUB_OBJECT_PROPERTY_OF1right), rest671)
end
|  ( 64, ( ( _, ( MlyValue.ntVOID REFLEXIVE_OBJECT_PROPERTY1, 
REFLEXIVE_OBJECT_PROPERTY1left, REFLEXIVE_OBJECT_PROPERTY1right)) :: 
rest671)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
REFLEXIVE_OBJECT_PROPERTY1 = REFLEXIVE_OBJECT_PROPERTY1 ()
 in (())
end; ()))
 in ( LrTable.NT 36, ( result, REFLEXIVE_OBJECT_PROPERTY1left, 
REFLEXIVE_OBJECT_PROPERTY1right), rest671)
end
|  ( 65, ( ( _, ( MlyValue.ntVOID SYMMETRIC_OBJECT_PROPERTY1, 
SYMMETRIC_OBJECT_PROPERTY1left, SYMMETRIC_OBJECT_PROPERTY1right)) :: 
rest671)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
SYMMETRIC_OBJECT_PROPERTY1 = SYMMETRIC_OBJECT_PROPERTY1 ()
 in (())
end; ()))
 in ( LrTable.NT 36, ( result, SYMMETRIC_OBJECT_PROPERTY1left, 
SYMMETRIC_OBJECT_PROPERTY1right), rest671)
end
|  ( 66, ( ( _, ( MlyValue.ntVOID TRANSITIVE_OBJECT_PROPERTY1, 
TRANSITIVE_OBJECT_PROPERTY1left, TRANSITIVE_OBJECT_PROPERTY1right)) ::
 rest671)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
TRANSITIVE_OBJECT_PROPERTY1 = TRANSITIVE_OBJECT_PROPERTY1 ()
 in (())
end; ()))
 in ( LrTable.NT 36, ( result, TRANSITIVE_OBJECT_PROPERTY1left, 
TRANSITIVE_OBJECT_PROPERTY1right), rest671)
end
|  ( 67, ( ( _, ( MlyValue.OBJECT_PROPERTY_EXPRESSION 
OBJECT_PROPERTY_EXPRESSION1, OBJECT_PROPERTY_EXPRESSION1left, 
OBJECT_PROPERTY_EXPRESSION1right)) :: rest671)) => let val  result = 
MlyValue.SUB_OBJECT_PROPERTY_EXPRESSION (fn _ => let val  (
OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 in (OBJECT_PROPERTY_EXPRESSION)
end)
 in ( LrTable.NT 37, ( result, OBJECT_PROPERTY_EXPRESSION1left, 
OBJECT_PROPERTY_EXPRESSION1right), rest671)
end
|  ( 68, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: ( _, ( MlyValue.SUB_OBJECT_PROPERTY_EXPRESSION 
SUB_OBJECT_PROPERTY_EXPRESSION1, _, _)) :: ( _, ( MlyValue.ntVOID 
AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, T_SUB_PROPERTY_OF1left, _
)) :: rest671)) => let val  result = MlyValue.ntVOID (fn _ => ( let
 val  AXIOM_ANNOTATIONS1 = AXIOM_ANNOTATIONS1 ()
 val  (SUB_OBJECT_PROPERTY_EXPRESSION as 
SUB_OBJECT_PROPERTY_EXPRESSION1) = SUB_OBJECT_PROPERTY_EXPRESSION1 ()
 val  (OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 in (
RelationMgr.setSubrelation (SUB_OBJECT_PROPERTY_EXPRESSION, OBJECT_PROPERTY_EXPRESSION)
)
end; ()))
 in ( LrTable.NT 38, ( result, T_SUB_PROPERTY_OF1left, T_RPAREN1right)
, rest671)
end
|  ( 69, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: ( _, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, (
 _, T_REFLEXIVE_PROPERTY1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  (OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 in (RelationMgr.setReflexive OBJECT_PROPERTY_EXPRESSION)
end; ()))
 in ( LrTable.NT 39, ( result, T_REFLEXIVE_PROPERTY1left, 
T_RPAREN1right), rest671)
end
|  ( 70, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: ( _, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, (
 _, T_SYMMETRIC_PROPERTY1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  (OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 in (RelationMgr.setSymmetric OBJECT_PROPERTY_EXPRESSION)
end; ()))
 in ( LrTable.NT 40, ( result, T_SYMMETRIC_PROPERTY1left, 
T_RPAREN1right), rest671)
end
|  ( 71, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: ( _, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, (
 _, T_TRANSITIVE_PROPERTY1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  AXIOM_ANNOTATIONS1 = 
AXIOM_ANNOTATIONS1 ()
 val  (OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 in (RelationMgr.setTransitive OBJECT_PROPERTY_EXPRESSION)
end; ()))
 in ( LrTable.NT 41, ( result, T_TRANSITIVE_PROPERTY1left, 
T_RPAREN1right), rest671)
end
|  ( 72, ( ( _, ( MlyValue.SAME_INDIVIDUAL SAME_INDIVIDUAL1, 
SAME_INDIVIDUAL1left, SAME_INDIVIDUAL1right)) :: rest671)) => let val 
 result = MlyValue.ASSERTION (fn _ => let val  (SAME_INDIVIDUAL as 
SAME_INDIVIDUAL1) = SAME_INDIVIDUAL1 ()
 in (SAME_INDIVIDUAL)
end)
 in ( LrTable.NT 42, ( result, SAME_INDIVIDUAL1left, 
SAME_INDIVIDUAL1right), rest671)
end
|  ( 73, ( ( _, ( MlyValue.DIFFERENT_INDIVIDUALS 
DIFFERENT_INDIVIDUALS1, DIFFERENT_INDIVIDUALS1left, 
DIFFERENT_INDIVIDUALS1right)) :: rest671)) => let val  result = 
MlyValue.ASSERTION (fn _ => let val  (DIFFERENT_INDIVIDUALS as 
DIFFERENT_INDIVIDUALS1) = DIFFERENT_INDIVIDUALS1 ()
 in (DIFFERENT_INDIVIDUALS)
end)
 in ( LrTable.NT 42, ( result, DIFFERENT_INDIVIDUALS1left, 
DIFFERENT_INDIVIDUALS1right), rest671)
end
|  ( 74, ( ( _, ( MlyValue.CLASS_ASSERTION CLASS_ASSERTION1, 
CLASS_ASSERTION1left, CLASS_ASSERTION1right)) :: rest671)) => let val 
 result = MlyValue.ASSERTION (fn _ => let val  (CLASS_ASSERTION as 
CLASS_ASSERTION1) = CLASS_ASSERTION1 ()
 in (CLASS_ASSERTION)
end)
 in ( LrTable.NT 42, ( result, CLASS_ASSERTION1left, 
CLASS_ASSERTION1right), rest671)
end
|  ( 75, ( ( _, ( MlyValue.OBJECT_PROPERTY_ASSERTION 
OBJECT_PROPERTY_ASSERTION1, OBJECT_PROPERTY_ASSERTION1left, 
OBJECT_PROPERTY_ASSERTION1right)) :: rest671)) => let val  result = 
MlyValue.ASSERTION (fn _ => let val  (OBJECT_PROPERTY_ASSERTION as 
OBJECT_PROPERTY_ASSERTION1) = OBJECT_PROPERTY_ASSERTION1 ()
 in (OBJECT_PROPERTY_ASSERTION)
end)
 in ( LrTable.NT 42, ( result, OBJECT_PROPERTY_ASSERTION1left, 
OBJECT_PROPERTY_ASSERTION1right), rest671)
end
|  ( 76, ( ( _, ( MlyValue.NEGATIVE_OBJECT_PROPERTY_ASSERTION 
NEGATIVE_OBJECT_PROPERTY_ASSERTION1, 
NEGATIVE_OBJECT_PROPERTY_ASSERTION1left, 
NEGATIVE_OBJECT_PROPERTY_ASSERTION1right)) :: rest671)) => let val  
result = MlyValue.ASSERTION (fn _ => let val  (
NEGATIVE_OBJECT_PROPERTY_ASSERTION as 
NEGATIVE_OBJECT_PROPERTY_ASSERTION1) = 
NEGATIVE_OBJECT_PROPERTY_ASSERTION1 ()
 in (NEGATIVE_OBJECT_PROPERTY_ASSERTION)
end)
 in ( LrTable.NT 42, ( result, NEGATIVE_OBJECT_PROPERTY_ASSERTION1left
, NEGATIVE_OBJECT_PROPERTY_ASSERTION1right), rest671)
end
|  ( 77, ( ( _, ( MlyValue.INDIVIDUAL INDIVIDUAL1, INDIVIDUAL1left, 
INDIVIDUAL1right)) :: rest671)) => let val  result = 
MlyValue.SOURCE_INDIVIDUAL (fn _ => let val  (INDIVIDUAL as 
INDIVIDUAL1) = INDIVIDUAL1 ()
 in (INDIVIDUAL)
end)
 in ( LrTable.NT 43, ( result, INDIVIDUAL1left, INDIVIDUAL1right), 
rest671)
end
|  ( 78, ( ( _, ( MlyValue.INDIVIDUAL INDIVIDUAL1, INDIVIDUAL1left, 
INDIVIDUAL1right)) :: rest671)) => let val  result = 
MlyValue.TARGET_INDIVIDUAL (fn _ => let val  (INDIVIDUAL as 
INDIVIDUAL1) = INDIVIDUAL1 ()
 in (INDIVIDUAL)
end)
 in ( LrTable.NT 44, ( result, INDIVIDUAL1left, INDIVIDUAL1right), 
rest671)
end
|  ( 79, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.INDIVIDUALS INDIVIDUALS1, _, _)) :: ( _, ( 
MlyValue.INDIVIDUAL INDIVIDUAL2, _, _)) :: ( _, ( MlyValue.INDIVIDUAL 
INDIVIDUAL1, _, _)) :: _ :: ( _, ( _, T_SAME_INDIVIDUAL1left, _)) :: 
rest671)) => let val  result = MlyValue.SAME_INDIVIDUAL (fn _ => let
 val  INDIVIDUAL1 = INDIVIDUAL1 ()
 val  INDIVIDUAL2 = INDIVIDUAL2 ()
 val  (INDIVIDUALS as INDIVIDUALS1) = INDIVIDUALS1 ()
 in (sameIndividual (INDIVIDUAL1::INDIVIDUAL2::INDIVIDUALS))
end)
 in ( LrTable.NT 45, ( result, T_SAME_INDIVIDUAL1left, T_RPAREN1right)
, rest671)
end
|  ( 80, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.INDIVIDUALS INDIVIDUALS1, _, _)) :: ( _, ( 
MlyValue.INDIVIDUAL INDIVIDUAL2, _, _)) :: ( _, ( MlyValue.INDIVIDUAL 
INDIVIDUAL1, _, _)) :: _ :: ( _, ( _, T_DIFFERENT_INDIVIDUALS1left, _)
) :: rest671)) => let val  result = MlyValue.DIFFERENT_INDIVIDUALS (fn
 _ => let val  INDIVIDUAL1 = INDIVIDUAL1 ()
 val  INDIVIDUAL2 = INDIVIDUAL2 ()
 val  (INDIVIDUALS as INDIVIDUALS1) = INDIVIDUALS1 ()
 in (differentIndividuals (INDIVIDUAL1::INDIVIDUAL2::INDIVIDUALS))
end
)
 in ( LrTable.NT 46, ( result, T_DIFFERENT_INDIVIDUALS1left, 
T_RPAREN1right), rest671)
end
|  ( 81, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.CLASS_EXPRESSION CLASS_EXPRESSION1, _, _)) :: ( _, ( 
MlyValue.INDIVIDUAL INDIVIDUAL1, _, _)) :: ( _, ( MlyValue.ntVOID 
AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, ( _, T_CLASS_ASSERTION1left, _
)) :: rest671)) => let val  result = MlyValue.CLASS_ASSERTION (fn _ =>
 let val  AXIOM_ANNOTATIONS1 = AXIOM_ANNOTATIONS1 ()
 val  (INDIVIDUAL as INDIVIDUAL1) = INDIVIDUAL1 ()
 val  (CLASS_EXPRESSION as CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 in (Parsetree.AT (INDIVIDUAL, CLASS_EXPRESSION))
end)
 in ( LrTable.NT 47, ( result, T_CLASS_ASSERTION1left, T_RPAREN1right)
, rest671)
end
|  ( 82, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.TARGET_INDIVIDUAL TARGET_INDIVIDUAL1, _, _)) :: ( _, ( 
MlyValue.SOURCE_INDIVIDUAL SOURCE_INDIVIDUAL1, _, _)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: ( _, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, (
 _, T_PROPERTY_ASSERTION1left, _)) :: rest671)) => let val  result = 
MlyValue.OBJECT_PROPERTY_ASSERTION (fn _ => let val  
AXIOM_ANNOTATIONS1 = AXIOM_ANNOTATIONS1 ()
 val  (OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 val  (SOURCE_INDIVIDUAL as SOURCE_INDIVIDUAL1) = SOURCE_INDIVIDUAL1
 ()
 val  (TARGET_INDIVIDUAL as TARGET_INDIVIDUAL1) = TARGET_INDIVIDUAL1
 ()
 in (
Parsetree.AT (SOURCE_INDIVIDUAL, Parsetree.DIAMOND (OBJECT_PROPERTY_EXPRESSION, Parsetree.NOMINAL TARGET_INDIVIDUAL))
)
end)
 in ( LrTable.NT 48, ( result, T_PROPERTY_ASSERTION1left, 
T_RPAREN1right), rest671)
end
|  ( 83, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( 
MlyValue.TARGET_INDIVIDUAL TARGET_INDIVIDUAL1, _, _)) :: ( _, ( 
MlyValue.SOURCE_INDIVIDUAL SOURCE_INDIVIDUAL1, _, _)) :: ( _, ( 
MlyValue.OBJECT_PROPERTY_EXPRESSION OBJECT_PROPERTY_EXPRESSION1, _, _)
) :: ( _, ( MlyValue.ntVOID AXIOM_ANNOTATIONS1, _, _)) :: _ :: ( _, (
 _, T_NEGATIVE_PROPERTY_ASSERTION1left, _)) :: rest671)) => let val  
result = MlyValue.NEGATIVE_OBJECT_PROPERTY_ASSERTION (fn _ => let val 
 AXIOM_ANNOTATIONS1 = AXIOM_ANNOTATIONS1 ()
 val  (OBJECT_PROPERTY_EXPRESSION as OBJECT_PROPERTY_EXPRESSION1) = 
OBJECT_PROPERTY_EXPRESSION1 ()
 val  (SOURCE_INDIVIDUAL as SOURCE_INDIVIDUAL1) = SOURCE_INDIVIDUAL1
 ()
 val  (TARGET_INDIVIDUAL as TARGET_INDIVIDUAL1) = TARGET_INDIVIDUAL1
 ()
 in (
Parsetree.AT (SOURCE_INDIVIDUAL, Parsetree.NEG (Parsetree.DIAMOND (OBJECT_PROPERTY_EXPRESSION, Parsetree.NOMINAL TARGET_INDIVIDUAL)))
)
end)
 in ( LrTable.NT 49, ( result, T_NEGATIVE_PROPERTY_ASSERTION1left, 
T_RPAREN1right), rest671)
end
|  ( 84, ( rest671)) => let val  result = MlyValue.CLASS_EXPRESSIONS
 (fn _ => (nil))
 in ( LrTable.NT 50, ( result, defaultPos, defaultPos), rest671)
end
|  ( 85, ( ( _, ( MlyValue.CLASS_EXPRESSIONS CLASS_EXPRESSIONS1, _, 
CLASS_EXPRESSIONS1right)) :: ( _, ( MlyValue.CLASS_EXPRESSION 
CLASS_EXPRESSION1, CLASS_EXPRESSION1left, _)) :: rest671)) => let val 
 result = MlyValue.CLASS_EXPRESSIONS (fn _ => let val  (
CLASS_EXPRESSION as CLASS_EXPRESSION1) = CLASS_EXPRESSION1 ()
 val  (CLASS_EXPRESSIONS as CLASS_EXPRESSIONS1) = CLASS_EXPRESSIONS1
 ()
 in (CLASS_EXPRESSION::CLASS_EXPRESSIONS)
end)
 in ( LrTable.NT 50, ( result, CLASS_EXPRESSION1left, 
CLASS_EXPRESSIONS1right), rest671)
end
|  ( 86, ( rest671)) => let val  result = MlyValue.INDIVIDUALS (fn _
 => (nil))
 in ( LrTable.NT 51, ( result, defaultPos, defaultPos), rest671)
end
|  ( 87, ( ( _, ( MlyValue.INDIVIDUALS INDIVIDUALS1, _, 
INDIVIDUALS1right)) :: ( _, ( MlyValue.INDIVIDUAL INDIVIDUAL1, 
INDIVIDUAL1left, _)) :: rest671)) => let val  result = 
MlyValue.INDIVIDUALS (fn _ => let val  (INDIVIDUAL as INDIVIDUAL1) = 
INDIVIDUAL1 ()
 val  (INDIVIDUALS as INDIVIDUALS1) = INDIVIDUALS1 ()
 in (INDIVIDUAL::INDIVIDUALS)
end)
 in ( LrTable.NT 51, ( result, INDIVIDUAL1left, INDIVIDUALS1right), 
rest671)
end
|  ( 88, ( rest671)) => let val  result = MlyValue.ntVOID (fn _ => (()
))
 in ( LrTable.NT 52, ( result, defaultPos, defaultPos), rest671)
end
|  ( 89, ( ( _, ( MlyValue.ntVOID ANNOTATIONS1, _, ANNOTATIONS1right))
 :: ( _, ( MlyValue.ntVOID ANNOTATION1, ANNOTATION1left, _)) :: 
rest671)) => let val  result = MlyValue.ntVOID (fn _ => ( let val  
ANNOTATION1 = ANNOTATION1 ()
 val  ANNOTATIONS1 = ANNOTATIONS1 ()
 in (())
end; ()))
 in ( LrTable.NT 52, ( result, ANNOTATION1left, ANNOTATIONS1right), 
rest671)
end
|  ( 90, ( rest671)) => let val  result = MlyValue.ntVOID (fn _ => (()
))
 in ( LrTable.NT 53, ( result, defaultPos, defaultPos), rest671)
end
|  ( 91, ( ( _, ( MlyValue.ntVOID PREFIX_DEFINITIONS1, _, 
PREFIX_DEFINITIONS1right)) :: ( _, ( MlyValue.ntVOID 
PREFIX_DEFINITION1, PREFIX_DEFINITION1left, _)) :: rest671)) => let
 val  result = MlyValue.ntVOID (fn _ => ( let val  PREFIX_DEFINITION1
 = PREFIX_DEFINITION1 ()
 val  PREFIX_DEFINITIONS1 = PREFIX_DEFINITIONS1 ()
 in (())
end; ()))
 in ( LrTable.NT 53, ( result, PREFIX_DEFINITION1left, 
PREFIX_DEFINITIONS1right), rest671)
end
|  ( 92, ( rest671)) => let val  result = MlyValue.DIDOA (fn _ => (nil
))
 in ( LrTable.NT 54, ( result, defaultPos, defaultPos), rest671)
end
|  ( 93, ( ( _, ( MlyValue.DIDOA DIDOA1, _, DIDOA1right)) :: ( _, ( 
MlyValue.DIRECTLY_IMPORTS_DOCUMENT DIRECTLY_IMPORTS_DOCUMENT1, 
DIRECTLY_IMPORTS_DOCUMENT1left, _)) :: rest671)) => let val  result = 
MlyValue.DIDOA (fn _ => let val  (DIRECTLY_IMPORTS_DOCUMENT as 
DIRECTLY_IMPORTS_DOCUMENT1) = DIRECTLY_IMPORTS_DOCUMENT1 ()
 val  (DIDOA as DIDOA1) = DIDOA1 ()
 in (DIRECTLY_IMPORTS_DOCUMENT::DIDOA)
end)
 in ( LrTable.NT 54, ( result, DIRECTLY_IMPORTS_DOCUMENT1left, 
DIDOA1right), rest671)
end
|  ( 94, ( ( _, ( MlyValue.DIDOA DIDOA1, _, DIDOA1right)) :: ( _, ( 
MlyValue.ntVOID ANNOTATION1, ANNOTATION1left, _)) :: rest671)) => let
 val  result = MlyValue.DIDOA (fn _ => let val  ANNOTATION1 = 
ANNOTATION1 ()
 val  (DIDOA as DIDOA1) = DIDOA1 ()
 in (DIDOA)
end)
 in ( LrTable.NT 54, ( result, ANNOTATION1left, DIDOA1right), rest671)

end
|  ( 95, ( ( _, ( MlyValue.ntVOID ANNOTATIONS1, ANNOTATIONS1left, 
ANNOTATIONS1right)) :: rest671)) => let val  result = MlyValue.ntVOID
 (fn _ => ( let val  ANNOTATIONS1 = ANNOTATIONS1 ()
 in (())
end; ()))
 in ( LrTable.NT 55, ( result, ANNOTATIONS1left, ANNOTATIONS1right), 
rest671)
end
|  ( 96, ( ( _, ( MlyValue.ntVOID ANNOTATIONS1, ANNOTATIONS1left, 
ANNOTATIONS1right)) :: rest671)) => let val  result = MlyValue.ntVOID
 (fn _ => ( let val  ANNOTATIONS1 = ANNOTATIONS1 ()
 in (())
end; ()))
 in ( LrTable.NT 56, ( result, ANNOTATIONS1left, ANNOTATIONS1right), 
rest671)
end
|  ( 97, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.ntVOID 
ANNOTATIONS_FOR_ENTITY1, _, _)) :: ( _, ( MlyValue.ntVOID ENTITY1, _,
 _)) :: ( _, ( MlyValue.ntVOID ANNOTATIONS_FOR_AXIOM1, _, _)) :: _ :: 
( _, ( _, T_ENTITY_ANNOTATION1left, _)) :: rest671)) => let val  
result = MlyValue.ntVOID (fn _ => ( let val  ANNOTATIONS_FOR_AXIOM1 = 
ANNOTATIONS_FOR_AXIOM1 ()
 val  ENTITY1 = ENTITY1 ()
 val  ANNOTATIONS_FOR_ENTITY1 = ANNOTATIONS_FOR_ENTITY1 ()
 in (())
end; ()))
 in ( LrTable.NT 57, ( result, T_ENTITY_ANNOTATION1left, 
T_RPAREN1right), rest671)
end
|  ( 98, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.CONSTANT 
CONSTANT1, _, _)) :: ( _, ( MlyValue.IRI IRI1, _, _)) :: _ :: ( _, ( _
, T_ANNOTATION1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  IRI1 = IRI1 ()
 val  CONSTANT1 = CONSTANT1 ()
 in (())
end; ()))
 in ( LrTable.NT 58, ( result, T_ANNOTATION1left, T_RPAREN1right), 
rest671)
end
|  ( 99, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.CONSTANT 
CONSTANT1, _, _)) :: _ :: ( _, ( _, T_LABEL1left, _)) :: rest671)) =>
 let val  result = MlyValue.ntVOID (fn _ => ( let val  CONSTANT1 = 
CONSTANT1 ()
 in (())
end; ()))
 in ( LrTable.NT 58, ( result, T_LABEL1left, T_RPAREN1right), rest671)

end
|  ( 100, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.CONSTANT 
CONSTANT1, _, _)) :: _ :: ( _, ( _, T_COMMENT1left, _)) :: rest671))
 => let val  result = MlyValue.ntVOID (fn _ => ( let val  CONSTANT1 = 
CONSTANT1 ()
 in (())
end; ()))
 in ( LrTable.NT 58, ( result, T_COMMENT1left, T_RPAREN1right), 
rest671)
end
|  ( 101, ( ( _, ( _, _, T_RPAREN1right)) :: ( _, ( MlyValue.ntVOID 
ENTITY1, _, _)) :: ( _, ( MlyValue.IRI IRI1, _, _)) :: _ :: ( _, ( _, 
T_ANNOTATION1left, _)) :: rest671)) => let val  result = 
MlyValue.ntVOID (fn _ => ( let val  IRI1 = IRI1 ()
 val  ENTITY1 = ENTITY1 ()
 in (())
end; ()))
 in ( LrTable.NT 59, ( result, T_ANNOTATION1left, T_RPAREN1right), 
rest671)
end
|  ( 102, ( ( _, ( MlyValue.IRI IRI1, IRI1left, IRI1right)) :: rest671
)) => let val  result = MlyValue.CONSTANT (fn _ => let val  (IRI as 
IRI1) = IRI1 ()
 in ((IRI))
end)
 in ( LrTable.NT 60, ( result, IRI1left, IRI1right), rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.ONTOLOGY_DOCUMENT x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : OwlFs_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun T_XSTRING (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.T_XSTRING (fn () => i),p1,p2))
fun T_INTERSECTION_OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.VOID,p1,p2))
fun T_UNION_OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.VOID,p1,p2))
fun T_COMPLEMENT_OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.VOID,p1,p2))
fun T_ONE_OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun T_SOME_VALUES_FROM (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun T_ALL_VALUES_FROM (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun T_HAS_VALUE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun T_SUB_CLASS_OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun T_EQUIVALENT_CLASSES (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9
,(ParserData.MlyValue.VOID,p1,p2))
fun T_DISJOINT_CLASSES (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10
,(ParserData.MlyValue.VOID,p1,p2))
fun T_DISJOINT_UNION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun T_SUB_PROPERTY_OF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun T_REFLEXIVE_PROPERTY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 
13,(ParserData.MlyValue.VOID,p1,p2))
fun T_SYMMETRIC_PROPERTY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 
14,(ParserData.MlyValue.VOID,p1,p2))
fun T_TRANSITIVE_PROPERTY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 
15,(ParserData.MlyValue.VOID,p1,p2))
fun T_SAME_INDIVIDUAL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 16,(
ParserData.MlyValue.VOID,p1,p2))
fun T_DIFFERENT_INDIVIDUALS (p1,p2) = Token.TOKEN (
ParserData.LrTable.T 17,(ParserData.MlyValue.VOID,p1,p2))
fun T_CLASS_ASSERTION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 18,(
ParserData.MlyValue.VOID,p1,p2))
fun T_PROPERTY_ASSERTION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 
19,(ParserData.MlyValue.VOID,p1,p2))
fun T_NEGATIVE_PROPERTY_ASSERTION (p1,p2) = Token.TOKEN (
ParserData.LrTable.T 20,(ParserData.MlyValue.VOID,p1,p2))
fun T_NAMESPACE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 21,(
ParserData.MlyValue.VOID,p1,p2))
fun T_ONTOLOGY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 22,(
ParserData.MlyValue.VOID,p1,p2))
fun T_IMPORTS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 23,(
ParserData.MlyValue.VOID,p1,p2))
fun T_ANNOTATION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 24,(
ParserData.MlyValue.VOID,p1,p2))
fun T_DECLARATION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 25,(
ParserData.MlyValue.VOID,p1,p2))
fun T_CLASS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 26,(
ParserData.MlyValue.VOID,p1,p2))
fun T_OBJECT_PROPERTY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 27,(
ParserData.MlyValue.VOID,p1,p2))
fun T_ANNOTATION_PROPERTY (p1,p2) = Token.TOKEN (ParserData.LrTable.T 
28,(ParserData.MlyValue.VOID,p1,p2))
fun T_NAMED_INDIVIDUAL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 29
,(ParserData.MlyValue.VOID,p1,p2))
fun T_TOP (p1,p2) = Token.TOKEN (ParserData.LrTable.T 30,(
ParserData.MlyValue.VOID,p1,p2))
fun T_BOTTOM (p1,p2) = Token.TOKEN (ParserData.LrTable.T 31,(
ParserData.MlyValue.VOID,p1,p2))
fun T_NON_NEGATIVE_INTEGER (i,p1,p2) = Token.TOKEN (
ParserData.LrTable.T 32,(ParserData.MlyValue.T_NON_NEGATIVE_INTEGER
 (fn () => i),p1,p2))
fun T_ENTITY_ANNOTATION (p1,p2) = Token.TOKEN (ParserData.LrTable.T 33
,(ParserData.MlyValue.VOID,p1,p2))
fun T_LABEL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 34,(
ParserData.MlyValue.VOID,p1,p2))
fun T_COMMENT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 35,(
ParserData.MlyValue.VOID,p1,p2))
fun T_LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 36,(
ParserData.MlyValue.VOID,p1,p2))
fun T_RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 37,(
ParserData.MlyValue.VOID,p1,p2))
fun T_EQS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 38,(
ParserData.MlyValue.VOID,p1,p2))
fun T_STRING (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 39,(
ParserData.MlyValue.T_STRING (fn () => i),p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 40,(
ParserData.MlyValue.VOID,p1,p2))
end
end
