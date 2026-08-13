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


structure TkbTree =
	struct
		datatype formula = PC of string | DC | MDC | NEG of formula | CONJ of formula list | DISJ of formula list | BOX of string * formula | DIA of string * formula | EQ of string
		
		
		fun subst dict (PC c) =
			let
			in
				case Binarymap.peek (dict, c)
					of NONE => (Binarymap.insert (dict, c, PC c), PC c)
					 | SOME DC => Exn.unexpected "TkbTree.subst"
					 | SOME MDC => (dict, PC c)
					 | SOME t => (dict, t)
			end
		  | subst dict (EQ n) = (dict, EQ n)
		  | subst dict (NEG t) =
			let
				val (dict, t) = subst dict t
			in
				(dict, NEG t)
			end
		  | subst dict (CONJ ts) =
			let
				val (dict, ts) = foldl (fn (t, (dict, ts)) => (fn (dict, t) => (dict, t::ts)) (subst dict t)) (dict, nil) ts
			in
				(dict, CONJ (List.rev ts))
			end
		  | subst dict (DISJ ts) =
			let
				val (dict, ts) = foldl (fn (t, (dict, ts)) => (fn (dict, t) => (dict, t::ts)) (subst dict t)) (dict, nil) ts
			in
				(dict, DISJ (List.rev ts))
			end
		  | subst dict (BOX (r, t)) =
			let
				val (dict, t) = subst dict t
			in
				(dict, BOX (r, t))
			end
		  | subst dict (DIA (r, t)) =
			let
				val (dict, t) = subst dict t
			in
				(dict, DIA (r, t))
			end
		  | subst dict DC = Exn.unexpArg "TkbTree.subst"
		  | subst dict MDC = Exn.unexpArg "TkbTree.subst"
		
		
		fun findDef m (PC c) =
			let
			in
				case Binarymap.peek (m, c)
					of NONE => Binarymap.insert (m, c, PC c)
					 | SOME _ => m
			end
		  | findDef m (EQ _) = m
		  | findDef m (NEG t) = findDef m t
		  | findDef m (CONJ ts) = foldl (fn (t, m) => findDef m t) m ts
		  | findDef m (DISJ ts) = foldl (fn (t, m) => findDef m t) m ts
		  | findDef m (BOX (_, t)) = findDef m t
		  | findDef m (DIA (_, t)) = findDef m t
		  | findDef _ DC = Exn.unexpArg "TkbTree.findDef"
		  | findDef _ MDC = Exn.unexpArg "TkbTree.findDef"
		
		
		fun preventSubst m (PC c) = Binarymap.insert (m, c, MDC)
		  | preventSubst m (EQ _) = m
		  | preventSubst m (NEG t) = preventSubst m t
		  | preventSubst m (CONJ ts) = foldl (fn (t, m) => preventSubst m t) m ts
		  | preventSubst m (DISJ ts) = foldl (fn (t, m) => preventSubst m t) m ts
		  | preventSubst m (BOX (_, t)) = preventSubst m t
		  | preventSubst m (DIA (_, t)) = preventSubst m t
		  | preventSubst _ DC = Exn.unexpArg "TkbTree.preventSubst"
		  | preventSubst _ MDC = Exn.unexpArg "TkbTree.preventSubst"
		
		
		fun toParsetree (PC c) = Parsetree.PROPVAR c
		  | toParsetree (EQ n) = Parsetree.NOMINAL n
		  | toParsetree (NEG t) = Parsetree.neg (toParsetree t)
		  | toParsetree (CONJ ts) = Parsetree.mconj (map toParsetree ts)
		  | toParsetree (DISJ ts) = Parsetree.mdisj (map toParsetree ts)
		  | toParsetree (BOX (r, t)) = Parsetree.BOX (r, toParsetree t)
		  | toParsetree (DIA (r, t)) = Parsetree.DIAMOND (r, toParsetree t)
		  | toParsetree DC = Exn.unexpArg "TkbTree.toParsetree"
		  | toParsetree MDC = Exn.unexpArg "TkbTree.toParsetree"
	end
