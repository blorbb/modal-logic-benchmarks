functor DfgLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : Dfg_TOKENS
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
\\001\000\001\000\019\000\002\000\018\000\003\000\017\000\004\000\016\000\
\\005\000\015\000\006\000\014\000\007\000\013\000\008\000\012\000\
\\009\000\011\000\010\000\010\000\000\000\
\\001\000\001\000\019\000\002\000\018\000\003\000\017\000\004\000\016\000\
\\005\000\015\000\006\000\014\000\007\000\013\000\008\000\012\000\
\\009\000\011\000\010\000\010\000\015\000\009\000\000\000\
\\001\000\001\000\019\000\002\000\018\000\003\000\017\000\004\000\016\000\
\\005\000\015\000\006\000\014\000\007\000\013\000\008\000\012\000\
\\009\000\011\000\010\000\010\000\015\000\021\000\000\000\
\\001\000\001\000\031\000\000\000\
\\001\000\001\000\032\000\000\000\
\\001\000\010\000\024\000\000\000\
\\001\000\010\000\025\000\000\000\
\\001\000\010\000\026\000\000\000\
\\001\000\010\000\027\000\000\000\
\\001\000\010\000\028\000\000\000\
\\001\000\010\000\029\000\000\000\
\\001\000\011\000\030\000\000\000\
\\001\000\011\000\040\000\000\000\
\\001\000\011\000\042\000\000\000\
\\001\000\011\000\044\000\000\000\
\\001\000\011\000\049\000\000\000\
\\001\000\011\000\050\000\000\000\
\\001\000\011\000\051\000\000\000\
\\001\000\012\000\038\000\000\000\
\\001\000\012\000\039\000\000\000\
\\001\000\012\000\041\000\000\000\
\\001\000\013\000\004\000\000\000\
\\001\000\014\000\006\000\000\000\
\\001\000\016\000\000\000\017\000\000\000\000\000\
\\053\000\000\000\
\\054\000\000\000\
\\055\000\000\000\
\\056\000\000\000\
\\057\000\000\000\
\\058\000\001\000\019\000\002\000\018\000\003\000\017\000\004\000\016\000\
\\005\000\015\000\006\000\014\000\007\000\013\000\008\000\012\000\
\\009\000\011\000\010\000\010\000\000\000\
\\059\000\000\000\
\\060\000\000\000\
\\061\000\000\000\
\\062\000\000\000\
\\063\000\000\000\
\\064\000\000\000\
\\065\000\000\000\
\\066\000\000\000\
\\067\000\000\000\
\\068\000\000\000\
\\069\000\000\000\
\\070\000\012\000\043\000\000\000\
\\071\000\000\000\
\"
val actionRowNumbers =
"\021\000\022\000\001\000\024\000\
\\002\000\029\000\026\000\025\000\
\\000\000\005\000\006\000\007\000\
\\008\000\009\000\010\000\033\000\
\\032\000\031\000\028\000\027\000\
\\030\000\011\000\003\000\004\000\
\\000\000\000\000\000\000\000\000\
\\040\000\018\000\019\000\012\000\
\\020\000\013\000\041\000\014\000\
\\000\000\000\000\039\000\000\000\
\\037\000\000\000\036\000\015\000\
\\016\000\017\000\042\000\035\000\
\\034\000\038\000\023\000"
val gotoT =
"\
\\001\000\050\000\002\000\001\000\000\000\
\\003\000\003\000\000\000\
\\004\000\006\000\005\000\005\000\000\000\
\\000\000\
\\004\000\018\000\005\000\005\000\000\000\
\\004\000\020\000\005\000\005\000\000\000\
\\000\000\
\\000\000\
\\005\000\021\000\000\000\
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
\\005\000\031\000\000\000\
\\005\000\032\000\000\000\
\\005\000\034\000\006\000\033\000\000\000\
\\005\000\034\000\006\000\035\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\005\000\043\000\000\000\
\\005\000\044\000\000\000\
\\000\000\
\\005\000\045\000\000\000\
\\000\000\
\\005\000\034\000\006\000\046\000\000\000\
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
val numstates = 51
val numrules = 19
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
 | SLIST of unit ->  (Parsetree.parsetree list)
 | FORMULA of unit ->  (Parsetree.parsetree)
 | FLIST of unit ->  (Parsetree.parsetree list)
 | CJLIST of unit ->  (Parsetree.parsetree list)
 | AXLIST of unit ->  (Parsetree.parsetree list)
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
fn (T 15) => true | _ => false
val showTerminal =
fn (T 0) => "VAR"
  | (T 1) => "TRUE"
  | (T 2) => "FALSE"
  | (T 3) => "AND"
  | (T 4) => "OR"
  | (T 5) => "IMPL"
  | (T 6) => "NOT"
  | (T 7) => "DIA"
  | (T 8) => "BOX"
  | (T 9) => "LPAREN"
  | (T 10) => "RPAREN"
  | (T 11) => "SEP"
  | (T 12) => "AXIOMS"
  | (T 13) => "CONJECTURES"
  | (T 14) => "NONE"
  | (T 15) => "EOF"
  | (T 16) => "END"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 16) $$ (T 15) $$ (T 14) $$ (T 13) $$ (T 12) $$ (T 11) $$ (T 10)
 $$ (T 9) $$ (T 8) $$ (T 7) $$ (T 6) $$ (T 5) $$ (T 4) $$ (T 3) $$ (T 
2) $$ (T 1)end
structure Actions =
struct 
type int = Int.int
exception mlyAction of int
local open Header in
val actions = 
fn (i392:int,defaultPos,stack,
    (()):arg) =>
case (i392,stack)
of  ( 0, ( ( _, ( MlyValue.CJLIST CJLIST1, _, CJLIST1right)) :: ( _, (
 MlyValue.AXLIST AXLIST1, AXLIST1left, _)) :: rest671)) => let val  
result = MlyValue.START (fn _ => let val  AXLIST1 = AXLIST1 ()
 val  (CJLIST as CJLIST1) = CJLIST1 ()
 in (Parsetree.mdisj CJLIST)
end)
 in ( LrTable.NT 0, ( result, AXLIST1left, CJLIST1right), rest671)
end
|  ( 1, ( ( _, ( _, _, NONE1right)) :: ( _, ( _, AXIOMS1left, _)) :: 
rest671)) => let val  result = MlyValue.AXLIST (fn _ => (nil))
 in ( LrTable.NT 1, ( result, AXIOMS1left, NONE1right), rest671)
end
|  ( 2, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( _, 
AXIOMS1left, _)) :: rest671)) => let val  result = MlyValue.AXLIST (fn
 _ => let val  FLIST1 = FLIST1 ()
 in (Exn.unexpected "Input contains axioms")
end)
 in ( LrTable.NT 1, ( result, AXIOMS1left, FLIST1right), rest671)
end
|  ( 3, ( ( _, ( _, _, NONE1right)) :: ( _, ( _, CONJECTURES1left, _))
 :: rest671)) => let val  result = MlyValue.CJLIST (fn _ => (nil))
 in ( LrTable.NT 2, ( result, CONJECTURES1left, NONE1right), rest671)

end
|  ( 4, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( _, 
CONJECTURES1left, _)) :: rest671)) => let val  result = 
MlyValue.CJLIST (fn _ => let val  (FLIST as FLIST1) = FLIST1 ()
 in (FLIST)
end)
 in ( LrTable.NT 2, ( result, CONJECTURES1left, FLIST1right), rest671)

end
|  ( 5, ( ( _, ( MlyValue.FORMULA FORMULA1, FORMULA1left, 
FORMULA1right)) :: rest671)) => let val  result = MlyValue.FLIST (fn _
 => let val  (FORMULA as FORMULA1) = FORMULA1 ()
 in ([FORMULA])
end)
 in ( LrTable.NT 3, ( result, FORMULA1left, FORMULA1right), rest671)

end
|  ( 6, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( 
MlyValue.FORMULA FORMULA1, FORMULA1left, _)) :: rest671)) => let val  
result = MlyValue.FLIST (fn _ => let val  (FORMULA as FORMULA1) = 
FORMULA1 ()
 val  (FLIST as FLIST1) = FLIST1 ()
 in (FORMULA::FLIST)
end)
 in ( LrTable.NT 3, ( result, FORMULA1left, FLIST1right), rest671)
end
|  ( 7, ( ( _, ( MlyValue.VAR VAR1, VAR1left, VAR1right)) :: rest671))
 => let val  result = MlyValue.FORMULA (fn _ => let val  (VAR as VAR1)
 = VAR1 ()
 in (Parsetree.PROPVAR VAR)
end)
 in ( LrTable.NT 4, ( result, VAR1left, VAR1right), rest671)
end
|  ( 8, ( ( _, ( _, TRUE1left, TRUE1right)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => (Parsetree.mconj nil))
 in ( LrTable.NT 4, ( result, TRUE1left, TRUE1right), rest671)
end
|  ( 9, ( ( _, ( _, FALSE1left, FALSE1right)) :: rest671)) => let val 
 result = MlyValue.FORMULA (fn _ => (Parsetree.mdisj nil))
 in ( LrTable.NT 4, ( result, FALSE1left, FALSE1right), rest671)
end
|  ( 10, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: ( _, ( MlyValue.VAR VAR1, _, _)) :: _ :: ( _,
 ( _, DIA1left, _)) :: rest671)) => let val  result = MlyValue.FORMULA
 (fn _ => let val  (VAR as VAR1) = VAR1 ()
 val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (Parsetree.DIAMOND (VAR, FORMULA))
end)
 in ( LrTable.NT 4, ( result, DIA1left, RPAREN1right), rest671)
end
|  ( 11, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: ( _, ( MlyValue.VAR VAR1, _, _)) :: _ :: ( _,
 ( _, BOX1left, _)) :: rest671)) => let val  result = MlyValue.FORMULA
 (fn _ => let val  (VAR as VAR1) = VAR1 ()
 val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (Parsetree.BOX (VAR, FORMULA))
end)
 in ( LrTable.NT 4, ( result, BOX1left, RPAREN1right), rest671)
end
|  ( 12, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.SLIST SLIST1
, _, _)) :: _ :: ( _, ( _, AND1left, _)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (SLIST as SLIST1) = SLIST1
 ()
 in (Parsetree.mconj SLIST)
end)
 in ( LrTable.NT 4, ( result, AND1left, RPAREN1right), rest671)
end
|  ( 13, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.SLIST SLIST1
, _, _)) :: _ :: ( _, ( _, OR1left, _)) :: rest671)) => let val  
result = MlyValue.FORMULA (fn _ => let val  (SLIST as SLIST1) = SLIST1
 ()
 in (Parsetree.mdisj SLIST)
end)
 in ( LrTable.NT 4, ( result, OR1left, RPAREN1right), rest671)
end
|  ( 14, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA2, _, _)) :: _ :: ( _, ( MlyValue.FORMULA FORMULA1, _, _)) :: _
 :: ( _, ( _, IMPL1left, _)) :: rest671)) => let val  result = 
MlyValue.FORMULA (fn _ => let val  FORMULA1 = FORMULA1 ()
 val  FORMULA2 = FORMULA2 ()
 in (Parsetree.impl FORMULA1 FORMULA2)
end)
 in ( LrTable.NT 4, ( result, IMPL1left, RPAREN1right), rest671)
end
|  ( 15, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: ( _, ( _, NOT1left, _)) :: rest671)) => let
 val  result = MlyValue.FORMULA (fn _ => let val  (FORMULA as FORMULA1
) = FORMULA1 ()
 in (Parsetree.neg FORMULA)
end)
 in ( LrTable.NT 4, ( result, NOT1left, RPAREN1right), rest671)
end
|  ( 16, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.FORMULA (fn _ => let val  (FORMULA as FORMULA1
) = FORMULA1 ()
 in (FORMULA)
end)
 in ( LrTable.NT 4, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 17, ( ( _, ( MlyValue.FORMULA FORMULA1, FORMULA1left, 
FORMULA1right)) :: rest671)) => let val  result = MlyValue.SLIST (fn _
 => let val  (FORMULA as FORMULA1) = FORMULA1 ()
 in ([FORMULA])
end)
 in ( LrTable.NT 5, ( result, FORMULA1left, FORMULA1right), rest671)

end
|  ( 18, ( ( _, ( MlyValue.SLIST SLIST1, _, SLIST1right)) :: _ :: ( _,
 ( MlyValue.FORMULA FORMULA1, FORMULA1left, _)) :: rest671)) => let
 val  result = MlyValue.SLIST (fn _ => let val  (FORMULA as FORMULA1)
 = FORMULA1 ()
 val  (SLIST as SLIST1) = SLIST1 ()
 in (FORMULA::SLIST)
end)
 in ( LrTable.NT 5, ( result, FORMULA1left, SLIST1right), rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.START x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : Dfg_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun VAR (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.VAR (fn () => i),p1,p2))
fun TRUE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.VOID,p1,p2))
fun FALSE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.VOID,p1,p2))
fun AND (p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.VOID,p1,p2))
fun OR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun IMPL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun NOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun DIA (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun BOX (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun SEP (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun AXIOMS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun CONJECTURES (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
fun NONE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 14,(
ParserData.MlyValue.VOID,p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 15,(
ParserData.MlyValue.VOID,p1,p2))
fun END (p1,p2) = Token.TOKEN (ParserData.LrTable.T 16,(
ParserData.MlyValue.VOID,p1,p2))
end
end
