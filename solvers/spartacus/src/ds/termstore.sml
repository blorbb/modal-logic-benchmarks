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


structure Termstore :> TERMSTORE =
	struct
		datatype store =
				S of {
					  all : Dependency.depcy Binarydict.dict 
					, inv : (int * (Term.index list)) list ref
					}
		
		
		fun empty () = S {all = Binarydict.empty (), inv = ref nil}
		
		
		fun add (S {all, inv}) (k, d) =
			case Binarydict.peek (all, k)
				of NONE => (
						  Binarydict.insert (all, k, d)
						; (
							case !inv
								of nil => inv := [(Dependency.btDepth d, [k])]
								 | xs as (d', ks)::xr => (
									case Int.compare (Dependency.btDepth d, d')
										of LESS => Exn.unexpected "Termstore.add"
										 | EQUAL => inv := (d', k::ks)::xr
										 | GREATER => inv := (Dependency.btDepth d, [k])::xs
									)
						  )
						; true
					)
				|  SOME d' =>
						if Dependency.btDepth d < Dependency.btDepth d'
						then Exn.unexpected "Termstore.add"
						else false
		
		
		fun peek (S {all, ...}) k = Binarydict.peek (all, k)
		
		
		fun isEmpty (S {inv, ...}) = null (!inv)
		
		
		fun numItems (S {all, ...}) = Binarydict.numItems all
		
		
		fun listItems (S {all, ...}) = Binarydict.listItems all
		
		
		fun backtrack (S {all, inv}) d =
			let
				exception Done
				
				fun remove nil = inv := nil
				  | remove (xs as (d', ks)::xr) =
					if d < d'
					then (app (fn k => ignore (Binarydict.remove (all, k))) ks; remove xr)
					else inv := xs
			in
				remove (!inv)
			end
		
		
		fun toString (S {all, ...}) =
				  (Util.listToString (fn (k, d) => "(" ^ (Int.toString k) ^ "|" ^ (Dependency.toString d) ^ ")") (Binarydict.listItems all))
	end
