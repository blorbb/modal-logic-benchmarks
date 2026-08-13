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


structure Agenda :> AGENDA =
	struct
		datatype action =
				  DIAMOND of int * Term.index * Dependency.depcy * int
				| BOX of int * Term.index * Dependency.depcy
				| BRANCH of int * Term.index * Dependency.depcy * int
				| AT of string * Term.index * Dependency.depcy
				| EQ of int * string * Dependency.depcy
				| UNIV of Term.index * Dependency.depcy
				| EXIST of Term.index * Dependency.depcy
		
		
		type queue = action BtprioQ.queue ref
		
		
		exception Empty
		
		exception Bcp
		
		
		val q = ref (BtprioQ.mkQueue (fn _ => Exn.unexpected "evaluating function passed to BtprioQ.makeQueue in Agenda."))
		
		val rs = ref nil : (action * int * int) list ref
		
		
		val expOrder = ref [#"[", #"@", #"n", #"A", #"E", #"<", #"|"]
		
		
		val fBcp = ref (fn _ => Exn.unexpected "Agenda.fBcp not set.")
		
		
		fun setBcpFunction f = fBcp := f
		
		
		fun getOrder () = String.implode (!expOrder)
		
		
		fun setOrder s =
			let
				fun rm _ nil = nil
				  | rm x (y::yr) = if x = y then yr else y::(rm x yr)
				
				val errMsg = "Same character occurring twice in order specification."
				
				fun setOrder' ys nil = ys
				  | setOrder' ys (#"n"::xr) =
						if List.exists (fn x => x = #"n") xr
						then Exn.error errMsg
						else #"n"::(setOrder' (rm #"n" ys) xr)
				  | setOrder' ys (#"["::xr) =
						if List.exists (fn x => x = #"[") xr
						then Exn.error errMsg
						else #"["::(setOrder' (rm #"[" ys) xr)
				  | setOrder' ys (#"<"::xr) =
						if List.exists (fn x => x = #"<") xr
						then Exn.error errMsg
						else if List.exists (fn x => x = #"%") xr
						then Exn.error "Order specification contains both '<' and '%'"
						else #"<"::(setOrder' (rm #"<" ys) xr)
				  | setOrder' ys (#"@"::xr) =
						if List.exists (fn x => x = #"@") xr
						then Exn.error errMsg
						else #"@"::(setOrder' (rm #"@" ys) xr)
				  | setOrder' ys (#"E"::xr) =
						if List.exists (fn x => x = #"E") xr
						then Exn.error errMsg
						else #"E"::(setOrder' (rm #"E" ys) xr)
				  | setOrder' ys (#"A"::xr) =
						if List.exists (fn x => x = #"A") xr
						then Exn.error errMsg
						else #"A"::(setOrder' (rm #"A" ys) xr)
				  | setOrder' ys (#"|"::xr) =
						if List.exists (fn x => x = #"|") xr
						then Exn.error errMsg
						else if List.exists (fn x => x = #"%") xr
						then Exn.error "Order specification contains both '|' and '%'"
						else #"|"::(setOrder' (rm #"|" ys) xr)
				  | setOrder' ys (#"%"::xr) =
						if List.exists (fn x => x = #"%") xr
						then Exn.error errMsg
						else if List.exists (fn x => x = #"<" orelse x = #"|") xr
						then Exn.error "Order specification contains '%' and one of '<','|'"
						else (Settings.diadisjdep := true; #"%"::(setOrder' (rm #"|" (rm #"<" ys)) xr))
				  | setOrder' _ (c::_) = Exn.error ("Invalid character " ^ (String.implode [c]) ^ " in term order specification.")
			in
				expOrder := (setOrder' (!expOrder) (String.explode s))
			end
		
		
		fun initialize () =
			let
				fun eqFifo (EQ (w1, n1, d1), EQ (w2, n2, d2)) =
						Util.compare [
							  fn () => Int.compare (Dependency.btDepth d1, Dependency.btDepth d2)
							, fn () => Int.compare (w1, w2)
							, fn () => String.compare (n1, n2)
						]
				  | eqFifo _ = Exn.unexpArg "Agenda.initialize.eqFifo"
				
				fun eqDep (EQ (w1, n1, d1), EQ (w2, n2, d2)) =
						Util.compare [
							  fn () => Dependency.compare (d1, d2)
							, fn () => Int.compare (w1, w2)
							, fn () => String.compare (n1, n2)
						]
				  | eqDep _ = Exn.unexpArg "Agenda.initialize.eqDep"
				
				fun atFifo (AT (n1, k1, d1), AT (n2, k2, d2)) =
						Util.compare [
							  fn () => Int.compare (Dependency.btDepth d1, Dependency.btDepth d2)
							, fn () => String.compare (n1, n2)
							, fn () => Int.compare (k1, k2)
						]
				  | atFifo _ = Exn.unexpArg "Agenda.initialize.atFifo"
				
				fun atDep (AT (n1, k1, d1), AT (n2, k2, d2)) =
						Util.compare [
							  fn () => Dependency.compare (d1, d2)
							, fn () => String.compare (n1, n2)
							, fn () => Int.compare (k1, k2)
						]
				  | atDep _ = Exn.unexpArg "Agenda.initialize.atDep"
				
				fun boxFifoNode (BOX (w1, k1, _), BOX (w2, k2, _)) = Util.intCompare [(w1, w2), (k1, k2)]
				  | boxFifoNode _ = Exn.unexpArg "Agenda.initialize.boxFifoNode"
				
				fun boxDep (BOX (w1, k1, d1), BOX (w2, k2, d2)) = (
					case Dependency.compare (d1, d2)
						of EQUAL => Util.intCompare [(w1, w2), (k1, k2)]
						 | r => r
					)
				  | boxDep _ = Exn.unexpArg "Agenda.initialize.boxDep"
				
				fun diaFifoNode (DIAMOND (w1, k1, _, _), DIAMOND (w2, k2, _, _)) = Util.intCompare [(w1, w2), (k1, k2)]
				  | diaFifoNode _ = Exn.unexpArg "Agenda.initialize.diaFifoNode"
				
				fun diaLifoNode (DIAMOND (w1, k1, _, _), DIAMOND (w2, k2, _, _)) = Util.intCompare [(w2, w1), (k1, k2)]
				  | diaLifoNode _ = Exn.unexpArg "Agenda.initialize.diaLifoNode"
				
				fun diaCarFifoNode (DIAMOND (w1, k1, _, c1), DIAMOND (w2, k2, _, c2)) = Util.intCompare [(c2, c1), (w1, w2), (k1, k2)]
				  | diaCarFifoNode _ = Exn.unexpArg "Agenda.initialize.diaFifoNode"
				
				fun diaCarLifoNode (DIAMOND (w1, k1, _, c1), DIAMOND (w2, k2, _, c2)) = Util.intCompare [(c2, c1), (w2, w1), (k1, k2)]
				  | diaCarLifoNode _ = Exn.unexpArg "Agenda.initialize.diaLifoNode"
				
				fun diaFifo (DIAMOND (w1, k1, d1, _), DIAMOND (w2, k2, d2, _)) = Util.intCompare [(Dependency.btDepth d1, Dependency.btDepth d2), (k1, k2), (w1, w2)]
				  | diaFifo _ = Exn.unexpArg "Agenda.initialize.diaFifo"
				
				fun diaDep (DIAMOND (w1, k1, d1, _), DIAMOND (w2, k2, d2, _)) = (
						case Dependency.compare (d1, d2)
							of EQUAL => Util.intCompare [(k1, k2), (w1, w2)]
							 | r => r
						)
				  | diaDep _ = Exn.unexpArg "Agenda.initialize.diaDep"
				
				fun diaLifo (DIAMOND (w1, k1, d1, _), DIAMOND (w2, k2, d2, _)) = Util.intCompare [(Dependency.btDepth d2, Dependency.btDepth d1), (k1, k2), (w1, w2)]
				  | diaLifo _ = Exn.unexpArg "Agenda.initialize.diaLifoNode"
				
				fun disjFifoNode (BRANCH (w1, k1, _, _), BRANCH (w2, k2, _, _)) = Util.intCompare [(w1, w2), (k1, k2)]
				  | disjFifoNode _ = Exn.unexpArg "Agenda.initialize.disjFifoNode"
				
				fun disjLifoNode (BRANCH (w1, k1, _, _), BRANCH (w2, k2, _, _)) = Util.intCompare [(w2, w1), (k1, k2)]
				  | disjLifoNode _ = Exn.unexpArg "Agenda.initialize.disjLifoNode"
				
				fun disjFifoNodePen (BRANCH (w1, k1, _, p1), BRANCH (w2, k2, _, p2)) = Util.intCompare [(w1, w2), (p2, p1), (k1, k2)]
				  | disjFifoNodePen _ = Exn.unexpArg "Agenda.initialize.disjFifoNode"
				
				fun disjLifoNodePen (BRANCH (w1, k1, _, p1), BRANCH (w2, k2, _, p2)) = Util.intCompare [(w2, w1), (p2, p1), (k1, k2)]
				  | disjLifoNodePen _ = Exn.unexpArg "Agenda.initialize.disjLifoNode"
				
				fun disjPenFifoNode (BRANCH (w1, k1, _, p1), BRANCH (w2, k2, _, p2)) = Util.intCompare [(p2, p1), (w1, w2), (k1, k2)]
				  | disjPenFifoNode _ = Exn.unexpArg "Agenda.initialize.disjFifoNode"
				
				fun disjPenLifoNode (BRANCH (w1, k1, _, p1), BRANCH (w2, k2, _, p2)) = Util.intCompare [(p2, p1), (w2, w1), (k1, k2)]
				  | disjPenLifoNode _ = Exn.unexpArg "Agenda.initialize.disjLifoNode"
				
				fun disjFifo (BRANCH (w1, k1, d1, _), BRANCH (w2, k2, d2, _)) = Util.intCompare [(Dependency.btDepth d1, Dependency.btDepth d2), (k1, k2), (w1, w2)]
				  | disjFifo _ = Exn.unexpArg "Agenda.initialize.disjFifo"
				
				fun disjLifo (BRANCH (w1, k1, d1, _), BRANCH (w2, k2, d2, _)) = Util.intCompare [(Dependency.btDepth d2, Dependency.btDepth d1), (k1, k2), (w1, w2)]
				  | disjLifo _ = Exn.unexpArg "Agenda.initialize.disjLifo"
				
				fun disjDep (BRANCH (w1, k1, d1, _), BRANCH (w2, k2, d2, _)) = (
						case Dependency.compare (d1, d2)
							of EQUAL => Util.intCompare [(k1, k2), (w1, w2)]
							 | r => r
						)
				  | disjDep _ = Exn.unexpArg "Agenda.initialize.disjDep"
				
				fun univOrd (UNIV (k1, d1), UNIV (k2, d2)) = (
					case Dependency.compare (d1, d2)
						of EQUAL =>	Int.compare (k1, k2)
						 | r => r
					)
				  | univOrd _ = Exn.unexpArg "Agenda.initialize.univOrd"
				
				fun existOrd (EXIST (k1, d1), EXIST (k2, d2)) = (
					case Dependency.compare (d1, d2)
						of EQUAL =>	Int.compare (k1, k2)
						 | r => r
					)
				  | existOrd _ = Exn.unexpArg "Agenda.initialize.existOrd"
				
				fun ddDep (DIAMOND (w1, k1, d1, _), DIAMOND (w2, k2, d2, _)) = (
						case Dependency.compare (d1, d2)
							of EQUAL => Util.intCompare [(k1, k2), (w1, w2)]
							 | r => r
						)
				  | ddDep (DIAMOND (w1, k1, d1, _), BRANCH (w2, k2, d2, _)) = (
						case Dependency.compare (d1, d2)
							of EQUAL => Util.intCompare [(k1, k2), (w1, w2)]
							 | r => r
						)
				  | ddDep (BRANCH (w1, k1, d1, _), DIAMOND (w2, k2, d2, _)) = (
						case Dependency.compare (d1, d2)
							of EQUAL => Util.intCompare [(k1, k2), (w1, w2)]
							 | r => r
						)
				  | ddDep (BRANCH (w1, k1, d1, _), BRANCH (w2, k2, d2, _)) = (
						case Dependency.compare (d1, d2)
							of EQUAL => Util.intCompare [(k1, k2), (w1, w2)]
							 | r => r
						)
				  | ddDep _ = Exn.unexpArg "Agenda.initialize.ddDep"
				
				
				fun compare (x, y) =
					let
						fun symbolOf (UNIV _)    = #"A"
						  | symbolOf (BOX _)     = #"["
						  | symbolOf (EQ _)      = #"n"
						  | symbolOf (AT _)      = #"@"
						  | symbolOf (BRANCH _)  = if !Settings.diadisjdep then #"%" else #"|"
						  | symbolOf (DIAMOND _) = if !Settings.diadisjdep then #"%" else #"<"
						  | symbolOf (EXIST _)   = #"E"
						
						fun lookup (x, y) =
							case List.find (fn z => z = x orelse z = y) (!expOrder)
								of NONE => Exn.unexpected "Agenda.initialize.compare.lookup"
								 | SOME z => if z = x then LESS else GREATER
					in
						lookup (symbolOf x, symbolOf y)
					end
				
				
				fun mkComparisonFn (diamond, box, branch, at, eq, univ, exist) = (
					fn (x as (DIAMOND _), y as (DIAMOND _)) => diamond (x, y)
					|  (x as (BOX _), y as (BOX _)) => box (x, y)
					|  (x as (BRANCH _), y as (BRANCH _)) => branch (x, y)
					|  (x as (AT _), y as (AT _)) => at (x, y)
					|  (x as (EQ _), y as (EQ _)) => eq (x, y)
					|  (x as (UNIV _), y as (UNIV _)) => univ (x, y)
					|  (x as (EXIST _), y as (EXIST _)) => exist (x, y)
					|  (x as (DIAMOND _), y as (BRANCH _)) => if !Settings.diadisjdep then ddDep (x, y) else compare (x, y)
					|  (x as (BRANCH _), y as (DIAMOND _)) => if !Settings.diadisjdep then ddDep (x, y) else compare (x, y)
					|  (x, y) => compare (x, y)
				)
			in
				  q := (BtprioQ.mkQueue (
							mkComparisonFn (
								  (
									if !Settings.diadisjdep
									then ddDep
									else
										case !Settings.diaExpOrder
											of Settings.OLDWORLD => diaFifoNode
											| Settings.NEWWORLD => diaLifoNode
											| Settings.LIFO => diaLifo
											| Settings.FIFO => diaFifo
											| Settings.DEP => diaDep
											| Settings.CARNEW => diaCarLifoNode
											| Settings.CAROLD => diaCarFifoNode
											| _ => Exn.unexpected "Agenda.mkComparisonFn"
								  )
								, boxDep
								, (
									if !Settings.diadisjdep
									then ddDep
									else
										case !Settings.disjExpOrder
											of Settings.OLDWORLD => disjFifoNode
											| Settings.NEWWORLD => disjLifoNode
											| Settings.LIFO => disjLifo
											| Settings.FIFO => disjFifo
											| Settings.DEP => disjDep
											| Settings.OLDPEN => disjFifoNodePen
											| Settings.NEWPEN => disjLifoNodePen
											| Settings.PENOLD => disjPenFifoNode
											| Settings.PENNEW => disjPenLifoNode
											| _ => Exn.unexpected "Agenda.mkComparisonFn"
								  )
								, atDep
								, eqDep
								, univOrd
								, existOrd
							)
					)
				  )
				; rs := nil
			end
		
		
		fun insert (a, d) = q := (BtprioQ.insert (!q, a, d))
		
		
		fun backtrack d =
			let
				fun backtrackRemembered () =
					let
						fun f xs =
							case xs
								of nil => (rs := nil; nil)
								|  (xs' as ((a, ins, exp)::xr)) =>
									if exp <= d
									then (rs := xs'; nil)
									else
										if ins <= d
										then (a, ins)::(f xr)
										else f xr
					in
						f (!rs)
					end
			in
				  q := (BtprioQ.backtrack (!q) d)
				; app insert (backtrackRemembered ())
			end
		
		
		fun isEmpty () = BtprioQ.isEmpty (!q)
		
		
		fun remember x = Ref.push rs x
		
		
		fun pop d =
					let
						val (q', res) = BtprioQ.pop (!q)
					in
						  (
							case res
								of DIAMOND (_, _, d', _) => 
									if Dependency.btDepth d' < d
									then remember (res, Dependency.btDepth d', d)
									else ()
								|  BRANCH (_, _, d', _) =>
									if !Settings.bcpFullyEnabled
									then
										let
											val (fq, res) = BtprioQ.find (!fBcp) (!q)
										in
											  (
												case res
													of BRANCH (_, _, d', _) =>
														if Dependency.btDepth d' < d
														then remember (res, Dependency.btDepth d', d)
														else ()
													 | _ => Exn.unexpected "Agenda.pop: not a disjunction."
											  )
											; q := (fq (!q))
											; raise Bcp
										end
										handle BtprioQ.NotFound => (
											if Dependency.btDepth d' < d
											then remember (res, Dependency.btDepth d', d)
											else ()
										)
									else
										if Dependency.btDepth d' < d
										then remember (res, Dependency.btDepth d', d)
										else ()
								|  AT (_, _, d') =>
									if Dependency.btDepth d' < d
									then remember (res, Dependency.btDepth d', d)
									else ()
								|  EQ (_, _, d') =>
									if Dependency.btDepth d' < d
									then remember (res, Dependency.btDepth d', d)
									else ()
								|  BOX (_, _, d') =>
									if Dependency.btDepth d' < d
									then remember (res, Dependency.btDepth d', d)
									else ()
								|  UNIV (_, d') =>
									if Dependency.btDepth d' < d
									then remember (res, Dependency.btDepth d', d)
									else ()
								|  EXIST (_, d') =>
									if Dependency.btDepth d' < d
									then remember (res, Dependency.btDepth d', d)
									else ()
						  )
						; q := q'
						; res
					end
		
		
		fun insertX (a, d) =
			case BtprioQ.remove (!q, a)
				of (_, NONE) => q := (BtprioQ.insert (!q, a, d))
				 | (q', SOME (a', d')) => (
				 	  q := BtprioQ.insert (q', a, d)
				 	; if d' < d
				 	  then remember (a', d', d)
				 	  else ()
				 	)
		
		
		fun toString () =
			let
				val xs = BtprioQ.listItems (!q)
				
				fun f (DIAMOND (w, k, _, c)) = "<>" ^ (Int.toString k) ^ "(" ^ (Int.toString c) ^ ")#" ^ (Int.toString w)
				  | f (BOX (w, k, _)) = "[]" ^ (Int.toString k) ^ "#" ^ (Int.toString w)
				  | f (BRANCH (w, k, _, p)) = "\\/" ^ (Int.toString k) ^ "(" ^ (Int.toString p) ^ ")#" ^ (Int.toString w)
				  | f (AT (n, k, _)) = "@" ^ n ^ ":" ^ (Int.toString k)
				  | f (EQ (w, n, _)) = "(=" ^ n ^ ")#" ^ (Int.toString w)
				  | f (UNIV (k, _)) = "A" ^ (Int.toString k)
				  | f (EXIST (k, _)) = "E" ^ (Int.toString k)
			in
				(Util.listToString f xs) ^ "\n"
			end
	end
