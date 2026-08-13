functor AdvancedTkbLrValsFun(structure Token : TOKEN)
 : sig structure ParserData : PARSER_DATA
       structure Tokens : AdvancedTkb_TOKENS
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



exception MultDef


datatype constraint = CIMPL of TkbTree.formula * TkbTree.formula | CEQ of TkbTree.formula * TkbTree.formula | CTRANS of string list | CREFL of string list | CSER of string list | CSYM of string list | CIMPR of string * string

datatype definition = CPT of string * TkbTree.formula | CTR of constraint

fun transform xs =
	let
		fun findDef (CPT (c, t), m) =
			let
				val m = TkbTree.findDef m t
			in
				case Binarymap.peek (m, c)
					of SOME (TkbTree.PC _) => Binarymap.insert (m, c, TkbTree.MDC)
					 | SOME TkbTree.DC => Binarymap.insert (m, c, TkbTree.MDC)
					 | SOME _ => m
					 | NONE => Binarymap.insert (m, c, TkbTree.DC)
			end
	  | findDef (CTR (CIMPL (t1, t2)), m) = TkbTree.preventSubst (TkbTree.findDef m t2) t1
	  | findDef (CTR (CEQ (t1, t2)), m) = TkbTree.preventSubst (TkbTree.preventSubst m t2) t1
	  | findDef (CTR (CTRANS rs), m) = m
	  | findDef (CTR (CREFL rs), m) = m
	  | findDef (CTR (CSER rs), m) = m
	  | findDef (CTR (CSYM rs), m) = m
	  | findDef (CTR (CIMPR (r1, r2)), m) = m
		
		fun define (CPT (c, t), (dict, ys)) =
			let
			in
				case Binarymap.peek (dict, c)
					of SOME TkbTree.DC =>
						let
							val (dict, t) = TkbTree.subst dict t
						in
							(Binarymap.insert (dict, c, t), ys)
						end
					 | SOME TkbTree.MDC =>
						let
							val (dict, t) = TkbTree.subst dict t
						in
							case !Settings.dcRepresentation
								of Settings.DCRNORM =>
									(dict, (Parsetree.dimpl (Parsetree.PROPVAR c) (TkbTree.toParsetree t))::ys)
								 | Settings.DCRCONJ =>
									let
										val t' = TkbTree.toParsetree t
										val t1 = Parsetree.impl (Parsetree.PROPVAR c) t'
										val t2 = Parsetree.impl t' (Parsetree.PROPVAR c)
									in
										(dict, (Parsetree.conj t1 t2)::ys)
									end
								 | Settings.DCRDISJ =>
									let
										val t' = TkbTree.toParsetree t
										val t1 = Parsetree.conj (Parsetree.PROPVAR c) t'
										val t2 = Parsetree.conj (Parsetree.neg (Parsetree.PROPVAR c)) (Parsetree.neg t')
									in
										(dict, (Parsetree.disj t1 t2)::ys)
									end
						end
					 | SOME _ => Exn.unexpected "AdvancedTkbGrm.transform.define"
					 | NONE => Exn.unexpected "AdvancedTkbGrm.transform.define"
			end
		  | define (CTR (CIMPL (t1, t2)), (dict, ys)) = (dict, (Parsetree.impl (TkbTree.toParsetree t1) (TkbTree.toParsetree t2))::ys)
		  | define (CTR (CEQ (t1, t2)), (dict, ys)) = (dict, (Parsetree.dimpl (TkbTree.toParsetree t1) (TkbTree.toParsetree t2))::ys)
		  | define (CTR (CTRANS rs), x) = (app RelationMgr.setTransitive rs; x)
		  | define (CTR (CREFL rs), x) = (app RelationMgr.setReflexive rs; x)
		  | define (CTR (CSER rs), x) = (app RelationMgr.setSerial rs; x)
		  | define (CTR (CSYM rs), x) = (app RelationMgr.setSymmetric rs; x)
		  | define (CTR (CIMPR (r1, r2)), x) = (RelationMgr.setSubrelation (r1, r2); x)
		
		val m = foldl findDef (Binarymap.mkDict String.compare) xs
		
		val (dict, ys) = foldl define (m, nil) xs
		
		val univ =
			foldl
				(fn (t, s) => Parsetree.conj s t)
				(Parsetree.mconj nil)
				ys
		
		val checksat =
			let
				fun f c =
					case Binarymap.peek (dict, c)
						of NONE => (c, Parsetree.mconj nil)
						 | SOME TkbTree.MDC => (c, Parsetree.EXISTS (Parsetree.PROPVAR c))
						 | SOME TkbTree.DC => Exn.unexpected "AdvancedTkbGrm.transform"
						 | SOME t => (c, Parsetree.EXISTS (TkbTree.toParsetree t))
			in
				map f
					(case !Settings.checksat
						of ["*"] => map #1 (Binarymap.listItems dict)
						 | xs => xs
					)
			end
	in
		(Parsetree.ALL univ, SOME checksat)
	end


end
structure LrTable = Token.LrTable
structure Token = Token
local open LrTable in 
val table=let val actionRows =
"\
\\001\000\001\000\026\000\000\000\
\\001\000\001\000\028\000\000\000\
\\001\000\001\000\037\000\002\000\036\000\003\000\035\000\004\000\063\000\
\\005\000\062\000\006\000\061\000\007\000\060\000\008\000\059\000\
\\009\000\034\000\017\000\058\000\000\000\
\\001\000\001\000\037\000\002\000\036\000\003\000\035\000\009\000\034\000\000\000\
\\001\000\001\000\037\000\002\000\036\000\003\000\035\000\009\000\034\000\
\\010\000\072\000\000\000\
\\001\000\001\000\039\000\000\000\
\\001\000\001\000\042\000\002\000\041\000\003\000\040\000\000\000\
\\001\000\001\000\045\000\002\000\044\000\003\000\043\000\000\000\
\\001\000\001\000\046\000\000\000\
\\001\000\001\000\048\000\000\000\
\\001\000\001\000\080\000\000\000\
\\001\000\001\000\081\000\000\000\
\\001\000\001\000\082\000\000\000\
\\001\000\009\000\008\000\000\000\
\\001\000\009\000\010\000\011\000\024\000\012\000\023\000\013\000\022\000\
\\014\000\021\000\015\000\020\000\016\000\019\000\018\000\018\000\
\\019\000\017\000\020\000\016\000\021\000\015\000\022\000\014\000\000\000\
\\001\000\010\000\025\000\000\000\
\\001\000\010\000\049\000\000\000\
\\001\000\010\000\051\000\000\000\
\\001\000\010\000\052\000\000\000\
\\001\000\010\000\053\000\000\000\
\\001\000\010\000\065\000\000\000\
\\001\000\010\000\073\000\000\000\
\\001\000\010\000\074\000\000\000\
\\001\000\010\000\075\000\000\000\
\\001\000\010\000\076\000\000\000\
\\001\000\010\000\077\000\000\000\
\\001\000\010\000\078\000\000\000\
\\001\000\010\000\087\000\000\000\
\\001\000\010\000\088\000\000\000\
\\001\000\010\000\089\000\000\000\
\\001\000\010\000\090\000\000\000\
\\001\000\010\000\091\000\000\000\
\\001\000\010\000\092\000\000\000\
\\001\000\010\000\093\000\000\000\
\\001\000\010\000\094\000\000\000\
\\001\000\011\000\024\000\012\000\023\000\013\000\022\000\014\000\021\000\
\\015\000\020\000\016\000\019\000\018\000\018\000\019\000\017\000\
\\020\000\016\000\021\000\015\000\022\000\014\000\000\000\
\\001\000\023\000\000\000\000\000\
\\100\000\000\000\
\\101\000\009\000\008\000\000\000\
\\102\000\000\000\
\\103\000\000\000\
\\104\000\009\000\010\000\000\000\
\\105\000\000\000\
\\106\000\009\000\010\000\000\000\
\\107\000\000\000\
\\108\000\009\000\010\000\000\000\
\\109\000\000\000\
\\110\000\000\000\
\\111\000\000\000\
\\112\000\000\000\
\\113\000\000\000\
\\114\000\000\000\
\\115\000\000\000\
\\116\000\000\000\
\\117\000\000\000\
\\118\000\000\000\
\\119\000\000\000\
\\120\000\000\000\
\\121\000\000\000\
\\122\000\000\000\
\\123\000\000\000\
\\124\000\000\000\
\\125\000\000\000\
\\126\000\001\000\037\000\002\000\036\000\003\000\035\000\009\000\034\000\000\000\
\\127\000\000\000\
\\128\000\000\000\
\\129\000\000\000\
\\130\000\000\000\
\\131\000\000\000\
\\132\000\000\000\
\\133\000\000\000\
\\134\000\000\000\
\\135\000\000\000\
\\136\000\000\000\
\\137\000\000\000\
\\138\000\000\000\
\\139\000\000\000\
\\140\000\000\000\
\\141\000\001\000\080\000\000\000\
\\142\000\000\000\
\\143\000\001\000\028\000\000\000\
\\144\000\000\000\
\"
val actionRowNumbers =
"\013\000\045\000\043\000\041\000\
\\040\000\037\000\014\000\046\000\
\\035\000\044\000\042\000\015\000\
\\000\000\001\000\001\000\001\000\
\\001\000\003\000\003\000\005\000\
\\006\000\007\000\008\000\038\000\
\\009\000\016\000\080\000\017\000\
\\018\000\019\000\068\000\003\000\
\\002\000\076\000\075\000\074\000\
\\003\000\020\000\003\000\003\000\
\\003\000\003\000\003\000\004\000\
\\021\000\039\000\022\000\055\000\
\\081\000\054\000\053\000\052\000\
\\023\000\024\000\025\000\026\000\
\\010\000\011\000\012\000\003\000\
\\003\000\003\000\027\000\059\000\
\\028\000\029\000\030\000\031\000\
\\032\000\033\000\058\000\057\000\
\\056\000\051\000\066\000\065\000\
\\077\000\034\000\078\000\003\000\
\\003\000\069\000\063\000\071\000\
\\070\000\047\000\062\000\061\000\
\\060\000\050\000\049\000\048\000\
\\067\000\079\000\073\000\072\000\
\\064\000\036\000"
val gotoT =
"\
\\001\000\097\000\003\000\005\000\004\000\004\000\005\000\003\000\
\\006\000\002\000\007\000\001\000\000\000\
\\004\000\007\000\005\000\003\000\006\000\002\000\007\000\001\000\000\000\
\\004\000\009\000\005\000\003\000\006\000\002\000\007\000\001\000\000\000\
\\004\000\010\000\005\000\003\000\006\000\002\000\007\000\001\000\000\000\
\\000\000\
\\000\000\
\\004\000\011\000\005\000\003\000\006\000\002\000\007\000\001\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\013\000\025\000\000\000\
\\013\000\027\000\000\000\
\\013\000\028\000\000\000\
\\013\000\029\000\000\000\
\\008\000\031\000\011\000\030\000\000\000\
\\008\000\036\000\011\000\030\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\003\000\045\000\004\000\004\000\005\000\003\000\006\000\002\000\
\\007\000\001\000\000\000\
\\000\000\
\\000\000\
\\013\000\048\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\000\000\
\\008\000\052\000\011\000\030\000\000\000\
\\008\000\055\000\009\000\054\000\010\000\053\000\011\000\030\000\000\000\
\\000\000\
\\000\000\
\\000\000\
\\008\000\062\000\011\000\030\000\000\000\
\\000\000\
\\008\000\064\000\011\000\030\000\000\000\
\\008\000\065\000\011\000\030\000\000\000\
\\008\000\066\000\011\000\030\000\000\000\
\\008\000\067\000\011\000\030\000\000\000\
\\008\000\068\000\011\000\030\000\000\000\
\\008\000\069\000\011\000\030\000\000\000\
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
\\012\000\077\000\000\000\
\\000\000\
\\000\000\
\\008\000\081\000\011\000\030\000\000\000\
\\002\000\083\000\008\000\082\000\011\000\030\000\000\000\
\\002\000\084\000\008\000\082\000\011\000\030\000\000\000\
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
\\012\000\093\000\000\000\
\\008\000\094\000\011\000\030\000\000\000\
\\008\000\095\000\011\000\030\000\000\000\
\\000\000\
\\002\000\096\000\008\000\082\000\011\000\030\000\000\000\
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
\"
val numstates = 98
val numrules = 45
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
 | ATOM of unit ->  (string) | VARLIST of unit ->  (string list)
 | ONEOFLIST of unit ->  (TkbTree.formula)
 | ATOMIC_EXPR of unit ->  (TkbTree.formula)
 | RULE_EXPR of unit ->  (TkbTree.formula)
 | BOOLEAN_EXPR of unit ->  (TkbTree.formula)
 | FORMULA of unit ->  (TkbTree.formula)
 | NOTHINGTODO of unit ->  (unit)
 | CONSTRAINT of unit ->  (definition)
 | CONCEPT of unit ->  (definition)
 | DCLIST of unit ->  (definition list)
 | DCLISTS of unit ->  ( ( Parsetree.parsetree * (string * Parsetree.parsetree) list option )  list)
 | FLIST of unit ->  (TkbTree.formula list)
 | START of unit ->  ( ( Parsetree.parsetree * (string * Parsetree.parsetree) list option )  list)
end
type svalue = MlyValue.svalue
type result = 
 ( Parsetree.parsetree * (string * Parsetree.parsetree) list option )  list
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
fn (T 22) => true | _ => false
val showTerminal =
fn (T 0) => "ATOM"
  | (T 1) => "TRUE"
  | (T 2) => "FALSE"
  | (T 3) => "AND"
  | (T 4) => "OR"
  | (T 5) => "NOT"
  | (T 6) => "BOX"
  | (T 7) => "DIA"
  | (T 8) => "LPAREN"
  | (T 9) => "RPAREN"
  | (T 10) => "DPR"
  | (T 11) => "DPC"
  | (T 12) => "DC"
  | (T 13) => "DI"
  | (T 14) => "IMPLIESC"
  | (T 15) => "EQUALC"
  | (T 16) => "ONEOF"
  | (T 17) => "TRANSITIVE"
  | (T 18) => "REFLEXIVE"
  | (T 19) => "SERIAL"
  | (T 20) => "SYMMETRIC"
  | (T 21) => "IMPLIESR"
  | (T 22) => "EOF"
  | _ => "bogus-term"
local open Header in
val errtermvalue=
fn _ => MlyValue.VOID
end
val terms : term list = nil
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
of  ( 0, ( ( _, ( MlyValue.DCLISTS DCLISTS1, DCLISTS1left, 
DCLISTS1right)) :: rest671)) => let val  result = MlyValue.START (fn _
 => let val  (DCLISTS as DCLISTS1) = DCLISTS1 ()
 in (DCLISTS)
end)
 in ( LrTable.NT 0, ( result, DCLISTS1left, DCLISTS1right), rest671)

end
|  ( 1, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.DCLIST 
DCLIST1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let val 
 result = MlyValue.DCLISTS (fn _ => let val  (DCLIST as DCLIST1) = 
DCLIST1 ()
 in ([transform DCLIST])
end)
 in ( LrTable.NT 2, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 2, ( ( _, ( MlyValue.DCLISTS DCLISTS1, _, DCLISTS1right)) :: _ ::
 ( _, ( MlyValue.DCLIST DCLIST1, _, _)) :: ( _, ( _, LPAREN1left, _))
 :: rest671)) => let val  result = MlyValue.DCLISTS (fn _ => let val 
 (DCLIST as DCLIST1) = DCLIST1 ()
 val  (DCLISTS as DCLISTS1) = DCLISTS1 ()
 in ((transform DCLIST)::DCLISTS)
end)
 in ( LrTable.NT 2, ( result, LPAREN1left, DCLISTS1right), rest671)

end
|  ( 3, ( ( _, ( MlyValue.DCLIST DCLIST1, DCLIST1left, DCLIST1right))
 :: rest671)) => let val  result = MlyValue.DCLISTS (fn _ => let val 
 (DCLIST as DCLIST1) = DCLIST1 ()
 in ([transform DCLIST])
end)
 in ( LrTable.NT 2, ( result, DCLIST1left, DCLIST1right), rest671)
end
|  ( 4, ( ( _, ( MlyValue.CONCEPT CONCEPT1, CONCEPT1left, 
CONCEPT1right)) :: rest671)) => let val  result = MlyValue.DCLIST (fn
 _ => let val  (CONCEPT as CONCEPT1) = CONCEPT1 ()
 in ([CONCEPT])
end)
 in ( LrTable.NT 3, ( result, CONCEPT1left, CONCEPT1right), rest671)

end
|  ( 5, ( ( _, ( MlyValue.DCLIST DCLIST1, _, DCLIST1right)) :: ( _, ( 
MlyValue.CONCEPT CONCEPT1, CONCEPT1left, _)) :: rest671)) => let val  
result = MlyValue.DCLIST (fn _ => let val  (CONCEPT as CONCEPT1) = 
CONCEPT1 ()
 val  (DCLIST as DCLIST1) = DCLIST1 ()
 in (CONCEPT::DCLIST)
end)
 in ( LrTable.NT 3, ( result, CONCEPT1left, DCLIST1right), rest671)

end
|  ( 6, ( ( _, ( MlyValue.CONSTRAINT CONSTRAINT1, CONSTRAINT1left, 
CONSTRAINT1right)) :: rest671)) => let val  result = MlyValue.DCLIST
 (fn _ => let val  (CONSTRAINT as CONSTRAINT1) = CONSTRAINT1 ()
 in ([CONSTRAINT])
end)
 in ( LrTable.NT 3, ( result, CONSTRAINT1left, CONSTRAINT1right), 
rest671)
end
|  ( 7, ( ( _, ( MlyValue.DCLIST DCLIST1, _, DCLIST1right)) :: ( _, ( 
MlyValue.CONSTRAINT CONSTRAINT1, CONSTRAINT1left, _)) :: rest671)) =>
 let val  result = MlyValue.DCLIST (fn _ => let val  (CONSTRAINT as 
CONSTRAINT1) = CONSTRAINT1 ()
 val  (DCLIST as DCLIST1) = DCLIST1 ()
 in (CONSTRAINT::DCLIST)
end)
 in ( LrTable.NT 3, ( result, CONSTRAINT1left, DCLIST1right), rest671)

end
|  ( 8, ( ( _, ( MlyValue.NOTHINGTODO NOTHINGTODO1, NOTHINGTODO1left, 
NOTHINGTODO1right)) :: rest671)) => let val  result = MlyValue.DCLIST
 (fn _ => let val  NOTHINGTODO1 = NOTHINGTODO1 ()
 in (nil)
end)
 in ( LrTable.NT 3, ( result, NOTHINGTODO1left, NOTHINGTODO1right), 
rest671)
end
|  ( 9, ( ( _, ( MlyValue.DCLIST DCLIST1, _, DCLIST1right)) :: ( _, ( 
MlyValue.NOTHINGTODO NOTHINGTODO1, NOTHINGTODO1left, _)) :: rest671))
 => let val  result = MlyValue.DCLIST (fn _ => let val  NOTHINGTODO1 =
 NOTHINGTODO1 ()
 val  (DCLIST as DCLIST1) = DCLIST1 ()
 in (DCLIST)
end)
 in ( LrTable.NT 3, ( result, NOTHINGTODO1left, DCLIST1right), rest671
)
end
|  ( 10, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA2, _, _)) :: ( _, ( MlyValue.FORMULA FORMULA1, _, _)) :: _ :: (
 _, ( _, LPAREN1left, _)) :: rest671)) => let val  result = 
MlyValue.CONSTRAINT (fn _ => let val  FORMULA1 = FORMULA1 ()
 val  FORMULA2 = FORMULA2 ()
 in (CTR (CIMPL (FORMULA1, FORMULA2)))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 11, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: ( _, ( MlyValue.ATOM ATOM1, _, _)) :: _ :: ( _, (
 _, LPAREN1left, _)) :: rest671)) => let val  result = 
MlyValue.CONSTRAINT (fn _ => let val  (ATOM as ATOM1) = ATOM1 ()
 val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (CTR (CIMPL (TkbTree.PC ATOM, FORMULA)))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 12, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671))
 => let val  result = MlyValue.CONSTRAINT (fn _ => let val  (FORMULA
 as FORMULA1) = FORMULA1 ()
 in (CTR (CIMPL (TkbTree.CONJ nil, FORMULA)))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 13, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671))
 => let val  result = MlyValue.CONSTRAINT (fn _ => let val  (FORMULA
 as FORMULA1) = FORMULA1 ()
 in (CTR (CIMPL (TkbTree.DISJ nil, FORMULA)))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 14, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA2, _, _)) :: ( _, ( MlyValue.FORMULA FORMULA1, _, _)) :: _ :: (
 _, ( _, LPAREN1left, _)) :: rest671)) => let val  result = 
MlyValue.CONSTRAINT (fn _ => let val  FORMULA1 = FORMULA1 ()
 val  FORMULA2 = FORMULA2 ()
 in (CTR (CEQ (FORMULA1, FORMULA2)))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 15, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) =>
 let val  result = MlyValue.CONSTRAINT (fn _ => let val  (VARLIST as 
VARLIST1) = VARLIST1 ()
 in (CTR (CTRANS VARLIST))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 16, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) =>
 let val  result = MlyValue.CONSTRAINT (fn _ => let val  (VARLIST as 
VARLIST1) = VARLIST1 ()
 in (CTR (CREFL VARLIST))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 17, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) =>
 let val  result = MlyValue.CONSTRAINT (fn _ => let val  (VARLIST as 
VARLIST1) = VARLIST1 ()
 in (CTR (CSER VARLIST))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 18, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.VARLIST 
VARLIST1, _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) =>
 let val  result = MlyValue.CONSTRAINT (fn _ => let val  (VARLIST as 
VARLIST1) = VARLIST1 ()
 in (CTR (CSYM VARLIST))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 19, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.ATOM ATOM2,
 _, _)) :: ( _, ( MlyValue.ATOM ATOM1, _, _)) :: _ :: ( _, ( _, 
LPAREN1left, _)) :: rest671)) => let val  result = MlyValue.CONSTRAINT
 (fn _ => let val  ATOM1 = ATOM1 ()
 val  ATOM2 = ATOM2 ()
 in (CTR (CIMPR (ATOM1, ATOM2)))
end)
 in ( LrTable.NT 5, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 20, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.ATOM ATOM1,
 _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let val  
result = MlyValue.NOTHINGTODO (fn _ => let val  ATOM1 = ATOM1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 21, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.ATOM ATOM1,
 _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let val  
result = MlyValue.NOTHINGTODO (fn _ => let val  ATOM1 = ATOM1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 22, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.ATOM ATOM1,
 _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let val  
result = MlyValue.NOTHINGTODO (fn _ => let val  ATOM1 = ATOM1 ()
 in (())
end)
 in ( LrTable.NT 6, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 23, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: ( _, ( MlyValue.ATOM ATOM1, _, _)) :: _ :: ( _, (
 _, LPAREN1left, _)) :: rest671)) => let val  result = 
MlyValue.CONCEPT (fn _ => let val  (ATOM as ATOM1) = ATOM1 ()
 val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (CPT (ATOM, FORMULA))
end)
 in ( LrTable.NT 4, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 24, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671))
 => let val  result = MlyValue.CONCEPT (fn _ => let val  (FORMULA as 
FORMULA1) = FORMULA1 ()
 in (CTR (CEQ (TkbTree.CONJ nil, FORMULA)))
end)
 in ( LrTable.NT 4, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 25, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: _ :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671))
 => let val  result = MlyValue.CONCEPT (fn _ => let val  (FORMULA as 
FORMULA1) = FORMULA1 ()
 in (CTR (CEQ (TkbTree.DISJ nil, FORMULA)))
end)
 in ( LrTable.NT 4, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 26, ( ( _, ( MlyValue.FORMULA FORMULA1, FORMULA1left, 
FORMULA1right)) :: rest671)) => let val  result = MlyValue.FLIST (fn _
 => let val  (FORMULA as FORMULA1) = FORMULA1 ()
 in ([FORMULA])
end)
 in ( LrTable.NT 1, ( result, FORMULA1left, FORMULA1right), rest671)

end
|  ( 27, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( 
MlyValue.FORMULA FORMULA1, FORMULA1left, _)) :: rest671)) => let val  
result = MlyValue.FLIST (fn _ => let val  (FORMULA as FORMULA1) = 
FORMULA1 ()
 val  (FLIST as FLIST1) = FLIST1 ()
 in (FORMULA::FLIST)
end)
 in ( LrTable.NT 1, ( result, FORMULA1left, FLIST1right), rest671)
end
|  ( 28, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.BOOLEAN_EXPR
 BOOLEAN_EXPR1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) =>
 let val  result = MlyValue.FORMULA (fn _ => let val  (BOOLEAN_EXPR
 as BOOLEAN_EXPR1) = BOOLEAN_EXPR1 ()
 in (BOOLEAN_EXPR)
end)
 in ( LrTable.NT 7, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 29, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.RULE_EXPR 
RULE_EXPR1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.FORMULA (fn _ => let val  (RULE_EXPR as 
RULE_EXPR1) = RULE_EXPR1 ()
 in (RULE_EXPR)
end)
 in ( LrTable.NT 7, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 30, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.ONEOFLIST 
ONEOFLIST1, _, _)) :: _ :: ( _, ( _, LPAREN1left, _)) :: rest671)) =>
 let val  result = MlyValue.FORMULA (fn _ => let val  (ONEOFLIST as 
ONEOFLIST1) = ONEOFLIST1 ()
 in (ONEOFLIST)
end)
 in ( LrTable.NT 7, ( result, LPAREN1left, RPAREN1right), rest671)
end
|  ( 31, ( ( _, ( MlyValue.ATOMIC_EXPR ATOMIC_EXPR1, ATOMIC_EXPR1left,
 ATOMIC_EXPR1right)) :: rest671)) => let val  result = 
MlyValue.FORMULA (fn _ => let val  (ATOMIC_EXPR as ATOMIC_EXPR1) = 
ATOMIC_EXPR1 ()
 in (ATOMIC_EXPR)
end)
 in ( LrTable.NT 7, ( result, ATOMIC_EXPR1left, ATOMIC_EXPR1right), 
rest671)
end
|  ( 32, ( ( _, ( MlyValue.FORMULA FORMULA1, _, FORMULA1right)) :: ( _
, ( _, NOT1left, _)) :: rest671)) => let val  result = 
MlyValue.BOOLEAN_EXPR (fn _ => let val  (FORMULA as FORMULA1) = 
FORMULA1 ()
 in (TkbTree.NEG FORMULA)
end)
 in ( LrTable.NT 8, ( result, NOT1left, FORMULA1right), rest671)
end
|  ( 33, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( _,
 AND1left, _)) :: rest671)) => let val  result = MlyValue.BOOLEAN_EXPR
 (fn _ => let val  (FLIST as FLIST1) = FLIST1 ()
 in (TkbTree.CONJ FLIST)
end)
 in ( LrTable.NT 8, ( result, AND1left, FLIST1right), rest671)
end
|  ( 34, ( ( _, ( MlyValue.FLIST FLIST1, _, FLIST1right)) :: ( _, ( _,
 OR1left, _)) :: rest671)) => let val  result = MlyValue.BOOLEAN_EXPR
 (fn _ => let val  (FLIST as FLIST1) = FLIST1 ()
 in (TkbTree.DISJ FLIST)
end)
 in ( LrTable.NT 8, ( result, OR1left, FLIST1right), rest671)
end
|  ( 35, ( ( _, ( MlyValue.FORMULA FORMULA1, _, FORMULA1right)) :: ( _
, ( MlyValue.ATOM ATOM1, _, _)) :: ( _, ( _, BOX1left, _)) :: rest671)
) => let val  result = MlyValue.RULE_EXPR (fn _ => let val  (ATOM as 
ATOM1) = ATOM1 ()
 val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (TkbTree.BOX (ATOM, FORMULA))
end)
 in ( LrTable.NT 9, ( result, BOX1left, FORMULA1right), rest671)
end
|  ( 36, ( ( _, ( MlyValue.FORMULA FORMULA1, _, FORMULA1right)) :: ( _
, ( MlyValue.ATOM ATOM1, _, _)) :: ( _, ( _, DIA1left, _)) :: rest671)
) => let val  result = MlyValue.RULE_EXPR (fn _ => let val  (ATOM as 
ATOM1) = ATOM1 ()
 val  (FORMULA as FORMULA1) = FORMULA1 ()
 in (TkbTree.DIA (ATOM, FORMULA))
end)
 in ( LrTable.NT 9, ( result, DIA1left, FORMULA1right), rest671)
end
|  ( 37, ( ( _, ( MlyValue.ATOM ATOM1, ATOM1left, ATOM1right)) :: 
rest671)) => let val  result = MlyValue.ATOMIC_EXPR (fn _ => let val 
 (ATOM as ATOM1) = ATOM1 ()
 in (TkbTree.PC ATOM)
end)
 in ( LrTable.NT 10, ( result, ATOM1left, ATOM1right), rest671)
end
|  ( 38, ( ( _, ( _, TRUE1left, TRUE1right)) :: rest671)) => let val  
result = MlyValue.ATOMIC_EXPR (fn _ => (TkbTree.CONJ nil))
 in ( LrTable.NT 10, ( result, TRUE1left, TRUE1right), rest671)
end
|  ( 39, ( ( _, ( _, FALSE1left, FALSE1right)) :: rest671)) => let
 val  result = MlyValue.ATOMIC_EXPR (fn _ => (TkbTree.DISJ nil))
 in ( LrTable.NT 10, ( result, FALSE1left, FALSE1right), rest671)
end
|  ( 40, ( ( _, ( _, _, RPAREN1right)) :: ( _, ( MlyValue.FORMULA 
FORMULA1, _, _)) :: ( _, ( _, LPAREN1left, _)) :: rest671)) => let
 val  result = MlyValue.ATOMIC_EXPR (fn _ => let val  (FORMULA as 
FORMULA1) = FORMULA1 ()
 in (FORMULA)
end)
 in ( LrTable.NT 10, ( result, LPAREN1left, RPAREN1right), rest671)

end
|  ( 41, ( ( _, ( MlyValue.ATOM ATOM1, ATOM1left, ATOM1right)) :: 
rest671)) => let val  result = MlyValue.ONEOFLIST (fn _ => let val  (
ATOM as ATOM1) = ATOM1 ()
 in (TkbTree.EQ ATOM)
end)
 in ( LrTable.NT 11, ( result, ATOM1left, ATOM1right), rest671)
end
|  ( 42, ( ( _, ( MlyValue.ONEOFLIST ONEOFLIST1, _, ONEOFLIST1right))
 :: ( _, ( MlyValue.ATOM ATOM1, ATOM1left, _)) :: rest671)) => let
 val  result = MlyValue.ONEOFLIST (fn _ => let val  (ATOM as ATOM1) = 
ATOM1 ()
 val  (ONEOFLIST as ONEOFLIST1) = ONEOFLIST1 ()
 in (TkbTree.DISJ [TkbTree.EQ ATOM, ONEOFLIST])
end)
 in ( LrTable.NT 11, ( result, ATOM1left, ONEOFLIST1right), rest671)

end
|  ( 43, ( ( _, ( MlyValue.ATOM ATOM1, ATOM1left, ATOM1right)) :: 
rest671)) => let val  result = MlyValue.VARLIST (fn _ => let val  (
ATOM as ATOM1) = ATOM1 ()
 in ([ATOM])
end)
 in ( LrTable.NT 12, ( result, ATOM1left, ATOM1right), rest671)
end
|  ( 44, ( ( _, ( MlyValue.VARLIST VARLIST1, _, VARLIST1right)) :: ( _
, ( MlyValue.ATOM ATOM1, ATOM1left, _)) :: rest671)) => let val  
result = MlyValue.VARLIST (fn _ => let val  (ATOM as ATOM1) = ATOM1 ()
 val  (VARLIST as VARLIST1) = VARLIST1 ()
 in (ATOM::VARLIST)
end)
 in ( LrTable.NT 12, ( result, ATOM1left, VARLIST1right), rest671)
end
| _ => raise (mlyAction i392)
end
val void = MlyValue.VOID
val extract = fn a => (fn MlyValue.START x => x
| _ => let exception ParseInternal
	in raise ParseInternal end) a ()
end
end
structure Tokens : AdvancedTkb_TOKENS =
struct
type svalue = ParserData.svalue
type ('a,'b) token = ('a,'b) Token.token
fun ATOM (i,p1,p2) = Token.TOKEN (ParserData.LrTable.T 0,(
ParserData.MlyValue.ATOM (fn () => i),p1,p2))
fun TRUE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 1,(
ParserData.MlyValue.VOID,p1,p2))
fun FALSE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 2,(
ParserData.MlyValue.VOID,p1,p2))
fun AND (p1,p2) = Token.TOKEN (ParserData.LrTable.T 3,(
ParserData.MlyValue.VOID,p1,p2))
fun OR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 4,(
ParserData.MlyValue.VOID,p1,p2))
fun NOT (p1,p2) = Token.TOKEN (ParserData.LrTable.T 5,(
ParserData.MlyValue.VOID,p1,p2))
fun BOX (p1,p2) = Token.TOKEN (ParserData.LrTable.T 6,(
ParserData.MlyValue.VOID,p1,p2))
fun DIA (p1,p2) = Token.TOKEN (ParserData.LrTable.T 7,(
ParserData.MlyValue.VOID,p1,p2))
fun LPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 8,(
ParserData.MlyValue.VOID,p1,p2))
fun RPAREN (p1,p2) = Token.TOKEN (ParserData.LrTable.T 9,(
ParserData.MlyValue.VOID,p1,p2))
fun DPR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 10,(
ParserData.MlyValue.VOID,p1,p2))
fun DPC (p1,p2) = Token.TOKEN (ParserData.LrTable.T 11,(
ParserData.MlyValue.VOID,p1,p2))
fun DC (p1,p2) = Token.TOKEN (ParserData.LrTable.T 12,(
ParserData.MlyValue.VOID,p1,p2))
fun DI (p1,p2) = Token.TOKEN (ParserData.LrTable.T 13,(
ParserData.MlyValue.VOID,p1,p2))
fun IMPLIESC (p1,p2) = Token.TOKEN (ParserData.LrTable.T 14,(
ParserData.MlyValue.VOID,p1,p2))
fun EQUALC (p1,p2) = Token.TOKEN (ParserData.LrTable.T 15,(
ParserData.MlyValue.VOID,p1,p2))
fun ONEOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 16,(
ParserData.MlyValue.VOID,p1,p2))
fun TRANSITIVE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 17,(
ParserData.MlyValue.VOID,p1,p2))
fun REFLEXIVE (p1,p2) = Token.TOKEN (ParserData.LrTable.T 18,(
ParserData.MlyValue.VOID,p1,p2))
fun SERIAL (p1,p2) = Token.TOKEN (ParserData.LrTable.T 19,(
ParserData.MlyValue.VOID,p1,p2))
fun SYMMETRIC (p1,p2) = Token.TOKEN (ParserData.LrTable.T 20,(
ParserData.MlyValue.VOID,p1,p2))
fun IMPLIESR (p1,p2) = Token.TOKEN (ParserData.LrTable.T 21,(
ParserData.MlyValue.VOID,p1,p2))
fun EOF (p1,p2) = Token.TOKEN (ParserData.LrTable.T 22,(
ParserData.MlyValue.VOID,p1,p2))
end
end
