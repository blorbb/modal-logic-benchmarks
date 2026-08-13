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


structure Lazynomstore :> LAZYNOMSTORE =
	struct
		type item = (Term.index * Dependency.depcy) list ref
		
		datatype store =
			S of {
				  bm : (Term.propvar, item) Binarymap.dict ref
				, inv : (int * Term.propvar) list ref
				, pstore : Propstore.pstore
				}
		
		
		fun empty pstore = S {bm = ref (Binarymap.mkDict (String.compare)), inv = ref nil, pstore = pstore}
		
		
		fun add (S {bm, inv, pstore}) (t, d) =
			let
				exception Satisfied
				
				val neqs =
					case Translator.getTerm t
						of Term.DISJ cs => Term.Catstore.getNeqs cs
						 | _ => Exn.unexpected "Lazystore.add: not a disjunction"
				
				fun findWitness nil = NONE
				  | findWitness (k::kr) =
						case Translator.getTerm k
							of Term.NEQ n => (
									case Propstore.peek pstore n
										of NONE => SOME n
										 | SOME (true, _) => findWitness kr
										 | SOME (false, _) => raise Satisfied
								)
							 | _ => Exn.unexpected "Lazynomstore.add.findWitness: not a nominal literal"
				
				fun add' n =
					let
					in
						case Binarymap.peek (!bm, n)
							of NONE => (
								  bm := (Binarymap.insert (!bm, n, ref [(t, d)]))
								; Ref.push inv (Dependency.btDepth d, n)
								)
							 | SOME r => (
								  Ref.push r (t, d)
								; Ref.push inv (Dependency.btDepth d, n)
								)
					end
			in
				( case findWitness neqs
					of NONE => false 
					 | SOME n => (add' n; true)
				) handle Satisfied => true
			end
		
		
		fun backtrack (S {bm, inv, ...}) d =
			let
				fun backtrack' m nil = (
						  bm := m
						; inv := nil
					)
				  | backtrack' (m : (Term.propvar, item) Binarymap.dict) (xs as (d', n)::xr) =
						if d' > d
						then
							let
								val r = Binarymap.find (m, n)
							in
								case !r
									of [_] => backtrack' (#1 (Binarymap.remove (m, n))) xr
									 | (_::yr) => (r := yr; backtrack' m xr)
									 | nil => Exn.unexpected "Lazystore.backtrack"
							end
						else (
							  bm := m
							; inv := xs
						)
			in
				backtrack' (!bm) (!inv)
			end
		
		
		fun assert (s as S {bm, inv, ...}) n curDepth =
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
				case Binarymap.peek (!bm, n)
					of NONE => nil
					 | SOME r => List.mapPartial mf (!r)
			end
		
		
		fun listNominals (S {bm, pstore, ...}) =
			List.mapPartial
				(fn (n, _) => case Propstore.peek pstore n of SOME _ => NONE | NONE => SOME n)
				(Binarymap.listItems (!bm))
		
		
		fun listItems (S {bm, ...}) = List.concat (map (! o #2) (Binarymap.listItems (!bm)))
	end
