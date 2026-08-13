functor IntohyloLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : Intohylo_TOKENS
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
\\001\000\001\000\026\000\002\000\025\000\004\000\024\000\005\000\023\000\
\\008\000\022\000\009\000\021\000\010\000\020\000\011\000\019\000\
\\013\000\018\000\015\000\017\000\019\000\016\000\020\000\015\000\
\\021\000\014\000\022\000\013\000\024\000\012\000\000\000\
\\001\000\002\000\033\000\000\000\
\\001\000\003\000\038\000\000\000\
\\001\000\003\000\039\000\000\000\
\\001\000\012\000\053\000\000\000\
\\001\000\014\000\052\000\000\000\
\\001\000\016\000\051\000\000\000\
\\001\000\026\000\000\000\027\000\000\000\000\000\
\\001\000\027\000\032\000\000\000\
\\058\000\000\000\
\\059\000\025\000\031\000\000\000\
\\060\000\000\000\
\\061\000\000\000\
\\062\000\000\000\
\\063\000\000\000\
\\064\000\000\000\
\\065\000\023\000\044\000\000\000\
\\066\000\000\000\
\\067\000\000\000\
\\068\000\000\000\
\\069\000\000\000\
\\070\000\000\000\
\\071\000\000\000\
\\072\000\000\000\
\\073\000\000\000\
\\074\000\006\000\027\000\000\000\
\\075\000\000\000\
\\076\000\007\000\030\000\000\000\
\\077\000\000\000\
\\078\000\017\000\029\000\000\000\
\\079\000\000\000\
\\080\000\018\000\028\000\000\000\
\\081\000\000\000\
\\082\000\000\000\
\\083\000\000\000\
\\084\000\000\000\
\\085\000\000\000\
\\086\000\000\000\
\\087\000\000\000\
\"
val actionRowNumbers =
"\000\000\018\000\017\000\025\000\
\\012\000\031\000\029\000\027\000\
\\010\000\008\000\001\000\000\000\
\\000\000\000\000\000\000\002\000\
\\003\000\000\000\000\000\000\000\
\\000\000\014\000\013\000\016\000\
\\015\000\000\000\000\000\000\000\
\\000\000\000\000\009\000\000\000\
\\022\000\021\000\020\000\019\000\
\\006\000\005\000\004\000\035\000\
\\033\000\024\000\000\000\026\000\
\\032\000\030\000\028\000\011\000\
\\038\000\000\000\000\000\023\000\
\\037\000\036\000\034\000\007\000"
val gotoT =
"\
\\001\000\055\000\002\000\009\000\003\000\008\000\004\000\007\000\
\\005\000\006\000\006\000\005\000\007\000\004\000\008\000\003\000\
\\009\000\002\000\010\000\001\000\000\000\
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
\\008\000\032\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\033\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\034\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\035\000\009\000\002\000\010\000\001\000\000\000\
\\000\000\
\\000\000\
\\003\000\038\000\004\000\007\000\005\000\006\000\006\000\005\000\
\\007\000\004\000\008\000\003\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\039\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\040\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\041\000\009\000\002\000\010\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\004\000\043\000\008\000\003\000\009\000\002\000\010\000\001\000\000\000\
\\004\000\007\000\005\000\006\000\006\000\005\000\007\000\044\000\
\\008\000\003\000\009\000\002\000\010\000\001\000\000\000\
\\004\000\007\000\005\000\006\000\006\000\045\000\008\000\003\000\
\\009\000\002\000\010\000\001\000\000\000\
\\004\000\007\000\005\000\046\000\008\000\003\000\009\000\002\000\
\\010\000\001\000\000\000\
\\002\000\047\000\003\000\008\000\004\000\007\000\005\000\006\000\
\\006\000\005\000\007\000\004\000\008\000\003\000\009\000\002\000\
\\010\000\001\000\000\000\
\\000\000\
\\008\000\048\000\009\000\002\000\010\000\001\000\000\000\
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
\\008\000\052\000\009\000\002\000\010\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\008\000\053\000\009\000\002\000\010\000\001\000\000\000\
\\008\000\054\000\009\000\002\000\010\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\"
val numstates = 56
val numrules = 30
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
 | RELATION of unit ->  (string) | NOMINAL of unit ->  (string)
 | PROPOSITION of unit ->  (string)
 | ATOP of unit ->  (Parsetree.parsetree)
 | MOP of unit ->  (Parsetree.parsetree)
 | OTHER of unit ->  (Parsetree.parsetree)
 | DIMPLICATION of unit ->  (Parsetree.parsetree)
 | IMPLICATION of unit ->  (Parsetree.parsetree)
 | DISJUNCTION of unit ->  (Parsetree.parsetree)
 | CONJUNCTION of unit ->  (Parsetree.parsetree)
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
fn (T 25) => true | _ => false
val showTerminal =
fn (T 0) => "PROPOSITION"
  | (T 1) => "NOMINAL"
  | (T 2) => "RELATION"
  | (T 3) => "TRUE"
  | (T 4) => "FALSE"
  | (T 5) => "AND"
  | (T 6) => "OR"
  | (T 7) => "NOT"
  | (T 8) => "BOX"
  | (T 9) => "DIA"
  | (T 10) => "LPAREN"
  | (T 11) => "RPAREN"
  | (T 12) => "LBRACKET"
  | (T 13) => "RBRACKET"
  | (T 14) => "LCHEVRON"
  | (T 15) => "RCHEVRON"
  | (T 16) => "IMPL"
  | (T 17) => "DIMPL"
  | (T 18) => "ALL"
  | (T 19) => "EXISTS"
  | (T 20) => "DIFF"
  | (T 21) => "NEGDIFF"
  | (T 22) => "COLON"
  | (T 23) => "AT"
  | (T 24) => "SEMI"
  | (T 25) => "EOF"
  | (T 26) => "END"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 26) $$ (T 25) $$ (T 24) $$ (T 23) $$ (T 22) $$ (T 21) $$ (T 20)
 $$ (T 19) $$ (T 18) $$ (T 17) $$ (T 16) $$ (T 15) $$ (T 14) $$ (T 13)
 $$ (T 12) $$ (T 11) $$ (T 10) $$ (T 9) $$ (T 8) $$ (T 7) $$ (T 6) $$ 
(T 5) $$ (T 4) $$ (T 3)end
structure Actions =
struct 
type int = Int.int
exception mlyAction of int
local open Header in
val actions = 
fn (i392:int,defaultPos,stack,
    (()):arg) =>
case (i392,stack)
of  ( 0, ( ( _, ( _, _, END1right)) :: ( _, ( MlyValue.FLIST FLIST1, 
FLIST1left, _)) :: rest671)) => let val  result = MlyValue.START (fn _
 => let val  (FLIST as FLIST1) = FLIST1 ()
 in (Parsetree.mconj FLIST)
end)
 in ( LrTable.NT 0, ( result, FLIST1left, END1right), rest671)
end
|  ( 1, ( ( _, ( MlyValue.FORMULA FORMULA1, FORMULA1left, 
FORMULA1right)) :: rest671)) => let val  result = MlyValue.FLIST (fn _
 => let val  (FORMULA as FORMULA1) = FORMULA1 ()
 in ([FORMULA])
end)
 in ( LrTable.NT 1, ( result, FORMULA1left, FORMULA1right), rest671)

end
|  ( 2, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: _ :: ( _, 
( MlyValue.FORMULA FORMULA1, FORMULA1left, _)) :: rest671)) => let
 val  result = MlyValue.FLIST (fn _ => let val  (FORMULA as FORMULA1)
 = FORMULA1 ()
 val  (FLIST as FLIST1) = FLIST1 ()
 in (FORMULA::FLIST)
end)
 in ( LrTable.NT 1, ( result, FORMULA1left, FLIST1right), rest671)
end
|  ( 3, ( ( _, ( MlyValue.DIMPLICATION DIMPLICATION1, 
DIMPLICATION1left, DIMPLICATION1right)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (DIMPLICATION as 
DIMPLICATION1) = DIMPLICATION1 ()
 in (DIMPLICATION)
end)
 in ( LrTable.NT 2, ( result, DIMPLICATION1left, DIMPLICATION1right), 
rest671)
end
|  ( 4, ( ( _, ( _, TRUE1left, TRUE1right)) :: rest671)) => let val  
result = MlyValue.OTHER (fn _ => (Parsetree.mconj nil))
 in ( LrTable.NT 7, ( result, TRUE1left, TRUE1right), rest671)
end
|  ( 5, ( ( _, ( _, FALSE1left, FALSE1right)) :: rest671)) => let val 
 result = MlyValue.OTHER (fn _ => (Parsetree.mdisj nil))
 in ( LrTable.NT 7, ( result, FALSE1left, FALSE1right), rest671)
end
|  ( 6, ( ( _, ( MlyValue.PROPOSITION PROPOSITION1, PROPOSITION1left, 
PROPOSITION1right)) :: rest671)) => let val  result = MlyValue.OTHER
 (fn _ => let val  (PROPOSITION as PROPOSITION1) = PROPOSITION1 ()
 in (Parsetree.PROPVAR PROPOSITION)
end)
 in ( LrTable.NT 7, ( result, PROPOSITION1left, PROPOSITION1right), 
rest671)
end
|  ( 7, ( ( _, ( MlyValue.NOMINAL NOMINAL1, NOMINAL1left, 
NOMINAL1right)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (NOMINAL as NOMINAL1) = NOMINAL1 ()
 in (Parsetree.NOMINAL NOMINAL)
end)
 in ( LrTable.NT 7, ( result, NOMINAL1left, NOMINAL1right), rest671)

end
|  ( 8, ( ( _, ( MlyValue.MOP MOP1, MOP1left, MOP1right)) :: rest671))
 => let val  result = MlyValue.OTHER (fn _ => let val  (MOP as MOP1) =
 MOP1 ()
 in (MOP)
end)
 in ( LrTable.NT 7, ( result, MOP1left, MOP1right), rest671)
end
|  ( 9, ( ( _, ( MlyValue.ATOP ATOP1, ATOP1left, ATOP1right)) :: 
rest671)) => let val  result = MlyValue.OTHER (fn _ => let val  (ATOP
 as ATOP1) = ATOP1 ()
 in (ATOP)
end)
 in ( LrTable.NT 7, ( result, ATOP1left, ATOP1right), rest671)
end
|  ( 10, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 ALL1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.ALL OTHER)
end)
 in ( LrTable.NT 7, ( result, ALL1left, OTHER1right), rest671)
end
|  ( 11, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 EXISTS1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn
 _ => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.EXISTS OTHER)
end)
 in ( LrTable.NT 7, ( result, EXISTS1left, OTHER1right), rest671)
end
|  ( 12, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 DIFF1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.DIFF OTHER)
end)
 in ( LrTable.NT 7, ( result, DIFF1left, OTHER1right), rest671)
end
|  ( 13, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 NEGDIFF1left, _)) :: rest671)) => let val  result = MlyValue.OTHER
 (fn _ => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.NEGDIFF OTHER)
end)
 in ( LrTable.NT 7, ( result, NEGDIFF1left, OTHER1right), rest671)
end
|  ( 14, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.OTHER (fn _ => let val  (FORMULA as FORMULA1)
 = FORMULA1 ()
 in (FORMULA)
end)
 in ( LrTable.NT 7, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 15, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 NOT1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.neg OTHER)
end)
 in ( LrTable.NT 7, ( result, NOT1left, OTHER1right), rest671)
end
|  ( 16, ( ( _, ( MlyValue.OTHER OTHER1, OTHER1left, OTHER1right)) :: 
rest671)) => let val  result = MlyValue.CONJUNCTION (fn _ => let val 
 (OTHER as OTHER1) = OTHER1 ()
 in (OTHER)
end)
 in ( LrTable.NT 3, ( result, OTHER1left, OTHER1right), rest671)
end
|  ( 17, ( ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, _, 
CONJUNCTION1right)) :: _ :: ( _, ( MlyValue.OTHER OTHER1, OTHER1left,
 _)) :: rest671)) => let val  result = MlyValue.CONJUNCTION (fn _ =>
 let val  (OTHER as OTHER1) = OTHER1 ()
 val  (CONJUNCTION as CONJUNCTION1) = CONJUNCTION1 ()
 in (Parsetree.conj OTHER CONJUNCTION)
end)
 in ( LrTable.NT 3, ( result, OTHER1left, CONJUNCTION1right), rest671)

end
|  ( 18, ( ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, CONJUNCTION1left,
 CONJUNCTION1right)) :: rest671)) => let val  result = 
MlyValue.DISJUNCTION (fn _ => let val  (CONJUNCTION as CONJUNCTION1) =
 CONJUNCTION1 ()
 in (CONJUNCTION)
end)
 in ( LrTable.NT 4, ( result, CONJUNCTION1left, CONJUNCTION1right), 
rest671)
end
|  ( 19, ( ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, _, 
DISJUNCTION1right)) :: _ :: ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, 
CONJUNCTION1left, _)) :: rest671)) => let val  result = 
MlyValue.DISJUNCTION (fn _ => let val  (CONJUNCTION as CONJUNCTION1) =
 CONJUNCTION1 ()
 val  (DISJUNCTION as DISJUNCTION1) = DISJUNCTION1 ()
 in (Parsetree.disj CONJUNCTION DISJUNCTION)
end)
 in ( LrTable.NT 4, ( result, CONJUNCTION1left, DISJUNCTION1right), 
rest671)
end
|  ( 20, ( ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, DISJUNCTION1left,
 DISJUNCTION1right)) :: rest671)) => let val  result = 
MlyValue.IMPLICATION (fn _ => let val  (DISJUNCTION as DISJUNCTION1) =
 DISJUNCTION1 ()
 in (DISJUNCTION)
end)
 in ( LrTable.NT 5, ( result, DISJUNCTION1left, DISJUNCTION1right), 
rest671)
end
|  ( 21, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, _, 
IMPLICATION1right)) :: _ :: ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, 
DISJUNCTION1left, _)) :: rest671)) => let val  result = 
MlyValue.IMPLICATION (fn _ => let val  (DISJUNCTION as DISJUNCTION1) =
 DISJUNCTION1 ()
 val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 in (Parsetree.impl DISJUNCTION IMPLICATION)
end)
 in ( LrTable.NT 5, ( result, DISJUNCTION1left, IMPLICATION1right), 
rest671)
end
|  ( 22, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, IMPLICATION1left,
 IMPLICATION1right)) :: rest671)) => let val  result = 
MlyValue.DIMPLICATION (fn _ => let val  (IMPLICATION as IMPLICATION1)
 = IMPLICATION1 ()
 in (IMPLICATION)
end)
 in ( LrTable.NT 6, ( result, IMPLICATION1left, IMPLICATION1right), 
rest671)
end
|  ( 23, ( ( _, ( MlyValue.DIMPLICATION DIMPLICATION1, _, 
DIMPLICATION1right)) :: _ :: ( _, ( MlyValue.IMPLICATION IMPLICATION1,
 IMPLICATION1left, _)) :: rest671)) => let val  result = 
MlyValue.DIMPLICATION (fn _ => let val  (IMPLICATION as IMPLICATION1)
 = IMPLICATION1 ()
 val  (DIMPLICATION as DIMPLICATION1) = DIMPLICATION1 ()
 in (Parsetree.dimpl IMPLICATION DIMPLICATION)
end)
 in ( LrTable.NT 6, ( result, IMPLICATION1left, DIMPLICATION1right), 
rest671)
end
|  ( 24, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 BOX1left, _)) :: rest671)) => let val  result = MlyValue.MOP (fn _ =>
 let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.BOX ("rx", OTHER))
end)
 in ( LrTable.NT 8, ( result, BOX1left, OTHER1right), rest671)
end
|  ( 25, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: _ :: ( _,
 ( MlyValue.RELATION RELATION1, _, _)) :: ( _, ( _, LBRACKET1left, _))
 :: rest671)) => let val  result = MlyValue.MOP (fn _ => let val  (
RELATION as RELATION1) = RELATION1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.BOX (RELATION, OTHER))
end)
 in ( LrTable.NT 8, ( result, LBRACKET1left, OTHER1right), rest671)

end
|  ( 26, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 DIA1left, _)) :: rest671)) => let val  result = MlyValue.MOP (fn _ =>
 let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.DIAMOND ("rx", OTHER))
end)
 in ( LrTable.NT 8, ( result, DIA1left, OTHER1right), rest671)
end
|  ( 27, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: _ :: ( _,
 ( MlyValue.RELATION RELATION1, _, _)) :: ( _, ( _, LCHEVRON1left, _))
 :: rest671)) => let val  result = MlyValue.MOP (fn _ => let val  (
RELATION as RELATION1) = RELATION1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.DIAMOND (RELATION, OTHER))
end)
 in ( LrTable.NT 8, ( result, LCHEVRON1left, OTHER1right), rest671)

end
|  ( 28, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: _ :: ( _,
 ( MlyValue.NOMINAL NOMINAL1, NOMINAL1left, _)) :: rest671)) => let
 val  result = MlyValue.ATOP (fn _ => let val  (NOMINAL as NOMINAL1) =
 NOMINAL1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.AT (NOMINAL, OTHER))
end)
 in ( LrTable.NT 9, ( result, NOMINAL1left, OTHER1right), rest671)
end
|  ( 29, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( 
MlyValue.NOMINAL NOMINAL1, _, _)) :: ( _, ( _, AT1left, _)) :: rest671
)) => let val  result = MlyValue.ATOP (fn _ => let val  (NOMINAL as 
NOMINAL1) = NOMINAL1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.AT (NOMINAL, OTHER))
end)
 in ( LrTable.NT 9, ( result, AT1left, OTHER1right), rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.START x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : Intohylo_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun PROPOSITION (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.PROPOSITION (fn () => i),p1,p2))
fun NOMINAL (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.NOMINAL (fn () => i),p1,p2))
fun RELATION (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.RELATION (fn () => i),p1,p2))
fun TRUE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.VOID,p1,p2))
fun FALSE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun AND (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun OR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun NOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun BOX (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun DIA (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun LBRACKET (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun RBRACKET (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
fun LCHEVRON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 14,(
ParserData.MlyValue.VOID,p1,p2))
fun RCHEVRON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 15,(
ParserData.MlyValue.VOID,p1,p2))
fun IMPL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 16,(
ParserData.MlyValue.VOID,p1,p2))
fun DIMPL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 17,(
ParserData.MlyValue.VOID,p1,p2))
fun ALL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 18,(
ParserData.MlyValue.VOID,p1,p2))
fun EXISTS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 19,(
ParserData.MlyValue.VOID,p1,p2))
fun DIFF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 20,(
ParserData.MlyValue.VOID,p1,p2))
fun NEGDIFF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 21,(
ParserData.MlyValue.VOID,p1,p2))
fun COLON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 22,(
ParserData.MlyValue.VOID,p1,p2))
fun AT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 23,(
ParserData.MlyValue.VOID,p1,p2))
fun SEMI (p1,p2) = Token.TOKEN (ParserData.LrTable.T 24,(
ParserData.MlyValue.VOID,p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 25,(
ParserData.MlyValue.VOID,p1,p2))
fun END (p1,p2) = Token.TOKEN (ParserData.LrTable.T 26,(
ParserData.MlyValue.VOID,p1,p2))
end
end
