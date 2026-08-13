functor ParserLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : Parser_TOKENS
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
 *    $Date: 2009-09-25 21:38:23 +0200 (Fri, 25 Sep 2009) $
 *    $Author: goetzmann $
 *    $Revision: 463 $
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
\\001\000\001\000\027\000\002\000\026\000\003\000\025\000\008\000\024\000\
\\009\000\023\000\010\000\022\000\011\000\021\000\012\000\020\000\
\\013\000\019\000\014\000\018\000\015\000\017\000\017\000\016\000\
\\019\000\015\000\000\000\
\\001\000\001\000\039\000\000\000\
\\001\000\001\000\039\000\022\000\038\000\025\000\037\000\000\000\
\\001\000\001\000\039\000\022\000\042\000\025\000\041\000\000\000\
\\001\000\001\000\039\000\022\000\045\000\025\000\044\000\000\000\
\\001\000\001\000\046\000\000\000\
\\001\000\001\000\047\000\000\000\
\\001\000\001\000\049\000\000\000\
\\001\000\001\000\050\000\000\000\
\\001\000\016\000\070\000\000\000\
\\001\000\018\000\069\000\000\000\
\\001\000\020\000\068\000\000\000\
\\001\000\022\000\061\000\000\000\
\\001\000\022\000\062\000\000\000\
\\001\000\022\000\064\000\000\000\
\\001\000\022\000\065\000\000\000\
\\001\000\022\000\066\000\000\000\
\\001\000\022\000\067\000\000\000\
\\001\000\029\000\000\000\030\000\000\000\000\000\
\\077\000\000\000\
\\078\000\000\000\
\\079\000\001\000\027\000\002\000\026\000\003\000\025\000\008\000\024\000\
\\009\000\023\000\010\000\022\000\011\000\021\000\012\000\020\000\
\\013\000\019\000\014\000\018\000\015\000\017\000\017\000\016\000\
\\019\000\015\000\026\000\014\000\027\000\013\000\028\000\012\000\000\000\
\\080\000\026\000\014\000\027\000\013\000\028\000\012\000\000\000\
\\081\000\026\000\014\000\027\000\013\000\028\000\012\000\000\000\
\\082\000\026\000\014\000\027\000\013\000\028\000\012\000\000\000\
\\083\000\000\000\
\\084\000\000\000\
\\085\000\000\000\
\\086\000\000\000\
\\087\000\000\000\
\\088\000\000\000\
\\089\000\000\000\
\\090\000\000\000\
\\091\000\000\000\
\\092\000\000\000\
\\093\000\000\000\
\\094\000\000\000\
\\095\000\023\000\063\000\000\000\
\\096\000\000\000\
\\097\000\024\000\056\000\000\000\
\\098\000\000\000\
\\099\000\000\000\
\\100\000\000\000\
\\101\000\000\000\
\\102\000\000\000\
\\103\000\000\000\
\\104\000\000\000\
\\105\000\000\000\
\\106\000\000\000\
\\107\000\000\000\
\\108\000\000\000\
\\109\000\000\000\
\\110\000\000\000\
\\111\000\004\000\035\000\000\000\
\\112\000\000\000\
\\113\000\005\000\034\000\000\000\
\\114\000\000\000\
\\115\000\007\000\033\000\000\000\
\\116\000\000\000\
\\117\000\006\000\032\000\000\000\
\\118\000\000\000\
\"
val actionRowNumbers =
"\021\000\024\000\023\000\022\000\
\\000\000\059\000\019\000\057\000\
\\055\000\053\000\002\000\003\000\
\\004\000\005\000\006\000\000\000\
\\007\000\008\000\000\000\000\000\
\\000\000\000\000\000\000\041\000\
\\040\000\039\000\027\000\026\000\
\\025\000\020\000\000\000\000\000\
\\000\000\000\000\012\000\013\000\
\\036\000\037\000\014\000\015\000\
\\033\000\016\000\017\000\030\000\
\\011\000\010\000\009\000\042\000\
\\000\000\049\000\048\000\047\000\
\\046\000\045\000\000\000\060\000\
\\058\000\056\000\054\000\035\000\
\\034\000\001\000\032\000\031\000\
\\029\000\028\000\000\000\000\000\
\\052\000\050\000\051\000\038\000\
\\043\000\044\000\018\000"
val gotoT =
"\
\\001\000\074\000\002\000\009\000\003\000\008\000\004\000\007\000\
\\005\000\006\000\006\000\005\000\007\000\004\000\008\000\003\000\
\\009\000\002\000\010\000\001\000\000\000\
\\007\000\026\000\008\000\003\000\009\000\002\000\010\000\001\000\000\000\
\\007\000\027\000\008\000\003\000\009\000\002\000\010\000\001\000\000\000\
\\007\000\028\000\008\000\003\000\009\000\002\000\010\000\001\000\000\000\
\\002\000\009\000\003\000\008\000\004\000\007\000\005\000\029\000\
\\006\000\005\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\011\000\034\000\000\000\
\\011\000\038\000\000\000\
\\011\000\041\000\000\000\
\\000\000\
\\000\000\
\\002\000\009\000\003\000\008\000\004\000\007\000\005\000\046\000\
\\006\000\005\000\000\000\
\\000\000\
\\000\000\
\\002\000\049\000\000\000\
\\002\000\050\000\000\000\
\\002\000\051\000\000\000\
\\002\000\052\000\000\000\
\\002\000\053\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\002\000\009\000\003\000\008\000\004\000\007\000\005\000\055\000\
\\006\000\005\000\000\000\
\\002\000\009\000\003\000\008\000\004\000\007\000\006\000\056\000\000\000\
\\002\000\009\000\003\000\008\000\004\000\057\000\000\000\
\\002\000\009\000\003\000\058\000\000\000\
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
\\002\000\069\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\002\000\070\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\011\000\071\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\002\000\072\000\000\000\
\\002\000\073\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\"
val numstates = 75
val numrules = 42
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
 | VAR of unit ->  (string) | VARLIST of unit ->  (string list)
 | SERLIST of unit ->  (unit) | TRANSLIST of unit ->  (unit)
 | REFLLIST of unit ->  (unit) | PREFIX of unit ->  (unit)
 | DIMPLICATION of unit ->  (Parsetree.parsetree)
 | IMPLICATION of unit ->  (Parsetree.parsetree)
 | DISJUNCTION of unit ->  (Parsetree.parsetree)
 | CONJUNCTION of unit ->  (Parsetree.parsetree)
 | OTHER of unit ->  (Parsetree.parsetree)
 | START of unit ->  (Parsetree.parsetree option)
end
type svalue = MlyValue.svalue
type result = Parsetree.parsetree option
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
fn (T 28) => true | _ => false
val showTerminal =
fn (T 0) => "VAR"
  | (T 1) => "TRUE"
  | (T 2) => "FALSE"
  | (T 3) => "AND"
  | (T 4) => "OR"
  | (T 5) => "IMPL"
  | (T 6) => "DIMPL"
  | (T 7) => "NOT"
  | (T 8) => "ALL"
  | (T 9) => "EXISTS"
  | (T 10) => "DIFF"
  | (T 11) => "NEGDIFF"
  | (T 12) => "AT"
  | (T 13) => "EQ"
  | (T 14) => "LPAREN"
  | (T 15) => "RPAREN"
  | (T 16) => "LBRACKET"
  | (T 17) => "RBRACKET"
  | (T 18) => "LCHEVRON"
  | (T 19) => "RCHEVRON"
  | (T 20) => "LBRACE"
  | (T 21) => "RBRACE"
  | (T 22) => "SEP"
  | (T 23) => "COLON"
  | (T 24) => "AST"
  | (T 25) => "REFLEXIVE"
  | (T 26) => "TRANSITIVE"
  | (T 27) => "SERIAL"
  | (T 28) => "EOF"
  | (T 29) => "SEMI"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
 $$ (T 29) $$ (T 28) $$ (T 27) $$ (T 26) $$ (T 25) $$ (T 24) $$ (T 23)
 $$ (T 22) $$ (T 21) $$ (T 20) $$ (T 19) $$ (T 18) $$ (T 17) $$ (T 16)
 $$ (T 15) $$ (T 14) $$ (T 13) $$ (T 12) $$ (T 11) $$ (T 10) $$ (T 9)
 $$ (T 8) $$ (T 7) $$ (T 6) $$ (T 5) $$ (T 4) $$ (T 3) $$ (T 2) $$ (T 
1)end
structure Actions =
struct 
type int = Int.int
exception mlyAction of int
local open Header in
val actions = 
fn (i392:int,defaultPos,stack,
    (()):arg) =>
case (i392,stack)
of  ( 0, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, IMPLICATION1left,
 IMPLICATION1right)) :: rest671)) => let val  result = MlyValue.START
 (fn _ => let val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 in (SOME IMPLICATION)
end)
 in ( LrTable.NT 0, ( result, IMPLICATION1left, IMPLICATION1right), 
rest671)
end
|  ( 1, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, _, 
IMPLICATION1right)) :: ( _, ( MlyValue.PREFIX PREFIX1, PREFIX1left, _)
) :: rest671)) => let val  result = MlyValue.START (fn _ => let val  
PREFIX1 = PREFIX1 ()
 val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 in (SOME IMPLICATION)
end)
 in ( LrTable.NT 0, ( result, PREFIX1left, IMPLICATION1right), rest671
)
end
|  ( 2, ( rest671)) => let val  result = MlyValue.START (fn _ => (NONE
))
 in ( LrTable.NT 0, ( result, defaultPos, defaultPos), rest671)
end
|  ( 3, ( ( _, ( MlyValue.REFLLIST REFLLIST1, REFLLIST1left, 
REFLLIST1right)) :: rest671)) => let val  result = MlyValue.PREFIX (fn
 _ => let val  REFLLIST1 = REFLLIST1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, REFLLIST1left, REFLLIST1right), rest671)

end
|  ( 4, ( ( _, ( MlyValue.TRANSLIST TRANSLIST1, TRANSLIST1left, 
TRANSLIST1right)) :: rest671)) => let val  result = MlyValue.PREFIX
 (fn _ => let val  TRANSLIST1 = TRANSLIST1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, TRANSLIST1left, TRANSLIST1right), 
rest671)
end
|  ( 5, ( ( _, ( MlyValue.SERLIST SERLIST1, SERLIST1left, 
SERLIST1right)) :: rest671)) => let val  result = MlyValue.PREFIX (fn
 _ => let val  SERLIST1 = SERLIST1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, SERLIST1left, SERLIST1right), rest671)

end
|  ( 6, ( ( _, ( MlyValue.PREFIX PREFIX1, _, PREFIX1right)) :: ( _, ( 
MlyValue.REFLLIST REFLLIST1, REFLLIST1left, _)) :: rest671)) => let
 val  result = MlyValue.PREFIX (fn _ => let val  REFLLIST1 = REFLLIST1
 ()
 val  PREFIX1 = PREFIX1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, REFLLIST1left, PREFIX1right), rest671)

end
|  ( 7, ( ( _, ( MlyValue.PREFIX PREFIX1, _, PREFIX1right)) :: ( _, ( 
MlyValue.TRANSLIST TRANSLIST1, TRANSLIST1left, _)) :: rest671)) => let
 val  result = MlyValue.PREFIX (fn _ => let val  TRANSLIST1 = 
TRANSLIST1 ()
 val  PREFIX1 = PREFIX1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, TRANSLIST1left, PREFIX1right), rest671)

end
|  ( 8, ( ( _, ( MlyValue.PREFIX PREFIX1, _, PREFIX1right)) :: ( _, ( 
MlyValue.SERLIST SERLIST1, SERLIST1left, _)) :: rest671)) => let val  
result = MlyValue.PREFIX (fn _ => let val  SERLIST1 = SERLIST1 ()
 val  PREFIX1 = PREFIX1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, SERLIST1left, PREFIX1right), rest671)

end
|  ( 9, ( ( _, ( _, _, RBRACE1right)) :: _ :: ( _, ( _, REFLEXIVE1left
, _)) :: rest671)) => let val  result = MlyValue.REFLLIST (fn _ => (
RelationMgr.setAllReflexive ()))
 in ( LrTable.NT 7, ( result, REFLEXIVE1left, RBRACE1right), rest671)

end
|  ( 10, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: ( _, ( _, REFLEXIVE1left, _)) :: rest671)) => let
 val  result = MlyValue.REFLLIST (fn _ => let val  (VARLIST as 
VARLIST1) = VARLIST1 ()
 in (app RelationMgr.setReflexive VARLIST)
end)
 in ( LrTable.NT 7, ( result, REFLEXIVE1left, RBRACE1right), rest671)

end
|  ( 11, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( _, REFLEXIVE1left, _)
) :: rest671)) => let val  result = MlyValue.REFLLIST (fn _ => (()))
 in ( LrTable.NT 7, ( result, REFLEXIVE1left, RBRACE1right), rest671)

end
|  ( 12, ( ( _, ( _, _, RBRACE1right)) :: _ :: ( _, ( _, 
TRANSITIVE1left, _)) :: rest671)) => let val  result = 
MlyValue.TRANSLIST (fn _ => (RelationMgr.setAllTransitive ()))
 in ( LrTable.NT 8, ( result, TRANSITIVE1left, RBRACE1right), rest671)

end
|  ( 13, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: ( _, ( _, TRANSITIVE1left, _)) :: rest671)) => let
 val  result = MlyValue.TRANSLIST (fn _ => let val  (VARLIST as 
VARLIST1) = VARLIST1 ()
 in (app RelationMgr.setTransitive VARLIST)
end)
 in ( LrTable.NT 8, ( result, TRANSITIVE1left, RBRACE1right), rest671)

end
|  ( 14, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( _, TRANSITIVE1left, _
)) :: rest671)) => let val  result = MlyValue.TRANSLIST (fn _ => (()))
 in ( LrTable.NT 8, ( result, TRANSITIVE1left, RBRACE1right), rest671)

end
|  ( 15, ( ( _, ( _, _, RBRACE1right)) :: _ :: ( _, ( _, SERIAL1left,
 _)) :: rest671)) => let val  result = MlyValue.SERLIST (fn _ => (
RelationMgr.setAllSerial ()))
 in ( LrTable.NT 9, ( result, SERIAL1left, RBRACE1right), rest671)
end
|  ( 16, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: ( _, ( _, SERIAL1left, _)) :: rest671)) => let
 val  result = MlyValue.SERLIST (fn _ => let val  (VARLIST as VARLIST1
) = VARLIST1 ()
 in (app RelationMgr.setSerial VARLIST)
end)
 in ( LrTable.NT 9, ( result, SERIAL1left, RBRACE1right), rest671)
end
|  ( 17, ( ( _, ( _, _, RBRACE1right)) :: ( _, ( _, SERIAL1left, _))
 :: rest671)) => let val  result = MlyValue.SERLIST (fn _ => (()))
 in ( LrTable.NT 9, ( result, SERIAL1left, RBRACE1right), rest671)
end
|  ( 18, ( ( _, ( MlyValue.VAR VAR1, VAR1left, VAR1right)) :: rest671)
) => let val  result = MlyValue.VARLIST (fn _ => let val  (VAR as VAR1
) = VAR1 ()
 in ([VAR])
end)
 in ( LrTable.NT 10, ( result, VAR1left, VAR1right), rest671)
end
|  ( 19, ( ( _, ( MlyValue.VARLIST VARLIST1, _, VARLIST1right)) :: _
 :: ( _, ( MlyValue.VAR VAR1, VAR1left, _)) :: rest671)) => let val  
result = MlyValue.VARLIST (fn _ => let val  (VAR as VAR1) = VAR1 ()
 val  (VARLIST as VARLIST1) = VARLIST1 ()
 in (VAR::VARLIST)
end)
 in ( LrTable.NT 10, ( result, VAR1left, VARLIST1right), rest671)
end
|  ( 20, ( ( _, ( MlyValue.VAR VAR1, VAR1left, VAR1right)) :: rest671)
) => let val  result = MlyValue.OTHER (fn _ => let val  (VAR as VAR1)
 = VAR1 ()
 in (Parsetree.PROPVAR VAR)
end)
 in ( LrTable.NT 1, ( result, VAR1left, VAR1right), rest671)
end
|  ( 21, ( ( _, ( _, TRUE1left, TRUE1right)) :: rest671)) => let val  
result = MlyValue.OTHER (fn _ => (Parsetree.mconj nil))
 in ( LrTable.NT 1, ( result, TRUE1left, TRUE1right), rest671)
end
|  ( 22, ( ( _, ( _, FALSE1left, FALSE1right)) :: rest671)) => let
 val  result = MlyValue.OTHER (fn _ => (Parsetree.mdisj nil))
 in ( LrTable.NT 1, ( result, FALSE1left, FALSE1right), rest671)
end
|  ( 23, ( ( _, ( MlyValue.VAR VAR1, _, VAR1right)) :: ( _, ( _, 
EQ1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _ =>
 let val  (VAR as VAR1) = VAR1 ()
 in (Parsetree.NOMINAL VAR)
end)
 in ( LrTable.NT 1, ( result, EQ1left, VAR1right), rest671)
end
|  ( 24, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: _ :: ( _,
 ( MlyValue.VAR VAR1, _, _)) :: ( _, ( _, LCHEVRON1left, _)) :: 
rest671)) => let val  result = MlyValue.OTHER (fn _ => let val  (VAR
 as VAR1) = VAR1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.DIAMOND (VAR, OTHER))
end)
 in ( LrTable.NT 1, ( result, LCHEVRON1left, OTHER1right), rest671)

end
|  ( 25, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: _ :: ( _,
 ( MlyValue.VAR VAR1, _, _)) :: ( _, ( _, LBRACKET1left, _)) :: 
rest671)) => let val  result = MlyValue.OTHER (fn _ => let val  (VAR
 as VAR1) = VAR1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.BOX (VAR, OTHER))
end)
 in ( LrTable.NT 1, ( result, LBRACKET1left, OTHER1right), rest671)

end
|  ( 26, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 NOT1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.neg OTHER)
end)
 in ( LrTable.NT 1, ( result, NOT1left, OTHER1right), rest671)
end
|  ( 27, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 ALL1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.ALL OTHER)
end)
 in ( LrTable.NT 1, ( result, ALL1left, OTHER1right), rest671)
end
|  ( 28, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 EXISTS1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn
 _ => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.EXISTS OTHER)
end)
 in ( LrTable.NT 1, ( result, EXISTS1left, OTHER1right), rest671)
end
|  ( 29, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 DIFF1left, _)) :: rest671)) => let val  result = MlyValue.OTHER (fn _
 => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.DIFF OTHER)
end)
 in ( LrTable.NT 1, ( result, DIFF1left, OTHER1right), rest671)
end
|  ( 30, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( _,
 NEGDIFF1left, _)) :: rest671)) => let val  result = MlyValue.OTHER
 (fn _ => let val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.NEGDIFF OTHER)
end)
 in ( LrTable.NT 1, ( result, NEGDIFF1left, OTHER1right), rest671)
end
|  ( 31, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: ( _, ( 
MlyValue.VAR VAR1, _, _)) :: ( _, ( _, AT1left, _)) :: rest671)) =>
 let val  result = MlyValue.OTHER (fn _ => let val  (VAR as VAR1) = 
VAR1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.AT (VAR, OTHER))
end)
 in ( LrTable.NT 1, ( result, AT1left, OTHER1right), rest671)
end
|  ( 32, ( ( _, ( MlyValue.OTHER OTHER1, _, OTHER1right)) :: _ :: ( _,
 ( MlyValue.VAR VAR1, VAR1left, _)) :: rest671)) => let val  result = 
MlyValue.OTHER (fn _ => let val  (VAR as VAR1) = VAR1 ()
 val  (OTHER as OTHER1) = OTHER1 ()
 in (Parsetree.AT (VAR, OTHER))
end)
 in ( LrTable.NT 1, ( result, VAR1left, OTHER1right), rest671)
end
|  ( 33, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.IMPLICATION 
IMPLICATION1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.OTHER (fn _ => let val  (IMPLICATION as 
IMPLICATION1) = IMPLICATION1 ()
 in (IMPLICATION)
end)
 in ( LrTable.NT 1, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 34, ( ( _, ( MlyValue.OTHER OTHER1, OTHER1left, OTHER1right)) :: 
rest671)) => let val  result = MlyValue.CONJUNCTION (fn _ => let val 
 (OTHER as OTHER1) = OTHER1 ()
 in (OTHER)
end)
 in ( LrTable.NT 2, ( result, OTHER1left, OTHER1right), rest671)
end
|  ( 35, ( ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, _, 
CONJUNCTION1right)) :: _ :: ( _, ( MlyValue.OTHER OTHER1, OTHER1left,
 _)) :: rest671)) => let val  result = MlyValue.CONJUNCTION (fn _ =>
 let val  (OTHER as OTHER1) = OTHER1 ()
 val  (CONJUNCTION as CONJUNCTION1) = CONJUNCTION1 ()
 in (Parsetree.conj OTHER CONJUNCTION)
end)
 in ( LrTable.NT 2, ( result, OTHER1left, CONJUNCTION1right), rest671)

end
|  ( 36, ( ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, CONJUNCTION1left,
 CONJUNCTION1right)) :: rest671)) => let val  result = 
MlyValue.DISJUNCTION (fn _ => let val  (CONJUNCTION as CONJUNCTION1) =
 CONJUNCTION1 ()
 in (CONJUNCTION)
end)
 in ( LrTable.NT 3, ( result, CONJUNCTION1left, CONJUNCTION1right), 
rest671)
end
|  ( 37, ( ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, _, 
DISJUNCTION1right)) :: _ :: ( _, ( MlyValue.CONJUNCTION CONJUNCTION1, 
CONJUNCTION1left, _)) :: rest671)) => let val  result = 
MlyValue.DISJUNCTION (fn _ => let val  (CONJUNCTION as CONJUNCTION1) =
 CONJUNCTION1 ()
 val  (DISJUNCTION as DISJUNCTION1) = DISJUNCTION1 ()
 in (Parsetree.disj CONJUNCTION DISJUNCTION)
end)
 in ( LrTable.NT 3, ( result, CONJUNCTION1left, DISJUNCTION1right), 
rest671)
end
|  ( 38, ( ( _, ( MlyValue.DISJUNCTION DISJUNCTION1, DISJUNCTION1left,
 DISJUNCTION1right)) :: rest671)) => let val  result = 
MlyValue.DIMPLICATION (fn _ => let val  (DISJUNCTION as DISJUNCTION1)
 = DISJUNCTION1 ()
 in (DISJUNCTION)
end)
 in ( LrTable.NT 5, ( result, DISJUNCTION1left, DISJUNCTION1right), 
rest671)
end
|  ( 39, ( ( _, ( MlyValue.DIMPLICATION DIMPLICATION1, _, 
DIMPLICATION1right)) :: _ :: ( _, ( MlyValue.DISJUNCTION DISJUNCTION1,
 DISJUNCTION1left, _)) :: rest671)) => let val  result = 
MlyValue.DIMPLICATION (fn _ => let val  (DISJUNCTION as DISJUNCTION1)
 = DISJUNCTION1 ()
 val  (DIMPLICATION as DIMPLICATION1) = DIMPLICATION1 ()
 in (Parsetree.dimpl DISJUNCTION DIMPLICATION)
end)
 in ( LrTable.NT 5, ( result, DISJUNCTION1left, DIMPLICATION1right), 
rest671)
end
|  ( 40, ( ( _, ( MlyValue.DIMPLICATION DIMPLICATION1, 
DIMPLICATION1left, DIMPLICATION1right)) :: rest671)) => let val  
result = MlyValue.IMPLICATION (fn _ => let val  (DIMPLICATION as 
DIMPLICATION1) = DIMPLICATION1 ()
 in (DIMPLICATION)
end)
 in ( LrTable.NT 4, ( result, DIMPLICATION1left, DIMPLICATION1right), 
rest671)
end
|  ( 41, ( ( _, ( MlyValue.IMPLICATION IMPLICATION1, _, 
IMPLICATION1right)) :: _ :: ( _, ( MlyValue.DIMPLICATION DIMPLICATION1
, DIMPLICATION1left, _)) :: rest671)) => let val  result = 
MlyValue.IMPLICATION (fn _ => let val  (DIMPLICATION as DIMPLICATION1)
 = DIMPLICATION1 ()
 val  (IMPLICATION as IMPLICATION1) = IMPLICATION1 ()
 in (Parsetree.impl DIMPLICATION IMPLICATION)
end)
 in ( LrTable.NT 4, ( result, DIMPLICATION1left, IMPLICATION1right), 
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
structure Tokens : Parser_TOKENS =
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
fun DIMPL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun NOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun ALL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun EXISTS (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun DIFF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun NEGDIFF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun AT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun EQ (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 14,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 15,(
ParserData.MlyValue.VOID,p1,p2))
fun LBRACKET (p1,p2) = Token.TOKEN (ParserData.LrTable.T 16,(
ParserData.MlyValue.VOID,p1,p2))
fun RBRACKET (p1,p2) = Token.TOKEN (ParserData.LrTable.T 17,(
ParserData.MlyValue.VOID,p1,p2))
fun LCHEVRON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 18,(
ParserData.MlyValue.VOID,p1,p2))
fun RCHEVRON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 19,(
ParserData.MlyValue.VOID,p1,p2))
fun LBRACE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 20,(
ParserData.MlyValue.VOID,p1,p2))
fun RBRACE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 21,(
ParserData.MlyValue.VOID,p1,p2))
fun SEP (p1,p2) = Token.TOKEN (ParserData.LrTable.T 22,(
ParserData.MlyValue.VOID,p1,p2))
fun COLON (p1,p2) = Token.TOKEN (ParserData.LrTable.T 23,(
ParserData.MlyValue.VOID,p1,p2))
fun AST (p1,p2) = Token.TOKEN (ParserData.LrTable.T 24,(
ParserData.MlyValue.VOID,p1,p2))
fun REFLEXIVE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 25,(
ParserData.MlyValue.VOID,p1,p2))
fun TRANSITIVE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 26,(
ParserData.MlyValue.VOID,p1,p2))
fun SERIAL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 27,(
ParserData.MlyValue.VOID,p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 28,(
ParserData.MlyValue.VOID,p1,p2))
fun SEMI (p1,p2) = Token.TOKEN (ParserData.LrTable.T 29,(
ParserData.MlyValue.VOID,p1,p2))
end
end
