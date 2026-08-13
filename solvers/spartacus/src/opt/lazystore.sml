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


structure Lazystore :> LAZYSTORE =
	struct
		type item = bool * ((Term.index * Dependency.depcy) list ref)
		
		datatype store =
			S of {
				  bm : (Term.propvar, item) Binarymap.dict ref
				, inv : (int * Term.propvar) list ref
				, pstore : Propstore.pstore
				}
		
		
		fun empty pstore = S {bm = ref (Binarymap.mkDict (String.compare)), inv = ref nil, pstore = pstore}
		
		
		fun add (S {bm, inv, pstore}) (t, d) =
			let
				val _ = Debug.output (fn () => "ADD " ^ (Int.toString t) ^ "\n")
				exception Satisfied
				
				val cs = case Translator.getTerm t of Term.DISJ cs => cs | _ => Exn.unexpected "Lazystore.add: not a disjunction"
				
				fun getAndCheck () =
					let
						fun ff (a, s) =
							let
								val (p, b) =
									case Translator.getTerm a
										of Term.A a => a
										 | _ => Exn.unexpected "Lazystore.add: not a literal"
							in
								case Propstore.peek pstore p
									of NONE => (p, b)::s
									 | SOME (b', _) =>
										if b = b'
										then raise Satisfied
										else s
							end
					in
						foldl ff nil (Term.Catstore.getAtoms cs)
					end
				
				fun add' nil = false
				  | add' ((p, b)::ar) =
					let
					in
						case Binarymap.peek (!bm, p)
							of NONE => (
								  bm := (Binarymap.insert (!bm, p, (b, ref [(t, d)])))
								; Ref.push inv (Dependency.btDepth d, p)
								; true
								)
							 | SOME (b', r) =>
								if b = b'
								then (
									  Ref.push r (t, d)
									; Ref.push inv (Dependency.btDepth d, p)
									; true
									)
								else add' ar
					end
			in
				add' (getAndCheck ()) handle Satisfied => true
			end
		
		
		fun backtrack (S {bm, inv, ...}) d =
			let
				val _ = Debug.output (fn () => "BACKTRACK\n")
				fun backtrack' m nil = (
						  bm := m
						; inv := nil
					)
				  | backtrack' (m : (Term.propvar, item) Binarymap.dict) (xs as (d', p)::xr) =
						if d' > d
						then
							let
								val (_, r) = Binarymap.find (m, p)
							in
								case !r
									of [_] => backtrack' (#1 (Binarymap.remove (m, p))) xr
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
		
		
		fun assert (s as S {bm, inv, ...}) (p, b) curDepth =
			let
				val _ = Debug.output (fn () => "ASSERT " ^ p ^ "\n")
				fun mf (t, d) =
					let
						val d' = Dependency.updDepth d curDepth
					in
						if add s (t, d')
						then NONE
						else SOME (t, d')
					end
			in
				case Binarymap.peek (!bm, p)
					of NONE => nil
					 | SOME (b', r) =>
						if b = b'
						then nil
						else List.mapPartial mf (!r)
			end
		
		
		fun listPropositions (S {bm, pstore, ...}) =
			List.mapPartial
				(fn (p, (b, _)) => case Propstore.peek pstore p of SOME _ => NONE | NONE => SOME (p, b))
				(Binarymap.listItems (!bm))
		
		
		fun listItems (S {bm, ...}) = List.concat (map (! o #2 o #2) (Binarymap.listItems (!bm)))
		
		fun toString s =
			let
				val xs = listItems s
			in
				Util.listToString Int.toString (map #1 xs)
			end
	end
