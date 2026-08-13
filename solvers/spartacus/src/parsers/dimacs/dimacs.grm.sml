functor DimacsLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : Dimacs_TOKENS
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




end
structure LrTable = Token.LrTable
structure Token = Token
local open LrTable in 
val table=let val actionRows =
"\
\\001\000\001\000\009\000\004\000\008\000\000\000\
\\001\000\001\000\017\000\002\000\016\000\003\000\015\000\004\000\014\000\
\\005\000\013\000\006\000\012\000\007\000\011\000\000\000\
\\001\000\001\000\020\000\000\000\
\\001\000\007\000\022\000\000\000\
\\001\000\007\000\023\000\000\000\
\\001\000\007\000\024\000\000\000\
\\001\000\007\000\025\000\000\000\
\\001\000\007\000\026\000\000\000\
\\001\000\008\000\028\000\000\000\
\\001\000\008\000\036\000\000\000\
\\001\000\008\000\037\000\000\000\
\\001\000\008\000\038\000\000\000\
\\001\000\008\000\039\000\000\000\
\\001\000\008\000\040\000\000\000\
\\001\000\009\000\019\000\000\000\
\\001\000\010\000\000\000\011\000\000\000\000\000\
\\001\000\012\000\004\000\013\000\003\000\000\000\
\\042\000\000\000\
\\043\000\000\000\
\\044\000\001\000\009\000\004\000\008\000\000\000\
\\045\000\000\000\
\\046\000\001\000\009\000\004\000\008\000\000\000\
\\047\000\000\000\
\\048\000\000\000\
\\049\000\000\000\
\\050\000\000\000\
\\051\000\000\000\
\\052\000\000\000\
\\053\000\000\000\
\\054\000\000\000\
\\055\000\000\000\
\\056\000\000\000\
\\057\000\001\000\017\000\002\000\016\000\003\000\015\000\004\000\014\000\
\\005\000\013\000\006\000\012\000\007\000\011\000\000\000\
\\058\000\000\000\
\"
val actionRowNumbers =
"\016\000\000\000\001\000\021\000\
\\014\000\017\000\002\000\023\000\
\\018\000\001\000\003\000\004\000\
\\005\000\006\000\007\000\025\000\
\\022\000\019\000\024\000\008\000\
\\001\000\001\000\001\000\001\000\
\\001\000\020\000\026\000\032\000\
\\009\000\010\000\011\000\012\000\
\\013\000\033\000\031\000\030\000\
\\027\000\029\000\028\000\015\000"
val gotoT =
"\
\\001\000\039\000\000\000\
\\004\000\005\000\005\000\004\000\006\000\003\000\000\000\
\\003\000\008\000\000\000\
\\005\000\016\000\006\000\003\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\019\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\004\000\025\000\005\000\004\000\006\000\003\000\000\000\
\\000\000\
\\000\000\
\\002\000\028\000\003\000\027\000\000\000\
\\002\000\029\000\003\000\027\000\000\000\
\\003\000\030\000\000\000\
\\002\000\031\000\003\000\027\000\000\000\
\\002\000\032\000\003\000\027\000\000\000\
\\000\000\
\\000\000\
\\002\000\033\000\003\000\027\000\000\000\
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
\"
val numstates = 40
val numrules = 17
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
 | VAR of unit ->  (string)
 | LITERAL of unit ->  (Parsetree.parsetree)
 | CLAUSE of unit ->  (Parsetree.parsetree list)
 | CLAUSES of unit ->  (Parsetree.parsetree list)
 | FORMULA of unit ->  (Parsetree.parsetree)
 | FLIST of unit ->  (Parsetree.parsetree list)
 | START of unit ->  (Parsetree.parsetree)
end
type svalue = MlyValue.svalue
type result = Parsetree.parsetree
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
fn (T 9) => true | _ => false
val showTerminal =
fn (T 0) => "VAR"
  | (T 1) => "AND"
  | (T 2) => "OR"
  | (T 3) => "NOT"
  | (T 4) => "XOR"
  | (T 5) => "EQUAL"
  | (T 6) => "LPAREN"
  | (T 7) => "RPAREN"
  | (T 8) => "ZERO"
  | (T 9) => "EOF"
  | (T 10) => "END"
  | (T 11) => "SAT"
  | (T 12) => "CNF"
  | (T 13) => "P"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 13) $$ (T 12) $$ (T 11) $$ (T 10) $$ (T 9) $$ (T 8) $$ (T 7)
 $$ (T 6) $$ (T 5) $$ (T 4) $$ (T 3) $$ (T 2) $$ (T 1)end
structure Actions =
struct 
type int = Int.int
exception mlyAction of int
local open Header in
val actions = 
fn (i392:int,defaultPos,stack,
    (()):arg) =>
case (i392,stack)
of  ( 0, ( ( _, ( MlyValue.CLAUSES CLAUSES1, _, CLAUSES1right)) :: ( _
, ( _, CNF1left, _)) :: rest671)) => let val  result = MlyValue.START
 (fn _ => let val  (CLAUSES as CLAUSES1) = CLAUSES1 ()
 in (Parsetree.mconj CLAUSES)
end)
 in ( LrTable.NT 0, ( result, CNF1left, CLAUSES1right), rest671)
end
|  ( 1, ( ( _, ( MlyValue.FORMULA FORMULA1, _, FORMULA1right)) :: ( _,
 ( _, SAT1left, _)) :: rest671)) => let val  result = MlyValue.START
 (fn _ => let val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (FORMULA)
end)
 in ( LrTable.NT 0, ( result, SAT1left, FORMULA1right), rest671)
end
|  ( 2, ( ( _, ( _, _, ZERO1right)) :: ( _, ( MlyValue.CLAUSE CLAUSE1,
 CLAUSE1left, _)) :: rest671)) => let val  result = MlyValue.CLAUSES
 (fn _ => let val  (CLAUSE as CLAUSE1) = CLAUSE1 ()
 in ([Parsetree.mdisj CLAUSE])
end)
 in ( LrTable.NT 3, ( result, CLAUSE1left, ZERO1right), rest671)
end
|  ( 3, ( ( _, ( MlyValue.CLAUSES CLAUSES1, _, CLAUSES1right)) :: _ ::
 ( _, ( MlyValue.CLAUSE CLAUSE1, CLAUSE1left, _)) :: rest671)) => let
 val  result = MlyValue.CLAUSES (fn _ => let val  (CLAUSE as CLAUSE1)
 = CLAUSE1 ()
 val  (CLAUSES as CLAUSES1) = CLAUSES1 ()
 in ((Parsetree.mdisj CLAUSE)::CLAUSES)
end)
 in ( LrTable.NT 3, ( result, CLAUSE1left, CLAUSES1right), rest671)

end
|  ( 4, ( ( _, ( MlyValue.LITERAL LITERAL1, LITERAL1left, 
LITERAL1right)) :: rest671)) => let val  result = MlyValue.CLAUSE (fn
 _ => let val  (LITERAL as LITERAL1) = LITERAL1 ()
 in ([LITERAL])
end)
 in ( LrTable.NT 4, ( result, LITERAL1left, LITERAL1right), rest671)

end
|  ( 5, ( ( _, ( MlyValue.CLAUSE CLAUSE1, _, CLAUSE1right)) :: ( _, ( 
MlyValue.LITERAL LITERAL1, LITERAL1left, _)) :: rest671)) => let val  
result = MlyValue.CLAUSE (fn _ => let val  (LITERAL as LITERAL1) = 
LITERAL1 ()
 val  (CLAUSE as CLAUSE1) = CLAUSE1 ()
 in (LITERAL::CLAUSE)
end)
 in ( LrTable.NT 4, ( result, LITERAL1left, CLAUSE1right), rest671)

end
|  ( 6, ( ( _, ( MlyValue.VAR VAR1, VAR1left, VAR1right)) :: rest671))
 => let val  result = MlyValue.LITERAL (fn _ => let val  (VAR as VAR1)
 = VAR1 ()
 in (Parsetree.PROPVAR ("p" ^ VAR))
end)
 in ( LrTable.NT 5, ( result, VAR1left, VAR1right), rest671)
end
|  ( 7, ( ( _, ( MlyValue.VAR VAR1, _, VAR1right)) :: ( _, ( _, 
NOT1left, _)) :: rest671)) => let val  result = MlyValue.LITERAL (fn _
 => let val  (VAR as VAR1) = VAR1 ()
 in (Parsetree.neg (Parsetree.PROPVAR ("p" ^ VAR)))
end)
 in ( LrTable.NT 5, ( result, NOT1left, VAR1right), rest671)
end
|  ( 8, ( ( _, ( MlyValue.VAR VAR1, VAR1left, VAR1right)) :: rest671))
 => let val  result = MlyValue.FORMULA (fn _ => let val  (VAR as VAR1)
 = VAR1 ()
 in (Parsetree.PROPVAR ("p" ^ VAR))
end)
 in ( LrTable.NT 2, ( result, VAR1left, VAR1right), rest671)
end
|  ( 9, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.FORMULA (fn _ => let val  (FORMULA as FORMULA1
) = FORMULA1 ()
 in (FORMULA)
end)
 in ( LrTable.NT 2, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 10, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: ( _, ( _, NOT1left, _)) :: rest671)) => let
 val  result = MlyValue.FORMULA (fn _ => let val  (FORMULA as FORMULA1
) = FORMULA1 ()
 in (Parsetree.neg FORMULA)
end)
 in ( LrTable.NT 2, ( result, NOT1left, RPAREN1right), rest671)
end
|  ( 11, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FLIST FLIST1
, _, _)) :: _ :: ( _, ( _, AND1left, _)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (FLIST as FLIST1) = FLIST1
 ()
 in (Parsetree.mconj FLIST)
end)
 in ( LrTable.NT 2, ( result, AND1left, RPAREN1right), rest671)
end
|  ( 12, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FLIST FLIST1
, _, _)) :: _ :: ( _, ( _, OR1left, _)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (FLIST as FLIST1) = FLIST1
 ()
 in (Parsetree.mdisj FLIST)
end)
 in ( LrTable.NT 2, ( result, OR1left, RPAREN1right), rest671)
end
|  ( 13, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FLIST FLIST1
, _, _)) :: _ :: ( _, ( _, XOR1left, _)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (FLIST as FLIST1) = FLIST1
 ()
 in (Parsetree.mxor FLIST)
end)
 in ( LrTable.NT 2, ( result, XOR1left, RPAREN1right), rest671)
end
|  ( 14, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FLIST FLIST1
, _, _)) :: _ :: ( _, ( _, EQUAL1left, _)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (FLIST as FLIST1) = FLIST1
 ()
 in (Parsetree.mequal FLIST)
end)
 in ( LrTable.NT 2, ( result, EQUAL1left, RPAREN1right), rest671)
end
|  ( 15, ( ( _, ( MlyValue.FORMULA FORMULA1, FORMULA1left, 
FORMULA1right)) :: rest671)) => let val  result = MlyValue.FLIST (fn _
 => let val  (FORMULA as FORMULA1) = FORMULA1 ()
 in ([FORMULA])
end)
 in ( LrTable.NT 1, ( result, FORMULA1left, FORMULA1right), rest671)

end
|  ( 16, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( 
MlyValue.FORMULA FORMULA1, FORMULA1left, _)) :: rest671)) => let val  
result = MlyValue.FLIST (fn _ => let val  (FORMULA as FORMULA1) = 
FORMULA1 ()
 val  (FLIST as FLIST1) = FLIST1 ()
 in (FORMULA::FLIST)
end)
 in ( LrTable.NT 1, ( result, FORMULA1left, FLIST1right), rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.START x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : Dimacs_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun VAR (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.VAR (fn () => i),p1,p2))
fun AND (p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.VOID,p1,p2))
fun OR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.VOID,p1,p2))
fun NOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.VOID,p1,p2))
fun XOR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun EQUAL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun ZERO (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun END (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun SAT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun CNF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun P (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
end
end
