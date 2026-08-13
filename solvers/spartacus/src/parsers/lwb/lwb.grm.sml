functor LwbLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : Lwb_TOKENS
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
\\001\000\001\000\016\000\003\000\015\000\004\000\014\000\009\000\013\000\
\\010\000\012\000\011\000\011\000\012\000\010\000\000\000\
\\001\000\002\000\004\000\000\000\
\\001\000\013\000\030\000\000\000\
\\001\000\014\000\000\000\015\000\000\000\000\000\
\\001\000\015\000\005\000\000\000\
\\032\000\000\000\
\\033\000\002\000\004\000\000\000\
\\034\000\000\000\
\\035\000\000\000\
\\036\000\000\000\
\\037\000\000\000\
\\038\000\000\000\
\\039\000\000\000\
\\040\000\000\000\
\\041\000\000\000\
\\042\000\005\000\021\000\000\000\
\\043\000\000\000\
\\044\000\006\000\020\000\000\000\
\\045\000\000\000\
\\046\000\007\000\019\000\008\000\018\000\000\000\
\\047\000\000\000\
\\048\000\000\000\
\"
val actionRowNumbers =
"\001\000\004\000\000\000\005\000\
\\006\000\019\000\017\000\015\000\
\\000\000\000\000\000\000\000\000\
\\010\000\009\000\008\000\007\000\
\\000\000\000\000\000\000\000\000\
\\002\000\012\000\011\000\013\000\
\\021\000\020\000\018\000\016\000\
\\014\000\003\000"
val gotoT =
"\
\\001\000\029\000\002\000\001\000\000\000\
\\000\000\
\\003\000\007\000\004\000\006\000\005\000\005\000\006\000\004\000\000\000\
\\000\000\
\\002\000\015\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\007\000\004\000\006\000\005\000\005\000\006\000\020\000\000\000\
\\003\000\021\000\000\000\
\\003\000\022\000\000\000\
\\003\000\023\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\007\000\004\000\006\000\005\000\005\000\006\000\024\000\000\000\
\\003\000\007\000\004\000\006\000\005\000\005\000\006\000\025\000\000\000\
\\003\000\007\000\004\000\006\000\005\000\026\000\000\000\
\\003\000\007\000\004\000\027\000\000\000\
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
val numstates = 30
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
 | NEW of unit ->  (int) | VAR of unit ->  (string)
 | IMPLICATION of unit ->  (Parsetree.parsetree)
 | DISJUNCTION of unit ->  (Parsetree.parsetree)
 | CONJUNCTION of unit ->  (Parsetree.parsetree)
 | OTHER of unit ->  (Parsetree.parsetree)
 | FLIST of unit ->  ( ( int * Parsetree.parsetree )  list)
 | START of unit ->  ( ( int * Parsetree.parsetree )  list)
end
type svalue = MlyValue.svalue
type result =  ( int * Parsetree.parsetree )  list
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
fn (T 13) => true | _ => false
val showTerminal =
fn (T 0) => "VAR"
  | (T 1) => "NEW"
  | (T 2) => "TRUE"
  | (T 3) => "FALSE"
  | (T 4) => "AND"
  | (T 5) => "OR"
  | (T 6) => "IMPL"
  | (T 7) => "EQUIV"
  | (T 8) => "NOT"
  | (T 9) => "DIA"
  | (T 10) => "BOX"
  | (T 11) => "LPAREN"
  | (T 12) => "RPAREN"
  | (T 13) => "EOF"
  | (T 14) => "END"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 14) $$ (T 13) $$ (T 12) $$ (T 11) $$ (T 10) $$ (T 9) $$ (T 8)
 $$ (T 7) $$ (T 6) $$ (T 5) $$ (T 4) $$ (T 3) $$ (T 2)end
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
 in (FLIST)
end)
 in ( LrTable.NT 0, ( result, FLIST1left, END1right), rest671)
end
|  ( 1, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, _, 
IMPLICATION1right)) :: ( _, ( MlyValue.NEW NEW1, NEW1left, _)) :: 
rest671)) => let val  result = MlyValue.FLIST (fn _ => let val  (NEW
 as NEW1) = NEW1 ()
 val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 in ([(NEW, IMPLICATION)])
end)
 in ( LrTable.NT 1, ( result, NEW1left, IMPLICATION1right), rest671)

end
|  ( 2, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( 
MlyValue.IMPLICATION IMPLICATION1, _, _)) :: ( _, ( MlyValue.NEW NEW1,
 NEW1left, _)) :: rest671)) => let val  result = MlyValue.FLIST (fn _
 => let val  (NEW as NEW1) = NEW1 ()
 val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 val  (FLIST as FLIST1) = FLIST1 ()
 in ((NEW, IMPLICATION)::FLIST)
end)
 in ( LrTable.NT 1, ( result, NEW1left, FLIST1right), rest671)
end
|  ( 3, ( ( _, ( MlyValue.VAR VAR1, VAR1left, VAR1right)) :: rest671))
 => let val  result = MlyValue.OTHER (fn _ => let val  (VAR as VAR1) =
 VAR1 ()
 in (Parsetree.PROPVAR VAR)
end)
 in ( LrTable.NT 2, ( result, VAR1left, VAR1right), rest671)
end
|  ( 4, ( ( _, ( _, TRUE1left, TRUE1right)) :: rest671)) => let val  
result = MlyValue.OTHER (fn _ => (Parsetree.mconj nil))
 in ( LrTable.NT 2, ( result, TRUE1left, TRUE1right), rest671)
end
|  ( 5, ( ( _, ( _, FALSE1left, FALSE1right)) :: rest671)) => let val 
 result = MlyValue.OTHER (fn _ => (Parsetree.mdisj nil))
 in ( LrTable.NT 2, ( result, FALSE1left, FALSE1right), rest671)
end
|  ( 6, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _, 
DIA1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.DIAMOND ("r", OTHER))
end)
 in ( LrTable.NT 2, ( result, DIA1left, OTHER1right), rest671)
end
|  ( 7, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _, 
BOX1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.BOX ("r", OTHER))
end)
 in ( LrTable.NT 2, ( result, BOX1left, OTHER1right), rest671)
end
|  ( 8, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _, 
NOT1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.neg OTHER)
end)
 in ( LrTable.NT 2, ( result, NOT1left, OTHER1right), rest671)
end
|  ( 9, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.IMPLICATION 
IMPLICATION1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.OTHER (fn _ => let val  (IMPLICATION as 
IMPLICATION1) = IMPLICATION1 ()
 in (IMPLICATION)
end)
 in ( LrTable.NT 2, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 10, ( ( _, ( MlyValue.OTHER OTHER1, OTHER1left, OTHER1right)) :: 
rest671)) => let val  result = MlyValue.CONJUNCTION (fn _ => let val 
 (OTHER as OTHER1) = OTHER1 ()
 in (OTHER)
end)
 in ( LrTable.NT 3, ( result, OTHER1left, OTHER1right), rest671)
end
|  ( 11, ( ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, _, 
CONJUNCTION1right)) :: _ :: ( _, ( MlyValue.OTHER OTHER1, OTHER1left,
 _)) :: rest671)) => let val  result = MlyValue.CONJUNCTION (fn _ =>
 let val  (OTHER as OTHER1) = OTHER1 ()
 val  (CONJUNCTION as CONJUNCTION1) = CONJUNCTION1 ()
 in (Parsetree.conj OTHER CONJUNCTION)
end)
 in ( LrTable.NT 3, ( result, OTHER1left, CONJUNCTION1right), rest671)

end
|  ( 12, ( ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, CONJUNCTION1left,
 CONJUNCTION1right)) :: rest671)) => let val  result = 
MlyValue.DISJUNCTION (fn _ => let val  (CONJUNCTION as CONJUNCTION1) =
 CONJUNCTION1 ()
 in (CONJUNCTION)
end)
 in ( LrTable.NT 4, ( result, CONJUNCTION1left, CONJUNCTION1right), 
rest671)
end
|  ( 13, ( ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, _, 
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
|  ( 14, ( ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, DISJUNCTION1left,
 DISJUNCTION1right)) :: rest671)) => let val  result = 
MlyValue.IMPLICATION (fn _ => let val  (DISJUNCTION as DISJUNCTION1) =
 DISJUNCTION1 ()
 in (DISJUNCTION)
end)
 in ( LrTable.NT 5, ( result, DISJUNCTION1left, DISJUNCTION1right), 
rest671)
end
|  ( 15, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, _, 
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
|  ( 16, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, _, 
IMPLICATION1right)) :: _ :: ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, 
DISJUNCTION1left, _)) :: rest671)) => let val  result = 
MlyValue.IMPLICATION (fn _ => let val  (DISJUNCTION as DISJUNCTION1) =
 DISJUNCTION1 ()
 val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 in (Parsetree.dimpl DISJUNCTION IMPLICATION)
end)
 in ( LrTable.NT 5, ( result, DISJUNCTION1left, IMPLICATION1right), 
rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.START x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : Lwb_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun VAR (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.VAR (fn () => i),p1,p2))
fun NEW (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.NEW (fn () => i),p1,p2))
fun TRUE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.VOID,p1,p2))
fun FALSE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.VOID,p1,p2))
fun AND (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun OR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun IMPL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun EQUIV (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun NOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun DIA (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun BOX (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
fun END (p1,p2) = Token.TOKEN (ParserData.LrTable.T 14,(
ParserData.MlyValue.VOID,p1,p2))
end
end
