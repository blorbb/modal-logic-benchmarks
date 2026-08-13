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


structure Term =
	struct
		type index = int
		type relvar = string
		type propvar = string
		type atom = propvar * bool
		type nominal = propvar
		
		structure Catstore =
			struct
				type catstore = {
					  a : index list
					, conj : index list
					, disj : index list
					, dmd : index list
					, box : index list
					, ex : index list
					, all : index list
					, at : index list
					, eq : index list
					, neq : index list
				}
				
				val empty = {a = nil, conj = nil, disj = nil, dmd = nil, box = nil, ex = nil, all = nil, at = nil, eq = nil, neq = nil}
				
				fun isEmpty cs = cs = empty
				
				val listOrder = ref [#"N", #"p", #"<", #"[", #"@", #"E", #"n", #"A", #"&"]
				
				fun setOrder s =
					let
						fun rm _ nil = nil
						  | rm x (y::yr) = if x = y then yr else y::(rm x yr)
						
						val errMsg = "Same character occurring twice in ordering specification."
						
						fun setOrder' ys nil = ys
						  | setOrder' ys (#"p"::xr) =
								if List.exists (fn x => x = #"p") xr
								then Exn.error errMsg
								else #"p"::(setOrder' (rm #"p" ys) xr)
						  | setOrder' ys (#"N"::xr) =
								if List.exists (fn x => x = #"N") xr
								then Exn.error errMsg
								else
									if List.exists (fn x => x = #"n") xr orelse not (List.exists (fn x => x = #"n") ys)
									then #"N"::(setOrder' (rm #"N" ys) xr)
									else #"N"::(#"n"::(setOrder' (rm #"n" (rm #"N" ys)) xr))
						  | setOrder' ys (#"n"::xr) =
								if List.exists (fn x => x = #"n") xr
								then Exn.error errMsg
								else
									if List.exists (fn x => x = #"N") xr orelse not (List.exists (fn x => x = #"N") ys)
									then #"n"::(setOrder' (rm #"n" ys) xr)
									else #"N"::(#"n"::(setOrder' (rm #"n" (rm #"N" ys)) xr))
						  | setOrder' ys (#"["::xr) =
								if List.exists (fn x => x = #"[") xr
								then Exn.error errMsg
								else
									if List.exists (fn x => x = #"<") xr orelse not (List.exists (fn x => x = #"<") ys)
									then #"["::(setOrder' (rm #"[" ys) xr)
									else #"["::(#"<"::(setOrder' (rm #"<" (rm #"[" ys)) xr))
						  | setOrder' ys (#"<"::xr) =
								if List.exists (fn x => x = #"<") xr
								then Exn.error errMsg
								else
									if List.exists (fn x => x = #"[") xr orelse not (List.exists (fn x => x = #"[") ys)
									then #"<"::(setOrder' (rm #"<" ys) xr)
									else #"<"::(#"["::(setOrder' (rm #"[" (rm #"<" ys)) xr))
						  | setOrder' ys (#"@"::xr) =
								if List.exists (fn x => x = #"@") xr
								then Exn.error errMsg
								else #"@"::(setOrder' (rm #"@" ys) xr)
						  | setOrder' ys (#"E"::xr) =
								if List.exists (fn x => x = #"E") xr
								then Exn.error errMsg
								else
									if List.exists (fn x => x = #"A") xr orelse not (List.exists (fn x => x = #"A") ys)
									then #"E"::(setOrder' (rm #"E" ys) xr)
									else #"E"::(#"A"::(setOrder' (rm #"A" (rm #"E" ys)) xr))
						  | setOrder' ys (#"A"::xr) =
								if List.exists (fn x => x = #"A") xr
								then Exn.error errMsg
								else
									if List.exists (fn x => x = #"E") xr orelse not (List.exists (fn x => x = #"E") ys)
									then #"A"::(setOrder' (rm #"A" ys) xr)
									else #"A"::(#"E"::(setOrder' (rm #"E" (rm #"A" ys)) xr))
						  | setOrder' ys (#"&"::xr) =
								if List.exists (fn x => x = #"&") xr
								then Exn.error errMsg
								else #"&"::(setOrder' (rm #"&" ys) xr)
						  | setOrder' _ (c::_) = Exn.error ("Invalid character " ^ (String.implode [c]) ^ " in term ordering specification.")
					in
						listOrder := (setOrder' (!listOrder) (String.explode s))
					end
				
				fun listItems {a, conj, disj, dmd, box, ex, all, at, neq, eq} =
					let
						fun listItems' nil = disj
						  | listItems' (#"p"::xr) = a @ (listItems' xr)
						  | listItems' (#"N"::xr) = neq @ (listItems' xr)
						  | listItems' (#"n"::xr) = eq @ (listItems' xr)
						  | listItems' (#"<"::xr) = dmd @ (listItems' xr)
						  | listItems' (#"["::xr) = box @ (listItems' xr)
						  | listItems' (#"@"::xr) = at @ (listItems' xr)
						  | listItems' (#"E"::xr) = ex @ (listItems' xr)
						  | listItems' (#"A"::xr) = all @ (listItems' xr)
						  | listItems' (#"&"::xr) = conj @ (listItems' xr)
						  | listItems' (c::_) = Exn.unexpected ("Invalid item " ^ (String.implode [c]) ^ " in term ordering specification.")
					in
						listItems' (!listOrder)
					end
				
				fun getAtoms ({a, ...} : catstore) = a
				
				fun getConjunctions ({conj, ...} : catstore) = conj
				
				fun getDisjunctions ({disj, ...} : catstore) = disj
				
				fun getDiamonds ({dmd, ...} : catstore) = dmd
				
				fun getBoxes ({box, ...} : catstore) = box
				
				fun getExistentials ({ex, ...} : catstore) = ex
				
				fun getUniversals ({all, ...} : catstore) = all
				
				fun getAts ({at, ...} : catstore) = at
				
				fun getEqs ({eq, ...} : catstore) = eq
				
				fun getNeqs ({neq, ...} : catstore) = neq
				
				fun insert k nil = [k]
				  | insert k (x::xr) =
						case Int.compare (k, x)
							of LESS => k::x::xr
							|  EQUAL => x::xr
							|  GREATER => x::(insert k xr)
				
				fun addAtom {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a = insert k a, conj=conj, disj=disj, dmd=dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq=neq}
				
				fun addConjunction {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj = insert k conj, disj=disj, dmd=dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq=neq}
				
				fun addDisjunction {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj=conj, disj = insert k disj, dmd=dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq=neq}
				
				fun addDiamond {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj=conj, disj=disj, dmd = insert k dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq=neq}
				
				fun addBox {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj=conj, disj=disj, dmd=dmd, box = insert k box, ex=ex, all=all, at=at, eq=eq, neq=neq}
				
				fun addExistential {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj=conj, disj=disj, dmd=dmd, box=box, ex = insert k ex, all=all, at=at, eq=eq, neq=neq}
				
				fun addUniversal {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj=conj, disj=disj, dmd=dmd, box=box, ex=ex, all = insert k all, at=at, eq=eq, neq=neq}
				
				fun addAt {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
						{a=a, conj=conj, disj=disj, dmd=dmd, box=box, ex=ex, all=all, at = insert k at, eq=eq, neq=neq}
				
				fun addEq {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
					{a=a, conj=conj, disj=disj, dmd=dmd, box=box, ex=ex, all=all, at=at, eq = insert k eq, neq=neq}
				
				fun addNeq {a, conj, disj, dmd, box, ex, all, at, eq, neq} k =
					{a=a, conj=conj, disj=disj, dmd=dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq = insert k neq}
				
				fun indexlistCompare (nil, nil) = EQUAL
				  | indexlistCompare (xs, nil) = GREATER
				  | indexlistCompare (nil, ys) = LESS
				  | indexlistCompare (x::xr, y::yr) =
						case Int.compare (x, y)
							of EQUAL => indexlistCompare (xr, yr)
							|  z => z
				
				fun compare (cs1, cs2) = (
					case indexlistCompare (getAtoms cs1, getAtoms cs2)
					of EQUAL => (
						case indexlistCompare (getConjunctions cs1, getConjunctions cs2)
						of EQUAL => (
							case indexlistCompare (getDisjunctions cs1, getDisjunctions cs2)
							of EQUAL => (
								case indexlistCompare (getDiamonds cs1, getDiamonds cs2)
								of EQUAL => (
									case indexlistCompare (getBoxes cs1, getBoxes cs2)
										of EQUAL => (
											case indexlistCompare (getExistentials cs1, getExistentials cs2)
												of EQUAL => (
													case indexlistCompare (getUniversals cs1, getUniversals cs2)
														of EQUAL => (
															case indexlistCompare (getAts cs1, getAts cs2)
																of EQUAL => (
																	case indexlistCompare (getEqs cs1, getEqs cs2)
																		of EQUAL => indexlistCompare (getNeqs cs1, getNeqs cs2)
																		|  x => x
																	)
																|  x => x
															)
														|  x => x
													)
												|  x => x
											)
										|  x => x
									)
								|  x => x
							)
							|  x => x
						)
						|  x => x
					)
					|  x => x
				)
				
				fun filter p {a, conj, disj, dmd, box, ex, all, at, eq, neq} =
					let
						val cs = ref empty
					in
						  app (fn k => if p k then cs := (addAtom (!cs) k) else ()) a
						; app (fn k => if p k then cs := (addConjunction (!cs) k) else ()) conj
						; app (fn k => if p k then cs := (addDisjunction (!cs) k) else ()) disj
						; app (fn k => if p k then cs := (addDiamond (!cs) k) else ()) dmd
						; app (fn k => if p k then cs := (addBox (!cs) k) else ()) box
						; app (fn k => if p k then cs := (addExistential (!cs) k) else ()) ex
						; app (fn k => if p k then cs := (addUniversal (!cs) k) else ()) all
						; app (fn k => if p k then cs := (addAt (!cs) k) else ()) at
						; app (fn k => if p k then cs := (addEq (!cs) k) else ()) eq
						; app (fn k => if p k then cs := (addNeq (!cs) k) else ()) neq
						; !cs
					end
				
				fun size {a, conj, disj, dmd, box, ex, all, at, eq, neq} =
					  List.length a
					+ List.length conj
					+ List.length disj
					+ List.length dmd
					+ List.length box
					+ List.length ex
					+ List.length all
					+ List.length at
					+ List.length eq
					+ List.length neq
				
				fun containsBoth cs =
					let
						val (even, odd) = List.partition (fn x => x mod 2 = 0) (listItems cs)
						
						fun containsBoth' _ nil = false
						  | containsBoth' nil _ = false
						  | containsBoth' (xs as x::xr) (ys as y::yr) = (
							case Int.compare (x, y - 1)
								of EQUAL => true
								 | LESS => containsBoth' xr ys
								 | GREATER => containsBoth' xs yr
							)
					in
						containsBoth' (Listsort.sort Int.compare even) (Listsort.sort Int.compare odd)
					end
				
				fun cleanConj (cs as {a, conj, disj, dmd, box, ex, all, at, eq, neq}) =
					if containsBoth cs
					then NONE
					else
						case disj
							of (0::_) => NONE
							 | _ =>
								case conj
									of (1::xr) => SOME {a=a, conj=xr, disj=disj, dmd=dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq=neq}
									 | _ => SOME cs
					
				fun cleanDisj (cs as {a, conj, disj, dmd, box, ex, all, at, eq, neq}) =
					if containsBoth cs
					then NONE
					else
						case conj
							of (1::_) => NONE
							 | _ =>
								case disj
									of (0::xr) => SOME {a=a, conj=conj, disj=xr, dmd=dmd, box=box, ex=ex, all=all, at=at, eq=eq, neq=neq}
									 | _ => SOME cs
				
				fun toString cs = Util.listToString Int.toString (listItems cs)
			end
		
		datatype term =
				A of atom
			  | CONJ of Catstore.catstore
			  | DISJ of Catstore.catstore
			  | DMD of relvar * index
			  | BOX of relvar * index
			  | EX of index
			  | ALL of index
			  | AT of nominal * index
			  | EQ of nominal
			  | NEQ of nominal
			  
		fun compare ((A (p1, b1)), (A (p2, b2))) =
				if p1 < p2
				then LESS
				else if p1 > p2
				then GREATER
				else if b1 = b2
				then EQUAL
				else if b1
				then GREATER
				else LESS
		  | compare (A _, _) = LESS
		  | compare (_, A _) = GREATER
		  | compare (CONJ s1, CONJ s2) = Catstore.compare (s1, s2)
		  | compare (CONJ _, _) = LESS
		  | compare (_, CONJ _) = GREATER
		  | compare (DISJ s1, DISJ s2) = Catstore.compare (s1, s2)
		  | compare (DISJ _, _) = LESS
		  | compare (_, DISJ _) = GREATER
		  | compare (DMD (r1, k1), DMD (r2, k2)) =
				if r1 < r2
				then LESS
				else if r1 > r2
				then GREATER
				else Int.compare (k1, k2)
		  | compare (DMD _, _) = LESS
		  | compare (_, DMD _) = GREATER
		  | compare (BOX (r1, k1), BOX (r2, k2)) =
				if r1 < r2
				then LESS
				else if r1 > r2
				then GREATER
				else Int.compare (k1, k2)
		  | compare (BOX _, _) = LESS
		  | compare (_, BOX _) = GREATER
		  | compare (EX k1, EX k2) = Int.compare (k1, k2)
		  | compare (EX _, _) = LESS
		  | compare (_, EX _) = GREATER
		  | compare (ALL k1, ALL k2) = Int.compare (k1, k2)
		  | compare (ALL _, _) = LESS
		  | compare (_, ALL _) = GREATER
		  | compare (AT (n1, k1), AT (n2, k2)) =
				if n1 < n2
				then LESS
				else if n1 > n2
				then GREATER
				else Int.compare (k1, k2)
		  | compare (AT _, _) = LESS
		  | compare (_, AT _) = GREATER
		  | compare (EQ n1, EQ n2) = String.compare (n1, n2)
		  | compare (EQ _, _) = LESS
		  | compare (_, EQ _) = GREATER
		  | compare (NEQ n1, NEQ n2) = String.compare (n1, n2)
		
		fun toString (A (p, b)) = (if b then "" else "~") ^ p
		  | toString (CONJ cs) = "/\\(" ^ (Catstore.toString cs) ^ ")"
		  | toString (DISJ cs) = "\\/(" ^ (Catstore.toString cs) ^ ")"
		  | toString (DMD (r, t)) = "<" ^ r ^ ">" ^ (Int.toString t)
		  | toString (BOX (r, t)) = "[" ^ r ^ "]" ^ (Int.toString t)
		  | toString (EX t) = "E" ^ (Int.toString t)
		  | toString (ALL t) = "A" ^ (Int.toString t)
		  | toString (AT (n, k)) = "@" ^ n ^ ":" ^ (Int.toString k)
		  | toString (EQ n) = "(=" ^ n ^ ")"
		  | toString (NEQ n) = "(~=" ^ n ^ ")"
	end
