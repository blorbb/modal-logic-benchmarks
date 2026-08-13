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


structure Lazyboxstore :> LAZYBOXSTORE =
	struct
		datatype item = R | X of item | XN | L of (Term.index * Dependency.depcy) list ref
		
		datatype store =
			S of {
				  bm : (Term.propvar, item ref) Binarymap.dict ref
				, inv : (int * Term.relvar) list ref
				}
		
		
		fun empty rs =
			let
				val bm = ref (Binarymap.mkDict (String.compare))
			in
				  app (fn r => bm := Binarymap.insert (!bm, r, ref R)) rs
				; S {bm = bm, inv = ref nil}
			end
		
		
		fun add (S {bm, inv}) (t, d) =
			let
				val boxRelations =
					case Translator.getTerm t
						of Term.DISJ cs =>
							List.mapPartial
								(fn k =>
									case Translator.getTerm k
										of Term.BOX (r, _) => SOME r
										 | _ => Exn.unexpected "Lazyboxstore.add: not a box"
								)
								(Term.Catstore.getBoxes cs)
						 | _ => Exn.unexpected "Lazyboxstore.add: not a disjunction"
				
				fun add' nil = false
				  | add' (rel::yr) =
					let
					in
						case Binarymap.peek (!bm, rel)
							of NONE => (
								  bm := (Binarymap.insert (!bm, rel, ref (L (ref [(t, d)]))))
								; Ref.push inv (Dependency.btDepth d, rel)
								; true
								)
							 | SOME r =>
								case !r
									of R => add' yr
									 | X _ => add' yr
									 | XN => add' yr
									 | L r' => (
										  Ref.push r' (t, d)
										; Ref.push inv (Dependency.btDepth d, rel)
										; true
										)
					 end
			in
				add' boxRelations
			end
		
		
		fun backtrack (S {bm, inv}) d =
			let
				fun backtrack' m nil = (
						  bm := m
						; inv := nil
					)
				  | backtrack' (m : (Term.propvar, item ref) Binarymap.dict) (xs as (d', rel)::xr) =
						if d' > d
						then
							let
								val r = Binarymap.find (m, rel)
							in
								case !r
									of X y => (r := y; backtrack' m xr)
									 | XN => backtrack' (#1 (Binarymap.remove (m, rel))) xr
									 | R => Exn.unexpected "Lazyboxstore.backtrack"
									 | L r' =>
										case !r'
											of [_] => backtrack' (#1 (Binarymap.remove (m, rel))) xr
											 | _::yr => (r' := yr; backtrack' m xr)
											 | nil => Exn.unexpected "Lazyboxstore.backtrack"
							end
						else (
							  bm := m
							; inv := xs
						)
			in
				backtrack' (!bm) (!inv)
			end
		
		
		fun assert (s as S {bm, inv}) rel curDepth =
			let
				fun mf (t, d) =
					let
						val d' = Dependency.updDepth d curDepth
					in
						if add s (t, d')
						then NONE
						else SOME (t, d')
					end
			in
				case Binarymap.peek (!bm, rel)
					of NONE => (
						  bm := (Binarymap.insert (!bm, rel, ref XN))
						; Ref.push inv (curDepth, rel)
						; nil
						)
					 | SOME r =>
						case !r
							of (X _) => nil
							 | XN => nil
							 | R => nil
							 | L r' => (
								  r := X (L r')
								; Ref.push inv (curDepth, rel)
								; List.mapPartial mf (!r')
								; !r'
								)
			end
		
		
		fun listItems (S {bm, ...}) =
			let
				fun mf (L r) = SOME (!r)
				  | mf _ = NONE
			in
				List.concat (List.mapPartial (mf o ! o #2) (Binarymap.listItems (!bm)))
			end
	end
