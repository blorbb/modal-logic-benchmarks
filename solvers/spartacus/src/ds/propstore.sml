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


structure Propstore :> PROPSTORE =
	struct
		datatype pstore =
				PS of {
					  ps : (Term.propvar, (bool * Dependency.depcy)) Binarymap.dict ref
					, bs : ((int * Term.propvar list) list) ref
					}
		
		
		exception Unsat of Term.propvar * Dependency.depcy * Dependency.depcy
		
		
		fun empty () = PS {ps = ref (Binarymap.mkDict String.compare), bs = ref nil}
		
		
		fun add (PS {ps, bs}) p b d =
			let
				fun insert () =
					let
						val depth = Dependency.btDepth d
						
						fun insert' nil = [(depth, [p])]
						  | insert' (ys as (d', xs)::yr) =
								case Int.compare (depth, d')
									of LESS => Exn.unexpected "Propstore.add.insert.insert'"
									|  EQUAL => (d', p::xs)::yr
									|  GREATER => (depth, [p])::ys
					in
						ps := (Binarymap.insert (!ps, p, (b, d)));
						Ref.modify insert' bs
					end
			in
				case Binarymap.peek (!ps, p)
					of SOME (b', d') =>
						if b = b'
						then
							if Dependency.btDepth d < Dependency.btDepth d'
							then Exn.unexpected "Propstore.add"
							else false
						else raise Unsat (p, d, d')
					|  NONE => (insert (); true)
			end
		
		
		fun peek (PS {ps, ...}) p = Binarymap.peek (!ps, p)
		
		
		fun backtrack (PS {ps, bs}) d =
			let
				fun getObsolete (nil, rs) = (nil, rs)
				  | getObsolete ((d', xs)::yr, rs) =
						if d' <= d
						then ((d', xs)::yr, rs)
						else getObsolete (yr, xs@rs)
				
				val obs = case getObsolete (!bs, nil) of (ys, rs) => (bs := ys; rs)
			in
				ps := (foldl (fn (p, s) => (#1) (Binarymap.remove (s, p))) (!ps) obs)
			end
		
		fun listItems (PS {ps, ...}) = map (fn (p, (b, d)) => (p, b, d)) (Binarymap.listItems (!ps))
		
		
		fun toString ps = Util.listToString
				(fn (p, b, d) =>
					  "("
					^ (if b then "" else "~")
					^ p
					^ "|"
					^ (Dependency.toString d)
					^ ")"
				)
				(listItems ps)
	end
