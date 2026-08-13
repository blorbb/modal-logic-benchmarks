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


structure TreePatternstore :> PATTERNSTORE =
	struct
		datatype store = S of (Term.index Ubtree.tree * int) list ref
		
		
		fun mkStore n = (S (ref [(Ubtree.mkTree Int.compare, 0)]))
		
		
		fun backtrack (S r) d =
			let
				fun backtrack' nil = nil
				  | backtrack' (ts as ((t, d')::tr)) = if d < d' then backtrack' tr else ts
			in
				r := (backtrack' (!r))
			end
		
		
		fun add (S r) (ks, d) =	
			let
				fun add' nil = raise Exn.unexpArg "Patternstore.add: corrupt store"
				  | add' (ts as (t, d')::tr) =
					let
					in
						case Int.compare (d, d')
							of LESS => Exn.unexpArg "Patternstore.add: insertion depth too small "
							 | EQUAL => r := ((Ubtree.insert (t, ks), d)::tr)
							 | GREATER => r := ((Ubtree.insert (t, ks), d)::ts)
					end
			in
				add' (!r)
			end
		
		
		fun hasMatch (S r) ks =
			let
				fun hasMatch' nil = Exn.unexpArg "Patternstore.hasMatch: corrupt store"
				  | hasMatch' ((t, d)::_) = Ubtree.hasSuperset (t, ks)
			in
				hasMatch' (!r)
			end
	end
